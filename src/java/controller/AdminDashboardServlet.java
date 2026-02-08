package controller;

import dao.ProductDAO;
import dao.OrderDAO;
import dao.UserDAO;
import dao.CouponDAO;
import dao.ReviewDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = "/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Quyền admin (nếu muốn chặn cứng có thể thêm admin_check.jsp như cũ)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null
                || !"admin".equalsIgnoreCase(((model.User)session.getAttribute("user")).getRole())) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        OrderDAO orderDAO = new OrderDAO();
        UserDAO userDAO = new UserDAO();
        CouponDAO couponDAO = new CouponDAO();
        ReviewDAO reviewDAO = new ReviewDAO();

        // KPI
        request.setAttribute("totalProducts", productDAO.countProducts());
        request.setAttribute("totalRevenue", orderDAO.getTotalRevenue());

        // Tồn kho
        request.setAttribute("lowStockProducts", productDAO.getLowStockProducts());
        request.setAttribute("inStockProducts", productDAO.getInStockProducts());

        // Top khách hàng
        request.setAttribute("topUsers", userDAO.getTopUsers(5));

        // Đơn gần nhất
        request.setAttribute("recentOrders", orderDAO.getRecentOrders(10));

        // Thống kê trạng thái đơn hàng (Map<String, Integer>)
        request.setAttribute("orderStatusStats", orderDAO.getOrderStatusStats());

        // Bán chạy
        request.setAttribute("bestSelling", productDAO.getBestSellingProducts(8));

        // Coupon sắp hết hạn
        request.setAttribute("expiringCoupons", couponDAO.getExpiringWithinDays(7));

        // Thông báo hệ thống
        request.setAttribute("systemNotices", orderDAO.getSystemNotices());

        // Đánh giá mới nhất (8 bản ghi)
        request.setAttribute("latestReviews", reviewDAO.getReviewsPaged(null, null, null, 1, 8));

        RequestDispatcher rd = request.getRequestDispatcher("/admin/admin_dashboard.jsp");
        rd.forward(request, response);
    }
}