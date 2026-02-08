package service;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.time.OffsetDateTime;

/**
 * Enhanced N8N Service với Smart Complaint Handler integration
 */
public class N8nService {

    // ===== WEBHOOK URLs =====
    private static final String DEFAULT_TRIAGE_URL = "http://localhost:5678/webhook/chat-triage";
    
    private static final String N8N_TRIAGE_WEBHOOK =
            System.getenv().getOrDefault("N8N_TRIAGE_WEBHOOK", DEFAULT_TRIAGE_URL);

    private static final boolean USE_TEST_WEBHOOK =
            "true".equalsIgnoreCase(System.getenv().getOrDefault("N8N_USE_TEST_WEBHOOK", "false"));

    private static final int CONNECT_TIMEOUT_MS = 5000;
    private static final int READ_TIMEOUT_MS = 30000; // 30s để chờ AI processing

    // ===== HELPER METHODS =====
    private String esc(String s) {
        if (s == null) return "";
        return s
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");
    }

    private String normalizeWebhookUrl(String url) {
        if (!USE_TEST_WEBHOOK) return url;
        return url.replace("/webhook/", "/webhook-test/");
    }

    // ===== SYNC POST (with response) =====
    /**
     * Send triage event và CHỜ response từ n8n
     * Use case: Khi cần AI suggestion ngay lập tức
     * @param userId
     * @param message
     * @param userEmail
     * @param isGuest
     * @param intent
     * @param sentiment
     * @return 
     */
    public TriageResponse sendTriageEventSync(
            String userId,
            String message,
            String userEmail,
            boolean isGuest,
            String intent,
            String sentiment) {

        String ts = OffsetDateTime.now().toString();

        String json = "{"
                + "\"event\":\"chat_message_created\","
                + "\"user_id\":\"" + esc(userId) + "\","
                + "\"email\":\"" + esc(userEmail) + "\","
                + "\"is_guest\":" + (isGuest ? "true" : "false") + ","
                + "\"intent\":\"" + esc(intent) + "\","
                + "\"sentiment\":\"" + esc(sentiment) + "\","
                + "\"message\":\"" + esc(message) + "\","
                + "\"ts\":\"" + esc(ts) + "\""
                + "}";

        String finalUrl = normalizeWebhookUrl(N8N_TRIAGE_WEBHOOK);

        HttpURLConnection conn = null;
        try {
            URL url = new URL(finalUrl);
            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("Accept", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
            conn.setReadTimeout(READ_TIMEOUT_MS);

            byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
            conn.setFixedLengthStreamingMode(bytes.length);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(bytes);
            }

            int code = conn.getResponseCode();

            if (code == 200) {
                // Parse response
                try (java.io.BufferedReader br = new java.io.BufferedReader(
                        new java.io.InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    
                    StringBuilder response = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) {
                        response.append(line);
                    }

                    // Simple JSON parsing (or use Gson)
                    String responseJson = response.toString();
                    System.out.println("✅ n8n response: " + responseJson);

                    return new TriageResponse(true, code, responseJson, null);
                }
            } else {
                System.err.println("❌ n8n webhook failed: " + code);
                return new TriageResponse(false, code, null, "HTTP " + code);
            }

        } catch (Exception e) {
            System.err.println("❌ n8n error: " + e.getMessage());
            return new TriageResponse(false, 0, null, e.getMessage());
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    // ===== ASYNC POST (fire-and-forget) =====
    /**
     * Send triage event KHÔNG CHỜ response
     * Use case: Chỉ cần gửi log, không cần AI suggestion ngay
     */
    public void sendTriageEventAsync(
            String userId,
            String message,
            String userEmail,
            boolean isGuest,
            String intent,
            String sentiment) {

        String ts = OffsetDateTime.now().toString();

        String json = "{"
                + "\"event\":\"chat_message_created\","
                + "\"user_id\":\"" + esc(userId) + "\","
                + "\"email\":\"" + esc(userEmail) + "\","
                + "\"is_guest\":" + (isGuest ? "true" : "false") + ","
                + "\"intent\":\"" + esc(intent) + "\","
                + "\"sentiment\":\"" + esc(sentiment) + "\","
                + "\"message\":\"" + esc(message) + "\","
                + "\"ts\":\"" + esc(ts) + "\""
                + "}";

        final String finalUrl = normalizeWebhookUrl(N8N_TRIAGE_WEBHOOK);

        Thread t = new Thread(() -> {
            HttpURLConnection conn = null;
            try {
                URL url = new URL(finalUrl);
                conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
                conn.setRequestProperty("Accept", "application/json");
                conn.setDoOutput(true);
                conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
                conn.setReadTimeout(READ_TIMEOUT_MS);

                byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
                conn.setFixedLengthStreamingMode(bytes.length);

                try (OutputStream os = conn.getOutputStream()) {
                    os.write(bytes);
                }

                int code = conn.getResponseCode();
                System.out.println("📤 n8n async => " + code);

            } catch (Exception e) {
                System.err.println("❌ n8n async error: " + e.getMessage());
            } finally {
                if (conn != null) conn.disconnect();
            }
        });

        t.setName("n8n-webhook-async");
        t.setDaemon(true);
        t.start();
    }

    // ===== RESPONSE DTO =====
    public static class TriageResponse {
        public final boolean success;
        public final int httpCode;
        public final String responseJson;
        public final String errorMessage;

        public TriageResponse(boolean success, int httpCode, String responseJson, String errorMessage) {
            this.success = success;
            this.httpCode = httpCode;
            this.responseJson = responseJson;
            this.errorMessage = errorMessage;
        }

        public String getRequestId() {
            if (responseJson == null) return null;
            // Simple extract: "request_id":"req_..."
            int start = responseJson.indexOf("\"request_id\":\"");
            if (start == -1) return null;
            start += 14;
            int end = responseJson.indexOf("\"", start);
            if (end == -1) return null;
            return responseJson.substring(start, end);
        }

        public String getPriority() {
            if (responseJson == null) return null;
            int start = responseJson.indexOf("\"priority\":\"");
            if (start == -1) return null;
            start += 12;
            int end = responseJson.indexOf("\"", start);
            if (end == -1) return null;
            return responseJson.substring(start, end);
        }
    }
}