package service;

import dao.BotDAO;

public class ChatAiOrchestrator {

    // Class chứa kết quả phân loại sơ bộ
    public static class AiDecision {

        public String intent;      // short code (ví dụ: order_check, complaint...)
        public String sentiment;   // negative/neutral/positive
        public boolean escalateToAdmin; // Có cần chuyển người thật không?
        public String routedAnswer;     // Câu trả lời cứng (nếu có)
        public boolean useGemini;       // Có cần gọi AI Gemini không?
    }

    private final BotDAO botDAO = new BotDAO();
    private final GeminiService geminiService = new GeminiService(); // Service gọi Google Gemini

    // Hàm tiện ích: Cắt ngắn intent để lưu DB an toàn
    private String safeIntent(String intent) {
        if (intent == null) {
            return null;
        }
        intent = intent.trim();
        if (intent.length() > 80) {
            intent = intent.substring(0, 80);
        }
        return intent;
    }

    /**
     * PHẦN 1: Rule-based Classification (Phân loại luật) Giúp xác định nhanh ý
     * định của khách để quyết định có cần Gemini không.
     */
    public AiDecision classify(String userText) {
        AiDecision d = new AiDecision();
        String t = (userText == null ? "" : userText.toLowerCase());

        // 1. Xác định Intent (Ý định)
        if (t.contains("coupon") || t.contains("mã giảm") || t.contains("voucher")) {
            d.intent = "coupon_check";
        } else if (t.contains("đơn hàng") || t.contains("order") || t.contains("giao hàng") || t.contains("tracking")) {
            d.intent = "order_check";
        } else if (t.contains("bảo hành") || t.contains("warranty")) {
            d.intent = "warranty_policy";
        } else if (t.contains("khiếu nại") || t.contains("phàn nàn") || t.contains("lừa") || t.contains("tệ")) {
            d.intent = "complaint";
        } else if (t.contains("tìm") || t.contains("mua") || t.contains("sản phẩm") || t.contains("đèn")) {
            d.intent = "product_search";
        } else {
            d.intent = "smalltalk";
        }

        // 2. Xác định Sentiment (Cảm xúc)
        if (t.contains("tệ") || t.contains("bực") || t.contains("lừa") || t.contains("chậm") || t.contains("không hài lòng")) {
            d.sentiment = "negative";
        } else if (t.contains("cảm ơn") || t.contains("tốt") || t.contains("ok")) {
            d.sentiment = "positive";
        } else {
            d.sentiment = "neutral";
        }

        d.intent = safeIntent(d.intent);

        // Nếu khách giận hoặc khiếu nại -> Chuyển Admin ngay
        d.escalateToAdmin = "complaint".equals(d.intent) || "negative".equals(d.sentiment);

        // Xử lý các câu hỏi chính sách (Trả lời cứng cho nhanh)
        if ("warranty_policy".equals(d.intent)) {
            d.routedAnswer
                    = "Chính sách bảo hành: Sản phẩm được bảo hành 12-24 tháng theo quy định. "
                    + "Bạn vui lòng cung cấp Mã Đơn Hàng để mình kiểm tra thời hạn bảo hành nhé.";
            d.useGemini = false;
        } else {
            // Các trường hợp còn lại để Gemini lo
            d.useGemini = true;
        }

        return d;
    }

    /**
     * PHẦN 2: AI Generation with RFM Context (Tạo câu trả lời thông minh) Đây
     * là hàm chính để ChatServlet gọi khi useGemini = true
     */
    public String getAiResponse(String userMessage, int userId) {
        // 1. Lấy phân cụm khách hàng từ DB (Do Python tính toán)
        // Nếu khách chưa đăng nhập (userId=0 hoặc -1), coi là "New"
        String segment = (userId > 0) ? botDAO.getUserSegment(userId) : "New";
        System.out.println("DEBUG AI: User=" + userId + " | Segment=" + segment);
        // 2. Xây dựng Chiến thuật Marketing theo nhóm (RFM Strategy)
        String marketingStrategy = "";
        switch (segment) {
            case "Loyal":
                marketingStrategy = "ĐỐI TƯỢNG: Khách hàng VIP (Loyal - Rất quan trọng). "
                        + "MỤC TIÊU: Tri ân để họ cảm thấy được trân trọng. "
                        + "HÀNH ĐỘNG: Mời dùng mã 'TRIAN' (Giảm 15% tối đa 300k cho đơn từ 500k). "
                        + "THÁI ĐỘ: Kính trọng, đẳng cấp, coi họ là người đặc biệt.";
                break;

            case "Churn Risk":
                marketingStrategy = "ĐỐI TƯỢNG: Khách đã lâu không mua (Nguy cơ rời bỏ). "
                        + "MỤC TIÊU: Kéo khách quay lại bằng tình cảm. "
                        + "HÀNH ĐỘNG: Nhắn nhủ 'Shop nhớ bạn' và tặng mã 'MISSYOU' (Giảm 20% tối đa 200k). Nhấn mạnh mã chỉ có hạn trong 48h. "
                        + "THÁI ĐỘ: Ân cần, tha thiết, mong chờ.";
                break;

            case "Potential":
                marketingStrategy = "ĐỐI TƯỢNG: Khách hàng tiềm năng. "
                        + "MỤC TIÊU: Kích thích mua đơn hàng giá trị khá. "
                        + "HÀNH ĐỘNG: Tặng mã làm quen 'LAMQUEN' (Giảm ngay 30k cho đơn từ 150k). "
                        + "THÁI ĐỘ: Thân thiện, cởi mở như bạn bè.";
                break;

            case "Risk (Bom Hàng)":
                marketingStrategy = "ĐỐI TƯỢNG: Khách có lịch sử hủy đơn cao (Cảnh báo). "
                        + "MỤC TIÊU: Khuyến khích thanh toán trước để tránh bom hàng. "
                        + "HÀNH ĐỘNG: Chỉ tặng mã 'PREPAY' (Giảm 5%) NẾU khách chịu thanh toán Online/Chuyển khoản trước. Tuyệt đối KHÔNG mời chào COD. "
                        + "THÁI ĐỘ: Cẩn trọng, lịch sự nhưng chắc chắn.";
                break;

            default: // New hoặc Null
                marketingStrategy = "ĐỐI TƯỢNG: Khách hàng mới (New). "
                        + "MỤC TIÊU: Tạo ấn tượng đầu tiên tốt đẹp. "
                        + "HÀNH ĐỘNG: Chào mừng bằng mã 'HELLOSHOP' (Giảm 10% tối đa 50k cho đơn đầu). "
                        + "THÁI ĐỘ: Nhiệt tình, hiếu khách, hướng dẫn tỉ mỉ.";
                break;
        }

        // 3. Lấy dữ liệu sản phẩm liên quan (RAG - Retrieval Augmented Generation)
        // Dùng từ khóa trong tin nhắn khách để tìm sản phẩm relevant nhất
        String productContext = botDAO.searchProductFallback(userMessage);
        if (productContext.isEmpty()) {
            productContext = "Hiện không tìm thấy sản phẩm cụ thể nào khớp với câu hỏi.";
        }

        // 4. Ghép Prompt gửi Gemini
        String finalPrompt
                = "VAI TRÒ: Bạn là nhân viên tư vấn ảo chuyên nghiệp của Light Shop (bán đèn trang trí).\n\n"
                + "THÔNG TIN KHÁCH HÀNG: " + marketingStrategy + "\n\n"
                + "DỮ LIỆU SẢN PHẨM LIÊN QUAN:\n" + productContext + "\n\n"
                + "YÊU CẦU TRẢ LỜI:\n"
                + "- Trả lời ngắn gọn, tự nhiên bằng tiếng Việt.\n"
                + "- Khéo léo lồng ghép mã giảm giá (nếu có trong phần ƯU ĐÃI) vào câu trả lời.\n"
                + "- Nếu khách hỏi về sản phẩm, hãy dựa vào DỮ LIỆU SẢN PHẨM ở trên để tư vấn.\n\n"
                + "KHÁCH HỎI: \"" + userMessage + "\"";

        // 5. Gọi Service
        return geminiService.callAI(finalPrompt, "", "");
    }

    // Hàm phụ trợ cũ (giữ lại nếu cần dùng ở chỗ khác)
    public String buildRagContext(String userText) {
        return botDAO.searchProductFallback(userText);
    }
}
