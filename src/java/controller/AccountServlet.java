package controller;

import dao.UserDAO;
import dao.ProvinceDAO;
import model.User;
import model.Province;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/admin/account")
public class AccountServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ProvinceDAO provinceDAO = new ProvinceDAO();

    private boolean isAdmin(HttpSession session) {
        if (session == null) return false;
        Object o = session.getAttribute("user");
        if (o instanceof User) {
            return "admin".equalsIgnoreCase(((User) o).getRole());
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = nvl(req.getParameter("action"));

        if ("export".equalsIgnoreCase(action)) {
            handleExportCsv(req, resp);
            return;
        }

        if ("detail".equalsIgnoreCase(action)) {
            int id = parseIntOrDefault(req.getParameter("id"), 0);
            User u = id > 0 ? userDAO.getUserById(id) : null;
            if (u == null) {
                req.setAttribute("message", "Không tìm thấy tài khoản!");
                loadUserList(req);
                req.getRequestDispatcher("/admin/admin_account.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("userDetail", u);
            req.setAttribute("provinces", provinceDAO.getAll());
            req.getRequestDispatcher("/admin/admin_account_detail.jsp").forward(req, resp);
            return;
        }

        if ("edit".equalsIgnoreCase(action)) {
            int id = parseIntOrDefault(req.getParameter("id"), 0);
            User u = id > 0 ? userDAO.getUserById(id) : null;
            if (u == null) {
                req.setAttribute("message", "Không tìm thấy tài khoản để sửa!");
                loadUserList(req);
                req.getRequestDispatcher("/admin/admin_account.jsp").forward(req, resp);
                return;
            }
            req.setAttribute("userEdit", u);
            req.setAttribute("provinces", provinceDAO.getAll());
            req.getRequestDispatcher("/admin/admin_account_edit.jsp").forward(req, resp);
            return;
        }

        // Danh sách + lọc + phân trang
        loadUserList(req);
        req.getRequestDispatcher("/admin/admin_account.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (!isAdmin(session)) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = nvl(req.getParameter("action"));
        String message;

        try {
            switch (action) {
                case "delete": {
                    int id = parseIntOrDefault(req.getParameter("id"), 0);
                    boolean ok = (id > 0) && userDAO.deleteUser(id);
                    message = ok ? "Xóa thành công" : "Xóa thất bại";
                    break;
                }
                case "toggleRole": {
                    int id = parseIntOrDefault(req.getParameter("id"), 0);
                    User user = (id > 0) ? userDAO.getUserById(id) : null;
                    if (user != null) {
                        String newRole = "admin".equalsIgnoreCase(user.getRole()) ? "user" : "admin";
                        boolean ok = userDAO.changeUserRole(id, newRole);
                        message = ok ? "Đổi vai trò thành công" : "Không đổi được vai trò";
                    } else {
                        message = "Không tìm thấy tài khoản!";
                    }
                    break;
                }
                case "lock": {
                    int id = parseIntOrDefault(req.getParameter("id"), 0);
                    boolean ok = (id > 0) && userDAO.updateLockStatus(id, true);
                    message = ok ? "Đã khóa tài khoản" : "Khóa tài khoản thất bại";
                    break;
                }
                case "unlock": {
                    int id = parseIntOrDefault(req.getParameter("id"), 0);
                    boolean ok = (id > 0) && userDAO.updateLockStatus(id, false);
                    message = ok ? "Đã mở khóa tài khoản" : "Mở khóa tài khoản thất bại";
                    break;
                }
                case "update": {
                    int id = parseIntOrDefault(req.getParameter("id"), 0);
                    User current = (id > 0) ? userDAO.getUserById(id) : null;
                    if (current == null) {
                        message = "Không tìm thấy tài khoản để cập nhật!";
                        break;
                    }
                    String fullName = nvl(req.getParameter("fullName"));
                    String email = nvl(req.getParameter("email"));
                    String newPassword = nvl(req.getParameter("password")); // rỗng = giữ nguyên
                    String phone = nvl(req.getParameter("phoneNumber"));
                    String address = nvl(req.getParameter("address"));
                    Integer provinceId = parseNullableInt(req.getParameter("provinceId"));
                    String companyName = nvl(req.getParameter("companyName"));
                    String taxCode = nvl(req.getParameter("taxCode"));
                    String taxEmail = nvl(req.getParameter("taxEmail"));
                    String role = nvl(req.getParameter("role"));
                    boolean locked = "on".equalsIgnoreCase(nvl(req.getParameter("locked")));

                    // Validate email unique
                    if (email.isEmpty()) {
                        message = "Email không được để trống!";
                        break;
                    }
                    if (userDAO.emailExistsForOther(id, email)) {
                        message = "Email đã tồn tại cho tài khoản khác!";
                        req.setAttribute("error", message);
                        // Back to edit with entered values
                        User edited = new User(id, fullName, email, current.getPassword(), current.getRole(), phone);
                        edited.setAddress(address);
                        edited.setProvinceId(provinceId);
                        edited.setCompanyName(companyName);
                        edited.setTaxCode(taxCode);
                        edited.setTaxEmail(taxEmail);
                        req.setAttribute("userEdit", edited);
                        req.setAttribute("provinces", provinceDAO.getAll());
                        req.getRequestDispatcher("/admin/admin_account_edit.jsp").forward(req, resp);
                        return;
                    }

                    // Update profile (password optional)
                    boolean ok = userDAO.updateUserProfile(
                            id, fullName, email, newPassword.isEmpty() ? null : newPassword,
                            phone, address, provinceId, companyName, taxCode, taxEmail
                    );

                    // Update role if changed
                    boolean okRole = true;
                    if (!role.isEmpty() && !role.equalsIgnoreCase(current.getRole())) {
                        okRole = userDAO.changeUserRole(id, role);
                    }

                    // Update lock if changed
                    boolean okLock = true;
                    if (locked != current.isLocked()) {
                        okLock = userDAO.updateLockStatus(id, locked);
                    }

                    message = (ok && okRole && okLock) ? "Cập nhật tài khoản thành công" : "Cập nhật chưa hoàn tất";
                    // Quay lại trang chi tiết
                    resp.sendRedirect(req.getContextPath() + "/admin/account?action=detail&id=" + id + "&message=" + url(message));
                    return;
                }
                default:
                    message = "Hành động không hợp lệ";
            }
        } catch (Exception e) {
            e.printStackTrace();
            message = "Lỗi xử lý: " + e.getMessage();
        }

        req.setAttribute("message", message);
        loadUserList(req);
        req.getRequestDispatcher("/admin/admin_account.jsp").forward(req, resp);
    }

    // ============== Helpers ==============

    private void loadUserList(HttpServletRequest req) {
        String search = nvl(req.getParameter("search"));
        String role = nvl(req.getParameter("role"));
        String status = nvl(req.getParameter("status"));
        String createdFrom = nvl(req.getParameter("createdFrom"));
        String createdTo = nvl(req.getParameter("createdTo"));

        int page = parseIntOrDefault(req.getParameter("page"), 1);
        if (page < 1) page = 1;
        int pageSize = 10;

        int total = userDAO.countUsersAdvanced(
                emptyToNull(search),
                emptyToNull(role),
                emptyToNull(status),
                emptyToNull(createdFrom),
                emptyToNull(createdTo),
                null, null
        );
        int totalPages = (int) Math.ceil(total / (double) pageSize);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<User> users = userDAO.findUsersAdvanced(
                emptyToNull(search),
                emptyToNull(role),
                emptyToNull(status),
                emptyToNull(createdFrom),
                emptyToNull(createdTo),
                null, null,
                page, pageSize
        );

        req.setAttribute("users", users);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
    }

    private void handleExportCsv(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String search = nvl(req.getParameter("search"));
        String role = nvl(req.getParameter("role"));
        String status = nvl(req.getParameter("status"));
        String createdFrom = nvl(req.getParameter("createdFrom"));
        String createdTo = nvl(req.getParameter("createdTo"));

        int total = userDAO.countUsersAdvanced(
                emptyToNull(search),
                emptyToNull(role),
                emptyToNull(status),
                emptyToNull(createdFrom),
                emptyToNull(createdTo),
                null, null
        );
        if (total <= 0) total = 1;
        List<User> users = userDAO.findUsersAdvanced(
                emptyToNull(search),
                emptyToNull(role),
                emptyToNull(status),
                emptyToNull(createdFrom),
                emptyToNull(createdTo),
                null, null,
                1, total
        );

        String filename = "users_export.csv";
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Content-Disposition",
                "attachment; filename*=UTF-8''" + URLEncoder.encode(filename, StandardCharsets.UTF_8)
        );

        try (PrintWriter out = resp.getWriter()) {
            out.println("ID,Full Name,Email,Role,Status,Created At,Last Login,Phone,Address,Province");
            for (User u : users) {
                String statusStr = u.isLocked() ? "locked" : "active";
                String createdAt = u.getCreatedAt() != null ? String.valueOf(u.getCreatedAt()) : "";
                String lastLogin = u.getLastLoginAt() != null ? String.valueOf(u.getLastLoginAt()) : "";
                String phone = nvl(u.getPhoneNumber());
                String address = nvl(u.getAddress());
                String province = u.getProvinceId() != null ? String.valueOf(u.getProvinceId()) : "";
                out.printf("%d,%s,%s,%s,%s,%s,%s,%s,%s,%s%n",
                        u.getId(),
                        csv(u.getFullName()),
                        csv(u.getEmail()),
                        csv(u.getRole()),
                        statusStr,
                        csv(createdAt),
                        csv(lastLogin),
                        csv(phone),
                        csv(address),
                        csv(province)
                );
            }
        }
    }

    private static String nvl(String s) { return s == null ? "" : s.trim(); }
    private static String emptyToNull(String s) { String t = nvl(s); return t.isEmpty() ? null : t; }
    private static int parseIntOrDefault(String s, int def) { try { return (s == null || s.isEmpty()) ? def : Integer.parseInt(s); } catch (Exception e) { return def; } }
    private static Integer parseNullableInt(String s) { try { String t = nvl(s); return t.isEmpty() ? null : Integer.valueOf(t); } catch (Exception e) { return null; } }
    private static String csv(String v) {
        if (v == null) return "";
        String s = v.replace("\"", "\"\"");
        if (s.contains(",") || s.contains("\"") || s.contains("\n") || s.contains("\r")) return "\"" + s + "\"";
        return s;
    }
    private static String url(String v){ try { return URLEncoder.encode(nvl(v), StandardCharsets.UTF_8); } catch (Exception e){ return ""; } }
}