package controller;

import dao.OrderDAO;
import dao.OrderDetailDAO;
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

@WebServlet(name = "AdminOrderServlet", urlPatterns = "/admin/orders")
public class AdminOrderServlet extends HttpServlet {
    private final OrderDAO orderDAO = new OrderDAO();
    private final OrderDetailDAO detailDAO = new OrderDetailDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        // 🔒 Chỉ admin mới được phép truy cập
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null || action.equals("list")) {
            // 📋 Hiển thị tất cả đơn hàng
            List<Order> orders = orderDAO.getAllOrders();
            req.setAttribute("orders", orders);
            req.getRequestDispatcher("/admin/admin_orders.jsp").forward(req, resp);

        } else if (action.equals("detail")) {
            // 🔍 Xem chi tiết đơn hàng cụ thể
            int orderId = Integer.parseInt(req.getParameter("id"));
            List<OrderDetail> details = detailDAO.getDetailsByOrderId(orderId);
            req.setAttribute("details", details);
            req.setAttribute("orderId", orderId);
            req.getRequestDispatcher("/admin/admin_order_detail.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = req.getParameter("action");

        if ("updateStatus".equals(action)) {
            int orderId = Integer.parseInt(req.getParameter("orderId"));
            String newStatus = req.getParameter("status");

            boolean success = false;

            // 🔍 Lấy đơn hàng hiện tại để kiểm tra trạng thái cũ
            Order currentOrder = orderDAO.getOrderById(orderId);

            if (currentOrder != null) {
                String currentStatus = currentOrder.getStatus();

                // ✅ Nếu đang là "Chờ duyệt" → duyệt để chuyển thành "Đang giao"
                if ("Chờ duyệt".equalsIgnoreCase(currentStatus)) {
                    success = orderDAO.approveOrderByAdmin(orderId);
                } 
                // ✅ Nếu admin chọn thủ công các trạng thái khác → cập nhật bình thường
                else {
                    success = orderDAO.updateOrderStatus(orderId, newStatus);
                }
            }

            // 🔄 Gửi phản hồi về trang admin
            if (success) {
                req.setAttribute("message", "✅ Cập nhật trạng thái thành công!");
            } else {
                req.setAttribute("error", "❌ Cập nhật thất bại hoặc trạng thái không hợp lệ!");
            }

            List<Order> orders = orderDAO.getAllOrders();
            req.setAttribute("orders", orders);
            req.getRequestDispatcher("/admin/admin_orders.jsp").forward(req, resp);
        }
    }
}
