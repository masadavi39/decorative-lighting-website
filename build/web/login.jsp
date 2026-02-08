<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đăng nhập</title>
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
                max-width: 400px;
                margin: 60px auto;
                padding: 20px;
            }

            .login-box {
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

            .login-button {
                width: 100%;
                background-color: #007bff;
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

            .login-button:hover {
                background-color: #0056b3;
            }

            .register-link {
                text-align: center;
                margin-top: 20px;
                color: #666;
            }

            .register-link a {
                color: #007bff;
                text-decoration: none;
            }

            .register-link a:hover {
                text-decoration: underline;
            }

            @media (max-width: 768px) {
                .container {
                    margin: 40px auto;
                }

                .login-box {
                    padding: 30px 20px;
                }
            }
        </style>
    </head>
    <body>
        <%@ include file="partials/header.jsp" %>

        <div class="container">
            <div class="login-box" role="form" aria-label="Form đăng nhập">
                <h2>🔐 Đăng nhập</h2>

                <c:if test="${not empty error}">
                    <div class="error-message" role="alert">
                        ❌ ${error}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/auth" method="post" novalidate>
                    <input type="hidden" name="action" value="login">

                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" name="email"
                               placeholder="Nhập email của bạn" required autocomplete="email">
                    </div>

                    <div class="form-group">
                        <label for="password">Mật khẩu:</label>
                        <input type="password" id="password" name="password"
                               placeholder="Nhập mật khẩu" required autocomplete="current-password">
                    </div>

                    <div class="form-group" style="display: flex; justify-content: space-between; align-items: center;">
                        <label>
                            <input type="checkbox" name="remember" value="true"> Ghi nhớ đăng nhập
                        </label>
                        <a href="${pageContext.request.contextPath}/forgot_password.jsp" style="color:#007bff; text-decoration:none;">Quên mật khẩu?</a>
                    </div>

                    <button type="submit" class="login-button">Đăng nhập</button>
                </form>

                <div class="register-link" aria-live="polite">
                    <p>Chưa có tài khoản?
                        <a href="${pageContext.request.contextPath}/auth?action=register">Đăng ký ngay</a>
                    </p>
                </div>
            </div>
        </div>

        <%@ include file="partials/footer.jsp" %>
    </body>
</html>