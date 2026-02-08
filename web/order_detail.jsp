<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn hàng</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f8f9fa;
            color: #333;
            line-height: 1.6;
        }
        .container { max-width:1000px; margin:0 auto; padding:30px 20px; }
        .order-container {
            background:#fff; border-radius:10px; padding:30px;
            box-shadow:0 2px 10px rgba(0,0,0,0.1);
        }
        h2 { text-align:center; color:#2c3e50; margin-bottom:30px; font-size:2.2rem; }
        .info-box { background:#f8f9fa; padding:20px; border-radius:8px; margin-bottom:30px; }
        .info-item {
            display:flex; justify-content:space-between;
            margin-bottom:10px; padding:8px 0;
            border-bottom:1px solid #dee2e6;
        }
        .info-item:last-child { border-bottom:none; }
        .info-label { font-weight:600; color:#495057; }
        .status-badge {
            padding:5px 12px; border-radius:15px;
            font-size:0.85rem; font-weight:600;
        }
        .status-waiting { background:#fff3cd; color:#856404; }
        .status-shipping { background:#d1ecf1; color:#0c5460; }
        .status-delivered { background:#d4edda; color:#155724; }
        .status-cancelled { background:#f8d7da; color:#721c24; }
        table { width:100%; border-collapse:collapse; margin-bottom:30px; }
        th, td { padding:15px; text-align:center; border-bottom:1px solid #dee2e6; }
        th { background:#f8f9fa; font-weight:600; color:#495057; }
        .product-image {
            width:60px; height:60px; object-fit:cover; border-radius:5px;
        }
        .total-section {
            text-align:right; font-size:1.05rem; font-weight:bold;
            padding:20px; background:#e9ecef; border-radius:8px;
            margin-bottom:30px;
        }
        .total-line { display:flex; justify-content:space-between; gap:12px; margin:4px 0; }
        .total-line strong { font-size:1.15rem; }
        .total-divider { border-top:1px solid #ced4da; margin:10px 0; }
        .button {
            background:#007bff; color:#fff; border:none;
            padding:10px 20px; border-radius:5px; cursor:pointer;
            text-decoration:none; display:inline-block; margin:5px;
            transition:background-color .3s ease;
        }
        .button:hover { background:#0056b3; color:#fff; }
        .button.danger { background:#dc3545; }
        .button.danger:hover { background:#c82333; }
        .button.success { background:#28a745; }
        .button.success:hover { background:#218838; }
        .button.secondary { background:#6c757d; }
        .button.secondary:hover { background:#545b62; }
        .actions { text-align:center; margin-top:30px; }
        .completion-message { text-align:center; color:#28a745; font-weight:600; font-size:1.1rem; }
        @media (max-width: 768px) {
            table { font-size:0.9rem; }
            th, td { padding:10px 5px; }
            .info-item { flex-direction:column; gap:5px; }
            .total-line { font-size:.95rem; }
        }
    </style>
</head>
<body>
<%@ include file="partials/header.jsp" %>

<div class="container">
    <div class="order-container">
        <h2>📦 Chi tiết đơn hàng #${order.orderId}</h2>

        <div class="info-box">
            <div class="info-item">
                <span class="info-label">👤 Người đặt:</span>
                <span>${sessionScope.user.fullName}</span>
            </div>
            <div class="info-item">
                <span class="info-label">📍 Địa chỉ giao hàng:</span>
                <span>${order.address}</span>
            </div>
            <div class="info-item">
                <span class="info-label">📊 Trạng thái:</span>
                <span class="status-badge 
                    ${order.status == 'Chờ duyệt' ? 'status-waiting' :
                      order.status == 'Đang giao' ? 'status-shipping' :
                      order.status == 'Đã giao' ? 'status-delivered' : 'status-cancelled'}">
                    ${order.status}
                </span>
            </div>
            <div class="info-item">
                <span class="info-label">📅 Ngày đặt:</span>
                <span><fmt:formatDate value="${order.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span>
            </div>
        </div>

        <table>
            <thead>
            <tr>
                <th>Hình ảnh</th>
                <th>Sản phẩm</th>
                <th>Giá</th>
                <th>Số lượng</th>
                <th>Thành tiền</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="d" items="${details}">
                <tr>
                    <td>
                        <img src="${pageContext.request.contextPath}/${d.product.imagePath}"
                             alt="${d.product.name}" class="product-image">
                    </td>
                    <td>${d.product.name}</td>
                    <td><fmt:formatNumber value="${d.price}" type="number" groupingUsed="true"/>₫</td>
                    <td>${d.quantity}</td>
                    <td><fmt:formatNumber value="${d.price * d.quantity}" type="number" groupingUsed="true"/>₫</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>

        <!-- Tính subtotal từ chi tiết để hiển thị breakdown -->
        <c:set var="subtotal" value="0"/>
        <c:forEach var="d" items="${details}">
            <c:set var="subtotal" value="${subtotal + (d.price * d.quantity)}"/>
        </c:forEach>

        <div class="total-section">
            <div class="total-line">
                <span>Tạm tính</span>
                <span><fmt:formatNumber value="${subtotal}" type="number" groupingUsed="true"/>₫</span>
            </div>
            <div class="total-line">
                <span>Phí vận chuyển</span>
                <span><fmt:formatNumber value="${order.shippingFee}" type="number" groupingUsed="true"/>₫</span>
            </div>
            <div class="total-line">
                <span>Thuế</span>
                <span><fmt:formatNumber value="${order.tax}" type="number" groupingUsed="true"/>₫</span>
            </div>

            <c:if test="${order.discountAmount > 0}">
                <div class="total-line">
                    <span>Giảm theo coupon
                        <c:if test="${not empty order.couponCode}">
                            (<strong>${order.couponCode}</strong>)
                        </c:if>
                    </span>
                    <span>-<fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true"/>₫</span>
                </div>
            </c:if>

            <div class="total-divider"></div>
            <div class="total-line">
                <strong>Tổng tiền</strong>
                <strong><fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/>₫</strong>
            </div>
        </div>

        <div class="actions">
            <c:choose>
                <c:when test="${order.status == 'Chờ duyệt'}">
                    <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="cancel"/>
                        <input type="hidden" name="orderId" value="${order.orderId}"/>
                        <button type="submit" class="button danger">❌ Hủy đơn hàng</button>
                    </form>
                </c:when>
                <c:when test="${order.status == 'Đang giao'}">
                    <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="confirm"/>
                        <input type="hidden" name="orderId" value="${order.orderId}"/>
                        <button type="submit" class="button success">✅ Xác nhận đã nhận</button>
                    </form>
                </c:when>
                <c:when test="${order.status == 'Đã giao'}">
                    <p class="completion-message">✅ Đơn hàng đã hoàn thành!</p>
                </c:when>
                <%-- Trạng thái hủy --%>
                <c:when test="${order.status == 'Đã hủy'}">
                    <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="reorder"/>
                        <input type="hidden" name="orderId" value="${order.orderId}"/>
                        <button type="submit" class="button secondary">🛒 Đặt lại</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="delete"/>
                        <input type="hidden" name="orderId" value="${order.orderId}"/>
                        <button type="submit" class="button danger">🗑 Xóa</button>
                    </form>
                </c:when>
                <c:otherwise>
                    <p>Trạng thái không xác định.</p>
                </c:otherwise>
            </c:choose>

            <br><br>
            <a href="${pageContext.request.contextPath}/orders?action=list" class="button secondary">
                ⬅ Quay lại danh sách
            </a>
        </div>
    </div>
</div>

<%@ include file="partials/footer.jsp" %>
</body>
</html>