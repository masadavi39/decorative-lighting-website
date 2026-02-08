<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Khách hàng & Đơn hàng</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="customers" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header"><div class="container-fluid"><h1>📋 Khách hàng & Lịch sử Đơn hàng</h1></div></section>

    <section class="content">
      <div class="container-fluid">
        <div class="card">
          <div class="card-header d-flex align-items-center justify-content-between">
            <div>
              <form method="get" action="${pageContext.request.contextPath}/admin/customers" class="form-inline">
                <label class="mr-2">Hiển thị</label>
                <select name="pageSize" class="form-control form-control-sm mr-2" onchange="this.form.submit()">
                  <c:set var="ps" value="${pageSize != null ? pageSize : 10}"/>
                  <option value="5" ${ps==5?'selected':''}>5</option>
                  <option value="10" ${ps==10?'selected':''}>10</option>
                  <option value="20" ${ps==20?'selected':''}>20</option>
                  <option value="50" ${ps==50?'selected':''}>50</option>
                </select>
                <input type="hidden" name="page" value="${currentPage}"/>
              </form>
            </div>
            <small class="text-muted">Tổng khách hàng: ${totalItems}</small>
          </div>
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped mb-0">
                <thead>
                  <tr>
                    <th style="width:5%">ID</th>
                    <th style="width:25%">Thông tin Khách hàng</th>
                    <th style="width:70%">Danh sách Đơn hàng</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="u" items="${users}">
                    <tr>
                      <td>#${u.id}</td>
                      <td>
                        <div class="font-weight-bold">${u.fullName}</div>
                        <div class="text-muted">📧 ${u.email}</div>
                        <div class="text-muted">📞 ${u.phoneNumber != null ? u.phoneNumber : 'Chưa cập nhật'}</div>
                        <div class="text-muted">tk: ${u.role}</div>
                      </td>
                      <td>
                        <c:set var="userOrders" value="${ordersByUser[u.id]}"/>
                        <c:choose>
                          <c:when test="${not empty userOrders}">
                            <table class="table table-sm table-bordered mb-0">
                              <thead class="thead-light">
                                <tr>
                                  <th>Mã Đơn</th>
                                  <th>Ngày đặt</th>
                                  <th>Tổng tiền</th>
                                  <th>Trạng thái</th>
                                  <th>Hành động</th>
                                </tr>
                              </thead>
                              <tbody>
                                <c:forEach var="order" items="${userOrders}">
                                  <tr>
                                    <td>#${order.orderId}</td>
                                    <td><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td class="text-danger font-weight-bold">
                                      <fmt:formatNumber value="${order.totalPrice}" type="currency" currencySymbol="₫"/>
                                    </td>
                                    <td>
                                      <span class="badge
                                        ${order.status == 'Chờ duyệt' ? 'badge-warning' :
                                          (order.status == 'Đang giao' ? 'badge-info' :
                                            (order.status == 'Đã giao' ? 'badge-success' : 'badge-danger'))}">
                                        ${order.status}
                                      </span>
                                    </td>
                                    <td>
                                      <a href="orders?action=detail&id=${order.orderId}" class="btn btn-sm btn-outline-primary">Xem chi tiết</a>
                                    </td>
                                  </tr>
                                </c:forEach>
                              </tbody>
                            </table>
                          </c:when>
                          <c:otherwise>
                            <span class="text-muted font-italic">Khách hàng này chưa có đơn hàng nào.</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty users}">
                    <tr><td colspan="3" class="text-center text-muted py-3">Không có khách hàng.</td></tr>
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
                     href="${pageContext.request.contextPath}/admin/customers?page=${i}&pageSize=${pageSize}">${i}</a>
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