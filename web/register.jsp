<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đăng ký tài khoản</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Arial', sans-serif;
                background-color: #f8f9fa;
                color: #333;
                line-height: 1.6;
            }

            .container {
                max-width: 450px;
                margin: 60px auto;
                padding: 20px;
            }

            .register-box {
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }

            h2 {
                text-align: center;
                color: #2c3e50;
                margin-bottom: 30px;
                font-size: 2rem;
            }

            .error-message {
                background-color: #f8d7da;
                color: #721c24;
                padding: 12px;
                border-radius: 5px;
                margin-bottom: 20px;
                border: 1px solid #f5c6cb;
            }

            .form-group {
                margin-bottom: 20px;
            }

            label {
                display: block;
                margin-bottom: 8px;
                font-weight: 600;
                color: #495057;
            }

            input[type="text"],
            input[type="email"],
            input[type="password"] {
                width: 100%;
                padding: 12px;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 1rem;
            }

            input:focus {
                outline: none;
                border-color: #007bff;
                box-shadow: 0 0 5px rgba(0,123,255,0.3);
            }

            .register-button {
                width: 100%;
                background-color: #28a745;
                color: white;
                border: none;
                padding: 12px;
                border-radius: 5px;
                font-size: 1rem;
                font-weight: 600;
                cursor: pointer;
                margin-top: 10px;
                transition: background-color 0.3s ease;
            }

            .register-button:hover {
                background-color: #218838;
            }

            .login-link {
                text-align: center;
                margin-top: 20px;
                color: #666;
            }

            .login-link a {
                color: #007bff;
                text-decoration: none;
            }

            .login-link a:hover {
                text-decoration: underline;
            }

            @media (max-width: 768px) {
                .container {
                    margin: 40px auto;
                }

                .register-box {
                    padding: 30px 20px;
                }
            }
        </style>
    </head>
    <body>
        <%@ include file="partials/header.jsp" %>

        <div class="container">
            <div class="register-box" role="form" aria-label="Form đăng ký">
                <h2>📝 Đăng ký tài khoản</h2>

                <c:if test="${not empty error}">
                    <div class="error-message" role="alert">
                        ❌ ${error}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/auth" method="post" novalidate>
                    <input type="hidden" name="action" value="register">

                    <div class="form-group">
                        <label for="fullName">Họ và tên:</label>
                        <input type="text" id="fullName" name="fullName"
                               placeholder="Nhập họ và tên" required autocomplete="name">
                    </div>

                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email"
                               placeholder="Nhập email" required autocomplete="email">
                    </div>

                    <div class="form-group otp-group">
                        <label for="otp">Mã xác thực (OTP):</label>
                        <div style="display:flex; gap:10px; align-items:center;">
                            <input type="text" id="otp" name="otp" placeholder="Nhập mã OTP" required style="flex:1;" inputmode="numeric" autocomplete="one-time-code">
                            <button type="button" id="sendOtpBtn" style="
                                    background-color:#007bff;
                                    color:white;
                                    border:none;
                                    padding:12px 20px;
                                    border-radius:5px;
                                    cursor:pointer;
                                    " aria-live="polite">Gửi lại mã</button>
                        </div>
                        <div id="otpHelper" style="margin-top:8px; font-size:.9rem; color:#666;"></div>
                    </div>

                    <div class="form-group">
                        <label for="password">Mật khẩu:</label>
                        <input type="password" id="password" name="password"
                               placeholder="Nhập mật khẩu" required autocomplete="new-password">
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Nhập lại mật khẩu:</label>
                        <input type="password" id="confirmPassword" name="confirmPassword"
                               placeholder="Nhập lại mật khẩu" required autocomplete="new-password">
                    </div>

                    <button type="submit" class="register-button">Đăng ký</button>
                </form>

                <div class="login-link" aria-live="polite">
                    <p>Đã có tài khoản?
                        <a href="${pageContext.request.contextPath}/auth?action=login">Đăng nhập</a>
                    </p>
                </div>
            </div>
        </div>

        <%@ include file="partials/footer.jsp" %>

        <script>
            // Chức năng gửi OTP với đếm ngược 30 giây
            (function(){
                const btn = document.getElementById('sendOtpBtn');
                const emailEl = document.getElementById('email');
                const helper = document.getElementById('otpHelper');
                let countdown = null;

                function startCountdown(seconds){
                    let remain = seconds;
                    btn.disabled = true;
                    btn.style.opacity = '.7';
                    renderText(remain);
                    countdown = setInterval(()=>{
                        remain--;
                        renderText(remain);
                        if(remain <= 0){
                            clearInterval(countdown);
                            countdown = null;
                            btn.disabled = false;
                            btn.style.opacity = '';
                            btn.textContent = 'Gửi lại mã';
                            if (helper) helper.textContent = 'Bạn có thể gửi lại OTP.';
                        }
                    }, 1000);
                }
                function renderText(remain){
                    btn.textContent = `Gửi lại trong ${remain}s`;
                    if (helper) helper.textContent = `Vui lòng kiểm tra email để lấy OTP. Bạn có thể gửi lại sau ${remain} giây.`;
                }

                btn.addEventListener('click', function () {
                    if (btn.disabled) return;
                    const email = (emailEl.value || '').trim();
                    if (!email) {
                        alert("Vui lòng nhập email trước khi gửi OTP!");
                        emailEl.focus();
                        return;
                    }
                    // Gọi API gửi OTP
                    fetch('${pageContext.request.contextPath}/auth?action=sendOtp&email=' + encodeURIComponent(email), {
                        method: 'GET',
                        headers: {'X-Requested-With': 'XMLHttpRequest'}
                    })
                    .then(response => response.text())
                    .then(data => {
                        alert(data || "Đã gửi OTP. Vui lòng kiểm tra email.");
                        startCountdown(30);
                    })
                    .catch(err => {
                        alert("Gửi OTP thất bại: " + err);
                    });
                });
            })();
        </script>

    </body>
</html>