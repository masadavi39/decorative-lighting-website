package dao;

import java.sql.*;

public class InventoryMovementDAO {

    public boolean insertManualAdjust(int productId, int delta, String note, Integer adminId) {
        String sql = "INSERT INTO inventory_movements (product_id, order_detail_id, movement_type, quantity_change, note) " +
                     "VALUES (?, NULL, 'manual_adjust', ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, delta);
            ps.setString(3, note != null ? note : "");
            boolean ok = ps.executeUpdate() > 0;
            // (Tùy chọn) nếu muốn lưu adminId, có thể thêm cột admin_id vào bảng và set vào INSERT
            return ok;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}