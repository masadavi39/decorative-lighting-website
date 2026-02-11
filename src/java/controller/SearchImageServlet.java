package controller;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import service.VisualSearchService;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet("/search-image")
@MultipartConfig
public class SearchImageServlet extends HttpServlet {

    private static final String PYTHON_API_BASE = "http://localhost:8000";
    private static final int TIMEOUT_MS = 30000;

    private final VisualSearchService visualSearchService = new VisualSearchService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String imageUrl = request.getParameter("image_url");

        List<VisualSearchService.PyResult> results;

        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
            results = searchByImageUrl(imageUrl.trim());
        } else {
            Part filePart = request.getPart("image_file");
            results = visualSearchService.searchByImage(filePart);
        }

        Map<String, Object> resp = new HashMap<>();
        resp.put("results", results);
        response.getWriter().write(gson.toJson(resp));
    }

    private List<VisualSearchService.PyResult> searchByImageUrl(String imageUrl) {
        HttpURLConnection conn = null;
        try {
            URL url = new URL(PYTHON_API_BASE + "/search");
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setConnectTimeout(TIMEOUT_MS);
            conn.setReadTimeout(TIMEOUT_MS);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

            String body = "image_url=" + java.net.URLEncoder.encode(imageUrl, "UTF-8")
                        + "&topK=5&use_yolo=1";
            byte[] data = body.getBytes(StandardCharsets.UTF_8);

            try (OutputStream out = conn.getOutputStream()) {
                out.write(data);
            }

            if (conn.getResponseCode() == 200) {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        sb.append(line);
                    }
                    return parseResults(sb.toString());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) conn.disconnect();
        }
        return Collections.emptyList();
    }

    private List<VisualSearchService.PyResult> parseResults(String jsonResponse) {
        try {
            Map<String, Object> response = gson.fromJson(
                    jsonResponse, new TypeToken<Map<String, Object>>() {}.getType());

            List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");
            if (results == null) return Collections.emptyList();

            List<VisualSearchService.PyResult> output = new ArrayList<>();
            for (Map<String, Object> item : results) {
                int productId = ((Double) item.get("product_id")).intValue();
                float score = ((Double) item.get("score")).floatValue();
                int rank = ((Double) item.get("rank")).intValue();
                output.add(new VisualSearchService.PyResult(productId, score, rank));
            }
            return output;

        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
    }
}