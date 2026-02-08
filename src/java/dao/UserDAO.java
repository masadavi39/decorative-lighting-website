package dao;

import model.User;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

/**
 * UserDAO: Quản lý thao tác với bảng users, remember_tokens, password_resets.
 * Chú ý: Mật khẩu đang được lưu plain text theo thiết kế ban đầu.
 * Bảng users theo schema hiện tại đã có các cột:
 *  full_name, email, password_hash, role, phoneNumber,
 *  address, province_id, company_name, tax_code, tax_email
 */
public class UserDAO {

    public Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    // ========================== PROFILE ==========================
    /**
     * Cập nhật đầy đủ hồ sơ người dùng.
     *
     * @param id user_id
     * @param fullName tên hiển thị
     * @param email email
     * @param newPassword mật khẩu mới (null/empty = giữ nguyên)
     * @param phoneNumber số điện thoại
     * @param address địa chỉ giao hàng mặc định
     * @param provinceId id tỉnh/thành (có thể null)
     * @param companyName tên công ty (xuất hóa đơn)
     * @param taxCode mã số thuế
     * @param taxEmail email nhận hóa đơn
     * @return true nếu cập nhật thành công
     */
    public boolean updateUserProfile(int id,
                                     String fullName,
                                     String email,
                                     String newPassword,
                                     String phoneNumber,
                                     String address,
                                     Integer provinceId,
                                     String companyName,
                                     String taxCode,
                                     String taxEmail) throws SQLException {

        boolean changePassword = newPassword != null && !newPassword.isEmpty();
        String sql = changePassword ? """
            UPDATE users
               SET full_name = ?, email = ?, password_hash = ?,
                   phoneNumber = ?, address = ?, province_id = ?,
                   company_name = ?, tax_code = ?, tax_email = ?
             WHERE user_id = ?
            """ : """
            UPDATE users
               SET full_name = ?, email = ?,
                   phoneNumber = ?, address = ?, province_id = ?,
                   company_name = ?, tax_code = ?, tax_email = ?
             WHERE user_id = ?
            """;

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, fullName);
            ps.setString(i++, email);
            if (changePassword) {
                ps.setString(i++, newPassword);
            }
            ps.setString(i++, phoneNumber);
            ps.setString(i++, address);
            if (provinceId == null) {
                ps.setNull(i++, Types.INTEGER);
            } else {
                ps.setInt(i++, provinceId);
            }
            ps.setString(i++, companyName);
            ps.setString(i++, taxCode);
            ps.setString(i++, taxEmail);
            ps.setInt(i, id);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Kiểm tra email đã thuộc user khác chưa.
     */
    public boolean emailExistsForOther(int currentUserId, String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ? AND user_id <> ? LIMIT 1";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, currentUserId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ========================== REGISTER ==========================
    public boolean register(User u) {
        String sql = """
            INSERT INTO users (full_name, email, password_hash, role,
                               phoneNumber, address, province_id,
                               company_name, tax_code, tax_email)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassword());
            ps.setString(4, u.getRole());
            ps.setString(5, u.getPhoneNumber());
            ps.setString(6, u.getAddress());
            if (u.getProvinceId() == null) ps.setNull(7, Types.INTEGER); else ps.setInt(7, u.getProvinceId());
            ps.setString(8, u.getCompanyName());
            ps.setString(9, u.getTaxCode());
            ps.setString(10, u.getTaxEmail());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ========================== LOGIN ==========================
    public User login(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password_hash = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ========================== REMEMBER TOKEN ==========================
    public void saveRememberToken(int userId, String token, LocalDateTime expireAt) throws SQLException {
        String sql = "INSERT INTO remember_tokens (user_id, token, expire_at) VALUES (?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, token);
            ps.setTimestamp(3, Timestamp.valueOf(expireAt));
            ps.executeUpdate();
        }
    }

    public User findByRememberToken(String token) throws SQLException {
        String sql = """
            SELECT u.* FROM users u
            JOIN remember_tokens r ON u.user_id = r.user_id
            WHERE r.token = ? AND r.expire_at > CURRENT_TIMESTAMP
            """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        }
        return null;
    }

    public void deleteRememberToken(String token) throws SQLException {
        String sql = "DELETE FROM remember_tokens WHERE token = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }

    // ========================== PASSWORD RESET ==========================
    public void saveResetToken(int userId, String token) throws SQLException {
        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM password_resets WHERE user_id = ? OR expire_at < CURRENT_TIMESTAMP")) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("""
                INSERT INTO password_resets (user_id, email, token, expire_at, created_at, used)
                SELECT user_id, email, ?, CURRENT_TIMESTAMP + INTERVAL 1 HOUR, CURRENT_TIMESTAMP, 0
                FROM users WHERE user_id = ?
                """)) {
                ps.setString(1, token);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }
            conn.commit();
            conn.setAutoCommit(true);
        }
    }

    public User findByResetToken(String token) throws SQLException {
        String sql = """
            SELECT u.* FROM users u
            JOIN password_resets p ON u.user_id = p.user_id
            WHERE p.token = ? AND p.expire_at > CURRENT_TIMESTAMP AND p.used = 0
            LIMIT 1
            """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        }
        return null;
    }

    public void deleteResetToken(String token) throws SQLException {
        String sql = "UPDATE password_resets SET used = 1 WHERE token = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token);
            ps.executeUpdate();
        }
    }

    public void updatePassword(int userId, String newPassword) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ========================== SEARCH ==========================
    public List<User> searchUsers(String keyword) {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE full_name LIKE ? OR email LIKE ? OR role LIKE ? OR phoneNumber LIKE ? ORDER BY user_id";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            String k = "%" + keyword + "%";
            ps.setString(1, k);
            ps.setString(2, k);
            ps.setString(3, k);
            ps.setString(4, k);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapUser(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ========================== DELETE / ROLE ==========================
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean changeUserRole(int id, String role) {
        String sql = "UPDATE users SET role = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ========================== GET ONE / ALL ==========================
    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY user_id";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapUser(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ========================== TOP USERS ==========================
    public List<Map<String, Object>> getTopUsers(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = """
            SELECT u.user_id,
                   u.full_name,
                   u.email,
                   u.phoneNumber,
                   COUNT(o.order_id) AS orderCount,
                   COALESCE(SUM(o.total_price),0) AS totalSpent
            FROM users u
            LEFT JOIN orders o ON o.user_id = u.user_id AND o.status = 'Đã giao'
            GROUP BY u.user_id, u.full_name, u.email, u.phoneNumber
            ORDER BY totalSpent DESC
            LIMIT ?
            """;
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("user_id", rs.getInt("user_id"));
                    row.put("full_name", rs.getString("full_name"));
                    row.put("email", rs.getString("email"));
                    row.put("phoneNumber", rs.getString("phoneNumber"));
                    row.put("orderCount", rs.getInt("orderCount"));
                    row.put("totalSpent", rs.getDouble("totalSpent"));
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }
    // Thêm cột locked, created_at, last_login_at: đọc ra gán vào User
    private User mapUserWithExtended(ResultSet rs) throws SQLException {
        User u = new User(
                rs.getInt("user_id"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("password_hash"),
                rs.getString("role"),
                rs.getString("phoneNumber")
        );
        u.setAddress(rs.getString("address"));
        Object pObj = rs.getObject("province_id");
        u.setProvinceId(pObj == null ? null : rs.getInt("province_id"));
        u.setCompanyName(rs.getString("company_name"));
        u.setTaxCode(rs.getString("tax_code"));
        u.setTaxEmail(rs.getString("tax_email"));

        try { u.setCreatedAt(rs.getTimestamp("created_at")); } catch (Exception ignore) {}
        try { u.setLastLoginAt(rs.getTimestamp("last_login_at")); } catch (Exception ignore) {}
        try { u.setLocked(rs.getBoolean("locked")); } catch (Exception ignore) {}

        return u;
    }

    // Tìm kiếm nâng cao + phân trang
    public List<User> findUsersAdvanced(String keyword, String role, String status, String createdFrom, String createdTo, String lastLoginFrom, String lastLoginTo, int page, int pageSize) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(full_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(phoneNumber) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (role != null && !role.isBlank()) {
            sql.append(" AND role = ?");
            params.add(role);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND locked = ?");
            params.add("locked".equalsIgnoreCase(status));
        }
        if (createdFrom != null && !createdFrom.isBlank()) {
            sql.append(" AND DATE(created_at) >= ?");
            params.add(createdFrom);
        }
        if (createdTo != null && !createdTo.isBlank()) {
            sql.append(" AND DATE(created_at) <= ?");
            params.add(createdTo);
        }

        sql.append(" ORDER BY user_id ASC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUserWithExtended(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countUsersAdvanced(String keyword, String role, String status, String createdFrom, String createdTo, String lastLoginFrom, String lastLoginTo) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(full_name) LIKE ? OR LOWER(email) LIKE ? OR LOWER(phoneNumber) LIKE ?)");
            String kw = "%" + keyword.toLowerCase().trim() + "%";
            params.add(kw); params.add(kw); params.add(kw);
        }
        if (role != null && !role.isBlank()) {
            sql.append(" AND role = ?");
            params.add(role);
        }
        if (status != null && !status.isBlank()) {
            sql.append(" AND locked = ?");
            params.add("locked".equalsIgnoreCase(status));
        }
        if (createdFrom != null && !createdFrom.isBlank()) {
            sql.append(" AND DATE(created_at) >= ?");
            params.add(createdFrom);
        }
        if (createdTo != null && !createdTo.isBlank()) {
            sql.append(" AND DATE(created_at) <= ?");
            params.add(createdTo);
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Khóa/Mở khóa tài khoản
    public boolean updateLockStatus(int id, boolean locked) {
        String sql = "UPDATE users SET locked = ? WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, locked);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Ghi lại lần đăng nhập gần nhất (gọi từ Auth khi login)
    public void markLastLogin(int id) {
        String sql = "UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ========================== MAP HELPER ==========================
    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User(
                rs.getInt("user_id"),
                rs.getString("full_name"),
                rs.getString("email"),
                rs.getString("password_hash"),
                rs.getString("role"),
                rs.getString("phoneNumber")
        );
        u.setAddress(rs.getString("address"));
        Object pObj = rs.getObject("province_id");
        u.setProvinceId(pObj == null ? null : rs.getInt("province_id"));
        u.setCompanyName(rs.getString("company_name"));
        u.setTaxCode(rs.getString("tax_code"));
        u.setTaxEmail(rs.getString("tax_email"));
        return u;
    }
}