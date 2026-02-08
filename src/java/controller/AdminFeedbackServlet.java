package controller;

import dao.FeedbackDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import model.Feedback;

@WebServlet(name = "AdminFeedbackServlet", urlPatterns = {"/admin/feedbacks"})
public class AdminFeedbackServlet extends HttpServlet {

    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền admin
        HttpSession session = req.getSession();
        model.User user = (model.User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        // Lấy danh sách feedback
        List<Feedback> feedbacks = feedbackDAO.getAll();
        req.setAttribute("feedbacks", feedbacks);

        // Forward tới JSP
        req.getRequestDispatcher("/admin/admin_feedback.jsp").forward(req, resp);
    }
}