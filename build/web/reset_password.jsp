<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đặt lại mật khẩu</title>
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
            input[type="password"] {
                width: 100%;
                padding: 8px;
                border-radius: 4px;
                border: 1px solid #ccc;
            }
            button {
                margin-top: 16px;
                width: 100%;
                padding: 10px;
                background: #28a745;
                color: #fff;
                border: none;
                border-radius: 4px;
                cursor: pointer;
            }
            button:hover {
                background: #218838;
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
        <div class="container" role="form" aria-label="Form đặt lại mật khẩu">
            <h2>🔑 Đặt lại mật khẩu</h2>

            <c:choose>
                <c:when test="${empty param.token}">
                    <div class="message error" role="alert">Token không hợp lệ hoặc đã hết hạn!</div>
                </c:when>
                <c:otherwise>
                    <form action="${pageContext.request.contextPath}/auth" method="post" novalidate>
                        <input type="hidden" name="action" value="reset-password">
                        <input type="hidden" name="token" value="${token}">

                        <label for="npw">Mật khẩu mới:</label>
                        <input type="password" id="npw" name="password" placeholder="Nhập mật khẩu mới" required autocomplete="new-password">

                        <label for="cpw">Xác nhận mật khẩu:</label>
                        <input type="password" id="cpw" name="confirm_password" placeholder="Nhập lại mật khẩu" required autocomplete="new-password">

                        <button type="submit">Cập nhật mật khẩu</button>
                    </form>
                </c:otherwise>
            </c:choose>

            <c:if test="${not empty message}">
                <div class="message ${messageType}" role="alert">
                    ${message}
                </div>
            </c:if>
        </div>
        <%@ include file="partials/footer.jsp" %>
    </body>
</html>