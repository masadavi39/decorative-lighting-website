<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Quản lý đơn hàng</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeGroup" value="sales" scope="request"/>
  <c:set var="activeMenu" value="orders" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid">
        <h1>Quản lý đơn hàng</h1>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">

        <div class="card">
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped table-hover mb-0">
                <thead>
                  <tr>
                    <th>Mã đơn</th>
                    <th>Người nhận</th>
                    <th>SĐT</th>
                    <th>Ngày đặt</th>
                    <th>Tổng tiền</th>
                    <th>Địa chỉ</th>
                    <th>Trạng thái</th>
                    <th style="width:280px;">Hành động</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="o" items="${orders}">
                    <tr>
                      <td>#${o.orderId}</td>
                      <td>${o.receiverName}</td>
                      <td>${o.phone}</td>
                      <td><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                      <td><span class="text-danger font-weight-bold"><fmt:formatNumber value="${o.totalPrice}" type="currency" currencySymbol="₫"/></span></td>
                      <td class="text-break">${o.address}</td>
                      <td>
                        <c:set var="badge" value="${o.status == 'Chờ duyệt' ? 'warning' : (o.status == 'Đã giao' ? 'success' : (o.status == 'Đã huỷ' ? 'danger' : 'info'))}" />
                        <span class="badge badge-${badge}">${o.status}</span>
                      </td>
                      <td>
                        <a href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${o.orderId}" class="btn btn-sm btn-info">
                          <i class="fas fa-search"></i> Xem
                        </a>
                        <form action="${pageContext.request.contextPath}/admin/orders" method="post" class="d-inline-flex align-items-center">
                          <input type="hidden" name="action" value="updateStatus">
                          <input type="hidden" name="orderId" value="${o.orderId}">
                          <select name="status" class="form-control form-control-sm mr-2">
                            <option value="Chờ duyệt" ${o.status == 'Chờ duyệt' ? 'selected' : ''}>Chờ duyệt</option>
                            <option value="Đang giao" ${o.status == 'Đang giao' ? 'selected' : ''}>Đang giao</option>
                            <option value="Đã giao" ${o.status == 'Đã giao' ? 'selected' : ''}>Đã giao</option>
                            <option value="Đã huỷ" ${o.status == 'Đã huỷ' ? 'selected' : ''}>Đã huỷ</option>
                          </select>
                          <button class="btn btn-sm btn-primary"><i class="fas fa-save"></i> Cập nhật</button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty orders}">
                    <tr><td colspan="8" class="text-center text-muted py-3">Chưa có đơn hàng nào.</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
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