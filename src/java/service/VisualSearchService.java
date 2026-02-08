package service;

import jakarta.servlet.http.Part;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class VisualSearchService {
    
    // Python FastAPI URL (from app.py)
    private static final String PYTHON_API_BASE = "http://localhost:8000";
    private static final int TIMEOUT_MS = 30000; // 30 giây
    
    private final Gson gson = new Gson();

    /**
     * Kết quả trả về từ Python API
     */
    public static class PyResult {
        public int product_id;
        public float score;
        public int rank;
        
        public PyResult(int product_id, float score, int rank) {
            this.product_id = product_id;
            this.score = score;
            this.rank = rank;
        }
    }
    
    /**
     * Tìm kiếm bằng ảnh (upload từ chat widget)
     * @param filePart - File ảnh từ multipart request
     * @return Danh sách sản phẩm tương tự
     */
    public List<PyResult> searchByImage(Part filePart) {
        if (filePart == null || filePart.getSize() <= 0) {
            System.err.println("[VisualSearch] File part is null or empty");
            return Collections.emptyList();
        }

        HttpURLConnection conn = null;
        try {
            // 1. Tạo multipart request
            String boundary = "----" + System.currentTimeMillis();
            URL url = new URL(PYTHON_API_BASE + "/search");
            
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "multipart/form-data; boundary=" + boundary);
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);

            // 2. Ghi file vào body
            try (OutputStream out = conn.getOutputStream();
                 PrintWriter writer = new PrintWriter(new OutputStreamWriter(out, StandardCharsets.UTF_8), true)) {
                
                // File field
                writer.append("--").append(boundary).append("\r\n");
                writer.append("Content-Disposition: form-data; name=\"image_file\"; filename=\"")
                      .append(filePart.getSubmittedFileName()).append("\"\r\n");
                writer.append("Content-Type: ").append(filePart.getContentType()).append("\r\n\r\n");
                writer.flush();
                
                // Copy file data
                try (InputStream fileInput = filePart.getInputStream()) {
                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = fileInput.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                    out.flush();
                }
                
                writer.append("\r\n");
                
                // Top K field (mặc định 5)
                writer.append("--").append(boundary).append("\r\n");
                writer.append("Content-Disposition: form-data; name=\"topK\"\r\n\r\n");
                writer.append("5\r\n");
                
                // use_yolo field (bật YOLO smart crop)
                writer.append("--").append(boundary).append("\r\n");
                writer.append("Content-Disposition: form-data; name=\"use_yolo\"\r\n\r\n");
                writer.append("1\r\n");
                
                // End boundary
                writer.append("--").append(boundary).append("--\r\n");
                writer.flush();
            }

            // 3. Đọc response
            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }
                    
                    return parseResults(response.toString());
                }
            } else {
                System.err.println("[VisualSearch] Python API error: " + responseCode);
                return Collections.emptyList();
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("[VisualSearch] Error: " + e.getMessage());
            return Collections.emptyList();
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /**
     * Tìm kiếm bằng text (semantic search)
     * @param query - Câu hỏi người dùng
     * @return Danh sách sản phẩm liên quan
     */
    public List<PyResult> searchByText(String query) {
        if (query == null || query.trim().isEmpty()) {
            return Collections.emptyList();
        }

        HttpURLConnection conn = null;
        try {
            // 1. Tạo URL-encoded request
            String urlParameters = "text=" + java.net.URLEncoder.encode(query.trim(), "UTF-8") + "&top_k=5";
            byte[] postData = urlParameters.getBytes(StandardCharsets.UTF_8);

            URL url = new URL(PYTHON_API_BASE + "/search_text");
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Content-Length", String.valueOf(postData.length));
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);

            // 2. Gửi data
            try (OutputStream out = conn.getOutputStream()) {
                out.write(postData);
            }

            // 3. Đọc response
            int responseCode = conn.getResponseCode();
            if (responseCode == 200) {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }
                    
                    return parseResults(response.toString());
                }
            } else {
                System.err.println("[VisualSearch] Text search error: " + responseCode);
                return Collections.emptyList();
            }

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    /**
     * Parse JSON response từ Python
     * Format: {"results": [{"product_id": 1, "score": 0.9, "rank": 1}, ...]}
     */
    private List<PyResult> parseResults(String jsonResponse) {
        try {
            Map<String, Object> response = gson.fromJson(jsonResponse, 
                new TypeToken<Map<String, Object>>(){}.getType());
            
            List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");
            if (results == null) return Collections.emptyList();

            List<PyResult> output = new ArrayList<>();
            for (Map<String, Object> item : results) {
                int productId = ((Double) item.get("product_id")).intValue();
                float score = ((Double) item.get("score")).floatValue();
                int rank = ((Double) item.get("rank")).intValue();
                
                output.add(new PyResult(productId, score, rank));
            }
            
            return output;

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}