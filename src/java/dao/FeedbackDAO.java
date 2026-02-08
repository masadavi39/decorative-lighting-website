package dao;

import model.Feedback;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * Data access object for persisting and retrieving feedback entries.
 * Feedback messages are stored in the {@code feedback} table.
 */
public class FeedbackDAO {

    /** 🔹 Lưu phản hồi mới vào cơ sở dữ liệu */
    public boolean insert(Feedback f) {
        String sql = "INSERT INTO feedback (name, email, message, created_at) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, f.getName());
            ps.setString(2, f.getEmail());
            ps.setString(3, f.getMessage());
            ps.setTimestamp(4, new Timestamp(System.currentTimeMillis()));

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /** 🔹 Lấy danh sách tất cả phản hồi (cho admin xem trong tương lai) */
    public List<Feedback> getAll() {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT * FROM feedback ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Feedback f = new Feedback();
                f.setId(rs.getInt("feedback_id"));
                f.setName(rs.getString("name"));
                f.setEmail(rs.getString("email"));
                f.setMessage(rs.getString("message"));
                f.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(f);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
