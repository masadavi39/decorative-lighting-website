<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Sửa tài khoản</title>
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
      <h1>Sửa tài khoản</h1>
      <div>
        <a href="${pageContext.request.contextPath}/admin/account?action=detail&id=${userEdit.id}" class="btn btn-sm btn-secondary"><i class="fas fa-arrow-left"></i> Quay lại chi tiết</a>
      </div>
    </div></section>

    <section class="content">
      <div class="container-fluid">
        <c:if test="${not empty error}"><div class="alert alert-danger">${error}</div></c:if>

        <form action="${pageContext.request.contextPath}/admin/account" method="post">
          <input type="hidden" name="action" value="update"/>
          <input type="hidden" name="id" value="${userEdit.id}"/>

          <div class="card card-primary">
            <div class="card-header"><h3 class="card-title">Thông tin cơ bản</h3></div>
            <div class="card-body">
              <div class="form-row">
                <div class="form-group col-md-6">
                  <label>Họ tên</label>
                  <input type="text" name="fullName" class="form-control" required value="${userEdit.fullName}"/>
                </div>
                <div class="form-group col-md-6">
                  <label>Email</label>
                  <input type="email" name="email" class="form-control" required value="${userEdit.email}"/>
                </div>
              </div>
              <div class="form-row">
                <div class="form-group col-md-6">
                  <label>Mật khẩu mới (để trống nếu không đổi)</label>
                  <input type="password" name="password" class="form-control" />
                </div>
                <div class="form-group col-md-6">
                  <label>Điện thoại</label>
                  <input type="text" name="phoneNumber" class="form-control" value="${userEdit.phoneNumber}"/>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-8">
                  <label>Địa chỉ</label>
                  <input type="text" name="address" class="form-control" value="${userEdit.address}"/>
                </div>
                <div class="form-group col-md-4">
                  <label>Tỉnh/TP</label>
                  <select name="provinceId" class="form-control">
                    <option value="">-- Chọn --</option>
                    <c:forEach var="p" items="${provinces}">
                      <option value="${p.provinceId}" ${userEdit.provinceId == p.provinceId ? 'selected' : ''}>${p.name}</option>
                    </c:forEach>
                  </select>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-4">
                  <label>Vai trò</label>
                  <select name="role" class="form-control">
                    <option value="user" ${userEdit.role=='user' ? 'selected' : ''}>user</option>
                    <option value="admin" ${userEdit.role=='admin' ? 'selected' : ''}>admin</option>
                  </select>
                </div>
                <div class="form-group col-md-4">
                  <label>Trạng thái</label><br/>
                  <div class="form-check mt-2">
                    <input class="form-check-input" type="checkbox" id="locked" name="locked" ${userEdit.locked ? 'checked' : ''}/>
                    <label class="form-check-label" for="locked">Khóa tài khoản</label>
                  </div>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-4">
                  <label>Tên công ty</label>
                  <input type="text" name="companyName" class="form-control" value="${userEdit.companyName}"/>
                </div>
                <div class="form-group col-md-4">
                  <label>Mã số thuế</label>
                  <input type="text" name="taxCode" class="form-control" value="${userEdit.taxCode}"/>
                </div>
                <div class="form-group col-md-4">
                  <label>Email nhận hóa đơn</label>
                  <input type="email" name="taxEmail" class="form-control" value="${userEdit.taxEmail}"/>
                </div>
              </div>

            </div>
            <div class="card-footer">
              <button class="btn btn-primary"><i class="fas fa-save"></i> Lưu thay đổi</button>
              <a href="${pageContext.request.contextPath}/admin/account?action=detail&id=${userEdit.id}" class="btn btn-secondary">Hủy</a>
            </div>
          </div>
        </form>
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