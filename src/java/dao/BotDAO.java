package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class BotDAO {

    // Lấy thông tin đơn hàng gần nhất của User
    public String getRecentOrderContext(int userId) {
        StringBuilder sb = new StringBuilder();
        String query = "SELECT order_id, status, total_price, shipping_method "
                + "FROM orders WHERE user_id = ? ORDER BY created_at DESC LIMIT 1";

        // SỬA Ở ĐÂY: Dùng DBConnection.getConnection()
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                sb.append("Đơn hàng #").append(rs.getInt("order_id"));
                sb.append(" | Trạng thái: ").append(rs.getString("status"));
                sb.append(" | Tổng tiền: ").append(String.format("%,.0f", rs.getDouble("total_price")));
                sb.append(" | Vận chuyển: ").append(rs.getString("shipping_method"));
            } else {
                sb.append("Khách chưa có đơn hàng nào.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sb.toString();
    }

    // Fallback: Tìm sản phẩm bằng từ khóa (SQL LIKE) nếu Python lỗi
    public String searchProductFallback(String keyword) {
        StringBuilder sb = new StringBuilder();
        String query = "SELECT name, price FROM products WHERE name LIKE ? LIMIT 3";

        // SỬA Ở ĐÂY: Dùng DBConnection.getConnection()
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, "%" + keyword + "%");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                sb.append("- ").append(rs.getString("name"))
                        .append(" (").append(String.format("%,.0f", rs.getDouble("price"))).append(")\n");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sb.toString();
    }

    public String getUserSegment(int userId) {
        String segment = "New"; // Mặc định
        String sql = "SELECT segment FROM users WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String s = rs.getString("segment");
                    if (s != null && !s.isEmpty()) {
                        segment = s;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return segment;
    }
}
