<%@page import="model.User"%>
<%@page import="java.util.List"%>
<%@page import="dao.UserDAO"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    // Lấy dữ liệu đã được set từ Servlet: users, message, filters, paging
    String message = (String) request.getAttribute("message");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Tài khoản người dùng</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
  <style>
    .badge-role-user { background-color:#6c757d; }     /* xám đậm */
    .badge-role-admin{ background-color:#17a2b8; }     /* xanh cyan */
    .badge-role-super{ background-color:#6610f2; }     /* tím nếu có super */
    .badge-status-active { background:#28a745; }
    .badge-status-locked { background:#dc3545; }
    .table td, .table th { vertical-align: middle; }
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="accounts" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header"><div class="container-fluid"><h1>Tài khoản người dùng</h1></div></section>

    <section class="content">
      <div class="container-fluid">

        <!-- Bộ lọc nâng cao -->
        <div class="card card-primary card-outline">
          <div class="card-header d-flex align-items-center justify-content-between">
            <h3 class="card-title mb-0"><i class="fas fa-filter"></i> Lọc nâng cao</h3>
            <c:if test="${not empty message}">
              <span class="badge badge-info">${message}</span>
            </c:if>
          </div>
          <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin/account" class="form-inline flex-wrap">
              <div class="form-group mr-2 mb-2">
                <input type="text" name="search" class="form-control form-control-sm" placeholder="Từ khoá (tên/email/điện thoại)" value="${param.search}">
              </div>
              <div class="form-group mr-2 mb-2">
                <select name="role" class="form-control form-control-sm">
                  <option value="">-- Vai trò --</option>
                  <option value="user" ${param.role=='user'?'selected':''}>User</option>
                  <option value="admin" ${param.role=='admin'?'selected':''}>Admin</option>
                </select>
              </div>
              <div class="form-group mr-2 mb-2">
                <select name="status" class="form-control form-control-sm">
                  <option value="">-- Trạng thái --</option>
                  <option value="active" ${param.status=='active'?'selected':''}>Hoạt động</option>
                  <option value="locked" ${param.status=='locked'?'selected':''}>Đã khoá</option>
                </select>
              </div>
              <div class="form-group mr-2 mb-2">
                <input type="date" name="createdFrom" value="${param.createdFrom}" class="form-control form-control-sm" placeholder="Tạo từ">
              </div>
              <div class="form-group mr-2 mb-2">
                <input type="date" name="createdTo" value="${param.createdTo}" class="form-control form-control-sm" placeholder="Tạo đến">
              </div>
              <button type="submit" class="btn btn-sm btn-primary mb-2 mr-2"><i class="fas fa-search"></i> Lọc</button>
              <a href="${pageContext.request.contextPath}/admin/account" class="btn btn-sm btn-secondary mb-2"><i class="fas fa-undo"></i> Reset</a>
            </form>
          </div>
        </div>

        <div class="card">
          <div class="card-header d-flex align-items-center justify-content-between">
            <h3 class="card-title mb-0"><i class="fas fa-users"></i> Danh sách tài khoản</h3>
            <a href="${pageContext.request.contextPath}/admin/account?action=export" class="btn btn-sm btn-outline-info">
              <i class="fas fa-file-export"></i> Export
            </a>
          </div>

          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped mb-0">
                <thead>
                  <tr>
                    <th style="width:70px">ID</th>
                    <th>Tên</th>
                    <th>Email</th>
                    <th>Vai trò</th>
                    <th>Trạng thái</th>
                    <th>Ngày tạo</th>
                    <th>Đăng nhập gần nhất</th>
                    <th style="width:280px">Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="user" items="${users}">
                    <tr>
                      <td>#${user.id}</td>
                      <td class="text-break">${user.fullName}</td>
                      <td class="text-break">${user.email}</td>
                      <td>
                        <c:choose>
                          <c:when test="${user.role == 'admin'}"><span class="badge badge-role-admin">admin</span></c:when>
                          <c:otherwise><span class="badge badge-role-user">user</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td>
                        <span class="badge ${user.locked ? 'badge-status-locked' : 'badge-status-active'}">
                          ${user.locked ? 'Đã khóa' : 'Hoạt động'}
                        </span>
                      </td>
                      <td>
                        <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${not empty user.lastLoginAt}">
                            <fmt:formatDate value="${user.lastLoginAt}" pattern="dd/MM/yyyy HH:mm"/>
                          </c:when>
                          <c:otherwise><span class="text-muted">Chưa có</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="text-nowrap">
                        <a href="${pageContext.request.contextPath}/admin/account?action=detail&id=${user.id}" class="btn btn-xs btn-info">
                          <i class="fas fa-eye"></i> Xem
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/account?action=edit&id=${user.id}" class="btn btn-xs btn-primary">
                          <i class="fas fa-pen"></i> Sửa
                        </a>
                        <form action="${pageContext.request.contextPath}/admin/account" method="post" class="d-inline">
                          <input type="hidden" name="action" value="${user.locked ? 'unlock' : 'lock'}">
                          <input type="hidden" name="id" value="${user.id}">
                          <button class="btn btn-xs ${user.locked ? 'btn-success' : 'btn-warning'}">
                            <i class="fas ${user.locked ? 'fa-lock-open' : 'fa-lock'}"></i> ${user.locked ? 'Mở khóa' : 'Khóa'}
                          </button>
                        </form>
                        <form action="${pageContext.request.contextPath}/admin/account" method="post" class="d-inline" onsubmit="return confirm('Xoá tài khoản này?');">
                          <input type="hidden" name="action" value="delete">
                          <input type="hidden" name="id" value="${user.id}">
                          <button class="btn btn-xs btn-danger"><i class="fas fa-trash"></i> Xoá</button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty users}">
                    <tr><td colspan="8" class="text-center text-muted py-3">Không có dữ liệu.</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>

          <div class="card-footer">
            <!-- Phân trang -->
            <ul class="pagination pagination-sm mb-0">
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${i==currentPage?'active':''}">
                  <a class="page-link"
                     href="${pageContext.request.contextPath}/admin/account?page=${i
                     }&search=${fn:escapeXml(param.search)
                     }&role=${fn:escapeXml(param.role)
                     }&status=${fn:escapeXml(param.status)
                     }&createdFrom=${fn:escapeXml(param.createdFrom)
                     }&createdTo=${fn:escapeXml(param.createdTo)}">${i}</a>
                </li>
              </c:forEach>
            </ul>
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