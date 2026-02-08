package controller;

import dao.CouponDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * Áp dụng coupon: validate theo subtotal, lưu trạng thái vào session.
 * POST /coupon/apply với params:
 * - code: mã coupon
 * - subtotal: tổng tạm tính hiện tại (double)
 * - redirect: URL để quay lại (optional). Nếu request là AJAX (X-Requested-With: XMLHttpRequest) sẽ trả JSON thay vì redirect.
 */
@WebServlet(name="CouponServlet", urlPatterns={"/coupon/apply"})
public class CouponServlet extends HttpServlet {

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = trim(req.getParameter("code"));
        double subtotal = parseDouble(req.getParameter("subtotal"), 0);

        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendError(400,"Session không tồn tại"); return; }

        boolean valid;
        double discount;
        String message;

        if (code == null || code.isEmpty()) {
            valid = false;
            discount = 0;
            message = "Vui lòng nhập mã coupon.";
        } else {
            try {
                CouponDAO dao = new CouponDAO();
                CouponDAO.Preview preview = dao.validatePreview(code, subtotal);
                valid = preview.valid;
                discount = preview.discount != null ? preview.discount : 0;
                message = preview.message != null ? preview.message : "";
            } catch (Exception e) {
                valid = false;
                discount = 0;
                message = "Lỗi áp dụng coupon: " + e.getMessage();
            }
        }

        // Lưu trạng thái vào session
        session.setAttribute("appliedCouponCode", code != null ? code : "");
        session.setAttribute("couponValid", valid);
        session.setAttribute("couponDiscount", discount);
        session.setAttribute("couponMessage", valid ? null : message);

        // Nếu là AJAX -> trả JSON
        String xr = req.getHeader("X-Requested-With");
        if (xr != null && "XMLHttpRequest".equalsIgnoreCase(xr)) {
            resp.setContentType("application/json;charset=UTF-8");
            String json = String.format("{\"valid\":%s,\"code\":\"%s\",\"discount\":%.2f,\"message\":\"%s\"}",
                    valid, escape(code), discount, escape(message));
            resp.getWriter().write(json);
            return;
        }

        // Redirect về trang trước hoặc payment_confirmed
        String redirect = trim(req.getParameter("redirect"));
        if (redirect == null || redirect.isEmpty()) {
            redirect = req.getContextPath() + "/payment_confirmed.jsp";
        }
        resp.sendRedirect(redirect);
    }

    private String trim(String s){ return s == null ? null : s.trim(); }
    private double parseDouble(String s, double def){
        try { return Double.parseDouble(s); } catch (Exception e) { return def; }
    }
    private String escape(String s){
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"");
    }
}