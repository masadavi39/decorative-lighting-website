<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>${title}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="revenue" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid"><h1>${title}</h1></div>
    </section>

    <section class="content">
      <div class="container-fluid">
        <div class="card">
          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped table-hover mb-0">
                <thead>
                  <tr>
                    <th>Ảnh</th>
                    <th>Tên sản phẩm</th>
                    <th>Số lượng bán</th>
                    <th>Doanh thu (VND)</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="item" items="${details}">
                    <tr>
                      <td><img src="${pageContext.request.contextPath}/${item[0]}" class="img-thumbnail" style="width:60px;height:60px;object-fit:cover;" onerror="this.src='https://placehold.co/60x60?text=No+Img'"></td>
                      <td class="text-left font-weight-500">${item[1]}</td>
                      <td><span class="badge badge-info">${item[2]}</span></td>
                      <td class="text-success font-weight-bold"><fmt:formatNumber value="${item[3]}" type="number" groupingUsed="true"/></td>
                    </tr>
                  </c:forEach>
                  <c:if test="${empty details}">
                    <tr><td colspan="4" class="text-center text-muted py-3">Không có dữ liệu doanh thu cho thời gian này.</td></tr>
                  </c:if>
                </tbody>
              </table>
            </div>
          </div>
          <div class="card-footer">
            <a href="${pageContext.request.contextPath}/admin/products?action=revenue" class="btn btn-secondary">⬅ Quay lại thống kê</a>
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