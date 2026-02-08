<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Chi tiết sản phẩm #${product.id}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="products" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid d-flex align-items-center justify-content-between">
        <h1>Chi tiết sản phẩm</h1>
        <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${product.id}" class="btn btn-sm btn-primary"><i class="fas fa-pen"></i> Sửa</a>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">
        <div class="card">
          <div class="card-body">
            <div class="row">
              <div class="col-md-4">
                <img src="${pageContext.request.contextPath}/${product.imagePath}" class="img-fluid rounded"
                     onerror="this.onerror=null;this.src='https://placehold.co/400x300?text=No+Img'">
              </div>
              <div class="col-md-8">
                <h3>${product.name}</h3>
                <p class="text-muted">${product.categoryName}</p>
                <p>${product.description}</p>
                <p>Giá: <strong class="text-danger">${product.price}₫</strong></p>
                <p>Giá KM: <strong class="text-success">${empty product.promoPrice ? '—' : product.promoPrice + '₫'}</strong></p>
                <p>Tồn kho: <strong>${product.quantity}</strong></p>
                <p>Đã bán: <strong>${product.soldQuantity}</strong></p>
                <p>Thương hiệu: <strong>${empty product.manufacturer ? '—' : product.manufacturer}</strong></p>
                <p>Trạng thái: <strong>${product.status}</strong></p>
              </div>
            </div>
          </div>
          <div class="card-footer">
            <a href="${pageContext.request.contextPath}/admin/products?action=list" class="btn btn-secondary">⬅ Quay lại</a>
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