package model;

import java.time.LocalDateTime;

public class EmailOTP {
    private int otpId;
    private String email;
    private String otpCode;
    private LocalDateTime expireAt;

    public EmailOTP() {}

    public EmailOTP(String email, String otpCode, LocalDateTime expireAt) {
        this.email = email;
        this.otpCode = otpCode;
        this.expireAt = expireAt;
    }

    public int getOtpId() {
        return otpId;
    }

    public void setOtpId(int otpId) {
        this.otpId = otpId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getOtpCode() {
        return otpCode;
    }

    public void setOtpCode(String otpCode) {
        this.otpCode = otpCode;
    }

    public LocalDateTime getExpireAt() {
        return expireAt;
    }

    public void setExpireAt(LocalDateTime expireAt) {
        this.expireAt = expireAt;
    }
}
