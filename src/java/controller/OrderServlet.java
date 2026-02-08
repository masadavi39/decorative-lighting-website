package controller;

import dao.OrderDAO;
import dao.OrderDetailDAO;
import dao.DBConnection;
import model.Order;
import model.OrderDetail;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "OrderServlet", urlPatterns = "/orders")
public class OrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderDetailDAO orderDetailDAO = new OrderDetailDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");

        // validateCoupon: YÊU CẦU ĐĂNG NHẬP, trả JSON (không redirect HTML)
        if ("validateCoupon".equals(action)) {
            HttpSession s = req.getSession(false);
            User u = (s != null) ? (User) s.getAttribute("user") : null;
            if (u == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write("{\"valid\":false,\"message\":\"Bạn cần đăng nhập để áp dụng mã\"}");
                return;
            }

            resp.setContentType("application/json; charset=UTF-8");
            String code = req.getParameter("code") != null ? req.getParameter("code").trim() : "";
            double subtotal = 0;
            try { subtotal = Double.parseDouble(req.getParameter("subtotal")); } catch (Exception ignore) {}
            if (code.isEmpty() || subtotal <= 0) {
                resp.getWriter().write("{\"valid\":false,\"message\":\"Thiếu mã hoặc tổng tiền không hợp lệ\"}");
                return;
            }

            String sql = "SELECT code, discount_type, value, max_discount, start_at, end_at, usage_limit, used_count, min_subtotal, active " +
                         "FROM coupons WHERE code = ? LIMIT 1";
            try (java.sql.Connection c = DBConnection.getConnection();
                 java.sql.PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, code);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        resp.getWriter().write("{\"valid\":false,\"message\":\"Mã không tồn tại\"}");
                        return;
                    }
                    boolean active = rs.getBoolean("active");
                    java.sql.Timestamp startAt = rs.getTimestamp("start_at");
                    java.sql.Timestamp endAt = rs.getTimestamp("end_at");

                    Number ul = (Number) rs.getObject("usage_limit");
                    Integer usageLimit = ul != null ? ul.intValue() : null;

                    int usedCount = rs.getInt("used_count");
                    double minSubtotal = rs.getDouble("min_subtotal");
                    String type = rs.getString("discount_type");
                    double value = rs.getDouble("value");

                    java.math.BigDecimal md = (java.math.BigDecimal) rs.getObject("max_discount");
                    Double maxDiscount = (md != null ? md.doubleValue() : null);

                    long now = System.currentTimeMillis();
                    if (!active) { resp.getWriter().write("{\"valid\":false,\"message\":\"Mã đang tắt\"}"); return; }
                    if (startAt != null && now < startAt.getTime()) { resp.getWriter().write("{\"valid\":false,\"message\":\"Mã chưa hiệu lực\"}"); return; }
                    if (endAt != null && now > endAt.getTime()) { resp.getWriter().write("{\"valid\":false,\"message\":\"Mã đã hết hạn\"}"); return; }
                    if (usageLimit != null && usedCount >= usageLimit) { resp.getWriter().write("{\"valid\":false,\"message\":\"Mã đã hết lượt dùng\"}"); return; }
                    if (subtotal < (minSubtotal <= 0 ? 0 : minSubtotal)) {
                        resp.getWriter().write("{\"valid\":false,\"message\":\"Chưa đạt tối thiểu " + (long)minSubtotal + "\"}");
                        return;
                    }

                    double discount;
                    if ("percent".equalsIgnoreCase(type)) {
                        // ROUND 2 chữ số để khớp DB
                        java.math.BigDecimal bdSub = java.math.BigDecimal.valueOf(subtotal);
                        java.math.BigDecimal bdRate = java.math.BigDecimal.valueOf(value).divide(java.math.BigDecimal.valueOf(100));
                        discount = bdSub.multiply(bdRate).setScale(2, java.math.RoundingMode.HALF_UP).doubleValue();
                        if (maxDiscount != null) discount = Math.min(discount, maxDiscount);
                    } else {
                        discount = Math.min(value, subtotal);
                        discount = java.math.BigDecimal.valueOf(discount).setScale(2, java.math.RoundingMode.HALF_UP).doubleValue();
                    }
                    double totalAfter = Math.max(0, subtotal - discount);

                    String json = new StringBuilder()
                            .append("{\"valid\":true")
                            .append(",\"code\":\"").append(code).append("\"")
                            .append(",\"type\":\"").append(type).append("\"")
                            .append(",\"value\":").append(value)
                            .append(",\"max_discount\":").append(maxDiscount == null ? "null" : maxDiscount)
                            .append(",\"min_subtotal\":").append(minSubtotal)
                            .append(",\"discount\":").append(discount)
                            .append(",\"discountedTotal\":").append(totalAfter)
                            .append(",\"message\":\"Áp dụng thành công\"}")
                            .toString();
                    resp.getWriter().write(json);
                }
            } catch (Exception e) {
                e.printStackTrace();
                resp.getWriter().write("{\"valid\":false,\"message\":\"Lỗi máy chủ\"}");
            }
            return;
        }

        // CÁC NHÁNH KHÁC: YÊU CẦU ĐĂNG NHẬP
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        if (action == null || action.equals("list")) {
            List<Order> orders = orderDAO.getOrdersByUser(user.getId());
            req.setAttribute("orders", orders);
            req.getRequestDispatcher("order_list.jsp").forward(req, resp);
        } else if (action.equals("detail")) {
            int orderId = Integer.parseInt(req.getParameter("id"));
            Order order = orderDAO.getOrderById(orderId);
            List<OrderDetail> details = orderDetailDAO.getDetailsByOrderId(orderId);

            req.setAttribute("order", order);
            req.setAttribute("details", details);
            req.getRequestDispatcher("order_detail.jsp").forward(req, resp);
        } else if (action.equals("admin")) {
            List<Order> orders = orderDAO.getAllOrders();
            req.setAttribute("orders", orders);
            req.getRequestDispatcher("admin_orders.jsp").forward(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");
        String action = req.getParameter("action");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        if ("checkout".equals(action)) {
            @SuppressWarnings("unchecked")
            Map<Integer, OrderDetail> cart = (Map<Integer, OrderDetail>) session.getAttribute("cart");
            String receiverName = param(req, "receiverName", user.getFullName() != null ? user.getFullName() : "");
            String phone = param(req, "phone", "");
            int provinceId = parseIntOrDefault(req.getParameter("provinceId"), 1);
            String address = param(req, "address", "");
            String shippingMethod = param(req, "shippingMethod", "standard");
            int paymentId = parseIntOrDefault(req.getParameter("paymentId"), 2); // 2 = COD
            String note = param(req, "note", "");
            String couponCode = param(req, "couponCode", "");

            if (cart == null || cart.isEmpty()) {
                req.setAttribute("error", "Giỏ hàng của bạn đang trống!");
                req.getRequestDispatcher("cart.jsp").forward(req, resp);
                return;
            }

            Order order = new Order();
            order.setUserId(user.getId());
            order.setPaymentId(paymentId);
            order.setReceiverName(receiverName);
            order.setPhone(phone);
            order.setProvinceId(provinceId);
            order.setAddress(address);
            order.setShippingMethod(shippingMethod);
            order.setNote(note);
            order.setCouponCode(couponCode);
            order.setStatus("Chờ duyệt");

            int orderId = orderDAO.insertWithDetails(order, cart);

            if (orderId > 0) {
                session.removeAttribute("cart");
                session.setAttribute("cartSize", 0);
                resp.sendRedirect(req.getContextPath() + "/orders?action=list&success=1");
            } else {
                req.setAttribute("error", "Đặt hàng thất bại, vui lòng thử lại!");
                req.getRequestDispatcher("cart.jsp").forward(req, resp);
            }
        } else if ("confirm".equals(action)) {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            orderDAO.updateOrderStatus(orderId, "Đã giao");
            resp.sendRedirect(req.getContextPath() + "/orders?action=list");
        } else if ("cancel".equals(action)) {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            orderDAO.updateOrderStatus(orderId, "Đã hủy");
            resp.sendRedirect(req.getContextPath() + "/orders?action=list&msg=cancelled");
        } else if ("reorder".equals(action)) {
            int oldOrderId = Integer.parseInt(req.getParameter("orderId"));
            Order oldOrder = orderDAO.getOrderById(oldOrderId);
            List<OrderDetail> oldDetails = orderDetailDAO.getDetailsByOrderId(oldOrderId);

            if (oldOrder != null && oldDetails != null && !oldDetails.isEmpty()) {
                orderDetailDAO.deleteDetailsByOrderId(oldOrderId);
                orderDAO.deleteOrder(oldOrderId);

                Order newOrder = new Order();
                newOrder.setUserId(user.getId());
                newOrder.setPaymentId(oldOrder.getPaymentId() > 0 ? oldOrder.getPaymentId() : 2);
                newOrder.setReceiverName(oldOrder.getReceiverName());
                newOrder.setPhone(oldOrder.getPhone());
                newOrder.setProvinceId(oldOrder.getProvinceId());
                newOrder.setAddress(oldOrder.getAddress());
                newOrder.setShippingMethod(oldOrder.getShippingMethod() != null ? oldOrder.getShippingMethod() : "standard");
                newOrder.setNote(oldOrder.getNote());
                newOrder.setCouponCode(oldOrder.getCouponCode());
                newOrder.setStatus("Chờ duyệt");

                int newOrderId = orderDAO.insert(newOrder);

                if (newOrderId > 0) {
                    for (OrderDetail d : oldDetails) {
                        orderDetailDAO.insertOrderDetail(newOrderId, d.getProductId(), d.getQuantity(), d.getPrice());
                    }
                    resp.sendRedirect(req.getContextPath() + "/orders?action=list&reordered=1");
                } else {
                    req.setAttribute("error", "Không thể đặt lại đơn hàng này.");
                    req.getRequestDispatcher("order_list.jsp").forward(req, resp);
                }
            } else {
                req.setAttribute("error", "Đơn hàng không tồn tại hoặc rỗng.");
                req.getRequestDispatcher("order_list.jsp").forward(req, resp);
            }
        } else if ("delete".equals(action)) {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            orderDetailDAO.deleteDetailsByOrderId(orderId);
            orderDAO.deleteOrder(orderId);
            resp.sendRedirect(req.getContextPath() + "/orders?action=list&deleted=1");
        }
    }

    private static String param(HttpServletRequest req, String name, String def) {
        String v = req.getParameter(name);
        return (v == null || v.trim().isEmpty()) ? def : v.trim();
    }

    private static int parseIntOrDefault(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }
}