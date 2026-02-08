package dao;

import model.EmailOTP;
import java.sql.*;
import java.time.LocalDateTime;

public class EmailOtpDAO {

    private final Connection conn;

    public EmailOtpDAO(Connection conn) {
        this.conn = conn;
    }

    /**
     * Lưu OTP cho email. Nếu email đã tồn tại, ghi đè OTP cũ.
     */
    public boolean saveOTP(EmailOTP otp) {
        String sql = """
            INSERT INTO emailotp (email, otp_code, expire_at)
            VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE
                otp_code = VALUES(otp_code),
                expire_at = VALUES(expire_at)
        """;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, otp.getEmail());
            ps.setString(2, otp.getOtpCode());
            ps.setTimestamp(3, Timestamp.valueOf(otp.getExpireAt()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xác thực OTP: trả về true nếu OTP đúng và chưa hết hạn.
     */
    public boolean verifyOTP(String email, String otpCode) {
        String sql = "SELECT otp_code, expire_at FROM emailotp WHERE email = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String code = rs.getString("otp_code");
                    Timestamp expireTs = rs.getTimestamp("expire_at");
                    LocalDateTime expireAt = expireTs.toLocalDateTime();

                    // Kiểm tra OTP đúng và chưa hết hạn
                    return code.equals(otpCode) && LocalDateTime.now().isBefore(expireAt);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xoá OTP sau khi đăng ký thành công hoặc khi không cần nữa.
     */
    public boolean deleteOTP(String email) {
        String sql = "DELETE FROM emailotp WHERE email = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
