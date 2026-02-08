<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Trang cá nhân</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f4f6f8;
                color: #333;
                margin: 0;
                padding: 0;
            }

            .container {
                max-width: 760px;
                margin: 40px auto;
                padding: 30px 24px;
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            }

            h2 {
                text-align: center;
                color: #2c3e50;
                margin-bottom: 24px;
                font-size: 1.8rem;
            }

            .profile-form {
                width: 100%;
                display: flex;
                flex-direction: column;
                gap: 20px;
            }

            .form-group {
                display: flex;
                flex-direction: column;
            }

            .form-label {
                font-weight: 600;
                color: #555;
                margin-bottom: 8px;
                font-size: 0.95rem;
            }

            .form-input, .form-select, .form-textarea {
                width: 100%;
                padding: 12px 14px;
                border: 1px solid #ccc;
                border-radius: 8px;
                font-size: 1rem;
                transition: all 0.2s;
                box-sizing: border-box;
            }

            .form-input:focus, .form-select:focus, .form-textarea:focus {
                border-color: #007bff;
                box-shadow: 0 0 5px rgba(0,123,255,0.3);
                outline: none;
            }

            .grid {
                display: grid;
                grid-template-columns: repeat(2, minmax(0,1fr));
                gap: 16px;
            }

            .section {
                border: 1px solid #eee;
                border-radius: 10px;
                padding: 16px;
            }

            .section h3 {
                margin: 0 0 10px;
                font-size: 1.05rem;
                color: #2c3e50;
            }

            .btn {
                padding: 12px 24px;
                border-radius: 8px;
                border: none;
                font-weight: 600;
                font-size: 1rem;
                cursor: pointer;
                transition: background 0.2s;
                color: #fff;
                background: #007bff;
                text-align: center;
                text-decoration: none;
                display: inline-block;
                line-height: 1.2;
            }

            .btn:hover { background: #0056b3; }
            .btn-secondary { background: #6c757d; }
            .btn-secondary:hover { background: #545b62; }

            .success-message, .error-message {
                width: 100%;
                padding: 12px;
                font-weight: 600;
                text-align: center;
                border-radius: 6px;
                font-size: 0.95rem;
                margin-bottom: 16px;
                box-sizing: border-box;
            }
            .success-message { background: #d4edda; color: #155724; }
            .error-message { background: #f8d7da; color: #721c24; }

            @media (max-width: 700px) {
                .container { margin: 20px; padding: 20px; }
                .grid { grid-template-columns: 1fr; }
                .btn { width: 100%; }
            }
        </style>

    </head>
    <body>
        <%@ include file="partials/header.jsp" %>

        <div class="container">
            <h2>👤 Thông tin cá nhân</h2>

            <c:if test="${not empty success}">
                <div class="success-message">${success}</div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="error-message">${error}</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/profile" method="post" class="profile-form" autocomplete="off">
                <!-- Thông tin tài khoản -->
                <div class="section">
                    <h3>Thông tin tài khoản</h3>
                    <div class="grid">
                        <div class="form-group">
                            <label for="fullName" class="form-label">Tên hiển thị:</label>
                            <input type="text" id="fullName" name="fullName" class="form-input" value="${user.fullName}" maxlength="48" required>
                        </div>
                        <div class="form-group">
                            <label for="email" class="form-label">Email:</label>
                            <input type="email" id="email" name="email" class="form-input" value="${user.email}" maxlength="60" required>
                        </div>
                        <div class="form-group">
                            <label for="phoneNumber" class="form-label">Số điện thoại:</label>
                            <input type="text" id="phoneNumber" name="phoneNumber" class="form-input" value="${user.phoneNumber}" maxlength="20">
                        </div>
                        <div></div>
                        <div class="form-group">
                            <label for="password" class="form-label">Mật khẩu mới:</label>
                            <input type="password" id="password" name="password" class="form-input" autocomplete="new-password" minlength="6" maxlength="32">
                        </div>
                        <div class="form-group">
                            <label for="confirmPassword" class="form-label">Nhập lại mật khẩu:</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-input" autocomplete="new-password" minlength="6" maxlength="32">
                        </div>
                    </div>
                </div>

                <!-- Thông tin giao hàng mặc định -->
                <div class="section">
                    <h3>Thông tin giao hàng mặc định</h3>
                    <div class="grid">
                        <div class="form-group">
                            <label class="form-label" for="provinceId">Tỉnh/thành phố:</label>
                            <select name="provinceId" id="provinceId" class="form-select">
                                <option value="">-- Chọn tỉnh/thành phố --</option>
                                <option value="1"  <c:if test="${user.provinceId == 1}">selected</c:if>>TP Hà Nội</option>
                                <option value="2"  <c:if test="${user.provinceId == 2}">selected</c:if>>TP Huế</option>
                                <option value="3"  <c:if test="${user.provinceId == 3}">selected</c:if>>Quảng Ninh</option>
                                <option value="4"  <c:if test="${user.provinceId == 4}">selected</c:if>>Cao Bằng</option>
                                <option value="5"  <c:if test="${user.provinceId == 5}">selected</c:if>>Lạng Sơn</option>
                                <option value="6"  <c:if test="${user.provinceId == 6}">selected</c:if>>Lai Châu</option>
                                <option value="7"  <c:if test="${user.provinceId == 7}">selected</c:if>>Điện Biên</option>
                                <option value="8"  <c:if test="${user.provinceId == 8}">selected</c:if>>Sơn La</option>
                                <option value="9"  <c:if test="${user.provinceId == 9}">selected</c:if>>Thanh Hóa</option>
                                <option value="10" <c:if test="${user.provinceId == 10}">selected</c:if>>Nghệ An</option>
                                <option value="11" <c:if test="${user.provinceId == 11}">selected</c:if>>Hà Tĩnh</option>
                                <option value="12" <c:if test="${user.provinceId == 12}">selected</c:if>>Tuyên Quang</option>
                                <option value="13" <c:if test="${user.provinceId == 13}">selected</c:if>>Lào Cai</option>
                                <option value="14" <c:if test="${user.provinceId == 14}">selected</c:if>>Thái Nguyên</option>
                                <option value="15" <c:if test="${user.provinceId == 15}">selected</c:if>>Phú Thọ</option>
                                <option value="16" <c:if test="${user.provinceId == 16}">selected</c:if>>Bắc Ninh</option>
                                <option value="17" <c:if test="${user.provinceId == 17}">selected</c:if>>Hưng Yên</option>
                                <option value="18" <c:if test="${user.provinceId == 18}">selected</c:if>>TP Hải Phòng</option>
                                <option value="19" <c:if test="${user.provinceId == 19}">selected</c:if>>Ninh Bình</option>
                                <option value="20" <c:if test="${user.provinceId == 20}">selected</c:if>>Quảng Trị</option>
                                <option value="21" <c:if test="${user.provinceId == 21}">selected</c:if>>TP Đà Nẵng</option>
                                <option value="22" <c:if test="${user.provinceId == 22}">selected</c:if>>Quảng Ngãi</option>
                                <option value="23" <c:if test="${user.provinceId == 23}">selected</c:if>>Gia Lai</option>
                                <option value="24" <c:if test="${user.provinceId == 24}">selected</c:if>>Khánh Hòa</option>
                                <option value="25" <c:if test="${user.provinceId == 25}">selected</c:if>>Lâm Đồng</option>
                                <option value="26" <c:if test="${user.provinceId == 26}">selected</c:if>>Đắk Lắk</option>
                                <option value="27" <c:if test="${user.provinceId == 27}">selected</c:if>>TP Hồ Chí Minh</option>
                                <option value="28" <c:if test="${user.provinceId == 28}">selected</c:if>>Đồng Nai</option>
                                <option value="29" <c:if test="${user.provinceId == 29}">selected</c:if>>Tây Ninh</option>
                                <option value="30" <c:if test="${user.provinceId == 30}">selected</c:if>>TP Cần Thơ</option>
                                <option value="31" <c:if test="${user.provinceId == 31}">selected</c:if>>Vĩnh Long</option>
                                <option value="32" <c:if test="${user.provinceId == 32}">selected</c:if>>Đồng Tháp</option>
                                <option value="33" <c:if test="${user.provinceId == 33}">selected</c:if>>Cà Mau</option>
                                <option value="34" <c:if test="${user.provinceId == 34}">selected</c:if>>An Giang</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="address">Địa chỉ:</label>
                            <textarea id="address" name="address" rows="2" class="form-textarea" placeholder="Nhập địa chỉ chi tiết">${user.address}</textarea>
                        </div>
                    </div>
                </div>

                <!-- Thông tin hóa đơn (mặc định) -->
                <div class="section">
                    <h3>Thông tin xuất hóa đơn (mặc định)</h3>
                    <div class="grid">
                        <div class="form-group">
                            <label class="form-label" for="companyName">Tên công ty</label>
                            <input type="text" id="companyName" name="companyName" class="form-input" value="${user.companyName}">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="taxCode">Mã số thuế</label>
                            <input type="text" id="taxCode" name="taxCode" class="form-input" value="${user.taxCode}">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="taxEmail">Email nhận hóa đơn</label>
                            <input type="email" id="taxEmail" name="taxEmail" class="form-input" value="${user.taxEmail}">
                        </div>
                        <div></div>
                    </div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn">💾 Cập nhật</button>
                    <a href="${pageContext.request.contextPath}/products?action=list" class="btn btn-secondary">⬅ Về trang sản phẩm</a>
                </div>
            </form>
        </div>

        <%@ include file="partials/footer.jsp" %>
    </body>
</html>