package model;

import java.util.Date;

/**
 * Model User đầy đủ, khớp schema hiện tại của bảng users trong database.
 * Lưu ý: mật khẩu (password_hash) đang lưu plain text theo thiết kế ban đầu.
 */
public class User {
    private int id;
    private String fullName;
    private String email;
    private String password;
    private String role;
    private String phoneNumber;

    // Các trường hồ sơ mở rộng theo DB
    private String address;
    private Integer provinceId;  // có thể null
    private String companyName;
    private String taxCode;
    private String taxEmail;

    private boolean locked;
    private Date createdAt;
    private Date lastLoginAt;

    public User() {}

    public User(int id, String fullName, String email, String password, String role, String phoneNumber) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.password = password;
        this.role = role;
        this.phoneNumber = phoneNumber;
    }

    public User(String fullName, String email, String password, String role, String phoneNumber) {
        this(0, fullName, email, password, role, phoneNumber);
    }

    // Getters/Setters cơ bản
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    // Mở rộng theo DB
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Integer getProvinceId() { return provinceId; }
    public void setProvinceId(Integer provinceId) { this.provinceId = provinceId; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getTaxCode() { return taxCode; }
    public void setTaxCode(String taxCode) { this.taxCode = taxCode; }

    public String getTaxEmail() { return taxEmail; }
    public void setTaxEmail(String taxEmail) { this.taxEmail = taxEmail; }
    public boolean isLocked() { return locked; }
    public void setLocked(boolean locked) { this.locked = locked; }
    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
    public Date getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(Date lastLoginAt) { this.lastLoginAt = lastLoginAt; }

}