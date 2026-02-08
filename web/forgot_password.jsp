<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quên mật khẩu</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f4f4f4;
                margin: 0;
                padding: 0;
            }
            .container {
                max-width: 400px;
                margin: 80px auto;
                background: #fff;
                padding: 24px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
            h2 {
                text-align: center;
                margin-bottom: 24px;
            }
            label {
                display: block;
                margin: 12px 0 4px;
            }
            input[type="email"], input[type="password"] {
                width: 100%;
                padding: 8px;
                border-radius: 4px;
                border: 1px solid #ccc;
            }
            button {
                margin-top: 16px;
                width: 100%;
                padding: 10px;
                background: #007bff;
                color: #fff;
                border: none;
                border-radius: 4px;
                cursor: pointer;
            }
            button:hover {
                background: #0056b3;
            }
            .message {
                margin-top: 16px;
                padding: 10px;
                border-radius: 4px;
                text-align: center;
            }
            .error {
                background: #f8d7da;
                color: #842029;
            }
            .success {
                background: #d1e7dd;
                color: #0f5132;
            }
        </style>
    </head>
    <body>
        <%@ include file="partials/header.jsp" %>
        <div class="container" role="form" aria-label="Form quên mật khẩu">
            <h2>🔑 Quên mật khẩu</h2>
            <form action="${pageContext.request.contextPath}/auth" method="post" novalidate>
                <input type="hidden" name="action" value="forgot-password">
                <label for="fp_email">Email đăng ký:</label>
                <input type="email" id="fp_email" name="email" placeholder="Nhập email của bạn" required autocomplete="email">
                <button type="submit">Gửi liên kết đặt lại</button>
            </form>

            <c:if test="${not empty message}">
                <div class="message ${messageType}" role="alert">
                    ${message}
                </div>
            </c:if>
        </div>
        <%@ include file="partials/footer.jsp" %>
    </body>
</html>