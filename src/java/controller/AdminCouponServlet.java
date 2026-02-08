package controller;

import dao.CouponDAO;
import model.Coupon;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet(name = "AdminCouponServlet", urlPatterns = "/admin/coupons")
public class AdminCouponServlet extends HttpServlet {

    private final CouponDAO couponDAO = new CouponDAO();
    private final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        model.User user = (model.User) session.getAttribute("user");

        if (user == null || !"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        req.setCharacterEncoding("UTF-8");
        String action = Optional.ofNullable(req.getParameter("action")).orElse("list");

        switch (action) {
            case "edit": {
                String code = Optional.ofNullable(req.getParameter("code")).orElse("").trim();
                Coupon c = couponDAO.findByCode(code);
                if (c == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=list&error=notfound");
                    return;
                }
                req.setAttribute("editCoupon", c);
                // fallthrough -> list
            }
            case "list":
            default: {
                // Bộ lọc đơn giản: chỉ 2 input date: startAt và endAt
                String startAt = nvl(req.getParameter("startAt"));
                String endAt = nvl(req.getParameter("endAt"));

                // Giữ khả năng tương thích tham số cũ (nếu có)
                String keyword = nvl(req.getParameter("keyword"));
                String type = nvl(req.getParameter("type"));
                String activeStr = nvl(req.getParameter("active"));
                Boolean active = activeStr.isEmpty() ? null : ("1".equals(activeStr) ? Boolean.TRUE : Boolean.FALSE);

                int page = parseIntOrDefault(req.getParameter("page"), 1);
                int pageSize = parseIntOrDefault(req.getParameter("pageSize"), 10);

                // Map 2 tham số mới vào DAO: startFrom = startAt, endTo = endAt; các tham số còn lại null
                List<model.Coupon> coupons = couponDAO.searchPaged(
                        keyword,
                        type.isEmpty() ? null : type,
                        active,
                        startAt, null,
                        null, endAt,
                        page, pageSize
                );
                int total = couponDAO.countSearch(
                        keyword,
                        type.isEmpty() ? null : type,
                        active,
                        startAt, null,
                        null, endAt
                );
                int totalPages = (int) Math.ceil(total / (double) pageSize);

                req.setAttribute("coupons", coupons);
                // set lại các tham số UI
                req.setAttribute("startAt", startAt);
                req.setAttribute("endAt", endAt);
                req.setAttribute("keyword", keyword);
                req.setAttribute("type", type);
                req.setAttribute("activeVal", activeStr);
                req.setAttribute("currentPage", page);
                req.setAttribute("pageSize", pageSize);
                req.setAttribute("totalPages", totalPages);

                req.getRequestDispatcher("/admin/admin_coupons.jsp").forward(req, resp);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        model.User user = (model.User) session.getAttribute("user");
        if (user == null || !"admin".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/auth?action=login");
            return;
        }

        String action = Optional.ofNullable(req.getParameter("action")).orElse("list");

        switch (action) {
            case "add": {
                String code = nvl(req.getParameter("code")).toUpperCase();
                if (couponDAO.existsByCode(code)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=list&error=duplicate&code=" + code);
                    return;
                }

                String description = nvl(req.getParameter("description"));
                String discountType = req.getParameter("discountType"); // percent | fixed
                Double value = parseDoubleOrNull(req.getParameter("value"));
                boolean active = "on".equals(req.getParameter("active"));

                Date startDate = parseDateStartOfDayOrNull(req.getParameter("startDate"));
                Date endDate = parseDateEndOfDayOrNull(req.getParameter("endDate"));

                Date now = new Date();
                if (startDate == null) startDate = startOfDay(now);
                if (endDate == null) endDate = endOfDay(addDays(startDate, 365));
                if (endDate.before(startDate)) endDate = endOfDay(startDate);

                Coupon c = new Coupon();
                c.setCode(code);
                c.setDescription(description);
                c.setDiscountType(discountType);
                c.setValue(value);
                c.setActive(active);
                c.setStartDate(startDate);
                c.setEndDate(endDate);
                c.setMinSubtotal(parseDoubleOrNull(req.getParameter("minSubtotal")));
                c.setMaxDiscount(parseDoubleOrNull(req.getParameter("maxDiscount")));
                c.setUsageLimit(parseIntOrNull(req.getParameter("usageLimit")));

                couponDAO.insert(c);
                resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=list&done=add");
                return;
            }
            case "update": {
                String code = nvl(req.getParameter("code")).toUpperCase();
                Coupon exists = couponDAO.findByCode(code);
                if (exists == null) {
                    resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=list&error=notfound");
                    return;
                }
                String description = nvl(req.getParameter("description"));
                String discountType = req.getParameter("discountType");
                Double value = parseDoubleOrNull(req.getParameter("value"));
                boolean active = "on".equals(req.getParameter("active"));

                Date startDate = parseDateStartOfDayOrNull(req.getParameter("startDate"));
                Date endDate = parseDateEndOfDayOrNull(req.getParameter("endDate"));
                if (startDate == null) startDate = exists.getStartDate();
                if (endDate == null) endDate = exists.getEndDate();
                if (endDate.before(startDate)) endDate = endOfDay(startDate);

                exists.setDescription(description);
                exists.setDiscountType(discountType);
                exists.setValue(value);
                exists.setActive(active);
                exists.setStartDate(startDate);
                exists.setEndDate(endDate);
                exists.setMinSubtotal(parseDoubleOrNull(req.getParameter("minSubtotal")));
                exists.setMaxDiscount(parseDoubleOrNull(req.getParameter("maxDiscount")));
                exists.setUsageLimit(parseIntOrNull(req.getParameter("usageLimit")));

                couponDAO.update(exists);
                resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=edit&code=" + code + "&done=update");
                return;
            }
            case "toggle": {
                int id = parseIntOrDefault(req.getParameter("id"), 0);
                boolean active = "1".equals(req.getParameter("active"));
                couponDAO.updateActive(id, active);
                resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=list&done=toggle");
                return;
            }
            case "delete": {
                int id = parseIntOrDefault(req.getParameter("id"), 0);
                couponDAO.deleteById(id);
                resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=list&done=delete");
                return;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/coupons?action=list");
        }
    }

    // utils
    private static String nvl(String s) { return (s == null) ? "" : s.trim(); }
    private static Double parseDoubleOrNull(String s) { try { return (s == null || s.isEmpty()) ? null : Double.valueOf(s); } catch(Exception e){ return null; } }
    private Integer parseIntOrNull(String s) { try { return (s == null || s.isEmpty()) ? null : Integer.valueOf(s); } catch(Exception e){return null;} }
    private int parseIntOrDefault(String s, int def) { try { return (s == null || s.isEmpty()) ? def : Integer.parseInt(s); } catch(Exception e){ return def; } }
    private java.util.Date parseDateOrNull(String s) { try { return (s == null || s.isEmpty()) ? null : sdf.parse(s); } catch(Exception e){ return null; } }
    private Date parseDateStartOfDayOrNull(String s) { Date d = parseDateOrNull(s); return d == null ? null : startOfDay(d); }
    private Date parseDateEndOfDayOrNull(String s) { Date d = parseDateOrNull(s); return d == null ? null : endOfDay(d); }
    private static Date startOfDay(Date d) { Calendar cal = Calendar.getInstance(); cal.setTime(d); cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0); cal.set(Calendar.SECOND, 0); cal.set(Calendar.MILLISECOND, 0); return cal.getTime(); }
    private static Date endOfDay(Date d) { Calendar cal = Calendar.getInstance(); cal.setTime(d); cal.set(Calendar.HOUR_OF_DAY, 23); cal.set(Calendar.MINUTE, 59); cal.set(Calendar.SECOND, 59); cal.set(Calendar.MILLISECOND, 999); return cal.getTime(); }
    private static Date addDays(Date d, int days) { Calendar cal = Calendar.getInstance(); cal.setTime(d); cal.add(Calendar.DAY_OF_MONTH, days); return cal.getTime(); }
}