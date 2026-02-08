package dao;

import model.Order;
import model.OrderDetail;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;

/**
 * OrderDAO - thao tác với bảng orders, order_details và cung cấp các thống kê doanh thu
 */
public class OrderDAO {

    /**
     * (Legacy) Tạo đơn + chi tiết từ cart — đổi CartItem -> OrderDetail
     */
    public boolean createOrder(int userId, String address, Map<Integer, OrderDetail> cart) {
        String insertOrderSQL = """
            INSERT INTO `orders` (user_id, payment_id, receiver_name, phone, province_id, address, shipping_method, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """;
        String insertDetailSQL = """
            INSERT INTO `order_details` (order_id, product_id, quantity, price)
            VALUES (?, ?, ?, ?)
        """;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);

            int orderId = -1;
            try (PreparedStatement ps = conn.prepareStatement(insertOrderSQL, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, userId);
                ps.setInt(2, 2); // COD mặc định
                ps.setString(3, "");
                ps.setString(4, "");
                ps.setInt(5, 1);
                ps.setString(6, address);
                ps.setString(7, "standard");
                ps.setString(8, "Chờ duyệt");
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        orderId = rs.getInt(1);
                    }
                }
            }

            if (orderId <= 0) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement psDetail = conn.prepareStatement(insertDetailSQL)) {
                for (OrderDetail item : cart.values()) {
                    int pid = item.getProductId() > 0 ? item.getProductId()
                            : (item.getProduct() != null ? item.getProduct().getId() : 0);
                    psDetail.setInt(1, orderId);
                    psDetail.setInt(2, pid);
                    psDetail.setInt(3, item.getQuantity());
                    psDetail.setDouble(4, item.getPrice());
                    psDetail.addBatch();
                }
                psDetail.executeBatch();
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách đơn hàng theo người dùng
     */
    public List<Order> getOrdersByUser(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = """
            SELECT o.*
            FROM `orders` o
            WHERE o.user_id = ?
            ORDER BY o.created_at DESC
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả đơn hàng (admin)
     */
    public List<Order> getAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = """
            SELECT o.*
            FROM `orders` o
            ORDER BY o.created_at DESC
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapOrder(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy chi tiết sản phẩm trong 1 đơn hàng (bản gộp, giữ lại cho tương thích cũ)
     */
    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT * FROM `order_details` WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderDetail d = new OrderDetail();
                    d.setOrderDetailId(rs.getInt("order_detail_id"));
                    d.setOrderId(rs.getInt("order_id"));
                    d.setProductId(rs.getInt("product_id"));
                    d.setQuantity(rs.getInt("quantity"));
                    d.setPrice(rs.getDouble("price"));
                    try { d.setCreatedAt(rs.getTimestamp("created_at")); } catch (Exception ignore) {}
                    try { d.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (Exception ignore) {}
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Admin duyệt đơn hàng — chuyển 'Chờ duyệt' → 'Đang giao'
     */
    public boolean approveOrderByAdmin(int orderId) {
        String sql = "UPDATE `orders` SET status = 'Đang giao' WHERE order_id = ? AND status = 'Chờ duyệt'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Ánh xạ dữ liệu đơn hàng sang model Order (schema v3)
     */
    private Order mapOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("order_id"));
        o.setUserId(rs.getInt("user_id"));
        try { o.setPaymentId(rs.getInt("payment_id")); } catch (SQLException ignore) {}

        o.setReceiverName(rs.getString("receiver_name"));
        o.setPhone(rs.getString("phone"));
        try { o.setProvinceId(rs.getInt("province_id")); } catch (SQLException ignore) {}
        o.setAddress(rs.getString("address"));

        o.setShippingMethod(rs.getString("shipping_method"));
        try { o.setShippingFee(rs.getDouble("shipping_fee")); } catch (SQLException ignore) {}

        try { o.setInvoiceCompany(rs.getString("invoice_company")); } catch (SQLException ignore) {}
        try { o.setTaxCode(rs.getString("tax_code")); } catch (SQLException ignore) {}
        try { o.setTaxEmail(rs.getString("tax_email")); } catch (SQLException ignore) {}
        try { o.setNote(rs.getString("note")); } catch (SQLException ignore) {}

        try { o.setTax(rs.getDouble("tax")); } catch (SQLException ignore) {}
        try { o.setDiscountAmount(rs.getDouble("discount_amount")); } catch (SQLException ignore) {}
        try { o.setCouponCode(rs.getString("coupon_code")); } catch (SQLException ignore) {}
        o.setTotalPrice(rs.getDouble("total_price"));

        o.setStatus(rs.getString("status"));
        try { o.setPaymentStatus(rs.getString("payment_status")); } catch (SQLException ignore) {}
        try { o.setTrackingNumber(rs.getString("tracking_number")); } catch (SQLException ignore) {}

        try { o.setCreatedAt(rs.getTimestamp("created_at")); } catch (SQLException ignore) {}
        try { o.setUpdatedAt(rs.getTimestamp("updated_at")); } catch (SQLException ignore) {}

        return o;
    }

    /**
     * Lấy 1 đơn hàng theo ID
     */
    public Order getOrderById(int orderId) {
        String sql = """
            SELECT o.*
            FROM `orders` o
            WHERE o.order_id = ?
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapOrder(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm một đơn hàng (cho reorder/checkout) — KHỚP SCHEMA V3
     * LƯU Ý: coupon_code rỗng phải set NULL để không vi phạm FK.
     */
    public int insert(Order order) {
        String sql = """
            INSERT INTO `orders`
            (user_id, payment_id, receiver_name, phone, province_id, address, shipping_method, note, coupon_code, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            int paymentId = order.getPaymentId() > 0 ? order.getPaymentId() : 2; // COD
            String shippingMethod = (order.getShippingMethod() != null && !order.getShippingMethod().isEmpty())
                    ? order.getShippingMethod() : "standard";

            ps.setInt(1, order.getUserId());
            ps.setInt(2, paymentId);
            ps.setString(3, nvl(order.getReceiverName()));
            ps.setString(4, nvl(order.getPhone()));
            ps.setInt(5, order.getProvinceId() > 0 ? order.getProvinceId() : 1);
            ps.setString(6, nvl(order.getAddress()));
            ps.setString(7, shippingMethod);
            ps.setString(8, nvl(order.getNote()));
            setNullableString(ps, 9, order.getCouponCode()); // rỗng -> NULL
            ps.setString(10, (order.getStatus() != null && !order.getStatus().isEmpty()) ? order.getStatus() : "Chờ duyệt");

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Tạo Order + Details trong 1 transaction.
     * B1: Insert Order với coupon_code = NULL để không bị FK/trigger chặn.
     * B2: Insert order_details (triggers sẽ tính total).
     * B3: Nếu user có coupon và coupon tồn tại, UPDATE coupon_code; nếu trigger chặn do điều kiện, bỏ qua coupon.
     */
    public int insertWithDetails(Order order, Map<Integer, OrderDetail> cart) {
        String insertOrderSQL = """
            INSERT INTO `orders`
            (user_id, payment_id, receiver_name, phone, province_id, address, shipping_method, note, coupon_code, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        String insertDetailSQL = """
            INSERT INTO `order_details` (order_id, product_id, quantity, price)
            VALUES (?, ?, ?, ?)
        """;
        String checkCouponSQL = "SELECT 1 FROM coupons WHERE code = ? AND active = 1 LIMIT 1";
        String updateCouponSQL = "UPDATE `orders` SET coupon_code = ? WHERE order_id = ?";

        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psDetail = null;
        PreparedStatement psCouponCheck = null;
        PreparedStatement psCouponUpdate = null;
        ResultSet rsKeys = null;
        ResultSet rsCoupon = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String originalCoupon = trimToNull(order.getCouponCode()); // rỗng -> null

            psOrder = conn.prepareStatement(insertOrderSQL, Statement.RETURN_GENERATED_KEYS);

            int paymentId = order.getPaymentId() > 0 ? order.getPaymentId() : 2; // COD mặc định
            String shippingMethod = (order.getShippingMethod() != null && !order.getShippingMethod().isEmpty())
                    ? order.getShippingMethod() : "standard";

            psOrder.setInt(1, order.getUserId());
            psOrder.setInt(2, paymentId);
            psOrder.setString(3, nvl(order.getReceiverName()));
            psOrder.setString(4, nvl(order.getPhone()));
            psOrder.setInt(5, order.getProvinceId() > 0 ? order.getProvinceId() : 1);
            psOrder.setString(6, nvl(order.getAddress()));
            psOrder.setString(7, shippingMethod);
            psOrder.setString(8, nvl(order.getNote()));
            psOrder.setNull(9, Types.VARCHAR); // QUAN TRỌNG: NULL, không phải ""
            psOrder.setString(10, (order.getStatus() != null && !order.getStatus().isEmpty()) ? order.getStatus() : "Chờ duyệt");

            psOrder.executeUpdate();

            rsKeys = psOrder.getGeneratedKeys();
            int newOrderId = -1;
            if (rsKeys.next()) {
                newOrderId = rsKeys.getInt(1);
            }
            if (newOrderId <= 0) {
                conn.rollback();
                return -1;
            }

            // Chèn chi tiết đơn hàng
            psDetail = conn.prepareStatement(insertDetailSQL);
            for (OrderDetail line : cart.values()) {
                int pid = line.getProductId() > 0
                        ? line.getProductId()
                        : (line.getProduct() != null ? line.getProduct().getId() : 0);

                psDetail.setInt(1, newOrderId);
                psDetail.setInt(2, pid);
                psDetail.setInt(3, line.getQuantity());
                psDetail.setDouble(4, line.getPrice());
                psDetail.addBatch();
            }
            psDetail.executeBatch();
            // Triggers trên order_details sẽ tự CALL recalc_order_total

            // Sau khi đã có subtotal thực, nếu user có coupon: kiểm tra tồn tại rồi UPDATE
            if (originalCoupon != null) {
                psCouponCheck = conn.prepareStatement(checkCouponSQL);
                psCouponCheck.setString(1, originalCoupon);
                rsCoupon = psCouponCheck.executeQuery();

                if (rsCoupon.next()) {
                    try {
                        psCouponUpdate = conn.prepareStatement(updateCouponSQL);
                        psCouponUpdate.setString(1, originalCoupon);
                        psCouponUpdate.setInt(2, newOrderId);
                        psCouponUpdate.executeUpdate();

                        // BỔ SUNG: tái tính tổng sau khi cập nhật coupon_code
                        try (PreparedStatement psRecalc = conn.prepareStatement("CALL recalc_order_total(?)")) {
                            psRecalc.setInt(1, newOrderId);
                            psRecalc.execute();
                        }
                        // Nếu trigger bu_orders_validate_coupon chặn (min_subtotal,..) sẽ ném SQLException -> bỏ qua coupon.
                    } catch (SQLException ce) {
                        ce.printStackTrace(); // log và bỏ qua coupon, vẫn commit đơn
                    }
                } else {
                    // Không update coupon để tránh FK lỗi
                }
            }

            conn.commit();
            return newOrderId;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (rsCoupon != null) try { rsCoupon.close(); } catch (SQLException ignore) {}
            if (rsKeys != null) try { rsKeys.close(); } catch (SQLException ignore) {}
            if (psCouponUpdate != null) try { psCouponUpdate.close(); } catch (SQLException ignore) {}
            if (psCouponCheck != null) try { psCouponCheck.close(); } catch (SQLException ignore) {}
            if (psDetail != null) try { psDetail.close(); } catch (SQLException ignore) {}
            if (psOrder != null) try { psOrder.close(); } catch (SQLException ignore) {}
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignore) {}
            }
        }
        return -1;
    }

    /**
     * Xóa đơn hàng
     */
    public boolean deleteOrder(int orderId) {
        String sql = "DELETE FROM `orders` WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy 5 tuần gần nhất có doanh thu (chỉ tính 'Đã giao') — dùng created_at
     * Trả về List<String[]>: [weekLabel, revenue, weekCode]
     */
    public List<String[]> getWeeklyRevenue() {
        List<String[]> list = new ArrayList<>();
        String sql = """
            WITH weeks AS (
                SELECT CAST(YEARWEEK(DATE_SUB(CURDATE(), INTERVAL seq WEEK), 1) AS CHAR) AS week_code
                FROM (SELECT 0 AS seq UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t
            )
            SELECT w.week_code,
                   COALESCE(SUM(d.quantity * d.price), 0) AS revenue
            FROM weeks w
            LEFT JOIN orders o
              ON CAST(YEARWEEK(o.created_at, 1) AS CHAR) = w.week_code AND o.status = 'Đã giao'
            LEFT JOIN order_details d ON o.order_id = d.order_id
            GROUP BY w.week_code
            ORDER BY w.week_code ASC
        """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String weekCode = rs.getString("week_code").trim();
                double revenue = rs.getDouble("revenue");

                String weekLabel;
                try {
                    int weekNum = Integer.parseInt(weekCode.substring(4));
                    weekLabel = "Tuần " + weekNum;
                } catch (Exception e) {
                    weekLabel = weekCode;
                }

                list.add(new String[]{weekLabel, String.valueOf(revenue), weekCode});
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Chi tiết doanh thu theo tuần: map[weekCode] -> List{ productName, qty, revenueRounded }
     */
    public Map<String, List<String[]>> getWeeklyRevenueDetails() {
        Map<String, List<String[]>> map = new LinkedHashMap<>();

        String sql = """
            SELECT 
                CAST(YEARWEEK(o.created_at, 1) AS CHAR) AS week_code,
                p.name AS product_name,
                SUM(d.quantity) AS total_qty,
                SUM(d.quantity * d.price) AS total_revenue
            FROM orders o
            INNER JOIN order_details d ON o.order_id = d.order_id
            INNER JOIN products p ON p.product_id = d.product_id
            WHERE o.status = 'Đã giao'
            GROUP BY week_code, p.name
            ORDER BY week_code DESC
            LIMIT 100
        """;

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                String weekCode = rs.getString("week_code").trim();
                String productName = rs.getString("product_name");
                int qty = rs.getInt("total_qty");
                double revenue = rs.getDouble("total_revenue");

                map.computeIfAbsent(weekCode, k -> new ArrayList<>())
                        .add(new String[]{
                                productName,
                                String.valueOf(qty),
                                String.format("%.0f", revenue)
                        });
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    /**
     * Tổng doanh thu (chỉ tính đơn 'Đã giao')
     */
    public double getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(total_price), 0) FROM `orders` WHERE status = 'Đã giao'";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Doanh thu hôm nay (đơn 'Đã giao')
     */
    public double getTodayRevenue() {
        String sql = "SELECT COALESCE(SUM(total_price),0) AS total FROM `orders` WHERE status = 'Đã giao' AND DATE(created_at) = CURRENT_DATE()";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble("total");
        } catch (Exception e) { e.printStackTrace(); }
        return 0.0;
    }

    /**
     * Doanh thu tháng hiện tại (đơn 'Đã giao')
     */
    public double getThisMonthRevenue() {
        String sql = "SELECT COALESCE(SUM(total_price),0) AS total FROM `orders` " +
                     "WHERE status = 'Đã giao' AND YEAR(created_at) = YEAR(CURRENT_DATE()) AND MONTH(created_at) = MONTH(CURRENT_DATE())";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble("total");
        } catch (Exception e) { e.printStackTrace(); }
        return 0.0;
    }

    /**
     * Doanh thu năm hiện tại (đơn 'Đã giao')
     */
    public double getThisYearRevenue() {
        String sql = "SELECT COALESCE(SUM(total_price),0) AS total FROM `orders` " +
                     "WHERE status = 'Đã giao' AND YEAR(created_at) = YEAR(CURRENT_DATE())";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble("total");
        } catch (Exception e) { e.printStackTrace(); }
        return 0.0;
    }

    /**
     * Doanh thu theo ngày (N ngày gần nhất)
     * Trả List<String[]>: [yyyy-MM-dd, total]
     */
    public List<String[]> getDailyRevenue(int days) {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT DATE(created_at) AS d, COALESCE(SUM(total_price),0) AS total " +
                     "FROM orders WHERE status='Đã giao' " +
                     "AND created_at >= DATE_SUB(CURRENT_DATE(), INTERVAL ? DAY) " +
                     "GROUP BY DATE(created_at) ORDER BY d ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{ rs.getDate("d").toString(), String.valueOf(rs.getDouble("total")) });
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Doanh thu theo tháng (M tháng gần nhất)
     * Trả List<String[]>: [yyyy-MM, total]
     */
    public List<String[]> getMonthlyRevenue(int monthsBack) {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT DATE_FORMAT(created_at,'%Y-%m') AS m, COALESCE(SUM(total_price),0) AS total " +
                     "FROM orders WHERE status='Đã giao' " +
                     "AND created_at >= DATE_SUB(CURRENT_DATE(), INTERVAL ? MONTH) " +
                     "GROUP BY m ORDER BY m ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, monthsBack);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new String[]{ rs.getString("m"), String.valueOf(rs.getDouble("total")) });
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Cập nhật trạng thái đơn hàng
     */
    public boolean updateOrderStatus(int orderId, String newStatus) {
        String sql = "UPDATE `orders` SET status = ? WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Chi tiết doanh thu theo tuần: mỗi phần tử [image_path, name, qty, revenue]
     */
    public List<Object[]> getRevenueDetailByWeek(String weekCode) {
        List<Object[]> list = new ArrayList<>();
        String sql = """
            SELECT p.image_path,
                   p.name,
                   SUM(d.quantity) AS total_qty,
                   SUM(d.quantity * d.price) AS total_revenue
            FROM orders o
            JOIN order_details d ON o.order_id = d.order_id
            JOIN products p ON p.product_id = d.product_id
            WHERE o.status = 'Đã giao' AND CAST(YEARWEEK(o.created_at, 1) AS CHAR) = ?
            GROUP BY p.image_path, p.name
            ORDER BY total_revenue DESC
            LIMIT 500
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, weekCode);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{
                            rs.getString("image_path"),
                            rs.getString("name"),
                            rs.getInt("total_qty"),
                            rs.getDouble("total_revenue")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Chi tiết doanh thu theo ngày yyyy-MM-dd: mỗi phần tử [image_path, name, qty, revenue]
     */
    public List<Object[]> getRevenueDetailByDay(String dateYmd) {
        List<Object[]> list = new ArrayList<>();
        String sql = """
            SELECT p.image_path,
                   p.name,
                   SUM(d.quantity) AS total_qty,
                   SUM(d.quantity * d.price) AS total_revenue
            FROM orders o
            JOIN order_details d ON o.order_id = d.order_id
            JOIN products p ON p.product_id = d.product_id
            WHERE o.status = 'Đã giao' AND DATE(o.created_at) = ?
            GROUP BY p.image_path, p.name
            ORDER BY total_revenue DESC
            LIMIT 500
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, dateYmd);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{
                            rs.getString("image_path"),
                            rs.getString("name"),
                            rs.getInt("total_qty"),
                            rs.getDouble("total_revenue")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Chi tiết doanh thu theo tháng yyyy-MM: mỗi phần tử [image_path, name, qty, revenue]
     */
    public List<Object[]> getRevenueDetailByMonth(String monthYm) {
        List<Object[]> list = new ArrayList<>();
        String sql = """
            SELECT p.image_path,
                   p.name,
                   SUM(d.quantity) AS total_qty,
                   SUM(d.quantity * d.price) AS total_revenue
            FROM orders o
            JOIN order_details d ON o.order_id = d.order_id
            JOIN products p ON p.product_id = d.product_id
            WHERE o.status = 'Đã giao' AND DATE_FORMAT(o.created_at,'%Y-%m') = ?
            GROUP BY p.image_path, p.name
            ORDER BY total_revenue DESC
            LIMIT 1000
        """;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, monthYm);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{
                            rs.getString("image_path"),
                            rs.getString("name"),
                            rs.getInt("total_qty"),
                            rs.getDouble("total_revenue")
                    });
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy N đơn hàng gần nhất (mọi trạng thái), sắp xếp DESC theo created_at.
     */
    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = """
            SELECT o.* FROM orders o
            ORDER BY o.created_at DESC
            LIMIT ?
        """;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapOrder(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Đếm số lượng theo trạng thái đơn hàng.
     */
    public Map<String, Integer> getOrderStatusStats() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = """
            SELECT status, COUNT(*) AS cnt
            FROM orders
            GROUP BY status
        """;
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getInt("cnt"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return map;
    }

    /**
     * Ví dụ tạo notices hệ thống: đơn bị hủy gần đây, đơn chờ duyệt quá 3 ngày...
     * Bạn có thể thay bằng truy vấn thực tế theo nhu cầu.
     */
    public List<String> getSystemNotices() {
        List<String> notices = new ArrayList<>();
        // Đơn hủy trong 7 ngày gần đây
        String sqlCanceled = """
            SELECT COUNT(*) FROM orders
            WHERE status = 'Đã hủy'
              AND created_at >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
        """;
        // Đơn chờ duyệt hơn 3 ngày
        String sqlPendingLong = """
            SELECT COUNT(*) FROM orders
            WHERE status = 'Chờ duyệt'
              AND created_at < DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY)
        """;
        try (Connection c = DBConnection.getConnection()) {
            try (PreparedStatement ps = c.prepareStatement(sqlCanceled);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    notices.add("Có " + rs.getInt(1) + " đơn đã hủy trong 7 ngày gần đây.");
                }
            }
            try (PreparedStatement ps = c.prepareStatement(sqlPendingLong);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    notices.add("Có " + rs.getInt(1) + " đơn 'Chờ duyệt' quá 3 ngày.");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return notices;
    }

    /**
     * Doanh thu theo danh mục (dựa trên đơn 'Đã giao').
     * Trả về List<String[]>: [category_name, total_revenue]
     */
    public List<String[]> getRevenueByCategory() {
        List<String[]> list = new ArrayList<>();
        String sql = """
            SELECT c.name AS category_name,
                   COALESCE(SUM(d.quantity * d.price), 0) AS total
            FROM orders o
            JOIN order_details d ON o.order_id = d.order_id
            JOIN products p ON p.product_id = d.product_id
            JOIN categories c ON c.category_id = p.category_id
            WHERE o.status = 'Đã giao'
            GROUP BY c.name
            ORDER BY total DESC
        """;
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new String[]{ rs.getString("category_name"), String.valueOf(rs.getDouble("total")) });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    // ===== tiện ích =====
    private static String nvl(String s) {
        return (s == null) ? "" : s;
    }

    private static String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static void setNullableString(PreparedStatement ps, int idx, String value) throws SQLException {
        String v = trimToNull(value);
        if (v == null) ps.setNull(idx, Types.VARCHAR);
        else ps.setString(idx, v);
    }
    
}