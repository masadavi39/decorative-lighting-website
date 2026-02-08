<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Thêm sản phẩm</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css"/>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
</head>
<body class="hold-transition sidebar-mini">
<div class="wrapper">
  <%@ include file="../partials/admin_navbar.jspf" %>
  <c:set var="activeMenu" value="products" scope="request"/>
  <%@ include file="../partials/admin_sidebar.jspf" %>

  <div class="content-wrapper">
    <section class="content-header">
      <div class="container-fluid">
        <div class="row mb-2">
          <div class="col-sm-6"><h1>Thêm sản phẩm mới</h1></div>
          <div class="col-sm-6">
            <ol class="breadcrumb float-sm-right">
              <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/products?action=list">Sản phẩm</a></li>
              <li class="breadcrumb-item active">Thêm mới</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section class="content">
      <div class="container-fluid">
        <form action="${pageContext.request.contextPath}/admin/products" method="post" enctype="multipart/form-data">
          <input type="hidden" name="action" value="add">
          <div class="card card-primary">
            <div class="card-header">
              <h3 class="card-title"><i class="fas fa-plus"></i> Thông tin sản phẩm</h3>
            </div>
            <div class="card-body">
              <div class="form-group">
                <label>Danh mục</label>
                <select name="categoryId" class="form-control">
                  <c:forEach var="c" items="${categories}">
                    <option value="${c.categoryId}">${c.name}</option>
                  </c:forEach>
                </select>
              </div>
              <div class="form-group">
                <label>Tên sản phẩm</label>
                <input type="text" name="name" class="form-control" required>
              </div>
              <div class="form-group">
                <label>Mô tả</label>
                <textarea name="description" rows="4" class="form-control"></textarea>
              </div>
              <div class="form-row">
                <div class="form-group col-md-3">
                  <label>Giá</label>
                  <input type="number" name="price" step="0.01" class="form-control" required>
                </div>
                <div class="form-group col-md-3">
                  <label>Giá khuyến mãi</label>
                  <input type="number" name="promoPrice" step="0.01" class="form-control">
                </div>
                <div class="form-group col-md-3">
                  <label>Số lượng</label>
                  <input type="number" name="quantity" class="form-control">
                </div>
                <div class="form-group col-md-3">
                  <label>Thương hiệu</label>
                  <input type="text" name="manufacturer" class="form-control">
                </div>
              </div>
              <div class="form-group">
                <label>Trạng thái</label>
                <select name="status" class="form-control">
                  <option value="active">Đang bán</option>
                  <option value="inactive">Tạm ẩn</option>
                  <option value="out_of_stock">Hết hàng</option>
                </select>
              </div>
              <div class="form-group">
                <label>Ảnh sản phẩm</label>
                <div class="custom-file">
                  <input type="file" name="imageFile" class="custom-file-input" id="imageFile">
                  <label class="custom-file-label" for="imageFile">Chọn ảnh...</label>
                </div>
              </div>
            </div>
            <div class="card-footer">
              <button class="btn btn-primary"><i class="fas fa-save"></i> Thêm sản phẩm</button>
              <a href="${pageContext.request.contextPath}/admin/products?action=list" class="btn btn-secondary">Quay lại</a>
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
<script>
  $('.custom-file-input').on('change', function(){
    let fileName = $(this).val().split('\\').pop();
    $(this).next('.custom-file-label').addClass('selected').html(fileName);
  });
</script>
</body>
</html>