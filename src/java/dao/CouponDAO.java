package dao;

import model.Coupon;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.*;

/**
 * CouponDAO khớp với bảng coupons trong DB:
 * (coupon_id, code, description, discount_type, value, max_discount,
 *  start_at, end_at, usage_limit, used_count, min_subtotal, active)
 *
 * Lưu ý: TRÁNH import java.sql.* để không xung đột với java.util.Date.
 * Dùng import tường minh cho các lớp java.sql và dùng java.util.Date cho xử lý ngày.
 */
public class CouponDAO {

    public static class Preview {
        public boolean valid;
        public String message;
        public String code;
        public String type; // percent|fixed
        public Double value;
        public Double maxDiscount;
        public Double minSubtotal;
        public Double discount;
        public Double discountedTotal;
    }

    public static class CouponCalcResult {
        public final boolean valid;
        public final double discount;
        public final String message;
        public CouponCalcResult(boolean valid, double discount, String message) {
            this.valid = valid;
            this.discount = discount;
            this.message = message;
        }
    }

    private Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    // ================= CRUD / Query =================

    public List<Coupon> getAllCoupons() {
        List<Coupon> list = new ArrayList<>();
        String sql = """
            SELECT coupon_id, code, description, discount_type, value, max_discount,
                   start_at, end_at, usage_limit, used_count, min_subtotal, active
            FROM coupons
            ORDER BY coupon_id DESC
        """;
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public Coupon findByCode(String code) {
        String sql = """
            SELECT coupon_id, code, description, discount_type, value, max_discount,
                   start_at, end_at, usage_limit, used_count, min_subtotal, active
            FROM coupons WHERE code = ? LIMIT 1
        """;
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public boolean existsByCode(String code) {
        String sql = "SELECT 1 FROM coupons WHERE code = ? LIMIT 1";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean insert(Coupon cpn) {
        String sql = """
            INSERT INTO coupons
              (code, description, discount_type, value, max_discount,
               start_at, end_at, usage_limit, min_subtotal, active)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            java.util.Date start = normalizeStart(cpn.getStartDate());
            java.util.Date end   = normalizeEnd(cpn.getEndDate(), start);

            ps.setString(1, cpn.getCode());
            ps.setString(2, cpn.getDescription());
            ps.setString(3, cpn.getDiscountType());
            ps.setDouble(4, cpn.getValue() != null ? cpn.getValue() : 0d);

            if (cpn.getMaxDiscount() == null) ps.setNull(5, java.sql.Types.DECIMAL);
            else ps.setBigDecimal(5, BigDecimal.valueOf(cpn.getMaxDiscount()));

            ps.setTimestamp(6, new Timestamp(start.getTime()));
            ps.setTimestamp(7, new Timestamp(end.getTime()));

            if (cpn.getUsageLimit() == null) ps.setNull(8, java.sql.Types.INTEGER);
            else ps.setInt(8, cpn.getUsageLimit());

            if (cpn.getMinSubtotal() == null) ps.setNull(9, java.sql.Types.DECIMAL);
            else ps.setBigDecimal(9, BigDecimal.valueOf(cpn.getMinSubtotal()));

            ps.setBoolean(10, cpn.isActive());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean updateActive(int id, boolean active) {
        String sql = "UPDATE coupons SET active = ? WHERE coupon_id = ?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM coupons WHERE coupon_id = ?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    // ============== Validation / Calculation ==============

    /**
     * Xem trước áp dụng coupon cho subtotal (không ghi DB).
     * Logic:
     * - active = 1
     * - NOW() BETWEEN start_at AND end_at
     * - usage_limit: null -> bỏ qua, else used_count < usage_limit
     * - subtotal >= COALESCE(min_subtotal,0)
     * - percent: ROUND(subtotal * (value/100), 2), sau đó min với max_discount (nếu có)
     * - fixed: min(value, subtotal), ROUND(2)
     */
    public Preview validatePreview(String code, double subtotal) {
        Preview p = new Preview();
        p.code = code;

        if (code == null || code.trim().isEmpty()) {
            p.valid = false; p.message = "Thiếu mã coupon";
            return p;
        }
        if (subtotal <= 0) {
            p.valid = false; p.message = "Tổng tiền không hợp lệ";
            return p;
        }

        String sql = """
            SELECT code, discount_type, value, max_discount,
                   start_at, end_at, usage_limit, used_count, min_subtotal, active
            FROM coupons WHERE code = ? LIMIT 1
        """;
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, code.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) { p.valid=false; p.message="Mã không tồn tại"; return p; }

                boolean active = rs.getBoolean("active");
                Timestamp startAt = rs.getTimestamp("start_at");
                Timestamp endAt   = rs.getTimestamp("end_at");

                Integer usageLimit = rs.getObject("usage_limit") == null ? null : rs.getInt("usage_limit");
                int usedCount      = rs.getInt("used_count");

                BigDecimal minSubtotalBD = (BigDecimal) rs.getObject("min_subtotal");
                double minSubtotal = (minSubtotalBD == null) ? 0.0 : minSubtotalBD.doubleValue();

                String type = rs.getString("discount_type");
                double value = rs.getDouble("value");
                BigDecimal maxDiscountBD = (BigDecimal) rs.getObject("max_discount");
                Double maxDiscount = (maxDiscountBD != null ? maxDiscountBD.doubleValue() : null);

                long now = System.currentTimeMillis();
                if (!active) { p.valid=false; p.message="Mã đang tắt"; return p; }
                if (startAt != null && now < startAt.getTime()) { p.valid=false; p.message="Mã chưa hiệu lực"; return p; }
                if (endAt   != null && now > endAt.getTime())   { p.valid=false; p.message="Mã đã hết hạn"; return p; }
                if (usageLimit != null && usedCount >= usageLimit) { p.valid=false; p.message="Mã đã hết lượt dùng"; return p; }
                if (subtotal < Math.max(0, minSubtotal)) { p.valid=false; p.message="Chưa đạt tối thiểu " + formatMoney(minSubtotal); return p; }

                // Tính giảm
                double discount;
                if ("percent".equalsIgnoreCase(type)) {
                    BigDecimal bdSubtotal = BigDecimal.valueOf(subtotal);
                    BigDecimal bdRate = BigDecimal.valueOf(value).divide(BigDecimal.valueOf(100), 8, RoundingMode.HALF_UP);
                    double calc = bdSubtotal.multiply(bdRate).setScale(2, RoundingMode.HALF_UP).doubleValue(); // ROUND 2
                    discount = maxDiscount != null ? Math.min(calc, maxDiscount) : calc;
                } else {
                    discount = Math.min(value, subtotal);
                    discount = BigDecimal.valueOf(discount).setScale(2, RoundingMode.HALF_UP).doubleValue();
                }

                p.valid = true;
                p.message = "Áp dụng thành công";
                p.type = type;
                p.value = value;
                p.maxDiscount = maxDiscount;
                p.minSubtotal = minSubtotal;
                p.discount = discount;
                p.discountedTotal = Math.max(0, BigDecimal.valueOf(subtotal - discount).setScale(2, RoundingMode.HALF_UP).doubleValue());
            }
        } catch (Exception e) {
            e.printStackTrace();
            p.valid = false; p.message = "Lỗi máy chủ";
        }
        return p;
    }

    /**
     * Dùng cho báo giá/invoice: chỉ cần biết hợp lệ và số tiền giảm.
     */
    public CouponCalcResult validateAndCalc(String code, double subtotal) {
        Preview pv = validatePreview(code, subtotal);
        if (!pv.valid) {
            return new CouponCalcResult(false, 0.0, pv.message);
        }
        double d = pv.discount != null ? pv.discount : 0.0;
        return new CouponCalcResult(true, d, "OK");
    }
    
    /**
     * Lấy danh sách coupon sắp hết hạn trong N ngày tiếp theo.
     */
    public List<Coupon> getExpiringWithinDays(int days) {
        List<Coupon> list = new ArrayList<>();
        String sql = """
            SELECT coupon_id, code, description, discount_type, value, max_discount,
                   start_at, end_at, usage_limit, used_count, min_subtotal, active
            FROM coupons
            WHERE active = 1
              AND end_at BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL ? DAY)
            ORDER BY end_at ASC
        """;
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    /**
     * Tìm kiếm + lọc + phân trang
     * @param keyword tìm theo code/description
     * @param type 'percent' | 'fixed' | null
     * @param active null = tất cả; true/false lọc theo trạng thái
     * @param fromEnd before hoặc after? Ở đây dùng khoảng: startDate/endDate có thể null
     * @param page trang (>=1)
     * @param pageSize kích thước trang
     */
    public List<Coupon> searchPaged(String keyword, String type, Boolean active,
                                    String startFrom, String startTo,
                                    String endFrom, String endTo,
                                    int page, int pageSize) {
        List<Coupon> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
            SELECT coupon_id, code, description, discount_type, value, max_discount,
                   start_at, end_at, usage_limit, used_count, min_subtotal, active
            FROM coupons
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(code) LIKE ? OR LOWER(description) LIKE ?)");
            String kw = "%" + keyword.trim().toLowerCase() + "%";
            params.add(kw); params.add(kw);
        }
        if (type != null && !type.isBlank()) {
            sql.append(" AND discount_type = ?");
            params.add(type);
        }
        if (active != null) {
            sql.append(" AND active = ?");
            params.add(active ? 1 : 0);
        }
        if (startFrom != null && !startFrom.isBlank()) {
            sql.append(" AND DATE(start_at) >= ?");
            params.add(startFrom);
        }
        if (startTo != null && !startTo.isBlank()) {
            sql.append(" AND DATE(start_at) <= ?");
            params.add(startTo);
        }
        if (endFrom != null && !endFrom.isBlank()) {
            sql.append(" AND DATE(end_at) >= ?");
            params.add(endFrom);
        }
        if (endTo != null && !endTo.isBlank()) {
            sql.append(" AND DATE(end_at) <= ?");
            params.add(endTo);
        }

        sql.append(" ORDER BY end_at ASC, coupon_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public int countSearch(String keyword, String type, Boolean active,
                           String startFrom, String startTo,
                           String endFrom, String endTo) {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) FROM coupons WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(code) LIKE ? OR LOWER(description) LIKE ?)");
            String kw = "%" + keyword.trim().toLowerCase() + "%";
            params.add(kw); params.add(kw);
        }
        if (type != null && !type.isBlank()) {
            sql.append(" AND discount_type = ?");
            params.add(type);
        }
        if (active != null) {
            sql.append(" AND active = ?");
            params.add(active ? 1 : 0);
        }
        if (startFrom != null && !startFrom.isBlank()) {
            sql.append(" AND DATE(start_at) >= ?");
            params.add(startFrom);
        }
        if (startTo != null && !startTo.isBlank()) {
            sql.append(" AND DATE(start_at) <= ?");
            params.add(startTo);
        }
        if (endFrom != null && !endFrom.isBlank()) {
            sql.append(" AND DATE(end_at) >= ?");
            params.add(endFrom);
        }
        if (endTo != null && !endTo.isBlank()) {
            sql.append(" AND DATE(end_at) <= ?");
            params.add(endTo);
        }

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }

    public boolean update(Coupon cpn) {
        String sql = """
            UPDATE coupons
               SET description=?, discount_type=?, value=?, max_discount=?,
                   start_at=?, end_at=?, usage_limit=?, min_subtotal=?, active=?
             WHERE code = ?
        """;
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            java.util.Date start = normalizeStart(cpn.getStartDate());
            java.util.Date end   = normalizeEnd(cpn.getEndDate(), start);

            ps.setString(1, cpn.getDescription());
            ps.setString(2, cpn.getDiscountType());
            ps.setDouble(3, cpn.getValue() != null ? cpn.getValue() : 0d);

            if (cpn.getMaxDiscount() == null) ps.setNull(4, java.sql.Types.DECIMAL);
            else ps.setBigDecimal(4, BigDecimal.valueOf(cpn.getMaxDiscount()));

            ps.setTimestamp(5, new Timestamp(start.getTime()));
            ps.setTimestamp(6, new Timestamp(end.getTime()));

            if (cpn.getUsageLimit() == null) ps.setNull(7, java.sql.Types.INTEGER);
            else ps.setInt(7, cpn.getUsageLimit());

            if (cpn.getMinSubtotal() == null) ps.setNull(8, java.sql.Types.DECIMAL);
            else ps.setBigDecimal(8, BigDecimal.valueOf(cpn.getMinSubtotal()));

            ps.setBoolean(9, cpn.isActive());
            ps.setString(10, cpn.getCode());

            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }


    // ================= Helpers =================

    private Coupon mapRow(ResultSet rs) throws SQLException {
        Coupon cp = new Coupon();
        cp.setId(rs.getInt("coupon_id"));
        cp.setCode(rs.getString("code"));
        cp.setDescription(rs.getString("description"));
        cp.setDiscountType(rs.getString("discount_type"));
        cp.setValue(rs.getDouble("value"));

        BigDecimal maxD = (BigDecimal) rs.getObject("max_discount");
        cp.setMaxDiscount(maxD != null ? maxD.doubleValue() : null);

        cp.setStartDate(rs.getTimestamp("start_at"));
        cp.setEndDate(rs.getTimestamp("end_at"));

        Number ul = (Number) rs.getObject("usage_limit");
        cp.setUsageLimit(ul != null ? ul.intValue() : null);

        cp.setUsedCount(rs.getInt("used_count"));

        BigDecimal minS = (BigDecimal) rs.getObject("min_subtotal");
        cp.setMinSubtotal(minS != null ? minS.doubleValue() : 0.0);

        cp.setActive(rs.getBoolean("active"));
        return cp;
    }

    // Dùng java.util.Date tường minh để tránh xung đột với java.sql.Date
    private static java.util.Date startOfDay(java.util.Date d) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(d);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }
    private static java.util.Date endOfDay(java.util.Date d) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(d);
        cal.set(Calendar.HOUR_OF_DAY, 23);
        cal.set(Calendar.MINUTE, 59);
        cal.set(Calendar.SECOND, 59);
        cal.set(Calendar.MILLISECOND, 999);
        return cal.getTime();
    }
    private static java.util.Date addDays(java.util.Date d, int days) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(d);
        cal.add(Calendar.DAY_OF_MONTH, days);
        return cal.getTime();
    }

    private static java.util.Date normalizeStart(java.util.Date start) {
        java.util.Date now = new java.util.Date();
        return start == null ? startOfDay(now) : startOfDay(start);
    }
    private static java.util.Date normalizeEnd(java.util.Date end, java.util.Date start) {
        if (end == null) return endOfDay(addDays(start, 365));
        java.util.Date e = endOfDay(end);
        if (e.before(start)) e = endOfDay(start);
        return e;
    }

    private static String formatMoney(double v) {
        long lv = (long) v;
        if (Math.abs(v - lv) < 0.005) return String.format("%,d", lv);
        return String.format("%,.2f", v);
    }
}