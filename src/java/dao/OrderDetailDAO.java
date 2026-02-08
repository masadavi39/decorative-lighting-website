package dao;

import model.OrderDetail;
import model.Product;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDetailDAO {

    /**
     * Thêm chi tiết đơn hàng (khi người dùng đặt hàng)
     */
    public boolean insertOrderDetail(int orderId, int productId, int quantity, double price) {
        String sql = "INSERT INTO `order_details` (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);
            ps.setDouble(4, price);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách chi tiết sản phẩm của 1 đơn hàng
     */
    public List<OrderDetail> getDetailsByOrderId(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = """
            SELECT od.*, p.name AS product_name, p.image_path AS product_image
            FROM `order_details` od
            JOIN `products` p ON od.product_id = p.product_id
            WHERE od.order_id = ?
            ORDER BY od.order_detail_id
        """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderDetail d = new OrderDetail();
                d.setOrderDetailId(rs.getInt("order_detail_id"));
                d.setOrderId(rs.getInt("order_id"));
                d.setProductId(rs.getInt("product_id"));
                d.setQuantity(rs.getInt("quantity"));
                d.setPrice(rs.getDouble("price"));
                try {
                    d.setCreatedAt(rs.getTimestamp("created_at"));
                } catch (Exception ignore) {
                }
                try {
                    d.setUpdatedAt(rs.getTimestamp("updated_at"));
                } catch (Exception ignore) {
                }

                // Gắn thêm thông tin sản phẩm
                Product p = new Product();
                p.setId(rs.getInt("product_id"));
                p.setName(rs.getString("product_name"));
                p.setImagePath(rs.getString("product_image"));
                d.setProduct(p);

                list.add(d);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Xoá chi tiết đơn hàng (khi huỷ đơn)
     */
    public boolean deleteDetailsByOrderId(int orderId) {
        String sql = "DELETE FROM `order_details` WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Tính tổng tiền của một đơn hàng (subtotal)
     */
    public double calculateTotalByOrderId(int orderId) {
        double total = 0;
        String sql = "SELECT SUM(quantity * price) AS total FROM `order_details` WHERE order_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getDouble("total");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return total;
    }

}
