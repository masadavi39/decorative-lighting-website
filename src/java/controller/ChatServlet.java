package controller;

import com.google.gson.Gson;
import dao.BotDAO;
import dao.ChatDAO;
import dao.ProductDAO;
import dao.UserDAO;
import model.ChatMessage;
import model.ChatMessageDTO;
import model.Product;
import model.User;
import service.ChatAiOrchestrator;
import service.GeminiService;
import service.N8nService;
import service.VisualSearchService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet(name = "ChatServlet", urlPatterns = {"/chat-api"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ChatServlet extends HttpServlet {

    // --- SERVICES & DAO ---
    private final VisualSearchService visualService = new VisualSearchService();
    private final GeminiService geminiService = new GeminiService();
    private final N8nService n8nService = new N8nService();

    private final BotDAO botDAO = new BotDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private final ChatDAO chatDAO = new ChatDAO();
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    // --- BỘ NÃO MỚI (ORCHESTRATOR) ---
    private final ChatAiOrchestrator orchestrator = new ChatAiOrchestrator();

    // ==========================
    // Helpers
    // ==========================
    private String resolveSenderId(HttpServletRequest req) {
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        return (user != null) ? String.valueOf(user.getId()) : session.getId();
    }

    private Integer resolveAdminId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        User user = (User) session.getAttribute("user");
        if (user == null) return null;
        if (!"admin".equalsIgnoreCase(user.getRole())) return null;
        return user.getId();
    }

    private int parseInt(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    private String safeStr(String s) {
        return (s == null) ? "" : s;
    }

    private String buildProductContext(List<Product> products) {
        if (products == null || products.isEmpty()) return "";
        StringBuilder sb = new StringBuilder();
        for (Product p : products) {
            try {
                sb.append("- ").append(p.getName())
                  .append(" (Giá: ").append(String.format("%,.0f", p.getPrice())).append(" VNĐ)\n");
            } catch (Exception ignored) {}
        }
        return sb.toString();
    }

    private List<Map<String, Object>> buildProductCards(HttpServletRequest req, List<Product> products) {
        String ctx = req.getContextPath();
        List<Map<String, Object>> cards = new ArrayList<>();

        for (Product p : products) {
            Map<String, Object> m = new HashMap<>();
            int id = p.getId();
            String name = p.getName();
            double price = p.getPrice();
            String imagePath = p.getImagePath();

            m.put("id", id);
            m.put("name", name);
            m.put("price", price);

            String imageUrl = (imagePath != null && !imagePath.isEmpty())
                ? (ctx + "/" + imagePath)
                : (ctx + "/images/no-image.png");
            m.put("imageUrl", imageUrl);

            String productUrl = ctx + "/products?action=detail&id=" +
                URLEncoder.encode(String.valueOf(id), StandardCharsets.UTF_8);
            m.put("url", productUrl);

            cards.add(m);
        }
        return cards;
    }

    private List<Product> tryGetProductsForCards(String userText, String intent) {
        final double MIN_SCORE = 0.25;
        if (!"product_search".equals(intent)) return Collections.emptyList();

        List<VisualSearchService.PyResult> results = visualService.searchByText(userText);
        if (results == null || results.isEmpty()) return Collections.emptyList();

        List<Integer> ids = new ArrayList<>();
        for (VisualSearchService.PyResult r : results) {
            if (r == null) continue;
            if (r.score >= MIN_SCORE) ids.add(r.product_id);
        }
        if (ids.isEmpty()) return Collections.emptyList();
        return productDAO.getProductsByIdsPreserveOrder(ids);
    }

    // ==========================
    // POST
    // ==========================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        String action = req.getParameter("action");
        String senderId = resolveSenderId(req);

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        int userId = (user != null) ? user.getId() : -1;

        try {
            // ==========================
            // CASE 1: AI CHAT + QUICK REPLY
            // ==========================
            if ("ai_chat".equals(action) || "quick_reply".equals(action)) {
                String content = safeStr(req.getParameter("content")).trim();
                if (content.isEmpty()) {
                    out.print("{\"status\":\"error\",\"message\":\"Empty content\"}");
                    return;
                }

                boolean isGuest = (user == null);
                String userEmail = isGuest ? "" : safeStr(user.getEmail());

                // 1. Phân loại Intent (Dùng Orchestrator)
                ChatAiOrchestrator.AiDecision decision = orchestrator.classify(content);

                // 2. Lưu tin nhắn USER
                int userMsgId = chatDAO.saveMessage(
                    new ChatMessage(senderId, "USER", content),
                    "text", decision.intent, decision.sentiment, true
                );

                if (userMsgId <= 0) {
                    resp.setStatus(500);
                    out.print("{\"status\":\"error\",\"message\":\"Lỗi DB.\"}");
                    return;
                }

                // 3. Gửi n8n (Triage) - ASYNC (fire-and-forget)
                n8nService.sendTriageEventAsync(
                    senderId,
                    content,
                    userEmail,
                    isGuest,
                    decision.intent,
                    decision.sentiment
                );

                // 4. Kiểm tra Escalate (Chuyển người thật)
                if (decision.escalateToAdmin) {
                    String adminReply = "Mình đã ghi nhận và chuyển cho admin hỗ trợ. Bạn vui lòng để lại SĐT để được liên hệ sớm nhất.";
                    chatDAO.saveMessage(new ChatMessage(senderId, "ADMIN", adminReply), "text", "escalated_to_human", "neutral", false);
                    out.print("{\"status\":\"success\",\"reply\":" + gson.toJson(adminReply) + ",\"escalated\": true}");
                    return;
                }

                // 5. Rule-based Answer
                if (decision.routedAnswer != null && !decision.routedAnswer.isEmpty()) {
                    chatDAO.saveMessage(new ChatMessage(senderId, "ADMIN", decision.routedAnswer), "text", "bot_rule", "neutral", false);
                    out.print("{\"status\": \"success\",\"reply\":" + gson.toJson(decision.routedAnswer) + "}");
                    return;
                }

                // 6. Product Cards
                List<Product> productsForCards = tryGetProductsForCards(content, decision.intent);
                String productsJson = null;

                if (productsForCards != null && !productsForCards.isEmpty()) {
                    List<Map<String, Object>> cards = buildProductCards(req, productsForCards);
                    productsJson = gson.toJson(cards);

                    chatDAO.saveMessage(
                        new ChatMessage(senderId, "ADMIN", "[PRODUCTS_JSON]" + productsJson),
                        "products", "product_cards", "neutral", false
                    );
                }

                // 7. Tạo câu trả lời AI (Orchestrator + Gemini)
                String aiReply;
                try {
                    aiReply = orchestrator.getAiResponse(content, userId);
                } catch (Exception e) {
                    aiReply = "Xin lỗi, hệ thống AI đang bận. Bạn chờ chút nhé.";
                    e.printStackTrace();
                }

                chatDAO.saveMessage(new ChatMessage(senderId, "ADMIN", aiReply), "text", "bot_ai", "neutral", false);

                // 8. Trả về kết quả JSON
                if (productsJson != null) {
                    out.print("{\"status\":\"success\",\"reply\":" + gson.toJson(aiReply) + ",\"products\":" + productsJson + "}");
                } else {
                    out.print("{\"status\":\"success\",\"reply\":" + gson.toJson(aiReply) + "}");
                }
                return;
            }

            // ==========================
            // CASE 2: IMAGE SEARCH
            // ==========================
            if ("image_search".equals(action)) {
                Part filePart = req.getPart("image");
                if (filePart == null || filePart.getSize() <= 0) {
                    out.print("{\"status\":\"error\",\"message\":\"Missing image\"}");
                    return;
                }

                boolean isGuest = (user == null);
                String userEmail = isGuest ? "" : safeStr(user.getEmail());

                chatDAO.saveMessage(new ChatMessage(senderId, "USER", "[Đã gửi 1 hình ảnh]"), "text", "image_search", "neutral", true);

                // Gửi triage tới n8n (ASYNC)
                n8nService.sendTriageEventAsync(
                    senderId,
                    "[User uploaded image]",
                    userEmail,
                    isGuest,
                    "image_search",
                    "neutral"
                );

                List<VisualSearchService.PyResult> results = visualService.searchByImage(filePart);
                final double MIN_SCORE = 0.22;
                List<Integer> ids = new ArrayList<>();
                if (results != null) {
                    for (VisualSearchService.PyResult r : results) {
                        if (r != null && r.score >= MIN_SCORE) ids.add(r.product_id);
                    }
                }

                List<Product> products = ids.isEmpty() ? Collections.emptyList() : productDAO.getProductsByIdsPreserveOrder(ids);

                if (products != null && !products.isEmpty()) {
                    List<Map<String, Object>> cards = buildProductCards(req, products);
                    String productsJson = gson.toJson(cards);
                    String stored = "[PRODUCTS_JSON]" + productsJson;

                    chatDAO.saveMessage(new ChatMessage(senderId, "ADMIN", stored), "products", "product_cards", "neutral", false);

                    String aiReply = callGeminiSafe("Khách gửi ảnh tìm sản phẩm.", buildProductContext(products), "", senderId, userEmail, isGuest, "image_search", "neutral");

                    chatDAO.saveMessage(new ChatMessage(senderId, "ADMIN", aiReply), "text", "bot_ai", "neutral", false);
                    out.print("{\"status\":\"success\",\"products\":" + productsJson + ",\"reply\":" + gson.toJson(aiReply) + "}");
                } else {
                    String aiReply = "Mình chưa tìm thấy sản phẩm phù hợp từ ảnh này. Bạn thử gửi ảnh rõ hơn hoặc mô tả thêm nhé.";
                    chatDAO.saveMessage(new ChatMessage(senderId, "ADMIN", aiReply), "text", "bot_rule", "neutral", false);
                    out.print("{\"status\":\"success\",\"reply\":" + gson.toJson(aiReply) + "}");
                }
                return;
            }

            // ==========================
            // CASE 3: ADMIN SEND
            // ==========================
            if ("admin_send".equals(action)) {
                Integer adminId = resolveAdminId(req);
                if (adminId == null) {
                    resp.setStatus(403);
                    out.print("{\"status\":\"error\",\"message\":\"Forbidden\"}");
                    return;
                }

                String targetUserId = req.getParameter("targetId");
                String content = safeStr(req.getParameter("content")).trim();
                if (targetUserId == null || targetUserId.trim().isEmpty() || content.isEmpty()) {
                    out.print("{\"status\":\"error\",\"message\":\"Missing params\"}");
                    return;
                }

                chatDAO.saveMessage(
                    new ChatMessage(targetUserId, "ADMIN", content),
                    "text", "admin_reply", "neutral", false
                );

                out.print("{\"status\":\"success\"}");
                return;
            }

            // ==========================
            // CASE 4: ADMIN DELETE MESSAGE
            // ==========================
            if ("admin_delete_message".equals(action)) {
                Integer adminId = resolveAdminId(req);
                if (adminId == null) {
                    resp.setStatus(403);
                    out.print("{\"status\":\"error\",\"message\":\"Forbidden\"}");
                    return;
                }
                int messageId = parseInt(req.getParameter("messageId"), -1);
                boolean ok = messageId > 0 && chatDAO.softDeleteMessage(messageId, adminId);
                out.print("{\"status\":\"" + (ok ? "success" :  "error") + "\"}");
                return;
            }

            // ==========================
            // CASE 5: ADMIN RESTORE MESSAGE
            // ==========================
            if ("admin_restore_message".equals(action)) {
                Integer adminId = resolveAdminId(req);
                if (adminId == null) {
                    resp.setStatus(403);
                    out.print("{\"status\":\"error\",\"message\":\"Forbidden\"}");
                    return;
                }
                int messageId = parseInt(req.getParameter("messageId"), -1);
                boolean ok = messageId > 0 && chatDAO.restoreMessage(messageId);
                out.print("{\"status\":\"" + (ok ? "success" : "error") + "\"}");
                return;
            }

            // ==========================
            // CASE 6: ADMIN DELETE FOREVER
            // ==========================
            if ("admin_delete_forever".equals(action)) {
                Integer adminId = resolveAdminId(req);
                if (adminId == null) {
                    resp.setStatus(403);
                    out.print("{\"status\":\"error\",\"message\":\"Forbidden\"}");
                    return;
                }
                int messageId = parseInt(req.getParameter("messageId"), -1);
                boolean ok = messageId > 0 && chatDAO.deleteForever(messageId);
                out.print("{\"status\":\"" + (ok ? "success" : "error") + "\"}");
                return;
            }

            if (!resp.isCommitted()) out.print("{\"status\":\"error\",\"message\":\"Unknown action\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":" + gson.toJson(e.getMessage()) + "}");
        } finally {
            out.flush();
        }
    }

    // Wrapper gọi Gemini an toàn (cho Image Search)
    private String callGeminiSafe(String userText, String productContext, String orderContext,
                                  String senderId, String email, boolean isGuest,
                                  String intent, String sentiment) {
        try {
            String reply = geminiService.callAI(userText, productContext, orderContext);
            if (reply != null && (reply.contains("Mã 429") || reply.contains("rate limit"))) {
                // Gửi triage rate limit (intent chuyên biệt) - ASYNC
                n8nService.sendTriageEventAsync(
                    senderId,
                    userText,
                    email,
                    isGuest,
                    "ai_rate_limited",
                    sentiment
                );
            }
            return reply;
        } catch (Exception e) {
            return "Xin lỗi, hệ thống AI đang bận.";
        }
    }

    // ==========================
    // GET (XỬ LÝ LOAD LỊCH SỬ)
    // ==========================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");
        String myId = resolveSenderId(request);

        try {
            // ADMIN: load users
            if ("admin_load_users".equals(action)) {
                Integer adminId = resolveAdminId(request);
                if (adminId == null) {
                    response.setStatus(403);
                    out.print("{\"status\":\"error\",\"message\":\"Forbidden\"}");
                    return;
                }

                Set<String> userIds = chatDAO.getUsersWhoChatted();
                List<Map<String, String>> users = new ArrayList<>();
                for (String uid : userIds) {
                    String displayName = "Khách (" + uid + ")";
                    try {
                        int idInt = Integer.parseInt(uid);
                        User u = userDAO.getUserById(idInt);
                        if (u != null && u.getFullName() != null) displayName = u.getFullName();
                    } catch (NumberFormatException ignored) {}

                    Map<String, String> m = new HashMap<>();
                    m.put("id", uid);
                    m.put("name", displayName);
                    users.add(m);
                }
                out.print(gson.toJson(users));
                return;
            }

            // ADMIN: load chat
            if ("admin_load_chat".equals(action)) {
                Integer adminId = resolveAdminId(request);
                if (adminId == null) {
                    response.setStatus(403);
                    out.print("{\"status\":\"error\",\"message\":\"Forbidden\"}");
                    return;
                }
                String targetId = request.getParameter("targetId");
                int sinceId = parseInt(request.getParameter("sinceId"), 0);
                boolean includeDeleted = "1".equals(request.getParameter("includeDeleted"));

                List<ChatMessageDTO> history = (sinceId > 0)
                    ? chatDAO.getHistorySince(targetId, sinceId, includeDeleted)
                    : chatDAO.getHistoryDTO(targetId, includeDeleted);

                out.print(gson.toJson(history));
                return;
            }

            // ADMIN: trash list
            if ("admin_load_trash".equals(action)) {
                Integer adminId = resolveAdminId(request);
                if (adminId == null) {
                    response.setStatus(403);
                    out.print("{\"status\":\"error\",\"message\":\"Forbidden\"}");
                    return;
                }
                String targetId = request.getParameter("targetId");
                List<ChatMessageDTO> trash = chatDAO.getTrashHistory(targetId);
                out.print(gson.toJson(trash));
                return;
            }

            // USER: history + unreadCount + sinceId
            int sinceId = parseInt(request.getParameter("sinceId"), 0);
            List<ChatMessageDTO> history = (sinceId > 0)
                ? chatDAO.getHistorySince(myId, sinceId, false)
                : chatDAO.getHistoryDTO(myId, false);

            int unread = chatDAO.getUnreadCountForUser(myId);

            Map<String, Object> payload = new HashMap<>();
            payload.put("messages", history);
            payload.put("unreadCount", unread);
            out.print(gson.toJson(payload));

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"status\":\"error\",\"message\":" + gson.toJson(e.getMessage()) + "}");
        } finally {
            out.flush();
        }
    }
}