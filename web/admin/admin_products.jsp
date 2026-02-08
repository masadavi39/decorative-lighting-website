<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Quản lý sản phẩm</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
  <style>
    .truncate { max-width: 260px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .status-pill { display:inline-block; padding:2px 8px; border-radius:999px; font-size:12px; }
    .st-active { background:#e6fffa; color:#0f766e; border:1px solid #99f6e4; }
    .st-inactive { background:#f1f5f9; color:#334155; border:1px solid #cbd5e1; }
    .st-out { background:#fee2e2; color:#991b1b; border:1px solid #fecaca; }
    .img-50 { width:60px; height:60px; object-fit:cover; }
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="products" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid d-flex align-items-center justify-content-between">
        <h1>Quản lý sản phẩm</h1>
        <a href="${pageContext.request.contextPath}/admin/products?action=add" class="btn btn-sm btn-success">
          <i class="fas fa-plus"></i> Thêm sản phẩm
        </a>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">

        <div class="card card-primary card-outline">
          <div class="card-header"><i class="fas fa-filter mr-1"></i> Bộ lọc nâng cao</div>
          <div class="card-body">
            <form method="get" class="form-inline flex-wrap">
              <input type="hidden" name="action" value="list">
              <div class="form-group mr-2 mb-2">
                <input type="text" name="keyword" class="form-control form-control-sm" placeholder="Tên/Mô tả/Thương hiệu" value="${keyword}">
              </div>
              <div class="form-group mr-2 mb-2">
                <select name="categoryId" class="form-control form-control-sm">
                  <option value="">-- Danh mục --</option>
                  <c:forEach var="c" items="${categories}">
                    <option value="${c.categoryId}" ${categoryId == c.categoryId ? 'selected' : ''}>${c.name}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="form-group mr-2 mb-2">
                <input type="number" name="minPrice" class="form-control form-control-sm" placeholder="Giá từ" step="0.01" value="${minPrice}">
              </div>
              <div class="form-group mr-2 mb-2">
                <input type="number" name="maxPrice" class="form-control form-control-sm" placeholder="Giá đến" step="0.01" value="${maxPrice}">
              </div>
              <div class="form-group mr-2 mb-2">
                <select name="status" class="form-control form-control-sm">
                  <option value="">-- Trạng thái --</option>
                  <option value="active" ${status=='active'?'selected':''}>Đang bán</option>
                  <option value="inactive" ${status=='inactive'?'selected':''}>Tạm ẩn</option>
                  <option value="out_of_stock" ${status=='out_of_stock'?'selected':''}>Hết hàng</option>
                  <option value="all" ${status=='all'?'selected':''}>Tất cả</option>
                </select>
              </div>
              <div class="form-group mr-2 mb-2">
                <select name="sort" class="form-control form-control-sm">
                  <option value="">Sắp xếp</option>
                  <option value="price_asc" ${sort=='price_asc'?'selected':''}>Giá tăng</option>
                  <option value="price_desc" ${sort=='price_desc'?'selected':''}>Giá giảm</option>
                  <option value="name_asc" ${sort=='name_asc'?'selected':''}>Tên A-Z</option>
                  <option value="name_desc" ${sort=='name_desc'?'selected':''}>Tên Z-A</option>
                </select>
              </div>
              <button class="btn btn-sm btn-primary mb-2 mr-2"><i class="fas fa-search"></i> Lọc</button>
              <a href="${pageContext.request.contextPath}/admin/products?action=list" class="btn btn-sm btn-secondary mb-2"><i class="fas fa-undo"></i> Reset</a>
            </form>
          </div>
        </div>

        <div class="card">
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped table-hover mb-0">
                <thead>
                  <tr>
                    <th style="width:70px;">ID</th>
                    <th>Danh mục</th>
                    <th>Tên</th>
                    <th style="width:160px;">Giá</th>
                    <th style="width:120px;">Khuyến mãi</th>
                    <th style="width:90px;">Tồn kho</th>
                    <th style="width:110px;">Trạng thái</th>
                    <th style="width:90px;">Ảnh</th>
                    <th style="width:220px;">Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="p" items="${products}">
                    <tr>
                      <td>${p.id}</td>
                      <td class="truncate" title="${p.categoryName}">${p.categoryName}</td>
                      <td class="truncate" title="${p.name}">${p.name}</td>
                      <td>
                        <span class="text-danger font-weight-bold"><c:out value="${p.price}"/>₫</span>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${not empty p.promoPrice}">
                            <span class="text-success font-weight-bold"><c:out value="${p.promoPrice}"/>₫</span>
                          </c:when>
                          <c:otherwise><span class="text-muted">—</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>${p.quantity}</td>
                      <td>
                        <c:choose>
                          <c:when test="${p.status=='active'}"><span class="status-pill st-active">Đang bán</span></c:when>
                          <c:when test="${p.status=='inactive'}"><span class="status-pill st-inactive">Tạm ẩn</span></c:when>
                          <c:otherwise><span class="status-pill st-out">Hết hàng</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <img src="${pageContext.request.contextPath}/${p.imagePath}"
                             alt="${p.name}" class="img-50 img-thumbnail"
                             onerror="this.onerror=null;this.src='https://placehold.co/60x60?text=No+Img';">
                      </td>
                      <td class="text-nowrap">
                        <a href="${pageContext.request.contextPath}/admin/products?action=detail&id=${p.id}" class="btn btn-xs btn-outline-primary">
                          <i class="fas fa-eye"></i> Xem
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.id}" class="btn btn-xs btn-primary">
                          <i class="fas fa-pen"></i> Sửa
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/products?action=delete&id=${p.id}" class="btn btn-xs btn-danger"
                           onclick="return confirm('Xoá sản phẩm này?');">
                          <i class="fas fa-trash"></i> Xoá
                        </a>
                        <form action="${pageContext.request.contextPath}/admin/products" method="post" class="d-inline">
                          <input type="hidden" name="action" value="toggleStatus">
                          <input type="hidden" name="id" value="${p.id}">
                          <input type="hidden" name="to" value="${p.status=='inactive'?'active':'inactive'}">
                          <button class="btn btn-xs ${p.status=='inactive'?'btn-success':'btn-secondary'}">
                            <i class="fas ${p.status=='inactive'?'fa-toggle-on':'fa-toggle-off'}"></i>
                            ${p.status=='inactive'?'Bật':'Ẩn'}
                          </button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty products}">
                    <tr><td colspan="9" class="text-center text-muted py-3">Chưa có sản phẩm.</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>
          <div class="card-footer d-flex align-items-center justify-content-between">
            <div class="text-muted">Tổng: ${totalItems} sản phẩm</div>
            <ul class="pagination pagination-sm mb-0">
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${i==page?'active':''}">
                  <a class="page-link"
                     href="${pageContext.request.contextPath}/admin/products?action=list&page=${i
                     }&pageSize=${pageSize
                     }&keyword=${keyword
                     }&categoryId=${categoryId
                     }&minPrice=${minPrice
                     }&maxPrice=${maxPrice
                     }&status=${status
                     }&sort=${sort}">${i}</a>
                </li>
              </c:forEach>
            </ul>
          </div>
        </div>

      </div>
    </section>
  </div>

  <footer class="main-footer">
    <strong>Light Admin</strong>
  </footer>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
</body>
</html>