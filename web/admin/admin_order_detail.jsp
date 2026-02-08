<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Chi tiết đơn hàng #${orderId}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="orders" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid"><h1>Chi tiết đơn hàng #${orderId}</h1></div>
    </section>

    <section class="content">
      <div class="container-fluid">
        <div class="card">
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped table-hover mb-0">
                <thead>
                  <tr>
                    <th>Ảnh</th>
                    <th>Tên sản phẩm</th>
                    <th>Số lượng</th>
                    <th>Giá</th>
                    <th>Tổng</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="d" items="${details}">
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/${d.product.imagePath}" width="70" height="70" class="img-thumbnail" style="object-fit:cover;"></td>
                      <td><c:out value="${d.product.name}"/></td>
                      <td><c:out value="${d.quantity}"/></td>
                      <td><fmt:formatNumber value="${d.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                      <td><fmt:formatNumber value="${d.quantity * d.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>₫</td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty details}">
                    <tr><td colspan="5" class="text-center text-muted py-3">Không có dữ liệu chi tiết.</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>
          <div class="card-footer">
            <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-secondary">⬅ Quay lại danh sách</a>
          </div>
        </div>
      </div>
    </section>
  </div>

  <footer class="main-footer"><strong>Light Admin</strong></footer>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
</body>
</html>