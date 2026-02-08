package controller;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "ReviewsServlet", urlPatterns = "/reviews")
public class ReviewsServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();
    private static final Logger LOG = Logger.getLogger(ReviewsServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing action");
            return;
        }
        switch (action) {
            case "add" -> handleAddReview(req, resp);
            case "reply" -> handleAddReply(req, resp);
            case "approve" -> handleApprove(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action");
        }
    }

    private Integer getSessionUserId(HttpSession session) {
        if (session == null) return null;
        Object v = session.getAttribute("userId");
        if (v instanceof Integer i) return i;
        Object userObj = session.getAttribute("user");
        try {
            if (userObj != null) {
                try { return (Integer) userObj.getClass().getMethod("getId").invoke(userObj); }
                catch (NoSuchMethodException e) { return (Integer) userObj.getClass().getMethod("getUserId").invoke(userObj); }
            }
        } catch (Exception ignored) {}
        return null;
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        Object u = session.getAttribute("user");
        try {
            if (u != null) {
                String role = (String) u.getClass().getMethod("getRole").invoke(u);
                return "admin".equalsIgnoreCase(role);
            }
        } catch (Exception ignored) {}
        return false;
    }

    private void handleAddReview(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        Integer userId = getSessionUserId(session);

        String productIdStr = req.getParameter("productId");
        String ratingStr    = req.getParameter("rating");
        String title        = req.getParameter("title");
        String content      = req.getParameter("content");

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }
        if (content == null || content.trim().length() < 5) {
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=invalid&reason=short");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            int rating    = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=invalid&reason=rating");
                return;
            }

            // chặn trùng theo unique (product_id, user_id)
            if (reviewDAO.hasReviewed(productId, userId)) {
                resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productId + "&rv=invalid&reason=duplicate");
                return;
            }

            boolean ok = reviewDAO.addReview(productId, userId, rating, title, content.trim());
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productId + "&rv=" + (ok ? "ok" : "fail"));
        } catch (NumberFormatException nfe) {
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=invalid&reason=parse");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=invalid&reason=exception");
        }
    }

    private void handleAddReply(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        Integer userId = getSessionUserId(session);

        String reviewIdStr  = req.getParameter("productReviewId");
        String productIdStr = req.getParameter("productId");
        String content      = req.getParameter("replyContent");

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }
        if (content == null || content.trim().length() < 2) {
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=invalid&reason=reply");
            return;
        }

        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            boolean ok = reviewDAO.addReply(reviewId, userId, content.trim());
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=" + (ok ? "ok" : "fail"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=invalid&reason=exception");
        }
    }

    private void handleApprove(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Only admin can approve");
            return;
        }
        String reviewIdStr  = req.getParameter("productReviewId");
        String productIdStr = req.getParameter("productId");
        String approvedStr  = req.getParameter("approved");
        try {
            int reviewId = Integer.parseInt(reviewIdStr);
            boolean approved = "1".equals(approvedStr) || "true".equalsIgnoreCase(approvedStr);
            boolean ok = reviewDAO.approveReview(reviewId, approved);
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=" + (ok ? "ok" : "fail"));
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/products?action=detail&id=" + productIdStr + "&rv=invalid&reason=exception");
        }
    }
}