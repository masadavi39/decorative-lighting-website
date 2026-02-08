package controller;

import dao.UserDAO;
import dao.EmailOtpDAO;
import model.User;
import model.EmailOTP;
import util.EmailUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

@WebServlet(name = "AuthServlet", urlPatterns = "/auth")
public class AuthServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    // ========================== GET ==========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        switch (action != null ? action : "") {
            case "sendOtp":
                handleSendOtp(req, resp);
                break;
            case "register":
                req.getRequestDispatcher("register.jsp").forward(req, resp);
                break;
            case "logout":
                handleLogout(req, resp);
                break;
            case "reset-password":
                handleResetPasswordGet(req, resp);
                break;
            default:
                req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }

    private void handleResetPasswordGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String token = req.getParameter("token");
        if (token == null || token.isEmpty()) {
            req.setAttribute("message", "❌ Token không hợp lệ!");
            req.setAttribute("messageType", "error");
        } else {
            req.setAttribute("token", token);
        }
        req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
    }

    // ========================== POST ==========================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");

        switch (action != null ? action : "") {
            case "register":
                handleRegister(req, resp);
                break;
            case "login":
                handleLogin(req, resp);
                break;
            case "forgot-password":
                handleForgotPassword(req, resp);
                break;
            case "reset-password":
                handleResetPasswordPost(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/auth?action=login");
        }
    }

    // ========================== LOGIN ==========================
    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        boolean remember = "true".equals(req.getParameter("remember"));

        User user = userDAO.login(email, password);
        if (user != null) {
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);

            // NEW: ghi nhận thời điểm đăng nhập gần nhất
            try {
                userDAO.markLastLogin(user.getId());
            } catch (Exception e) {
                // log nhẹ, không chặn đăng nhập
                e.printStackTrace();
            }

            if (remember) {
                try {
                    String token = UUID.randomUUID().toString();
                    LocalDateTime expireAt = LocalDateTime.now().plusDays(14);
                    userDAO.saveRememberToken(user.getId(), token, expireAt);

                    Cookie cookie = new Cookie("remember_token", token);
                    cookie.setHttpOnly(true);
                    cookie.setMaxAge(14 * 24 * 60 * 60);
                    cookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
                    resp.addCookie(cookie);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            String redirectUrl = "user".equalsIgnoreCase(user.getRole())
                    ? "/products?action=list"
                    : "/admin/products?action=list";
            resp.sendRedirect(req.getContextPath() + redirectUrl);

        } else {
            req.setAttribute("error", "❌ Sai email hoặc mật khẩu!");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }

    // ========================== LOGOUT ==========================
    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        Cookie cookie = new Cookie("remember_token", "");
        cookie.setMaxAge(0);
        cookie.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
        resp.addCookie(cookie);

        resp.sendRedirect(req.getContextPath() + "/auth?action=login");
    }

    // ========================== REGISTER / OTP ==========================
    private void handleSendOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String email = req.getParameter("email");
        resp.setContentType("text/plain;charset=UTF-8");

        if (email == null || email.isEmpty()) {
            resp.getWriter().write("❌ Email không hợp lệ!");
            return;
        }

        try {
            String otpCode = String.valueOf((int) (Math.random() * 900000) + 100000);
            LocalDateTime expireAt = LocalDateTime.now().plusMinutes(5);

            EmailOTP otp = new EmailOTP(email, otpCode, expireAt);
            EmailOtpDAO otpDAO = new EmailOtpDAO(userDAO.getConnection());
            otpDAO.saveOTP(otp);

            EmailUtil.sendEmail(email, "Mã xác thực OTP",
                    "Mã OTP của bạn là: " + otpCode + "\nMã có hiệu lực trong 5 phút.", true);

            resp.getWriter().write("✅ OTP đã gửi tới email " + email);
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("❌ Gửi OTP thất bại!");
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String otpInput = req.getParameter("otp");

        try {
            EmailOtpDAO otpDAO = new EmailOtpDAO(userDAO.getConnection());
            if (!otpDAO.verifyOTP(email, otpInput)) {
                req.setAttribute("error", "❌ Mã OTP không hợp lệ hoặc đã hết hạn!");
                req.getRequestDispatcher("register.jsp").forward(req, resp);
                return;
            }

            User u = new User(fullName, email, password, "user", null);
            if (userDAO.register(u)) {
                otpDAO.deleteOTP(email);
                resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            } else {
                req.setAttribute("error", "Đăng ký thất bại. Vui lòng thử lại.");
                req.getRequestDispatcher("register.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Đăng ký thất bại. Vui lòng thử lại.");
            req.getRequestDispatcher("register.jsp").forward(req, resp);
        }
    }

    // ========================== FORGOT PASSWORD ==========================
    private void handleForgotPassword(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        User user = userDAO.findByEmail(email);

        if (user == null) {
            req.setAttribute("message", "❌ Email chưa đăng ký!");
            req.setAttribute("messageType", "error");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
            return;
        }

        try {
            String token = UUID.randomUUID().toString();
            LocalDateTime expireAt = LocalDateTime.now().plusHours(1);
            userDAO.saveResetToken(user.getId(), token);

            // ✅ Link đầy đủ, đảm bảo không bị lỗi context path
            String resetLink = req.getRequestURL().toString()
                    .replaceAll("\\?.*$", "")
                    + "?action=reset-password&token=" + token;

            EmailUtil.sendEmail(email, "Đặt lại mật khẩu", resetLink, false);

            req.setAttribute("message", "✅ Liên kết đặt lại mật khẩu đã được gửi tới email!");
            req.setAttribute("messageType", "success");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("message", "❌ Gửi email thất bại!");
            req.setAttribute("messageType", "error");
            req.getRequestDispatcher("forgot_password.jsp").forward(req, resp);
        }
    }

    // ========================== RESET PASSWORD ==========================
    private void handleResetPasswordPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String token = req.getParameter("token");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirm_password");

        if (token == null || token.isEmpty()) {
            req.setAttribute("message", "❌ Token không hợp lệ!");
            req.setAttribute("messageType", "error");
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        if (password == null || !password.equals(confirm)) {
            req.setAttribute("message", "❌ Mật khẩu không khớp!");
            req.setAttribute("messageType", "error");
            req.setAttribute("token", token);
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.findByResetToken(token);
            if (user == null) {
                req.setAttribute("message", "❌ Token hết hạn hoặc không hợp lệ!");
                req.setAttribute("messageType", "error");
                req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
                return;
            }

            userDAO.updatePassword(user.getId(), password);
            userDAO.deleteResetToken(token);

            req.setAttribute("message", "✅ Đặt lại mật khẩu thành công!");
            req.setAttribute("messageType", "success");
            req.getRequestDispatcher("login.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("message", "❌ Cập nhật mật khẩu thất bại!");
            req.setAttribute("messageType", "error");
            req.setAttribute("token", token);
            req.getRequestDispatcher("reset_password.jsp").forward(req, resp);
        }
    }
}