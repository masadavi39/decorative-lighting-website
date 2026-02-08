package controller;

import dao.CouponDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.OrderDetail;
import model.User;

import java.io.IOException;
import java.util.*;

@WebServlet(name="InvoiceServlet", urlPatterns={"/invoice/print"})
public class InvoiceServlet extends HttpServlet {

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { render(req,resp); }
    @Override protected void doGet (HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { render(req,resp); }

    private void render(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendError(400,"Session không tồn tại"); return; }

        @SuppressWarnings("unchecked")
        Map<Integer, OrderDetail> cart = (Map<Integer, OrderDetail>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) { resp.sendError(400,"Giỏ hàng trống"); return; }

        User user = (User) session.getAttribute("user");

        String receiver = param(req,"receiverName","buyer_name");
        if (blank(receiver) && user != null) receiver = nz(user.getFullName());
        String phone    = param(req,"phone","buyer_tel");
        if (blank(phone) && user != null)    phone = nz(user.getPhoneNumber());
        String address  = param(req,"address","buyer_address");
        if (blank(address) && user != null)  address = nz(user.getAddress());

        String province = param(req,"provinceId","buyer_province");
        int provinceId  = parseIntOrDefault(province, user != null && user.getProvinceId()!=null ? user.getProvinceId() : 1);

        String ship   = normalizeShip(param(req,"shippingMethod","shippingMethodHidden","shippingMethodSelect"));
        String note   = param(req,"note");
        String coupon = param(req,"couponCode");

        req.setAttribute("inv_receiver", receiver);
        req.setAttribute("inv_phone",    phone);
        req.setAttribute("inv_address",  address);
        req.setAttribute("inv_note",     note);
        req.setAttribute("inv_coupon",   coupon);
        req.setAttribute("inv_method",   ship);

        // Hàng hóa
        List<OrderDetail> lines = new ArrayList<>();
        double subtotal = 0;
        for (OrderDetail c : cart.values()) {
            OrderDetail d = new OrderDetail();
            d.setProductId(c.getProduct() != null ? c.getProduct().getId() : c.getProductId());
            d.setQuantity(c.getQuantity());
            d.setPrice(c.getPrice());
            d.setProduct(c.getProduct());
            subtotal += d.getSubtotal();
            lines.add(d);
        }
        req.setAttribute("inv_items", lines);
        req.setAttribute("inv_subtotal", subtotal);

        // Thuế 10% (như DB)
        double tax = Math.round(subtotal * 0.10 * 100.0)/100.0;

        // Phí ship theo enum DB
        double shipFee = switch (ship) {
            case "express" -> 60000;
            case "overnight" -> 120000;
            default -> 30000;
        };

        // Tính giảm theo coupon (nếu hợp lệ)
        double discount = 0;
        if (!blank(coupon)) {
            CouponDAO dao = new CouponDAO();
            CouponDAO.CouponCalcResult r = dao.validateAndCalc(coupon.trim(), subtotal);
            if (r.valid) discount = r.discount;
        }
        req.setAttribute("inv_tax", tax);
        req.setAttribute("inv_ship", shipFee);
        req.setAttribute("inv_discount", discount);

        double total = subtotal + tax + shipFee - discount;
        req.setAttribute("inv_total", total);

        req.getRequestDispatcher("/WEB-INF/views/invoice_print.jsp").forward(req, resp);
    }

    private String param(HttpServletRequest r, String... names){
        for(String n: names){
            String v = r.getParameter(n);
            if(v!=null && !v.trim().isEmpty()) return v.trim();
        }
        return "";
    }
    private boolean blank(String s){ return s == null || s.trim().isEmpty(); }
    private String nz(String s){ return s == null ? "" : s; }
    private int parseIntOrDefault(String s, int def){ try { return Integer.parseInt(s); } catch(Exception e){ return def; } }
    private String normalizeShip(String ship) {
        if (ship == null) return "standard";
        ship = ship.trim().toLowerCase(Locale.ROOT);
        return switch (ship) {
            case "express", "overnight", "standard" -> ship;
            default -> "standard";
        };
    }
}