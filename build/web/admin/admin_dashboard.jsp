<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Dashboard - Quản trị hệ thống</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    .truncate { max-width: 240px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
    .scroll-pane { max-height: 340px; overflow: auto; }
    .kpi .small-box .inner h3 { font-size: 1.6rem; }
    .card-body-tight { padding: .75rem 1rem; }
    .status-chip { display:inline-flex; align-items:center; gap:6px; padding:6px 10px; border-radius:999px; background:#f8fafc; border:1px solid #e5e7eb; margin:4px 6px 0 0; font-size:.85rem; }
    .chart-wrap { position: relative; height: 220px; }
  </style>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="dashboard" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid d-flex justify-content-between align-items-center">
        <h1 class="mb-0">Dashboard</h1>
        <ol class="breadcrumb float-sm-right mb-0"><li class="breadcrumb-item active">Dashboard</li></ol>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">

        <!-- KPI -->
        <div class="row kpi">
          <div class="col-6 col-md-3">
            <div class="small-box bg-info">
              <div class="inner">
                <h3><fmt:formatNumber value="${totalProducts}" type="number"/></h3>
                <p>Tổng sản phẩm</p>
              </div>
              <div class="icon"><i class="fas fa-boxes"></i></div>
              <a href="${pageContext.request.contextPath}/admin/products?action=list" class="small-box-footer">Chi tiết <i class="fas fa-arrow-circle-right"></i></a>
            </div>
          </div>
          <div class="col-6 col-md-3">
            <div class="small-box bg-success">
              <div class="inner">
                <h3><fmt:formatNumber value="${totalRevenue}" type="currency" currencySymbol="₫"/></h3>
                <p>Tổng doanh thu (Đã giao)</p>
              </div>
              <div class="icon"><i class="fas fa-sack-dollar"></i></div>
              <a href="${pageContext.request.contextPath}/admin/products?action=revenue" class="small-box-footer">Thống kê <i class="fas fa-arrow-circle-right"></i></a>
            </div>
          </div>
          <div class="col-6 col-md-3">
            <div class="small-box bg-warning">
              <div class="inner">
                <h3><fmt:formatNumber value="${totalRevenue * 0.2}" type="currency" currencySymbol="₫"/></h3>
                <p>Ước tính lãi (20%)</p>
              </div>
              <div class="icon"><i class="fas fa-chart-line"></i></div>
            </div>
          </div>
          <div class="col-6 col-md-3">
            <div class="small-box bg-primary">
              <div class="inner">
                <h3>
                  <c:choose>
                    <c:when test="${not empty orderStatusStats}">${orderStatusStats['Đã giao'] != null ? orderStatusStats['Đã giao'] : 0}</c:when>
                    <c:otherwise>0</c:otherwise>
                  </c:choose>
                </h3>
                <p>Đơn đã giao</p>
              </div>
              <div class="icon"><i class="fas fa-truck"></i></div>
            </div>
          </div>
        </div>

        <div class="row">
          <!-- Bên trái -->
          <div class="col-lg-8">
            <!-- Trạng thái đơn + biểu đồ -->
            <div class="card">
              <div class="card-header d-flex align-items-center justify-content-between">
                <h3 class="card-title mb-0"><i class="fas fa-chart-pie mr-1 text-success"></i>Trạng thái đơn hàng</h3>
              </div>
              <div class="card-body">
                <div class="chart-wrap mb-2">
                  <canvas id="orderStatusChart"></canvas>
                </div>
                <div>
                  <c:choose>
                    <c:when test="${not empty orderStatusStats}">
                      <c:forEach var="e" items="${orderStatusStats}">
                        <span class="status-chip">
                          <span class="badge" style="width:10px;height:10px;background:
                            ${e.key=='Chờ duyệt' ? '#f6ad55' :
                              (e.key=='Đang giao' ? '#63b3ed' :
                                (e.key=='Đã giao' ? '#68d391' : '#fc8181'))}"></span>
                          <strong>${e.key}</strong><span>${e.value}</span>
                        </span>
                      </c:forEach>
                    </c:when>
                    <c:otherwise><span class="text-muted">Chưa có dữ liệu.</span></c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>

            <!-- Đơn hàng gần nhất -->
            <div class="card">
              <div class="card-header d-flex align-items-center justify-content-between">
                <h3 class="card-title mb-0"><i class="fas fa-receipt mr-1"></i>Đơn hàng gần nhất</h3>
                <a class="btn btn-sm btn-outline-primary" href="${pageContext.request.contextPath}/admin/orders">Tất cả đơn</a>
              </div>
              <div class="card-body p-0">
                <div class="table-responsive">
                  <table class="table table-striped table-hover mb-0">
                    <thead class="thead-light">
                      <tr><th>#</th><th>Người nhận</th><th>Ngày</th><th>Tổng</th><th>TT</th><th></th></tr>
                    </thead>
                    <tbody>
                      <c:forEach var="o" items="${recentOrders}">
                        <tr>
                          <td>#${o.orderId}</td>
                          <td class="truncate" title="${fn:escapeXml(o.receiverName)}">${fn:escapeXml(o.receiverName)}</td>
                          <td><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                          <td class="text-danger font-weight-bold"><fmt:formatNumber value="${o.totalPrice}" type="currency" currencySymbol="₫"/></td>
                          <td><span class="badge badge-${o.status=='Chờ duyệt'?'warning':(o.status=='Đang giao'?'info':(o.status=='Đã giao'?'success':'danger'))}">${o.status}</span></td>
                          <td class="text-nowrap"><a class="btn btn-xs btn-outline-primary" href="${pageContext.request.contextPath}/admin/orders?action=detail&id=${o.orderId}"><i class="fas fa-eye"></i></a></td>
                        </tr>
                      </c:forEach>
                      <c:if test="${empty recentOrders}">
                        <tr><td colspan="6" class="text-center text-muted py-3">Chưa có dữ liệu.</td></tr>
                      </c:if>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

          </div>

          <!-- Bên phải -->
          <div class="col-lg-4">
            <!-- Thông báo -->
            <div class="card card-outline card-warning">
              <div class="card-header"><h3 class="card-title mb-0"><i class="fas fa-bell"></i> Thông báo hệ thống</h3></div>
              <div class="card-body card-body-tight">
                <c:choose>
                  <c:when test="${not empty systemNotices}">
                    <ul class="pl-3 mb-0">
                      <c:forEach var="n" items="${systemNotices}">
                        <li>${n}</li>
                      </c:forEach>
                    </ul>
                  </c:when>
                  <c:otherwise><span class="text-muted">Không có thông báo.</span></c:otherwise>
                </c:choose>
              </div>
            </div>

            <!-- Coupon sắp hết hạn -->
            <div class="card card-outline card-danger">
              <div class="card-header"><h3 class="card-title mb-0"><i class="fas fa-ticket-alt"></i> Coupon sắp hết hạn</h3></div>
              <div class="card-body p-0">
                <div class="table-responsive">
                  <table class="table table-sm table-striped mb-0">
                    <thead><tr><th>Mã</th><th>Kết thúc</th><th>Đã dùng</th></tr></thead>
                    <tbody>
                      <c:forEach var="c" items="${expiringCoupons}">
                        <tr>
                          <td><strong>${c.code}</strong></td>
                          <td><fmt:formatDate value="${c.endDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                          <td>${c.usedCount != null ? c.usedCount : 0}</td>
                        </tr>
                      </c:forEach>
                      <c:if test="${empty expiringCoupons}">
                        <tr><td colspan="3" class="text-center text-muted py-2">Không có coupon sắp hết hạn.</td></tr>
                      </c:if>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>

            <!-- Bán chạy -->
            <div class="card card-outline card-info">
              <div class="card-header"><h3 class="card-title mb-0"><i class="fas fa-fire"></i> Sản phẩm bán chạy</h3></div>
              <div class="card-body p-2 scroll-pane">
                <c:forEach var="p" items="${bestSelling}">
                  <div class="d-flex align-items-center mb-2">
                    <img src="${pageContext.request.contextPath}/${p.imagePath}" class="img-thumbnail mr-2" style="width:44px;height:44px;object-fit:cover" onerror="this.src='https://placehold.co/44x44'"/>
                    <div class="flex-fill">
                      <div class="truncate" title="${fn:escapeXml(p.name)}">${fn:escapeXml(p.name)}</div>
                      <small class="text-muted">Đã bán: ${p.soldQuantity}</small>
                    </div>
                    <div class="text-danger font-weight-bold"><fmt:formatNumber value="${p.price}" type="currency" currencySymbol="₫"/></div>
                  </div>
                </c:forEach>
                <c:if test="${empty bestSelling}"><p class="text-muted mb-0">Chưa có dữ liệu.</p></c:if>
              </div>
            </div>

            <!-- Top khách hàng -->
            <div class="card card-outline card-primary">
              <div class="card-header"><h3 class="card-title mb-0"><i class="fas fa-crown"></i> Top khách hàng</h3></div>
              <div class="card-body p-2 scroll-pane">
                <c:forEach var="u" items="${topUsers}" varStatus="vs">
                  <div class="d-flex align-items-center border-bottom py-2 mb-2">
                    <div class="mr-2">
                      <span class="img-circle bg-info text-white d-flex align-items-center justify-content-center" style="width:40px;height:40px;font-size:18px;">
                        <c:out value="${fn:substring(u.full_name,0,1)}" />
                      </span>
                    </div>
                    <div class="flex-fill">
                      <strong><span class="text-warning">#${vs.index + 1}</span> ${u.full_name}</strong><br>
                      <small class="text-muted">${u.email}</small><br>
                      <small class="text-muted"><i class="fas fa-shopping-cart"></i>
                        <c:choose><c:when test="${u.orderCount > 0}">${u.orderCount} đơn</c:when><c:otherwise>Chưa có đơn</c:otherwise></c:choose>
                      </small>
                    </div>
                    <div class="text-success font-weight-bold" style="font-size:14px;">
                      <fmt:formatNumber value="${u.totalSpent}" type="currency" currencySymbol="₫"/>
                    </div>
                  </div>
                </c:forEach>
                <c:if test="${empty topUsers}"><p class="text-muted mb-0">Chưa có dữ liệu.</p></c:if>
              </div>
            </div>

          </div>
        </div>

        <!-- Đánh giá mới nhất -->
        <div class="card">
          <div class="card-header d-flex align-items-center justify-content-between">
            <h3 class="card-title mb-0"><i class="fas fa-star text-warning mr-1"></i> Đánh giá mới nhất</h3>
            <a href="${pageContext.request.contextPath}/admin/reviews" class="btn btn-sm btn-outline-primary">Tất cả</a>
          </div>
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped mb-0">
                <thead class="thead-light">
                <tr><th>ID</th><th>Sản phẩm</th><th>User</th><th>Rating</th><th>TT</th><th>Ngày</th></tr>
                </thead>
                <tbody>
                <c:forEach var="rv" items="${latestReviews}">
                  <tr>
                    <td>${rv.productReviewId}</td>
                    <td class="truncate" title="${fn:escapeXml(rv.productName)}">
                      <a href="${pageContext.request.contextPath}/products?action=detail&id=${rv.productId}" target="_blank">#${rv.productId}</a>
                    </td>
                    <td class="truncate" title="${fn:escapeXml(rv.userName)}">${fn:escapeXml(rv.userName)}</td>
                    <td><span class="badge badge-info"><i class="fas fa-star"></i> ${rv.rating}</span></td>
                    <td><span class="badge ${rv.approved ? 'badge-success' : 'badge-warning'}">${rv.approved ? 'Duyệt' : 'Chờ'}</span></td>
                    <td><fmt:formatDate value="${rv.createdAt}" pattern="MM-dd HH:mm"/></td>
                  </tr>
                </c:forEach>
                <c:if test="${empty latestReviews}">
                  <tr><td colspan="6" class="text-center text-muted py-3">Chưa có đánh giá.</td></tr>
                </c:if>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      </div>
    </section>
  </div>

  <footer class="main-footer">
    <strong>Light Admin</strong>
    <div class="float-right d-none d-sm-inline-block"><b>AdminLTE</b> 3</div>
  </footer>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
<script>
  // Pie trạng thái đơn
  const statusLabels = [], statusValues = [], statusColors = [];
  <c:forEach var="e" items="${orderStatusStats}">
    statusLabels.push('<c:out value="${e.key}"/>');
    statusValues.push(<c:out value="${e.value}"/>);
  </c:forEach>
  const colorMap = {'Chờ duyệt':'#f6ad55','Đang giao':'#63b3ed','Đã giao':'#68d391','Đã hủy':'#fc8181','Đã huỷ':'#fc8181'};
  statusLabels.forEach(l => statusColors.push(colorMap[l] || '#a0aec0'));
  const ctx = document.getElementById('orderStatusChart').getContext('2d');
  new Chart(ctx, {
    type: 'doughnut',
    data: { labels: statusLabels, datasets: [{ data: statusValues, backgroundColor: statusColors }] },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: 'bottom' } },
      cutout: '55%'
    }
  });
</script>
</body>
</html>