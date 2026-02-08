<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Quản lý Coupon</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.7/dist/sweetalert2.min.css"/>
  <style>
    .badge-type { border-radius: 999px; padding: 6px 10px; font-size: .8rem; }
    .badge-type-percent { background: #e6fffa; color:#0b7285; border:1px solid #99e9f2; }
    .badge-type-fixed { background: #fff3bf; color:#7f4f24; border:1px solid #ffe08a; }

    .progress-thin { height: 8px; border-radius: 999px; background:#f1f5f9; }
    .progress-thin .bar { height: 100%; border-radius: 999px; background: linear-gradient(90deg,#22c55e,#eab308,#ef4444); }

    .toolbar .form-control, .toolbar .custom-select { margin-right:.5rem; }
    .toolbar .btn { margin-right:.5rem; }

    /* Bảng co theo nội dung, header không bẻ chữ; cột dài cho wrap, cột khác giữ nguyên */
    .table-responsive { overflow-x: auto; }
    .table-coupons { table-layout: auto; width: 100%; }
    .table-coupons th { white-space: nowrap; word-break: keep-all; }
    .table-coupons td { vertical-align: middle; }

    .wrap   { white-space: normal; word-break: break-word; }
    .nowrap { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    /* Min-width để tránh cột quá hẹp; sẽ cuộn ngang nếu không đủ chỗ */
    .col-id     { min-width: 60px; }
    .col-code   { min-width: 110px; }
    .col-type   { min-width: 120px; }
    .col-value  { min-width: 110px; }
    .col-min, .col-max, .col-limit { min-width: 110px; }
    .col-used   { min-width: 160px; }
    .col-status { min-width: 120px; }
    .col-actions{ min-width: 260px; }
  </style>
</head>

<body class="hold-transition sidebar-mini">
<div class="wrapper">

  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="coupons" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">

    <!-- HEADER -->
    <section class="content-header">
      <div class="container-fluid">
        <h1>Quản lý Coupon</h1>
        <div class="mt-2">
          <c:if test="${param.done eq 'add'}"><span class="badge badge-success">Đã thêm coupon</span></c:if>
          <c:if test="${param.done eq 'update'}"><span class="badge badge-success">Đã cập nhật</span></c:if>
          <c:if test="${param.done eq 'toggle'}"><span class="badge badge-info">Đã đổi trạng thái</span></c:if>
          <c:if test="${param.done eq 'delete'}"><span class="badge badge-danger">Đã xóa</span></c:if>
          <c:if test="${param.error eq 'duplicate'}"><span class="badge badge-warning">Mã coupon đã tồn tại!</span></c:if>
          <c:if test="${param.error eq 'notfound'}"><span class="badge badge-warning">Không tìm thấy coupon!</span></c:if>
        </div>
      </div>
    </section>

    <!-- MAIN -->
    <section class="content">
      <div class="container-fluid">

        <!-- Toolbar: Bộ lọc (2 date) + tìm theo mã + loại + pageSize + Nút Thêm coupon -->
        <div class="card card-primary card-outline">
          <div class="card-body d-flex align-items-end flex-wrap toolbar">
            <form class="form-inline d-flex align-items-end flex-wrap" method="get" action="${pageContext.request.contextPath}/admin/coupons">
              <input type="hidden" name="action" value="list"/>

              <div class="form-group mr-2">
                <label class="mr-2 mb-0">Start at</label>
                <input type="date" name="startAt" class="form-control form-control-sm" value="${startAt}">
              </div>

              <div class="form-group mr-2">
                <label class="mr-2 mb-0">End at</label>
                <input type="date" name="endAt" class="form-control form-control-sm" value="${endAt}">
              </div>

              <div class="form-group mr-2">
                <label class="mr-2 mb-0">Mã</label>
                <input type="text" name="keyword" class="form-control form-control-sm" placeholder="VD: SAVE10" value="${keyword}">
              </div>

              <div class="form-group mr-2">
                <label class="mr-2 mb-0">Loại</label>
                <select name="type" class="custom-select custom-select-sm" style="min-width:120px;">
                  <option value="">-- Tất cả --</option>
                  <option value="percent" ${type=='percent'?'selected':''}>Phần trăm</option>
                  <option value="fixed" ${type=='fixed'?'selected':''}>Cố định</option>
                </select>
              </div>

              <div class="form-group mr-2">
                <select name="pageSize" class="custom-select custom-select-sm">
                  <option value="10" ${pageSize==10?'selected':''}>10</option>
                  <option value="20" ${pageSize==20?'selected':''}>20</option>
                  <option value="50" ${pageSize==50?'selected':''}>50</option>
                </select>
              </div>

              <button class="btn btn-sm btn-primary"><i class="fas fa-search"></i> Lọc</button>
              <a href="${pageContext.request.contextPath}/admin/coupons?action=list" class="btn btn-sm btn-secondary">
                <i class="fas fa-undo"></i> Reset
              </a>
            </form>

            <div class="ml-auto">
              <button class="btn btn-sm btn-success" data-toggle="modal" data-target="#couponModal">
                <i class="fas fa-plus"></i> Thêm coupon
              </button>
            </div>
          </div>
        </div>

        <!-- DANH SÁCH COUPON -->
        <div class="card">
          <div class="card-header d-flex align-items-center">
            <h3 class="card-title mb-0"><i class="fas fa-list"></i> Danh sách coupon</h3>
          </div>

          <div class="card-body p-0">
            <div class="table-responsive">
              <table class="table table-striped mb-0 table-coupons">
                <thead>
                  <tr>
                    <th class="col-id">ID</th>
                    <th class="col-code">Mã</th>
                    <th class="wrap">Mô tả</th>
                    <th class="col-type">Loại</th>
                    <th class="col-value">Giá trị</th>
                    <th class="wrap">Hiệu lực</th>
                    <th class="col-min">Tối thiểu</th>
                    <th class="col-max">Tối đa</th>
                    <th class="col-limit">Giới hạn</th>
                    <th class="col-used">Đã dùng</th>
                    <th class="col-status">Trạng thái</th>
                    <th class="col-actions">Hành động</th>
                  </tr>
                </thead>

                <tbody>
                  <c:forEach var="c" items="${coupons}">
                    <tr>
                      <td class="nowrap">${c.id}</td>
                      <td class="nowrap"><strong>${c.code}</strong></td>
                      <td class="wrap">${c.description}</td>

                      <!-- LOẠI -->
                      <td class="nowrap">
                        <span class="badge-type ${c.discountType == 'percent' ? 'badge-type-percent' : 'badge-type-fixed'}">
                          <i class="fas ${c.discountType == 'percent' ? 'fa-percent' : 'fa-dollar-sign'}"></i>
                          <c:choose>
                            <c:when test="${c.discountType == 'percent'}">Phần trăm</c:when>
                            <c:otherwise>Cố định</c:otherwise>
                          </c:choose>
                        </span>
                      </td>

                      <!-- GIÁ TRỊ -->
                      <td class="nowrap">
                        <c:choose>
                          <c:when test="${c.discountType == 'percent'}">${c.value}%</c:when>
                          <c:otherwise><fmt:formatNumber value="${c.value}" type="number" groupingUsed="true" maxFractionDigits="0"/> VND</c:otherwise>
                        </c:choose>
                      </td>

                      <!-- HIỆU LỰC -->
                      <td class="wrap">
                        <small><fmt:formatDate value="${c.startDate}" pattern="yyyy-MM-dd HH:mm"/></small><br/>
                        <small><fmt:formatDate value="${c.endDate}" pattern="yyyy-MM-dd HH:mm"/></small>
                      </td>

                      <!-- MIN - MAX - LIMIT -->
                      <td class="nowrap">${c.minSubtotal != null ? c.minSubtotal : '-'}</td>
                      <td class="nowrap">${c.maxDiscount != null ? c.maxDiscount : '-'}</td>
                      <td class="nowrap">${c.usageLimit != null ? c.usageLimit : '-'}</td>

                      <!-- ĐÃ DÙNG: progress theo usage_limit -->
                      <td class="nowrap">
                        <div class="d-flex align-items-center">
                          <strong>${c.usedCount != null ? c.usedCount : 0}</strong>
                          <c:if test="${c.usageLimit != null}">
                            <span class="text-muted ml-1">/ ${c.usageLimit}</span>
                          </c:if>
                        </div>
                        <c:if test="${c.usageLimit != null}">
                          <c:set var="used" value="${c.usedCount != null ? c.usedCount : 0}"/>
                          <c:set var="limit" value="${c.usageLimit}"/>
                          <c:set var="uRatio" value="${limit > 0 ? (used * 1.0 / limit) : 0}"/>
                          <div class="progress-thin mt-1">
                            <div class="bar" style="width:
                              <c:choose>
                                <c:when test="${uRatio <= 0}">0%</c:when>
                                <c:when test="${uRatio >= 1}">100%</c:when>
                                <c:otherwise><fmt:formatNumber value="${uRatio * 100}" type="number" maxFractionDigits="0"/>%</c:otherwise>
                              </c:choose>"></div>
                          </div>
                        </c:if>
                      </td>

                      <!-- TRẠNG THÁI -->
                      <td class="nowrap">
                        <span class="badge ${c.active ? 'badge-success' : 'badge-secondary'}">
                          ${c.active ? 'Đang kích hoạt' : 'Đã tắt'}
                        </span>
                      </td>

                      <!-- ACTIONS -->
                      <td class="text-nowrap">
                        <a class="btn btn-sm btn-info"
                           href="${pageContext.request.contextPath}/admin/coupons?action=edit&code=${c.code}">
                          <i class="fas fa-pen"></i> Sửa
                        </a>
                        <form action="${pageContext.request.contextPath}/admin/coupons"
                              method="post" class="d-inline">
                          <input type="hidden" name="action" value="toggle"/>
                          <input type="hidden" name="id" value="${c.id}"/>
                          <input type="hidden" name="active" value="${c.active ? '0' : '1'}"/>
                          <button class="btn btn-sm ${c.active ? 'btn-warning' : 'btn-success'}">
                            <i class="fas ${c.active ? 'fa-toggle-off' : 'fa-toggle-on'}"></i>
                            ${c.active ? 'Tắt' : 'Bật'}
                          </button>
                        </form>
                        <button class="btn btn-sm btn-danger"
                                onclick="confirmDelete(${c.id}, '${c.code}')">
                          <i class="fas fa-trash"></i> Xóa
                        </button>
                      </td>

                    </tr>
                  </c:forEach>

                  <c:if test="${empty coupons}">
                    <tr><td colspan="12" class="text-center text-muted py-3">Chưa có coupon.</td></tr>
                  </c:if>

                </tbody>
              </table>
            </div>
          </div>

          <div class="card-footer d-flex justify-content-between align-items-center">
            <div>Trang ${currentPage} / ${totalPages}</div>
            <ul class="pagination pagination-sm mb-0">
              <li class="page-item ${currentPage==1?'disabled':''}">
                <a class="page-link"
                   href="${pageContext.request.contextPath}/admin/coupons?action=list&page=${currentPage-1
                   }&startAt=${startAt}&endAt=${endAt}&keyword=${keyword}&type=${type}&pageSize=${pageSize}">«</a>
              </li>
              <c:forEach begin="1" end="${totalPages}" var="i">
                <li class="page-item ${i==currentPage?'active':''}">
                  <a class="page-link"
                     href="${pageContext.request.contextPath}/admin/coupons?action=list&page=${i
                     }&startAt=${startAt}&endAt=${endAt}&keyword=${keyword}&type=${type}&pageSize=${pageSize}">${i}</a>
                </li>
              </c:forEach>
              <li class="page-item ${currentPage==totalPages?'disabled':''}">
                <a class="page-link"
                   href="${pageContext.request.contextPath}/admin/coupons?action=list&page=${currentPage+1
                   }&startAt=${startAt}&endAt=${endAt}&keyword=${keyword}&type=${type}&pageSize=${pageSize}">»</a>
              </li>
            </ul>
          </div>
        </div>

      </div>
    </section>
  </div>

  <!-- Modal Thêm/Sửa coupon -->
  <div class="modal fade" id="couponModal" tabindex="-1" role="dialog" aria-hidden="true" data-edit="${not empty editCoupon ? '1' : '0'}">
    <div class="modal-dialog modal-lg" role="document">
      <form action="${pageContext.request.contextPath}/admin/coupons" method="post" class="modal-content">
        <input type="hidden" name="action" value="${empty editCoupon ? 'add' : 'update'}"/>
        <div class="modal-header">
          <h5 class="modal-title">
            <i class="fas fa-ticket-alt mr-1"></i>
            <c:choose><c:when test="${not empty editCoupon}">Sửa coupon</c:when><c:otherwise>Thêm coupon</c:otherwise></c:choose>
          </h5>
          <button type="button" class="close" data-dismiss="modal"><span>&times;</span></button>
        </div>
        <div class="modal-body">
          <div class="form-row">
            <div class="form-group col-md-4">
              <label>Mã coupon</label>
              <input type="text" name="code" class="form-control" value="${editCoupon.code}" ${not empty editCoupon ? 'readonly' : ''} required>
              <c:if test="${param.error eq 'duplicate'}"><small class="text-danger">Mã đã tồn tại.</small></c:if>
            </div>
            <div class="form-group col-md-8">
              <label>Mô tả</label>
              <input type="text" name="description" class="form-control" value="${editCoupon.description}">
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-4">
              <label>Loại giảm giá</label>
              <select name="discountType" class="form-control" required>
                <option value="percent" ${editCoupon.discountType=='percent'?'selected':''}>Giảm theo %</option>
                <option value="fixed" ${editCoupon.discountType=='fixed'?'selected':''}>Giảm cố định</option>
              </select>
            </div>
            <div class="form-group col-md-4">
              <label>Giá trị</label>
              <input type="number" name="value" step="0.01" min="0" class="form-control" value="${editCoupon.value}" required>
            </div>
            <div class="form-group col-md-4">
              <div class="form-check mt-4">
                <input type="checkbox" class="form-check-input" id="active" name="active" ${editCoupon.active ? 'checked' : ''}>
                <label class="form-check-label" for="active">Kích hoạt</label>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-6">
              <label>Hiệu lực từ</label>
              <input type="date" name="startDate" class="form-control" value="<fmt:formatDate value='${editCoupon.startDate}' pattern='yyyy-MM-dd'/>">
            </div>
            <div class="form-group col-md-6">
              <label>Hiệu lực đến</label>
              <input type="date" name="endDate" class="form-control" value="<fmt:formatDate value='${editCoupon.endDate}' pattern='yyyy-MM-dd'/>">
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-4">
              <label>Đơn tối thiểu (VND)</label>
              <input type="number" name="minSubtotal" class="form-control" step="1" min="0" value="${editCoupon.minSubtotal}">
            </div>
            <div class="form-group col-md-4">
              <label>Giảm tối đa (VND)</label>
              <input type="number" name="maxDiscount" class="form-control" step="1" min="0" value="${editCoupon.maxDiscount}">
            </div>
            <div class="form-group col-md-4">
              <label>Giới hạn lượt dùng</label>
              <input type="number" name="usageLimit" class="form-control" step="1" min="0" value="${editCoupon.usageLimit}">
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-primary"><i class="fas fa-save"></i> <c:choose><c:when test="${not empty editCoupon}">Cập nhật</c:when><c:otherwise>Thêm</c:otherwise></c:choose></button>
          <button type="button" class="btn btn-secondary" data-dismiss="modal">Đóng</button>
        </div>
      </form>
    </div>
  </div>

  <footer class="main-footer"><strong>Light Admin</strong></footer>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.10.7/dist/sweetalert2.all.min.js"></script>
<script>
  // Tự mở modal khi vào chế độ edit
  $(function(){
    var isEdit = $('#couponModal').data('edit') === 1 || $('#couponModal').data('edit') === '1';
    if(isEdit){ $('#couponModal').modal('show'); }
  });

  function confirmDelete(id, code) {
    Swal.fire({
      title: 'Xóa coupon?',
      html: 'Bạn có chắc muốn xóa <b>' + (code || ('#'+id)) + '</b>?<br><small>Hành động không thể hoàn tác.</small>',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonColor: '#d33',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Xóa',
      cancelButtonText: 'Hủy'
    }).then((result) => {
      if (result.isConfirmed) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/admin/coupons';
        form.innerHTML = '<input type="hidden" name="action" value="delete">' +
                         '<input type="hidden" name="id" value="'+id+'">';
        document.body.appendChild(form);
        form.submit();
      }
    });
  }
</script>
</body>
</html>