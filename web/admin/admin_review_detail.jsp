<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
  // Không đặt gì trong scriptlet; chỉ giữ lại taglib ở trên
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Chi tiết đánh giá #${review.productReviewId}</title>

  <c:set var="cPath" value="${pageContext.request.contextPath}" />

  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@5.15.4/css/all.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css">
 
</head>
<body class="hold-transition sidebar-mini layout-fixed">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <!-- Header -->
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6">
            <h1><i class="fas fa-star mr-2"></i>Chi tiết đánh giá</h1>
          </div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="${cPath}/admin/dashboard">Dashboard</a></li>
              <li class="breadcrumb-item"><a href="${cPath}/admin/reviews">Đánh giá</a></li>
              <li class="breadcrumb-item active">Chi tiết</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Main -->
    <section class="content">
      <div class="container-fluid">

        <a href="${cPath}/admin/reviews" class="btn btn-sm btn-secondary mb-3">
          <i class="fas fa-arrow-left mr-1"></i>Quay lại danh sách
        </a>

        <c:if test="${empty review}">
          <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle mr-1"></i>Không tìm thấy đánh giá.
          </div>
        </c:if>

        <c:if test="${not empty review}">
          <!-- Review info -->
          <div class="card card-info">
            <div class="card-header d-flex align-items-center justify-content-between">
              <h3 class="card-title mb-0"><i class="fas fa-info-circle mr-1"></i>Đánh giá #${review.productReviewId}</h3>
              <span class="badge ${review.approved?'badge-success':'badge-warning'}">
                ${review.approved?'Đã duyệt':'Chờ duyệt'}
              </span>
            </div>
            <div class="card-body">
              <div class="row">
                <div class="col-md-6 col-lg-4">
                  <p><strong>Sản phẩm:</strong>
                    <a href="${cPath}/products?action=detail&id=${review.productId}" target="_blank">
                      #${review.productId}
                    </a>
                  </p>
                </div>
                <div class="col-md-6 col-lg-4">
                  <p><strong>User:</strong> ${fn:escapeXml(review.userName)}</p>
                </div>
                <div class="col-md-6 col-lg-4">
                  <p><strong>Rating:</strong> <span class="badge badge-info"><i class="fas fa-star"></i> ${review.rating}/5</span></p>
                </div>
                <div class="col-md-6 col-lg-4">
                  <p><strong>Ngày:</strong> <fmt:formatDate value="${review.createdAt}" pattern="yyyy-MM-dd HH:mm"/></p>
                </div>
              </div>

              <p><strong>Tiêu đề:</strong> ${fn:escapeXml(review.title)}</p>
              <p style="white-space:pre-line;">${fn:escapeXml(review.content)}</p>

              <form action="${cPath}/admin/reviews" method="post" class="mt-2">
                <input type="hidden" name="action" value="approve">
                <input type="hidden" name="productReviewId" value="${review.productReviewId}">
                <input type="hidden" name="approved" value="${review.approved? '0':'1'}">
                <button class="btn ${review.approved?'btn-danger':'btn-success'} btn-sm">
                  <i class="fas ${review.approved?'fa-times':'fa-check'} mr-1"></i>${review.approved?'Bỏ duyệt':'Duyệt'}
                </button>
              </form>

              <c:if test="${param.done eq '1'}">
                <div class="alert alert-success mt-3 mb-0 py-2">
                  <i class="fas fa-check-circle mr-1"></i>Cập nhật trạng thái thành công!
                </div>
              </c:if>
            </div>
          </div>

          <!-- Replies -->
          <div class="card card-primary">
            <div class="card-header">
              <h3 class="card-title mb-0"><i class="fas fa-comments mr-1"></i>Phản hồi</h3>
              <div class="card-tools">
                <c:if test="${not empty review.replies}">
                  <span class="badge badge-light">${fn:length(review.replies)} phản hồi</span>
                </c:if>
              </div>
            </div>
            <div class="card-body">
              <c:if test="${empty review.replies}">
                <p class="text-muted font-italic mb-3">Chưa có phản hồi nào.</p>
              </c:if>

              <c:forEach var="rp" items="${review.replies}">
                <div class="border-left pl-2 mb-3">
                  <div class="d-flex justify-content-between">
                    <strong>${fn:escapeXml(rp.userName)}</strong>
                    <small class="text-muted"><fmt:formatDate value="${rp.createdAt}" pattern="yyyy-MM-dd HH:mm"/></small>
                  </div>
                  <div style="white-space:pre-line;" class="mt-1">${fn:escapeXml(rp.content)}</div>
                </div>
              </c:forEach>

              <form action="${cPath}/admin/reviews" method="post" class="mt-2">
                <input type="hidden" name="action" value="reply">
                <input type="hidden" name="productReviewId" value="${review.productReviewId}">
                <div class="form-group">
                  <label for="replyContent"><i class="fas fa-reply mr-1"></i>Phản hồi mới</label>
                  <textarea id="replyContent" name="replyContent" class="form-control" rows="3" required
                            placeholder="Nội dung phản hồi..."></textarea>
                </div>
                <button class="btn btn-primary btn-sm">
                  <i class="fas fa-paper-plane mr-1"></i>Gửi phản hồi
                </button>
              </form>

              <c:if test="${param.replied eq '1'}">
                <div class="alert alert-success mt-3 mb-0 py-2">
                  <i class="fas fa-check-circle mr-1"></i>Đã thêm phản hồi.
                </div>
              </c:if>
              <!-- Nếu trước đó bạn đã đổi tham số về emptyReply, dùng dòng dưới -->
              <c:if test="${param.emptyReply == '1'}">
                <div class="alert alert-warning mt-3 mb-0 py-2">
                  <i class="fas fa-exclamation-triangle mr-1"></i>Nội dung phản hồi trống.
                </div>
              </c:if>
            </div>
          </div>
        </c:if>

      </div>
    </section>
  </div>

  <footer class="main-footer text-sm">
    <strong>Light Admin</strong>
    <div class="float-right d-none d-sm-inline-block">v1.0</div>
  </footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.6.4/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>

</body>
</html>