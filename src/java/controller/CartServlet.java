package controller;

import dao.ProductDAO;
import model.OrderDetail;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "CartServlet", urlPatterns = "/cart")
public class CartServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Tính subtotal để hiển thị nếu cần
        HttpSession session = req.getSession(false);
        if (session != null) {
            @SuppressWarnings("unchecked")
            Map<Integer, OrderDetail> cart = (Map<Integer, OrderDetail>) session.getAttribute("cart");
            double subtotal = 0;
            if (cart != null) {
                for (OrderDetail od : cart.values()) {
                    subtotal += od.getSubtotal();
                }
            }
            req.setAttribute("cartSubtotal", subtotal);
            session.setAttribute("cartSubtotalServer", subtotal);
        }
        req.getRequestDispatcher("cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(true);

        @SuppressWarnings("unchecked")
        Map<Integer, OrderDetail> cart = (Map<Integer, OrderDetail>) session.getAttribute("cart");
        if (cart == null) {
            cart = new HashMap<>();
        }

        String action = req.getParameter("action");
        boolean success = false;
        String message = "";
        int cartCount = 0;

        try {
            if ("add".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity = Integer.parseInt(req.getParameter("quantity"));
                Product product = productDAO.getProductById(productId);

                if (product != null) {
                    OrderDetail line = cart.get(productId);
                    if (line == null) {
                        line = new OrderDetail();
                        line.setProduct(product);
                        line.setProductId(product.getId());
                        line.setQuantity(quantity);
                        line.setPrice(product.getPrice());
                    } else {
                        line.setQuantity(line.getQuantity() + quantity);
                        // Nếu muốn đồng bộ giá mới nhất từ DB mỗi lần thêm:
                        // line.setPrice(product.getPrice());
                    }
                    cart.put(productId, line);
                    success = true;
                    message = "Đã thêm sản phẩm vào giỏ hàng";
                } else {
                    message = "Không tìm thấy sản phẩm";
                }

            } else if ("update".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                int quantity = Integer.parseInt(req.getParameter("quantity"));
                OrderDetail line = cart.get(productId);
                if (line != null) {
                    if (quantity <= 0) {
                        cart.remove(productId);
                        message = "Đã xóa sản phẩm khỏi giỏ hàng";
                    } else {
                        line.setQuantity(quantity);
                        message = "Đã cập nhật số lượng";
                    }
                    success = true;
                } else {
                    message = "Không tìm thấy sản phẩm trong giỏ hàng";
                }

            } else if ("remove".equals(action)) {
                int productId = Integer.parseInt(req.getParameter("productId"));
                if (cart.containsKey(productId)) {
                    cart.remove(productId);
                    success = true;
                    message = "Đã xóa sản phẩm khỏi giỏ hàng";
                } else {
                    message = "Không tìm thấy sản phẩm trong giỏ hàng";
                }

            } else if ("bulkUpdate".equals(action)) {
                for (String key : req.getParameterMap().keySet()) {
                    if (key.startsWith("quantity_")) {
                        int productId = Integer.parseInt(key.substring(9)); // "quantity_"
                        int quantity = Integer.parseInt(req.getParameter(key));
                        OrderDetail line = cart.get(productId);
                        if (line != null) {
                            if (quantity <= 0) {
                                cart.remove(productId);
                            } else {
                                line.setQuantity(quantity);
                            }
                        }
                    }
                }
                success = true;
                message = "Đã cập nhật số lượng sản phẩm";

            } else if ("clear".equals(action)) {
                cart.clear();
                success = true;
                message = "Đã xóa toàn bộ giỏ hàng";
            }

        } catch (NumberFormatException e) {
            message = "Dữ liệu không hợp lệ";
            e.printStackTrace();
        } catch (Exception e) {
            message = "Có lỗi xảy ra: " + e.getMessage();
            e.printStackTrace();
        }

        // Tính tổng số lượng trong giỏ (đếm theo quantity)
        cartCount = cart.values().stream().mapToInt(OrderDetail::getQuantity).sum();

        // Tính subtotal để dùng ở payment_confirmed/invoice/quote
        double subtotal = cart.values().stream().mapToDouble(OrderDetail::getSubtotal).sum();

        // Cập nhật session
        session.setAttribute("cart", cart);
        session.setAttribute("cartSize", cartCount);         // tổng số lượng
        session.setAttribute("cartDistinct", cart.size());   // số mặt hàng khác nhau
        session.setAttribute("cartSubtotalServer", subtotal);

        // Nếu là AJAX
        if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
            resp.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = resp.getWriter()) {
                out.write(String.format(
                        "{\"success\": %s, \"message\": \"%s\", \"cartCount\": %d, \"cartDistinct\": %d, \"subtotal\": %.2f}",
                        success, escapeJson(message), cartCount, cart.size(), subtotal
                ));
            }
            return;
        }

        // Nếu là request bình thường, redirect về lại trang trước
        String referer = req.getHeader("referer");
        if (referer != null && !referer.isEmpty()) {
            resp.sendRedirect(referer);
        } else {
            resp.sendRedirect(req.getContextPath() + "/cart.jsp");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\"","\\\"");
    }
}