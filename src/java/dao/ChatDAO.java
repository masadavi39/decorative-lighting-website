package dao;

import model.ChatMessage;
import model.ChatMessageDTO;

import java.sql.*;
import java.util.*;

public class ChatDAO {

    private String cut(String s, int max) {
        if (s == null) return null;
        s = s.trim();
        if (s.length() <= max) return s;
        return s.substring(0, max);
    }

    // SAVE with fallback
    public int saveMessage(ChatMessage msg, String type, String intent, String sentiment, boolean readByUser) {
        // bảo vệ độ dài theo schema hiện tại
        intent = cut(intent, 100);
        sentiment = cut(sentiment, 20);

        // Query "đầy đủ" (nếu DB đã có cột)
        String sqlFull =
            "INSERT INTO chat_messages (user_id, sender_type, message_content, intent, sentiment, read_by_user) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

        // Query fallback tối giản (schema cũ)
        String sqlBasic =
            "INSERT INTO chat_messages (user_id, sender_type, message_content) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection()) {

            // Thử SQL đầy đủ trước
            try (PreparedStatement ps = conn.prepareStatement(sqlFull, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, msg.getUserId());
                ps.setString(2, msg.getSender());
                ps.setString(3, msg.getContent());
                ps.setString(4, intent);
                ps.setString(5, sentiment);
                ps.setInt(6, readByUser ? 1 : 0);
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
                return -1;
            } catch (SQLException ex) {
                // Nếu lỗi do thiếu cột (Unknown column) hoặc do truncate intent, ta fallback basic
                // Truncate intent đã xử lý, nên chủ yếu là thiếu cột.
                try (PreparedStatement ps2 = conn.prepareStatement(sqlBasic, Statement.RETURN_GENERATED_KEYS)) {
                    ps2.setString(1, msg.getUserId());
                    ps2.setString(2, msg.getSender());
                    ps2.setString(3, msg.getContent());
                    ps2.executeUpdate();

                    try (ResultSet rs = ps2.getGeneratedKeys()) {
                        if (rs.next()) return rs.getInt(1);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Lỗi lưu tin nhắn: " + e.getMessage());
        }
        return -1;
    }

    public void saveMessage(ChatMessage msg) {
        saveMessage(msg, "text", null, null, false);
    }

    // === HISTORY DTO (not deleted) ===
    public List<ChatMessageDTO> getHistoryDTO(String userId, boolean includeDeleted) {
        List<ChatMessageDTO> list = new ArrayList<>();

        // Cố gắng đọc các cột mới, nếu fail thì fallback
        String sqlFull =
            "SELECT chat_message_id, user_id, sender_type, message_content, intent, sentiment, created_at, is_deleted " +
            "FROM chat_messages WHERE user_id = ? " +
            (includeDeleted ? "" : "AND (is_deleted IS NULL OR is_deleted = 0) ") +
            "ORDER BY chat_message_id ASC";

        String sqlBasic =
            "SELECT chat_message_id, user_id, sender_type, message_content, created_at " +
            "FROM chat_messages WHERE user_id = ? ORDER BY chat_message_id ASC";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlFull)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapDto(rs));
                }
                return list;
            } catch (SQLException ex) {
                try (PreparedStatement ps2 = conn.prepareStatement(sqlBasic)) {
                    ps2.setString(1, userId);
                    try (ResultSet rs = ps2.executeQuery()) {
                        while (rs.next()) {
                            int id = rs.getInt("chat_message_id");
                            String sender = rs.getString("sender_type");
                            String content = rs.getString("message_content");
                            Timestamp createdAt = rs.getTimestamp("created_at");

                            list.add(new ChatMessageDTO(
                                id, userId, sender, detectType(content), normalizeContent(content), detectMeta(content),
                                null, null, createdAt != null ? createdAt.toString() : null
                            ));
                        }
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    public List<ChatMessageDTO> getHistorySince(String userId, int sinceId, boolean includeDeleted) {
        List<ChatMessageDTO> list = new ArrayList<>();

        String sqlFull =
            "SELECT chat_message_id, user_id, sender_type, message_content, intent, sentiment, created_at, is_deleted " +
            "FROM chat_messages WHERE user_id = ? AND chat_message_id > ? " +
            (includeDeleted ? "" : "AND (is_deleted IS NULL OR is_deleted = 0) ") +
            "ORDER BY chat_message_id ASC";

        String sqlBasic =
            "SELECT chat_message_id, user_id, sender_type, message_content, created_at " +
            "FROM chat_messages WHERE user_id = ? AND chat_message_id > ? ORDER BY chat_message_id ASC";

        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlFull)) {
                ps.setString(1, userId);
                ps.setInt(2, sinceId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapDto(rs));
                }
                return list;
            } catch (SQLException ex) {
                try (PreparedStatement ps2 = conn.prepareStatement(sqlBasic)) {
                    ps2.setString(1, userId);
                    ps2.setInt(2, sinceId);
                    try (ResultSet rs = ps2.executeQuery()) {
                        while (rs.next()) {
                            int id = rs.getInt("chat_message_id");
                            String sender = rs.getString("sender_type");
                            String content = rs.getString("message_content");
                            Timestamp createdAt = rs.getTimestamp("created_at");

                            list.add(new ChatMessageDTO(
                                id, userId, sender, detectType(content), normalizeContent(content), detectMeta(content),
                                null, null, createdAt != null ? createdAt.toString() : null
                            ));
                        }
                    }
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        return list;
    }

    private ChatMessageDTO mapDto(ResultSet rs) throws SQLException {
        int id = rs.getInt("chat_message_id");
        String userId = rs.getString("user_id");
        String sender = rs.getString("sender_type");
        String content = rs.getString("message_content");
        String intent = nullSafe(rs, "intent");
        String sentiment = nullSafe(rs, "sentiment");
        Timestamp createdAt = rs.getTimestamp("created_at");

        return new ChatMessageDTO(
            id, userId, sender,
            detectType(content),
            normalizeContent(content),
            detectMeta(content),
            intent, sentiment,
            createdAt != null ? createdAt.toString() : null
        );
    }

    private String nullSafe(ResultSet rs, String col) {
        try { return rs.getString(col); } catch (Exception e) { return null; }
    }

    private String detectType(String content) {
        if (content != null && content.startsWith("[PRODUCTS_JSON]")) return "products";
        return "text";
    }

    private String normalizeContent(String content) {
        if (content != null && content.startsWith("[PRODUCTS_JSON]"))
            return "Mình tìm được một số sản phẩm phù hợp, bạn xem thử nhé.";
        return content;
    }

    private Map<String, Object> detectMeta(String content) {
        if (content != null && content.startsWith("[PRODUCTS_JSON]")) {
            String json = content.substring("[PRODUCTS_JSON]".length());
            Map<String, Object> meta = new HashMap<>();
            meta.put("productsJson", json);
            return meta;
        }
        return null;
    }

    // USERS
    public Set<String> getUsersWhoChatted() {
        Set<String> userIds = new LinkedHashSet<>();
        String sql = "SELECT user_id FROM chat_messages ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String uid = rs.getString("user_id");
                if (uid != null && !uid.trim().isEmpty()) userIds.add(uid);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return userIds;
    }

    // UNREAD COUNT: nếu DB chưa có read_by_user => luôn 0 (fallback)
    public int getUnreadCountForUser(String userId) {
        String sql = "SELECT COUNT(*) FROM chat_messages WHERE user_id=? AND sender_type='ADMIN' AND (is_deleted IS NULL OR is_deleted=0) AND read_by_user=0";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            // schema cũ -> không có read_by_user
            return 0;
        }
        return 0;
    }

    // ADMIN trash APIs: nếu DB chưa có is_deleted => bạn phải migrate mới dùng được.
    public boolean softDeleteMessage(int messageId, Integer adminId) {
        String sql = "UPDATE chat_messages SET is_deleted=1, deleted_at=NOW(), deleted_by=? WHERE chat_message_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (adminId == null) ps.setNull(1, Types.INTEGER);
            else ps.setInt(1, adminId);
            ps.setInt(2, messageId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean restoreMessage(int messageId) {
        String sql = "UPDATE chat_messages SET is_deleted=0, deleted_at=NULL, deleted_by=NULL WHERE chat_message_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean deleteForever(int messageId) {
        String sql = "DELETE FROM chat_messages WHERE chat_message_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public List<ChatMessageDTO> getTrashHistory(String userId) {
        List<ChatMessageDTO> list = new ArrayList<>();
        String sql = "SELECT chat_message_id, user_id, sender_type, message_content, intent, sentiment, created_at " +
                     "FROM chat_messages WHERE user_id=? AND is_deleted=1 ORDER BY chat_message_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapDto(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int cleanupGuestMessagesOlderThanDays(int days) {
        String sql = "DELETE FROM chat_messages WHERE user_id NOT REGEXP '^[0-9]+$' AND created_at < (NOW() - INTERVAL ? DAY)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            return ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
}