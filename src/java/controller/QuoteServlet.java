package controller;

import dao.CouponDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import model.OrderDetail;
import model.User;
import util.PdfGenerator;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.*;

@WebServlet(name = "QuoteServlet", urlPatterns = {"/quote/*"})
public class QuoteServlet extends HttpServlet {

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { process(req, resp); }
    @Override protected void doGet (HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException { process(req, resp); }

    private void process(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendError(400, "Session không tồn tại."); return; }

        @SuppressWarnings("unchecked")
        Map<Integer, OrderDetail> cart = (Map<Integer, OrderDetail>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) { resp.sendError(400, "Giỏ hàng trống."); return; }

        User user = (User) session.getAttribute("user");

        String receiver = first(req,"receiverName","buyer_name");
        if (blank(receiver) && user != null) receiver = nz(user.getFullName());
        String phone    = first(req,"phone","buyer_tel");
        if (blank(phone) && user != null)    phone = nz(user.getPhoneNumber());
        String address  = first(req,"address","buyer_address");
        if (blank(address) && user != null)  address = nz(user.getAddress());
        String province = first(req,"provinceId","buyer_province");
        int provinceId  = parseIntOrDefault(province, user != null && user.getProvinceId()!=null ? user.getProvinceId() : 1);

        String ship     = normalizeShip(first(req,"shippingMethod","shippingMethodHidden","shippingMethodSelect"));
        String pay      = first(req,"paymentId","pay_method_display");
        int paymentId   = parseIntOrDefault(pay,2); // 1: chuyển khoản, 2: COD
        String note     = first(req,"note");
        String coupon   = first(req,"couponCode");

        Order order = new Order();
        order.setReceiverName(receiver);
        order.setPhone(phone);
        order.setAddress(address);
        order.setProvinceId(provinceId);
        order.setShippingMethod(ship);
        order.setPaymentId(paymentId);
        order.setNote(note);
        order.setCouponCode(blank(coupon) ? null : coupon.trim());

        // Dòng chi tiết & tạm tính
        List<OrderDetail> details = new ArrayList<>();
        double subtotal = 0;
        for (OrderDetail line : cart.values()) {
            OrderDetail d = new OrderDetail();
            d.setProductId(line.getProduct() != null ? line.getProduct().getId() : line.getProductId());
            d.setQuantity(line.getQuantity());
            d.setPrice(line.getPrice());
            d.setProduct(line.getProduct());
            details.add(d);
            subtotal += d.getSubtotal();
        }
        order.setOrderDetails(details);

        // Phí ship theo enum DB
        double shipFee = switch (ship) {
            case "express" -> 60000;
            case "overnight" -> 120000;
            default -> 30000;
        };
        order.setShippingFee(shipFee);

        // Thuế 10% theo DB
        double tax = Math.round(subtotal * 0.10 * 100.0) / 100.0;
        order.setTax(tax);

        // Tính giảm theo coupon (nếu có)
        double discount = 0;
        if (order.getCouponCode() != null) {
            CouponDAO dao = new CouponDAO();
            CouponDAO.CouponCalcResult r = dao.validateAndCalc(order.getCouponCode(), subtotal);
            if (r.valid) discount = r.discount;
        }
        order.setDiscountAmount(discount);

        // Tổng cộng
        order.setTotalPrice(subtotal + shipFee + tax - discount);

        boolean download = "/download".equalsIgnoreCase(req.getPathInfo());

        ByteArrayOutputStream baos = new ByteArrayOutputStream(32 * 1024);
        try {
            PdfGenerator.generateOrderPdf(order, baos, getServletContext());
        } catch (Exception e) {
            throw new ServletException("Lỗi tạo PDF", e);
        }
        byte[] bytes = baos.toByteArray();

        resp.reset();
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", (download ? "attachment" : "inline") + "; filename=\"bao_gia.pdf\"");
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);
        resp.setContentLength(bytes.length);

        try (OutputStream os = resp.getOutputStream()) {
            os.write(bytes);
            os.flush();
        }
    }

    private String first(HttpServletRequest r, String... names) {
        for (String n : names) {
            String v = r.getParameter(n);
            if (v != null && !v.trim().isEmpty()) return v.trim();
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