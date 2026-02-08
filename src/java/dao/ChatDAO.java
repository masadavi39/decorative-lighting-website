package dao;

import model.ChatMessage;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class ChatDAO {
    
    // Cấu hình Database
    private final String DB_URL = "jdbc:mysql://localhost:3386/light_csdl"; 
    private final String DB_USER = "root";
    private final String DB_PASS = "";

    // 1. Hàm lấy kết nối
    public Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        } catch (Exception e) {
            System.err.println("❌ LỖI KẾT NỐI DB: " + e.getMessage());
            return null;
        }
    }

    // 2. Hàm lấy danh sách ID người dùng đã chat (Dùng cho Admin)
    // Tên hàm này phải khớp với bên ChatServlet gọi
    public List<String> getRecentUserIds() {
        List<String> users = new ArrayList<>();
        String sql = "SELECT DISTINCT user_id FROM chat_messages ORDER BY created_at DESC";
        
        Connection conn = getConnection();
        if (conn == null) return users;

        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                users.add(rs.getString("user_id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if(conn != null) conn.close(); } catch(Exception ex){}
        }
        return users;
    }
    
    // 3. Hàm lấy lịch sử tin nhắn
    public List<ChatMessage> getHistory(String userId) {
        List<ChatMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM chat_messages WHERE user_id = ? ORDER BY created_at ASC";
        
        Connection conn = getConnection();
        if (conn == null) return list;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new ChatMessage(
                    rs.getString("user_id"),
                    rs.getString("sender_type"),
                    rs.getString("message_content")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if(conn != null) conn.close(); } catch(Exception ex){}
        }
        return list;
    }

    // 4. Hàm lưu tin nhắn
    public void saveMessage(ChatMessage msg) {
        String sql = "INSERT INTO chat_messages (user_id, sender_type, message_content) VALUES (?, ?, ?)";
        
        Connection conn = getConnection();
        if (conn == null) return;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, msg.getUserId());
            ps.setString(2, msg.getSender());
            ps.setString(3, msg.getContent());
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if(conn != null) conn.close(); } catch(SQLException ex){}
        }
    }
    public Set<String> getUsersWhoChatted() {
        // LinkedHashSet giúp loại bỏ trùng lặp nhưng vẫn giữ thứ tự chèn
        Set<String> userIds = new LinkedHashSet<>();
        
        // Query lấy user_id, sắp xếp theo tin nhắn mới nhất
        String sql = "SELECT user_id FROM chat_messages ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                String uid = rs.getString("user_id");
                if (uid != null && !uid.trim().isEmpty()) {
                    userIds.add(uid);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return userIds;
    }
}