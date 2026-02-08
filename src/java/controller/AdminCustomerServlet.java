package controller;

import dao.OrderDAO;
import dao.UserDAO;
import model.Order;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "AdminCustomerServlet", urlPatterns = "/admin/customers")
public class AdminCustomerServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Kiểm tra quyền admin
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        // Lấy tất cả users và lọc role 'user'
        List<User> customers = userDAO.getAllUsers().stream()
                .filter(u -> "user".equalsIgnoreCase(u.getRole()))
                .collect(Collectors.toList());

        // (Phân trang nếu đã thêm trước đó)
        int page = parseIntOrDefault(req.getParameter("page"), 1);
        int pageSize = parseIntOrDefault(req.getParameter("pageSize"), 10);
        int totalItems = customers.size();
        int totalPages = (int) Math.ceil(totalItems / (double) pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;
        int fromIndex = Math.max(0, (page - 1) * pageSize);
        int toIndex = Math.min(totalItems, fromIndex + pageSize);
        List<User> pageCustomers = customers.subList(fromIndex, toIndex);

        Map<Integer, List<Order>> ordersByUser = new HashMap<>();
        for (User u : pageCustomers) {
            ordersByUser.put(u.getId(), orderDAO.getOrdersByUser(u.getId()));
        }

        req.setAttribute("users", pageCustomers);
        req.setAttribute("ordersByUser", ordersByUser);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalItems", totalItems);

        req.getRequestDispatcher("/admin/admin_customers.jsp").forward(req, resp);
    }

    private int parseIntOrDefault(String s, int def) {
        try { return (s == null || s.isBlank()) ? def : Integer.parseInt(s); }
        catch (Exception e) { return def; }
    }
}