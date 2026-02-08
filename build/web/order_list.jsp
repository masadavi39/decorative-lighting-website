<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đơn hàng của bạn</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Arial', sans-serif; background-color: #f8f9fa; color: #333; line-height: 1.6; }
            .container { max-width: 1200px; margin: 0 auto; padding: 30px 20px; }
            h2 { text-align: center; color: #2c3e50; margin-bottom: 30px; font-size: 2.2rem; }
            .orders-container { background: white; border-radius: 10px; padding: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .empty-orders { text-align: center; padding: 60px 20px; color: #666; }
            .empty-orders h3 { font-size: 1.5rem; margin-bottom: 15px; }
            table { width: 100%; border-collapse: collapse; }
            th, td { padding: 15px; text-align: center; border-bottom: 1px solid #dee2e6; }
            th { background-color: #f8f9fa; font-weight: 600; color: #495057; }
            .order-id { font-weight: bold; color: #007bff; }
            .status-badge { padding: 5px 12px; border-radius: 15px; font-size: 0.85rem; font-weight: 600; }
            .status-waiting { background-color: #fff3cd; color: #856404; }
            .status-shipping { background-color: #d1ecf1; color: #0c5460; }
            .status-delivered { background-color: #d4edda; color: #155724; }
            .status-cancelled { background-color: #f8d7da; color: #721c24; }
            .button { background-color: #007bff; color: white; border: none; padding: 6px 12px; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; font-size: 0.85rem; margin: 2px; transition: background-color 0.3s ease; }
            .button:hover { background-color: #0056b3; text-decoration: none; color: white; }
            .button.success { background-color: #28a745; }
            .button.success:hover { background-color: #218838; }
            .button.danger { background-color: #dc3545; }
            .button.danger:hover { background-color: #c82333; }
            .button.secondary { background-color: #6c757d; }
            .button.secondary:hover { background-color: #545b62; }
            .back-section { text-align: center; margin-top: 30px; }
            @media (max-width: 768px) {
                table { font-size: 0.85rem; }
                th, td { padding: 10px 5px; }
                .button { padding: 4px 8px; font-size: 0.75rem; }
            }
            .alert { padding: 12px 14px; border-radius: 8px; margin-bottom: 16px; font-size: 0.95rem; }
            .alert.success { background:#ecfdf5; color:#065f46; border:1px solid #a7f3d0; }
            .muted { color:#6b7280; font-size:.9rem; }
        </style>
    </head>
    <body>
        <%@ include file="partials/header.jsp" %>

        <div class="container">
            <h2>📦 Đơn hàng của bạn</h2>
            <!-- Thông báo sau khi checkout -->
            <c:if test="${param.success == '1'}">
                <div class="alert success">Đặt hàng thành công! Cảm ơn bạn đã mua sắm.</div>
            </c:if>
            <div class="orders-container">
                <c:choose>
                    <c:when test="${empty orders}">
                        <div class="empty-orders">
                            <h3>Chưa có đơn hàng</h3>
                            <p>Bạn chưa có đơn hàng nào.</p>
                            <a href="${pageContext.request.contextPath}/products?action=list" class="button">
                                Bắt đầu mua sắm
                            </a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Ngày đặt</th>
                                    <th>Tổng tiền</th>
                                    <th>Giảm giá</th>
                                    <th>Địa chỉ</th>
                                    <th>Trạng thái</th>
                                    <th>Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="o" items="${orders}">
                                    <tr>
                                        <td class="order-id">#${o.orderId}</td>
                                        <td><fmt:formatDate value="${o.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>

                                        <!-- Tổng tiền sau thuế/ship/giảm giá -->
                                        <td><fmt:formatNumber value="${o.totalPrice}" type="number" groupingUsed="true"/>₫</td>

                                        <!-- Cột giảm giá (nếu có) -->
                                        <td>
                                            <c:choose>
                                                <c:when test="${o.discountAmount > 0}">
                                                    -<fmt:formatNumber value="${o.discountAmount}" type="number" groupingUsed="true"/>₫
                                                    <c:if test="${not empty o.couponCode}">
                                                        <div class="muted">(${o.couponCode})</div>
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    0₫
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>${o.address}</td>
                                        <td>
                                            <span class="status-badge 
                                                  ${o.status == 'Chờ duyệt' ? 'status-waiting' :
                                                    o.status == 'Đang giao' ? 'status-shipping' :
                                                    o.status == 'Đã giao' ? 'status-delivered' : 'status-cancelled'}">
                                                      ${o.status}
                                                  </span>
                                            </td>
                                            <td>
                                                <a href="${pageContext.request.contextPath}/orders?action=detail&id=${o.orderId}" 
                                                   class="button">Xem</a>

                                                <c:if test="${o.status == 'Đang giao'}">
                                                    <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="confirm">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="button success">✅ Đã nhận</button>
                                                    </form>
                                                </c:if>

                                                <c:if test="${o.status == 'Chờ duyệt'}">
                                                    <form action="${pageContext.request.contextPath}/orders" method="post" style="display:inline;">
                                                        <input type="hidden" name="action" value="cancel">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <button type="submit" class="button danger">❌ Hủy</button>
                                                    </form>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>

                    <div class="back-section">
                        <a href="${pageContext.request.contextPath}/products?action=list" class="button secondary">
                            🛍️ Tiếp tục mua sắm
                        </a>
                    </div>
                </div>
            </div>

            <%@ include file="partials/footer.jsp" %>
        </body>
    </html>