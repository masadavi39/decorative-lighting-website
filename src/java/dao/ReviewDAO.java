package dao;

import model.ProductReview;
import model.ProductReviewReply;
import util.SpamDetector;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    public boolean hasReviewed(int productId, int userId) {
        String sql = "SELECT 1 FROM product_reviews WHERE product_id = ? AND user_id = ? LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /* ================== USER ACTIONS ================== */
    public boolean addReview(int productId, int userId, int rating, String title, String content) {
        // Rate-limit nhẹ: 3 review/giờ/người
        if (exceedRateLimitReviews(userId, 3, 60)) {
            System.err.println("Rate limit: user " + userId + " vượt quá số review cho phép trong 1 giờ");
            return false;
        }

        String sql = "INSERT INTO product_reviews (product_id, user_id, rating, title, content, approved) VALUES (?, ?, ?, ?, ?, 0)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, userId);
            ps.setInt(3, rating);
            ps.setString(4, title);
            ps.setString(5, content);
            boolean ok = ps.executeUpdate() > 0;

            if (ok) {
                Integer reviewId = findReviewIdByProductAndUser(productId, userId);
                if (reviewId != null) {
                    autoModerateAfterInsert(conn, reviewId, productId, userId, title, content);
                }
            }
            return ok;
        } catch (SQLIntegrityConstraintViolationException dup) {
            System.err.println("Duplicate or FK violation when insert product_reviews: " + dup.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addReply(int productReviewId, int userId, String content) {
        // Rate-limit: 10 reply/giờ/người
        if (exceedRateLimitReplies(userId, 10, 60)) {
            System.err.println("Rate limit: user " + userId + " vượt quá số reply cho phép trong 1 giờ");
            return false;
        }
        // Chống spam nội dung reply trước khi insert
        SpamDetector.Result r = SpamDetector.evaluate("", content);
        if (r.spam) {
            System.err.println("Reply bị đánh dấu spam: " + r.reasons);
            return false;
        }

        String sql = "INSERT INTO product_review_replies (product_review_id, user_id, content) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productReviewId);
            ps.setInt(2, userId);
            ps.setString(3, content);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean approveReview(int productReviewId, boolean approved) {
        String sql = "UPDATE product_reviews SET approved = ? WHERE product_review_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, approved);
            ps.setInt(2, productReviewId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /* ================== FRONT DISPLAY ================== */
    public List<ProductReview> getApprovedByProduct(int productId) {
        String sql = """
            SELECT r.*, u.full_name AS user_name
            FROM product_reviews r
            JOIN users u ON u.user_id = r.user_id
            WHERE r.product_id = ? AND r.approved = 1
            ORDER BY r.created_at DESC
        """;
        List<ProductReview> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductReview r = extractReview(rs);
                    r.setUserName(rs.getString("user_name"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        for (ProductReview r : list) {
            r.setReplies(getReplies(r.getProductReviewId()));
        }
        return list;
    }

    public Double getAverageRating(int productId) {
        String sql = "SELECT AVG(rating) FROM product_reviews WHERE product_id = ? AND approved = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double v = rs.getDouble(1);
                    if (rs.wasNull()) return null;
                    return v;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Integer countApproved(int productId) {
        String sql = "SELECT COUNT(*) FROM product_reviews WHERE product_id = ? AND approved = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /* ================== REPLIES ================== */
    public List<ProductReviewReply> getReplies(int productReviewId) {
        String sql = """
            SELECT rr.*, u.full_name AS user_name, u.role AS user_role
            FROM product_review_replies rr
            JOIN users u ON u.user_id = rr.user_id
            WHERE rr.product_review_id = ?
            ORDER BY rr.created_at ASC
        """;
        List<ProductReviewReply> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productReviewId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductReviewReply rr = new ProductReviewReply();
                    rr.setReplyId(rs.getInt("reply_id"));
                    rr.setProductReviewId(rs.getInt("product_review_id"));
                    rr.setUserId(rs.getInt("user_id"));
                    rr.setContent(rs.getString("content"));
                    rr.setCreatedAt(rs.getTimestamp("created_at"));
                    rr.setUserName(rs.getString("user_name"));
                    rr.setUserRole(rs.getString("user_role")); // NEW
                    list.add(rr);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ================== ADMIN LISTING ================== */
    public List<ProductReview> getReviewsPaged(String keyword, Integer productId,
                                               Boolean approved, int page, int pageSize) {
        List<ProductReview> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT r.*, u.full_name AS user_name, p.name AS product_name
            FROM product_reviews r
            JOIN users u ON u.user_id = r.user_id
            JOIN products p ON p.product_id = r.product_id
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(r.title) LIKE ? OR LOWER(r.content) LIKE ? OR LOWER(u.full_name) LIKE ? OR LOWER(p.name) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw); params.add(kw); params.add(kw); params.add(kw);
        }
        if (productId != null && productId > 0) {
            sql.append(" AND r.product_id = ?");
            params.add(productId);
        }
        if (approved != null) {
            sql.append(" AND r.approved = ?");
            params.add(approved ? 1 : 0);
        }

        sql.append(" ORDER BY r.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductReview r = extractReview(rs);
                    r.setUserName(rs.getString("user_name"));
                    r.setProductName(rs.getString("product_name"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countReviews(String keyword, Integer productId, Boolean approved) {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*)
            FROM product_reviews r
            JOIN users u ON u.user_id = r.user_id
            JOIN products p ON p.product_id = r.product_id
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(r.title) LIKE ? OR LOWER(r.content) LIKE ? OR LOWER(u.full_name) LIKE ? OR LOWER(p.name) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw); params.add(kw); params.add(kw); params.add(kw);
        }
        if (productId != null && productId > 0) {
            sql.append(" AND r.product_id = ?");
            params.add(productId);
        }
        if (approved != null) {
            sql.append(" AND r.approved = ?");
            params.add(approved ? 1 : 0);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public ProductReview getReviewById(int reviewId) {
        String sql = """
            SELECT r.*, u.full_name AS user_name, p.name AS product_name
            FROM product_reviews r
            JOIN users u ON u.user_id = r.user_id
            JOIN products p ON p.product_id = r.product_id
            WHERE r.product_review_id = ?
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductReview r = extractReview(rs);
                    r.setUserName(rs.getString("user_name"));
                    r.setProductName(rs.getString("product_name"));
                    r.setReplies(getReplies(r.getProductReviewId()));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /* ================== HELPER ================== */
    private ProductReview extractReview(ResultSet rs) throws SQLException {
        ProductReview r = new ProductReview();
        r.setProductReviewId(rs.getInt("product_review_id"));
        r.setProductId(rs.getInt("product_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRating(rs.getInt("rating"));
        r.setTitle(rs.getString("title"));
        r.setContent(rs.getString("content"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setApproved(rs.getBoolean("approved"));
        return r;
    }

    // Tìm id review vừa tạo qua unique (product_id, user_id)
    private Integer findReviewIdByProductAndUser(int productId, int userId) {
        String sql = "SELECT product_review_id FROM product_reviews WHERE product_id = ? AND user_id = ? ORDER BY created_at DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Kiểm tra user đã mua và đơn "Đã giao" chưa
    private boolean userPurchasedDelivered(Connection conn, int userId, int productId) {
        String sql = """
            SELECT 1
            FROM orders o
            JOIN order_details od ON od.order_id = o.order_id
            WHERE o.user_id = ? AND od.product_id = ? AND o.status = 'Đã giao'
            LIMIT 1
        """;
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Tự động duyệt sau khi insert nếu đạt điều kiện
    private void autoModerateAfterInsert(Connection reuseConn,
                                         int reviewId, int productId, int userId,
                                         String title, String content) {
        // Dùng connection sẵn có nếu truyền vào, nếu không tự mở
        boolean ownConn = (reuseConn == null);
        try (Connection conn = ownConn ? DBConnection.getConnection() : reuseConn) {
            // 1) Chống spam
            SpamDetector.Result eval = SpamDetector.evaluate(title, content);
            if (eval.spam) {
                System.out.println("[Moderation] Review " + reviewId + " flagged as spam: " + eval.reasons);
                // Giữ approved=0, chờ admin duyệt tay
                return;
            }

            // 2) Chỉ auto-approve nếu user đã mua & đơn đã giao
            boolean verifiedBuyer = userPurchasedDelivered(conn, userId, productId);
            if (verifiedBuyer) {
                // Nội dung hợp lệ + verified buyer => auto-approve
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE product_reviews SET approved = 1 WHERE product_review_id = ?")) {
                    ps.setInt(1, reviewId);
                    ps.executeUpdate();
                }
                System.out.println("[Moderation] Review " + reviewId + " auto-approved (verified buyer).");
            } else {
                System.out.println("[Moderation] Review " + reviewId + " pending (not verified buyer).");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Rate limit đơn giản: tối đa {limit} review trong {windowMinutes} phút
    private boolean exceedRateLimitReviews(int userId, int limit, int windowMinutes) {
        String sql = "SELECT COUNT(*) FROM product_reviews WHERE user_id = ? AND created_at > (CURRENT_TIMESTAMP - INTERVAL ? MINUTE)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, windowMinutes);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) >= limit;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false; // mặc định cho qua nếu lỗi
    }

    // Rate limit reply
    private boolean exceedRateLimitReplies(int userId, int limit, int windowMinutes) {
        String sql = "SELECT COUNT(*) FROM product_review_replies WHERE user_id = ? AND created_at > (CURRENT_TIMESTAMP - INTERVAL ? MINUTE)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, windowMinutes);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) >= limit;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}