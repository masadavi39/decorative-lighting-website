package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;
import java.sql.SQLException;
import java.util.regex.Pattern;

/**
 * ProfileServlet: cập nhật hồ sơ user theo các cột hiện có trong database (users).
 */
@WebServlet(name = "ProfileServlet", urlPatterns = "/profile")
public class ProfileServlet extends HttpServlet {

    private static final Pattern EMAIL_RE =
            Pattern.compile("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", Pattern.CASE_INSENSITIVE);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }
        request.setAttribute("user", user);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User sessionUser = (User) request.getSession().getAttribute("user");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/auth?action=login");
            return;
        }

        // Lấy form fields
        String fullName       = safeTrim(request.getParameter("fullName"));
        String email          = safeTrim(request.getParameter("email"));
        String password       = safeTrim(request.getParameter("password"));
        String confirmPassword= safeTrim(request.getParameter("confirmPassword"));

        String phoneNumber    = safeTrim(request.getParameter("phoneNumber"));
        String address        = safeTrim(request.getParameter("address"));
        String provinceRaw    = safeTrim(request.getParameter("provinceId"));
        Integer provinceId    = parseIntOrNull(provinceRaw);

        String companyName    = safeTrim(request.getParameter("companyName"));
        String taxCode        = safeTrim(request.getParameter("taxCode"));
        String taxEmail       = safeTrim(request.getParameter("taxEmail"));

        // User để hiển thị lại khi lỗi
        User viewUser = new User(
                sessionUser.getId(),
                fullName != null ? fullName : sessionUser.getFullName(),
                email != null ? email : sessionUser.getEmail(),
                sessionUser.getPassword(),
                sessionUser.getRole(),
                phoneNumber != null ? phoneNumber : sessionUser.getPhoneNumber()
        );
        viewUser.setAddress(address != null ? address : sessionUser.getAddress());
        viewUser.setProvinceId(provinceId != null ? provinceId : sessionUser.getProvinceId());
        viewUser.setCompanyName(companyName != null ? companyName : sessionUser.getCompanyName());
        viewUser.setTaxCode(taxCode != null ? taxCode : sessionUser.getTaxCode());
        viewUser.setTaxEmail(taxEmail != null ? taxEmail : sessionUser.getTaxEmail());

        // Validate
        if (isBlank(fullName)) {
            forwardError("Vui lòng nhập tên hiển thị.", viewUser, request, response);
            return;
        }
        if (isBlank(email) || !EMAIL_RE.matcher(email).matches()) {
            forwardError("Email không hợp lệ.", viewUser, request, response);
            return;
        }

        boolean changePassword = !isBlank(password) || !isBlank(confirmPassword);
        if (changePassword) {
            if (!password.equals(confirmPassword)) {
                forwardError("Mật khẩu nhập lại không khớp.", viewUser, request, response);
                return;
            }
            if (password.length() < 6 || password.length() > 32) {
                forwardError("Mật khẩu phải từ 6 đến 32 ký tự.", viewUser, request, response);
                return;
            }
        }

        if (!isBlank(taxEmail) && !EMAIL_RE.matcher(taxEmail).matches()) {
            forwardError("Email hóa đơn không hợp lệ.", viewUser, request, response);
            return;
        }

        UserDAO dao = new UserDAO();
        try {
            if (dao.emailExistsForOther(sessionUser.getId(), email)) {
                forwardError("Email đã được sử dụng bởi tài khoản khác.", viewUser, request, response);
                return;
            }

            boolean ok = dao.updateUserProfile(
                    sessionUser.getId(),
                    fullName,
                    email,
                    changePassword ? password : null,
                    phoneNumber,
                    address,
                    provinceId,
                    companyName,
                    taxCode,
                    taxEmail
            );
            if (!ok) {
                forwardError("Cập nhật không thành công. Vui lòng thử lại.", viewUser, request, response);
                return;
            }

            // Update session user
            sessionUser.setFullName(fullName);
            sessionUser.setEmail(email);
            if (changePassword) sessionUser.setPassword(password);
            sessionUser.setPhoneNumber(phoneNumber);
            sessionUser.setAddress(address);
            sessionUser.setProvinceId(provinceId);
            sessionUser.setCompanyName(companyName);
            sessionUser.setTaxCode(taxCode);
            sessionUser.setTaxEmail(taxEmail);
            request.getSession().setAttribute("user", sessionUser);

            request.setAttribute("success", "Cập nhật thành công!");
            request.setAttribute("user", sessionUser);
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
        } catch (SQLException e) {
            forwardError("Có lỗi khi cập nhật: " + e.getMessage(), viewUser, request, response);
        }
    }

    private void forwardError(String msg, User viewUser,
                              HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.setAttribute("user", viewUser);
        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    private static boolean isBlank(String s) { return s == null || s.trim().isEmpty(); }
    private static String safeTrim(String s) { return s == null ? null : s.trim(); }
    private static Integer parseIntOrNull(String s) {
        if (isBlank(s)) return null;
        try { return Integer.parseInt(s); } catch (NumberFormatException e) { return null; }
    }
}