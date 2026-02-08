<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Chi tiết tài khoản</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="accounts" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header"><div class="container-fluid d-flex justify-content-between align-items-center">
      <h1>Chi tiết tài khoản</h1>
      <div>
        <a href="${pageContext.request.contextPath}/admin/account" class="btn btn-sm btn-secondary"><i class="fas fa-arrow-left"></i> Quay lại</a>
        <a href="${pageContext.request.contextPath}/admin/account?action=edit&id=${userDetail.id}" class="btn btn-sm btn-primary"><i class="fas fa-pen"></i> Sửa</a>
      </div>
    </div></section>

    <section class="content">
      <div class="container-fluid">
        <c:if test="${param.message ne null}">
          <div class="alert alert-info">${param.message}</div>
        </c:if>

        <div class="card">
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <p><strong>ID:</strong> #${userDetail.id}</p>
                <p><strong>Họ tên:</strong> <c:out value="${userDetail.fullName}"/></p>
                <p><strong>Email:</strong> <c:out value="${userDetail.email}"/></p>
                <p><strong>Vai trò:</strong>
                  <span class="badge ${userDetail.role=='admin'?'badge-info':'badge-secondary'}">${userDetail.role}</span>
                </p>
                <p><strong>Trạng thái:</strong>
                  <span class="badge ${userDetail.locked?'badge-danger':'badge-success'}">${userDetail.locked?'Đã khóa':'Hoạt động'}</span>
                </p>
              </div>
              <div class="col-md-6">
                <p><strong>Điện thoại:</strong> <c:out value="${userDetail.phoneNumber}"/></p>
                <p><strong>Địa chỉ:</strong> <c:out value="${userDetail.address}"/></p>
                <p><strong>Tỉnh/TP:</strong>
                  <c:choose>
                    <c:when test="${not empty userDetail.provinceId}">
                      <c:set var="pname" value=""/>
                      <c:forEach var="p" items="${provinces}">
                        <c:if test="${p.provinceId == userDetail.provinceId}"><c:set var="pname" value="${p.name}"/></c:if>
                      </c:forEach>
                      #${userDetail.provinceId} <c:if test="${not empty pname}">- ${pname}</c:if>
                    </c:when>
                    <c:otherwise><span class="text-muted">Chưa cập nhật</span></c:otherwise>
                  </c:choose>
                </p>
                <p><strong>Ngày tạo:</strong> <fmt:formatDate value="${userDetail.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                <p><strong>Đăng nhập gần nhất:</strong>
                  <c:choose>
                    <c:when test="${not empty userDetail.lastLoginAt}">
                      <fmt:formatDate value="${userDetail.lastLoginAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </c:when>
                    <c:otherwise><span class="text-muted">Chưa có</span></c:otherwise>
                  </c:choose>
                </p>
              </div>
            </div>
          </div>
          <div class="card-footer">
            <form action="${pageContext.request.contextPath}/admin/account" method="post" class="d-inline">
              <input type="hidden" name="action" value="toggleRole"/>
              <input type="hidden" name="id" value="${userDetail.id}"/>
              <button class="btn btn-sm btn-outline-info"><i class="fas fa-user-shield"></i> Đổi vai trò</button>
            </form>
            <form action="${pageContext.request.contextPath}/admin/account" method="post" class="d-inline">
              <input type="hidden" name="action" value="${userDetail.locked?'unlock':'lock'}"/>
              <input type="hidden" name="id" value="${userDetail.id}"/>
              <button class="btn btn-sm ${userDetail.locked?'btn-success':'btn-warning'}">
                <i class="fas ${userDetail.locked?'fa-lock-open':'fa-lock'}"></i> ${userDetail.locked?'Mở khóa':'Khóa'}
              </button>
            </form>
            <form action="${pageContext.request.contextPath}/admin/account" method="post" class="d-inline" onsubmit="return confirm('Xóa tài khoản này?');">
              <input type="hidden" name="action" value="delete"/>
              <input type="hidden" name="id" value="${userDetail.id}"/>
              <button class="btn btn-sm btn-danger"><i class="fas fa-trash"></i> Xóa</button>
            </form>
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