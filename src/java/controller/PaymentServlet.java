package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.Map;

import model.OrderDetail;

@WebServlet(name = "PaymentServlet", urlPatterns ="/payment")
public class PaymentServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // BẮT BUỘC ĐĂNG NHẬP TRƯỚC KHI VÀO THANH TOÁN
        HttpSession session = request.getSession(false);
        model.User user = (session != null) ? (model.User) session.getAttribute("user") : null;
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        // Nạp provinces vào application scope nếu chưa có
        ServletContext app = getServletContext();
        if (app.getAttribute("provinces") == null) {
            try {
                java.util.List<model.Province> plist = new dao.ProvinceDAO().getAll();
                app.setAttribute("provinces", plist);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Giữ nguyên luồng set coupon từ cart (nếu có)
        String couponCode = safeTrim(request.getParameter("couponCode"));
        request.setAttribute("appliedCouponCode", couponCode);

        @SuppressWarnings("unchecked")
        Map<Integer, OrderDetail> cart = (Map<Integer, OrderDetail>) request.getSession().getAttribute("cart");
        double subtotal = 0;
        if (cart != null) for (OrderDetail it : cart.values()) subtotal += it.getSubtotal();
        request.setAttribute("cartSubtotalServer", subtotal);

        if (couponCode != null && !couponCode.isEmpty() && subtotal > 0) {
            var preview = new dao.CouponDAO().validatePreview(couponCode, subtotal);
            request.setAttribute("couponValid", preview.valid);
            request.setAttribute("couponMessage", preview.message);
            request.setAttribute("couponDiscount", preview.discount != null ? preview.discount : 0d);
            request.setAttribute("discountedTotal", preview.discountedTotal != null ? preview.discountedTotal : subtotal);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("payment_confirmed.jsp");
        dispatcher.forward(request, response);
    }

    private static String safeTrim(String s) { if (s==null) return null; String t=s.trim(); return t.isEmpty()?null:t; }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException { doGet(request, response); }
}