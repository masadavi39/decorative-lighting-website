package service;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

import javax.net.ssl.*;
import java.security.cert.X509Certificate;
import java.security.SecureRandom;

public class GeminiService {

    // ===== CẤU HÌNH =====
    private static final String API_KEY = loadApiKey();

    private static final String MODEL_NAME = "gemini-2.5-flash";

private static final String API_URL =
    "https://generativelanguage.googleapis.com/v1/models/"
    + MODEL_NAME + ":generateContent?key=" + API_KEY;


    // ===== LOAD API KEY TỪ CLASSPATH =====
    private static String loadApiKey() {
        try (InputStream is = GeminiService.class
                .getClassLoader()
                .getResourceAsStream("config.properties")) {

            if (is == null) {
                System.err.println("❌ Không tìm thấy config.properties trong classpath");
                return "";
            }

            Properties props = new Properties();
            props.load(is);

            String key = props.getProperty("GEMINI_API_KEY");
            if (key == null || key.isEmpty()) {
                System.err.println("❌ GEMINI_API_KEY trống");
                return "";
            }

            System.out.println("✅ Đã load API Key từ classpath");
            return key.trim();

        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    // ===== CALL AI =====
    public String callAI(String userMessage, String productContext, String orderContext) {
        disableSSL();
        if (API_KEY.isEmpty()) {
            return "Lỗi hệ thống: Chưa cấu hình API Key.";
        }

        try {
            // 1️⃣ PROMPT (GIỮ NGUYÊN)
            StringBuilder finalPrompt = new StringBuilder();
            finalPrompt.append(
                "Bạn là nhân viên tư vấn của 'Light Shop'. Trả lời ngắn gọn, lịch sự bằng tiếng Việt.\n"
            );

            if (productContext != null && !productContext.isEmpty()) {
                finalPrompt.append("DỮ LIỆU SẢN PHẨM:\n")
                           .append(productContext).append("\n");
            }
            if (orderContext != null && !orderContext.isEmpty()) {
                finalPrompt.append("DỮ LIỆU ĐƠN HÀNG:\n")
                           .append(orderContext).append("\n");
            }

            finalPrompt.append("KHÁCH HỎI: ").append(userMessage);

            // 2️⃣ JSON BODY (GIỮ NGUYÊN)
            String jsonBody =
                "{ \"contents\": [ { \"parts\": [ { \"text\": \"" +
                escapeJson(finalPrompt.toString()) +
                "\" } ] } ] }";

            // 3️⃣ HTTP REQUEST
            HttpURLConnection conn =
                (HttpURLConnection) new URL(API_URL).openConnection();

            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setDoOutput(true);
            conn.setConnectTimeout(10_000);
            conn.setReadTimeout(20_000);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonBody.getBytes(StandardCharsets.UTF_8));
            }

            // 4️⃣ RESPONSE
            int responseCode = conn.getResponseCode();

            if (responseCode == 200) {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {

                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }
                    return extractTextFromJson(response.toString());
                }
            } else {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {

                    StringBuilder error = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        error.append(line);
                    }

                    System.err.println("❌ GOOGLE API ERROR (" + responseCode + "): " + error);
                    return "AI đang bận (Mã " + responseCode + ").";
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            return "Lỗi kết nối AI.";
        }
    }

    // ===== HELPER =====
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "");
    }

    private String extractTextFromJson(String json) {
        try {
            String marker = "\"text\": \"";
            int start = json.indexOf(marker);
            if (start == -1) return "AI không trả lời.";

            start += marker.length();
            int end = start;
            boolean escaped = false;

            while (end < json.length()) {
                char c = json.charAt(end);
                if (c == '\\') escaped = !escaped;
                else if (c == '"' && !escaped) break;
                else escaped = false;
                end++;
            }

            return json.substring(start, end)
                       .replace("\\n", "\n")
                       .replace("\\\"", "\"")
                       .replace("\\\\", "\\");

        } catch (Exception e) {
            return json;
        }
    }

    // ===== TEST =====
    public static void main(String[] args) {
        GeminiService service = new GeminiService();
        System.out.println(service.callAI("Xin chào", "", ""));
    }
    
    // Hàm này giúp GlassFish bỏ qua lỗi PKIX
private static void disableSSL() {
    try {
        TrustManager[] trustAllCerts = new TrustManager[]{
            new X509TrustManager() {
                public X509Certificate[] getAcceptedIssuers() { return null; }
                public void checkClientTrusted(X509Certificate[] certs, String authType) { }
                public void checkServerTrusted(X509Certificate[] certs, String authType) { }
            }
        };

        SSLContext sc = SSLContext.getInstance("SSL");
        sc.init(null, trustAllCerts, new SecureRandom());
        HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
        HttpsURLConnection.setDefaultHostnameVerifier((hostname, session) -> true);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
}