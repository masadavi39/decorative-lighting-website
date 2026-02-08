package controller;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.ProductReview;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminReviewServlet", urlPatterns = {"/admin/reviews"})
public class AdminReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    private boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        User u = (User) session.getAttribute("user");
        return (u != null && "admin".equalsIgnoreCase(u.getRole()));
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            // CHUYỂN HƯỚNG: yêu cầu đăng nhập
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String detailId = req.getParameter("detail");
        if (detailId != null) {
            try {
                int rid = Integer.parseInt(detailId);
                ProductReview rv = reviewDAO.getReviewById(rid);
                if (rv == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/reviews?notfound=1");
                    return;
                }
                req.setAttribute("review", rv);
                req.setAttribute("activeMenu", "reviews");
                req.getRequestDispatcher("/admin/admin_review_detail.jsp").forward(req, resp);
                return;
            } catch (NumberFormatException e) {
                resp.sendRedirect(req.getContextPath() + "/admin/reviews?invalid=1");
                return;
            }
        }

        String keyword = req.getParameter("keyword");
        String productIdStr = req.getParameter("productId");
        String approvedStr = req.getParameter("approved");
        int page = parseIntOr(req.getParameter("page"), 1);
        int pageSize = 10;

        Integer productId = null;
        if (productIdStr != null && !productIdStr.isBlank()) {
            try { productId = Integer.valueOf(productIdStr); } catch (NumberFormatException ignored) {}
        }
        Boolean approved = null;
        if (approvedStr != null && !approvedStr.isBlank()) {
            if ("1".equals(approvedStr)) approved = true;
            else if ("0".equals(approvedStr)) approved = false;
        }

        List<ProductReview> reviews = reviewDAO.getReviewsPaged(keyword, productId, approved, page, pageSize);
        int total = reviewDAO.countReviews(keyword, productId, approved);
        int totalPages = (int)Math.ceil(total / (double)pageSize);

        req.setAttribute("reviews", reviews);
        req.setAttribute("keyword", keyword);
        req.setAttribute("productId", productIdStr);
        req.setAttribute("approvedVal", approvedStr);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("activeMenu", "reviews");

        req.getRequestDispatcher("/admin/admin_reviews.jsp").forward(req, resp);
    }

    private int parseIntOr(String v, int def){
        if(v == null) return def;
        try { return Integer.parseInt(v); } catch (NumberFormatException e){ return def; }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        if ("approve".equals(action)) {
            String reviewIdStr = req.getParameter("productReviewId");
            String approvedStr = req.getParameter("approved");
            try {
                int rid = Integer.parseInt(reviewIdStr);
                boolean approved = "1".equals(approvedStr) || "true".equalsIgnoreCase(approvedStr);
                reviewDAO.approveReview(rid, approved);
                resp.sendRedirect(req.getContextPath() + "/admin/reviews?detail=" + rid + "&done=1");
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/reviews?error=approve");
            }
        } else if ("reply".equals(action)) {
            String reviewIdStr = req.getParameter("productReviewId");
            String content = req.getParameter("replyContent");
            User u = (User) session.getAttribute("user");
            Integer userId = (u != null) ? u.getId() : null;

            if (userId == null) {
                resp.sendRedirect(req.getContextPath() + "/auth?action=login");
                return;
            }
            try {
                int rid = Integer.parseInt(reviewIdStr);
                if (content == null || content.isBlank()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/reviews?detail=" + rid + "&empty=1");
                    return;
                }
                reviewDAO.addReply(rid, userId, content.trim());
                resp.sendRedirect(req.getContextPath() + "/admin/reviews?detail=" + rid + "&replied=1");
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/reviews?error=reply");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/reviews?unknown=1");
        }
    }
}