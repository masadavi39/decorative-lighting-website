<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Quản trị đánh giá</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@5.15.4/css/all.min.css">
</head>
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">
  <%@ include file="/partials/admin_navbar.jspf" %>
  <%@ include file="/partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
  <!-- Header -->
  <section class="content-header">
    <div class="container-fluid">
      <div class="row mb-2">
        <div class="col-sm-6">
          <h1><i class="fas fa-star mr-2"></i>Đánh giá sản phẩm</h1>
        </div>
        <div class="col-sm-6">
          <ol class="breadcrumb float-sm-right">
            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
            <li class="breadcrumb-item active">Đánh giá</li>
          </ol>
        </div>
      </div>
    </div>
  </section>

  <!-- Main -->
  <section class="content">
    <div class="container-fluid">

      <!-- Alerts -->
      <c:if test="${param.done eq '1'}">
        <div class="alert alert-success alert-dismissible fade show">
          <i class="fas fa-check-circle mr-1"></i>Thao tác thành công.
          <button type="button" class="close" data-dismiss="alert">&times;</button>
        </div>
      </c:if>
      <c:if test="${param.error ne null}">
        <div class="alert alert-danger alert-dismissible fade show">
          <i class="fas fa-exclamation-triangle mr-1"></i>Lỗi: ${fn:escapeXml(param.error)}
          <button type="button" class="close" data-dismiss="alert">&times;</button>
        </div>
      </c:if>

      <!-- Bộ lọc -->
      <div class="card card-primary card-outline">
        <div class="card-header">
          <h3 class="card-title"><i class="fas fa-filter mr-1"></i>Lọc</h3>
        </div>
        <div class="card-body">
          <form class="form-inline flex-wrap" method="get">
            <div class="form-group mr-2 mb-2">
              <input type="text" name="keyword" value="${fn:escapeXml(keyword)}"
                     class="form-control form-control-sm" placeholder="Từ khóa (tiêu đề/nội dung/user/sản phẩm)">
            </div>
            <div class="form-group mr-2 mb-2">
              <input type="number" name="productId" value="${fn:escapeXml(productId)}"
                     class="form-control form-control-sm" placeholder="Product ID">
            </div>
            <div class="form-group mr-2 mb-2">
              <select name="approved" class="form-control form-control-sm">
                <option value="">-- Trạng thái --</option>
                <option value="1" ${approvedVal=='1'?'selected':''}>Đã duyệt</option>
                <option value="0" ${approvedVal=='0'?'selected':''}>Chờ duyệt</option>
              </select>
            </div>
            <button type="submit" class="btn btn-sm btn-primary mb-2 mr-2">
              <i class="fas fa-search mr-1"></i>Lọc
            </button>
            <a href="${pageContext.request.contextPath}/admin/reviews" class="btn btn-sm btn-secondary mb-2">
              <i class="fas fa-undo mr-1"></i>Reset
            </a>
          </form>
        </div>
      </div>

      <!-- Danh sách -->
      <div class="card">
        <div class="card-header">
          <h3 class="card-title"><i class="fas fa-list mr-1"></i>Danh sách đánh giá</h3>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-striped table-hover">
              <thead class="thead-light">
              <tr>
                <th>ID</th>
                <th>Sản phẩm</th>
                <th>User</th>
                <th>Rating</th>
                <th>Tiêu đề</th>
                <th>Nội dung</th>
                <th>Ngày</th>
                <th>Trạng thái</th>
                <th style="width:120px;">Thao tác</th>
              </tr>
              </thead>
              <tbody>
              <c:forEach var="rv" items="${reviews}">
                <tr>
                  <td>${rv.productReviewId}</td>
                  <td>
                    <a href="${pageContext.request.contextPath}/products?action=detail&id=${rv.productId}" target="_blank">
                      #${rv.productId}
                    </a><br/>
                    <c:if test="${not empty rv.productName}">
                      <small class="text-muted">${fn:escapeXml(rv.productName)}</small>
                    </c:if>
                  </td>
                  <td>${fn:escapeXml(rv.userName)}</td>
                  <td><span class="badge badge-info"><i class="fas fa-star"></i> ${rv.rating}/5</span></td>
                  <td class="text-truncate" style="max-width:260px;" title="${fn:escapeXml(rv.title)}">${fn:escapeXml(rv.title)}</td>
                  <td class="text-truncate" style="max-width:260px;" title="${fn:escapeXml(rv.content)}">${fn:escapeXml(rv.content)}</td>
                  <td><fmt:formatDate value="${rv.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                  <td>
                    <span class="badge ${rv.approved ? 'badge-success' : 'badge-warning'}">
                      ${rv.approved ? 'Đã duyệt' : 'Chờ duyệt'}
                    </span>
                  </td>
                  <td class="text-nowrap">
                    <a href="${pageContext.request.contextPath}/admin/reviews?detail=${rv.productReviewId}"
                       class="btn btn-xs btn-outline-primary" title="Chi tiết">
                      <i class="fas fa-eye"></i>
                    </a>
                    <form action="${pageContext.request.contextPath}/admin/reviews" method="post" class="d-inline">
                      <input type="hidden" name="action" value="approve">
                      <input type="hidden" name="productReviewId" value="${rv.productReviewId}">
                      <input type="hidden" name="approved" value="${rv.approved ? '0' : '1'}">
                      <button class="btn btn-xs ${rv.approved?'btn-outline-danger':'btn-outline-success'}" title="${rv.approved?'Bỏ duyệt':'Duyệt'}">
                        <i class="fas ${rv.approved?'fa-times-circle':'fa-check-circle'}"></i>
                      </button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty reviews}">
                <tr>
                  <td colspan="9" class="text-center text-muted font-italic">Không có đánh giá nào.</td>
                </tr>
              </c:if>
              </tbody>
            </table>
          </div>
        </div>
        <div class="card-footer">
          <ul class="pagination pagination-sm mb-0">
            <c:forEach begin="1" end="${totalPages}" var="i">
              <li class="page-item ${i==currentPage?'active':''}">
                <a class="page-link"
                   href="${pageContext.request.contextPath}/admin/reviews?page=${i
                   }&keyword=${fn:escapeXml(keyword)}&productId=${fn:escapeXml(productId)}&approved=${approvedVal}">${i}</a>
              </li>
            </c:forEach>
          </ul>
        </div>
      </div>

    </div>
  </section>
</div>

  <footer class="main-footer text-sm">
    <strong>Light Admin</strong>
    <div class="float-right d-none d-sm-inline-block">v1.0</div>
  </footer>
</div>

<!-- JS AdminLTE (CDN); sau khi OK đổi sang local trong assets/js -->
<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.4/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
</body>
</html>