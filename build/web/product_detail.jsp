<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} - Chi tiết sản phẩm</title>
    <meta name="description" content="${product.name} - thông tin chi tiết, giá, tồn kho và mô tả sản phẩm.">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #0d6efd;
            --success-color: #4CAF50;
            --danger-color: #dc3545;
            --warning-color: #ffc107;
        }
        body { background-color: #f8f9fa; }
        
        .product-main-image {
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .product-main-image img {
            width: 100%;
            height: 400px;
            object-fit: cover;
        }
        .price-main {
            font-size: 2rem;
            font-weight: 800;
            color: var(--primary-color);
        }
        .info-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 14px;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 500;
        }
        .info-chip.stock-ok { background: #d1e7dd; color: #0f5132; }
        .info-chip.stock-low { background: #fff3cd; color: #664d03; }
        .info-chip.stock-out { background: #f8d7da; color: #842029; }
        .info-chip.default { background: #e9ecef; color: #495057; }
        
        .buy-box {
            background: #fff;
            border: 1px solid #dee2e6;
            border-radius: 12px;
            padding: 20px;
        }
        .related-card {
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .related-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.12);
        }
        .related-card img {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
        }
        .stars {
            color: var(--warning-color);
            font-size: 1.2rem;
        }
        .star-select {
            font-size: 2rem;
            cursor: pointer;
        }
        .star-select span {
            color: #dee2e6;
            transition: color 0.2s;
        }
        .star-select span.active,
        .star-select span:hover {
            color: var(--warning-color);
        }
        .review-card { transition: transform 0.2s; }
        .review-card:hover { transform: translateY(-2px); }
        .review-avatar {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: var(--primary-color);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.1rem;
        }
        .admin-reply {
            background: #f0f7ff;
            border-left: 3px solid var(--primary-color);
            border-radius: 0 8px 8px 0;
            padding: 10px 12px;
            margin-top: 10px;
        }
        .recent-card { transition: transform 0.3s; }
        .recent-card:hover { transform: translateY(-3px); }
        .recent-card img {
            height: 150px;
            object-fit: cover;
        }

        /* ===== SUCCESS POPUP ===== */
        .success-popup-overlay {
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.6);
            display: none; opacity: 0; visibility: hidden;
            align-items: center; justify-content: center;
            z-index: 99999; backdrop-filter: blur(4px);
            transition: opacity 0.3s ease, visibility 0.3s ease;
            pointer-events: none; /* không chặn click khi ẩn */
        }
        .success-popup-overlay.show {
            display: flex; opacity: 1; visibility: visible;
            pointer-events: auto; /* cho phép click khi hiện */
        }
        .success-popup-content {
            background: #fff;
            border-radius: 24px;
            padding: 45px 50px;
            text-align: center;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.35);
            transform: scale(0.7) translateY(20px);
            transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            max-width: 420px;
            width: 90%;
        }
        .success-popup-overlay.show .success-popup-content {
            transform: scale(1) translateY(0);
        }

        .success-checkmark {
            width: 100px;
            height: 100px;
            margin: 0 auto 25px;
            position: relative;
        }
        .check-icon {
            width: 100px;
            height: 100px;
            position: relative;
            border-radius: 50%;
            box-sizing: content-box;
            border: 4px solid var(--success-color);
            background: linear-gradient(135deg, #e8f5e9 0%, #c8e6c9 100%);
        }
        .check-icon::before {
            top: 3px;
            left: -2px;
            width: 30px;
            transform-origin: 100% 50%;
            border-radius: 100px 0 0 100px;
        }
        .check-icon::after {
            top: 0;
            left: 30px;
            width: 60px;
            transform-origin: 0 50%;
            border-radius: 0 100px 100px 0;
            animation: rotate-circle 4.25s ease-in;
        }
        .check-icon::before,
        .check-icon::after {
            content: '';
            height: 100px;
            position: absolute;
            background: #fff;
            transform: rotate(-45deg);
        }
        .check-icon .icon-line {
            height: 5px;
            background-color: var(--success-color);
            display: block;
            border-radius: 2px;
            position: absolute;
            z-index: 10;
        }
        .check-icon .icon-line.line-tip {
            top: 56px;
            left: 18px;
            width: 30px;
            transform: rotate(45deg);
            animation: icon-line-tip 0.75s;
        }
        .check-icon .icon-line.line-long {
            top: 46px;
            right: 10px;
            width: 55px;
            transform: rotate(-45deg);
            animation: icon-line-long 0.75s;
        }
        .check-icon .icon-circle {
            top: -4px;
            left: -4px;
            z-index: 10;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            position: absolute;
            box-sizing: content-box;
            border: 4px solid rgba(76, 175, 80, 0.3);
            animation: pulse-ring 1.5s ease-out infinite;
        }
        .check-icon .icon-fix {
            top: 10px;
            width: 6px;
            left: 32px;
            z-index: 1;
            height: 100px;
            position: absolute;
            transform: rotate(-45deg);
            background-color: #fff;
        }

        @keyframes rotate-circle {
            0% { transform: rotate(-45deg); }
            5% { transform: rotate(-45deg); }
            12% { transform: rotate(-405deg); }
            100% { transform: rotate(-405deg); }
        }
        @keyframes icon-line-tip {
            0% { width: 0; left: 1px; top: 19px; }
            54% { width: 0; left: 1px; top: 19px; }
            70% { width: 55px; left: -8px; top: 46px; }
            84% { width: 20px; left: 26px; top: 58px; }
            100% { width: 30px; left: 18px; top: 56px; }
        }
        @keyframes icon-line-long {
            0% { width: 0; right: 56px; top: 64px; }
            65% { width: 0; right: 56px; top: 64px; }
            84% { width: 62px; right: 2px; top: 43px; }
            100% { width: 55px; right: 10px; top: 46px; }
        }
        @keyframes pulse-ring {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.1); opacity: 0.5; }
            100% { transform: scale(1); opacity: 1; }
        }

        .success-popup-text {
            font-size: 1.35rem;
            font-weight: 700;
            color: #2e7d32;
            margin: 0 0 10px;
        }
        .success-popup-subtext {
            font-size: 0.95rem;
            color: #666;
            margin-bottom: 25px;
        }
        .success-popup-actions {
            display: flex;
            gap: 12px;
            justify-content: center;
        }
        .success-popup-actions .btn {
            padding: 12px 28px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
        }
        .success-popup-actions .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .btn-continue {
            background: #f5f5f5;
            color: #333;
            border: none;
        }
        .btn-continue:hover {
            background: #e8e8e8;
            color: #333;
        }
        .btn-view-cart {
            background: linear-gradient(135deg, #4CAF50 0%, #43a047 100%);
            color: #fff;
            border: none;
        }
        .btn-view-cart:hover {
            background: linear-gradient(135deg, #43a047 0%, #388e3c 100%);
            color: #fff;
        }

        @media (max-width: 768px) {
            .product-main-image img { height: 300px; }
            .price-main { font-size: 1.5rem; }
            .success-popup-content { padding: 35px 25px; }
            .success-checkmark { width: 80px; height: 80px; }
            .check-icon { width: 80px; height: 80px; }
            .success-popup-actions { flex-direction: column; }
            .success-popup-actions .btn { width: 100%; }
        }
    </style>
</head>
<body>
    <%@ include file="partials/header.jsp" %>

    <!-- Success Popup -->
    <div class="success-popup-overlay" id="successPopup">
        <div class="success-popup-content">
            <div class="success-checkmark">
                <div class="check-icon">
                    <span class="icon-line line-tip"></span>
                    <span class="icon-line line-long"></span>
                    <div class="icon-circle"></div>
                    <div class="icon-fix"></div>
                </div>
            </div>
            <div class="success-popup-text">Thêm sản phẩm thành công!</div>
            <div class="success-popup-subtext">Sản phẩm đã được thêm vào giỏ hàng của bạn</div>
            <div class="success-popup-actions">
                <button type="button" class="btn btn-continue" id="btnContinueShopping">
                    <i class="bi bi-arrow-left me-2"></i>Tiếp tục mua
                </button>
                <a href="${pageContext.request.contextPath}/cart" class="btn btn-view-cart">
                    <i class="bi bi-cart-check me-2"></i>Xem giỏ hàng
                </a>
            </div>
        </div>
    </div>

    <div class="container py-4">
        <!-- Breadcrumbs -->
        <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/products?action=list">
                        <i class="bi bi-house"></i> Trang chủ
                    </a>
                </li>
                <li class="breadcrumb-item active" aria-current="page">${product.name}</li>
            </ol>
        </nav>

        <!-- Alerts (chỉ giữ các alert đánh giá; đã xóa alert thêm vào giỏ) -->
        <c:if test="${param.rv eq 'ok'}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i>
                Đã gửi đánh giá. Chờ duyệt trước khi hiển thị.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>
        <c:if test="${param.rv eq 'fail'}">
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                Gửi đánh giá thất bại. Vui lòng thử lại.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        </c:if>

        <!-- Main Content -->
        <div class="row g-4">
            <!-- Product Image -->
            <div class="col-lg-5">
                <div class="product-main-image">
                    <img src="${pageContext.request.contextPath}/${product.imagePath}" alt="${product.name}" class="img-fluid">
                </div>
            </div>

            <!-- Product Info -->
            <div class="col-lg-4">
                <c:set var="inStock" value="${product.quantity > 0}" />
                
                <span class="badge ${inStock ? 'bg-success' : 'bg-danger'} mb-2">
                    <c:choose>
                        <c:when test="${inStock}"><i class="bi bi-check-circle"></i> CÒN HÀNG</c:when>
                        <c:otherwise><i class="bi bi-x-circle"></i> HẾT HÀNG</c:otherwise>
                    </c:choose>
                </span>
                
                <h1 class="h3 fw-bold mb-3">${product.name}</h1>
                
                <div class="price-main mb-3">
                    <fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/>₫
                </div>
                
                <p class="text-muted small mb-3">Giá đã gồm VAT (nếu áp dụng)</p>

                <div class="d-flex flex-wrap gap-2 mb-4">
                    <span class="info-chip default">
                        <i class="bi bi-folder"></i>
                        <c:choose>
                            <c:when test="${not empty product.categoryName}">${product.categoryName}</c:when>
                            <c:otherwise>Danh mục #${product.categoryId}</c:otherwise>
                        </c:choose>
                    </span>
                    <span class="info-chip default">
                        <i class="bi bi-building"></i>
                        ${not empty product.manufacturer ? product.manufacturer : 'Không rõ'}
                    </span>
                    <span class="info-chip ${product.quantity > 20 ? 'stock-ok' : (product.quantity > 0 ? 'stock-low' : 'stock-out')}">
                        <i class="bi bi-box"></i>
                        Tồn: ${product.quantity}
                    </span>
                    <span class="info-chip default">
                        <i class="bi bi-fire"></i>
                        Đã bán: <fmt:formatNumber value="${product.soldQuantity}" type="number"/>
                    </span>
                </div>

                <!-- Buy Box -->
                <div class="buy-box">
                    <form id="addToCartForm" action="${pageContext.request.contextPath}/cart" method="post">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="productId" value="${product.id}">
                        
                        <div class="mb-3">
                            <label for="quantity" class="form-label fw-semibold">Số lượng</label>
                            <input type="number" class="form-control" id="quantity" name="quantity" 
                                   min="1" max="${product.quantity}" value="1" 
                                   style="width: 120px;" ${!inStock ? 'disabled' : ''}>
                        </div>
                        
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-lg ${!inStock ? 'disabled' : ''}" 
                                    id="addToCartBtn" ${!inStock ? 'disabled' : ''}>
                                <i class="bi bi-cart-plus"></i> Thêm vào giỏ hàng
                            </button>
                            <a href="${pageContext.request.contextPath}/products?action=list" class="btn btn-outline-secondary">
                                <i class="bi bi-arrow-left"></i> Quay lại danh sách
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Related Products -->
            <div class="col-lg-3">
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-lightning text-warning"></i> Sản phẩm liên quan
                        </h5>
                    </div>
                    <div class="card-body p-0" style="max-height: 500px; overflow-y: auto;">
                        <c:choose>
                            <c:when test="${not empty relatedProducts}">
                                <ul class="list-group list-group-flush">
                                    <c:forEach var="p" items="${relatedProducts}">
                                        <li class="list-group-item related-card">
                                            <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}" 
                                               class="d-flex align-items-center text-decoration-none text-dark">
                                                <img src="${pageContext.request.contextPath}/${p.imagePath}" 
                                                     alt="${p.name}" class="me-3 flex-shrink-0">
                                                <div class="min-width-0">
                                                    <h6 class="mb-1 small">${p.name}</h6>
                                                    <span class="small ${p.quantity > 0 ? 'text-success' : 'text-danger'}">
                                                        ${p.quantity > 0 ? 'Còn hàng' : 'Hết hàng'}
                                                    </span>
                                                    <div class="text-primary fw-bold small">
                                                        <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/>₫
                                                    </div>
                                                </div>
                                            </a>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:when>
                            <c:otherwise>
                                <div class="p-3 text-center text-muted">
                                    <i class="bi bi-inbox"></i> Không có sản phẩm liên quan
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <!-- Description -->
        <div class="card shadow-sm mt-4">
            <div class="card-header bg-white">
                <h5 class="mb-0"><i class="bi bi-file-text"></i> Mô tả sản phẩm</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty product.description}">
                        <p class="mb-0" style="white-space: pre-line;">${fn:escapeXml(product.description)}</p>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted fst-italic mb-0">Chưa có mô tả chi tiết cho sản phẩm này.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Reviews Section -->
        <div class="card shadow-sm mt-4">
            <div class="card-header bg-white">
                <h5 class="mb-0"><i class="bi bi-star"></i> Đánh giá sản phẩm</h5>
            </div>
            <div class="card-body">
                <!-- Rating Summary -->
                <div class="d-flex align-items-center gap-3 mb-4 pb-3 border-bottom">
                    <div class="stars">
                        <c:forEach begin="1" end="5" var="i">
                            <c:choose>
                                <c:when test="${avgRating >= i}"><i class="bi bi-star-fill"></i></c:when>
                                <c:otherwise><i class="bi bi-star"></i></c:otherwise>
                            </c:choose>
                        </c:forEach>
                    </div>
                    <span class="fw-bold">
                        <fmt:formatNumber value="${avgRating != null ? avgRating : 0}" type="number" maxFractionDigits="1"/>/5
                    </span>
                    <span class="text-muted small">
                        (<fmt:formatNumber value="${reviewCount != null ? reviewCount : 0}" type="number"/> đánh giá)
                    </span>
                </div>

                <!-- Reviews List -->
                <div class="row row-cols-1 row-cols-md-2 g-3 mb-4">
                    <c:forEach var="rv" items="${reviews}">
                        <div class="col">
                            <div class="card review-card h-100">
                                <div class="card-body">
                                    <div class="d-flex gap-3">
                                        <div class="review-avatar flex-shrink-0">
                                            <c:choose>
                                                <c:when test="${not empty rv.userName}">
                                                    ${fn:substring(rv.userName, 0, 1)}
                                                </c:when>
                                                <c:otherwise>U</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="flex-grow-1">
                                            <div class="d-flex justify-content-between align-items-start mb-1">
                                                <strong>
                                                    <c:choose>
                                                        <c:when test="${not empty rv.userName}">${rv.userName}</c:when>
                                                        <c:otherwise>User #${rv.userId}</c:otherwise>
                                                    </c:choose>
                                                </strong>
                                                <span class="stars small">
                                                    <c:forEach begin="1" end="5" var="i">
                                                        <c:choose>
                                                            <c:when test="${rv.rating >= i}"><i class="bi bi-star-fill"></i></c:when>
                                                            <c:otherwise><i class="bi bi-star"></i></c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                </span>
                                            </div>
                                            <div class="text-muted small mb-2">
                                                <fmt:formatDate value="${rv.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                            </div>
                                            <c:if test="${not empty rv.title}">
                                                <strong class="d-block mb-1">${fn:escapeXml(rv.title)}</strong>
                                            </c:if>
                                            <p class="mb-0">${fn:escapeXml(rv.content)}</p>
                                            
                                            <c:if test="${not empty rv.replies}">
                                                <c:forEach var="rp" items="${rv.replies}">
                                                    <c:if test="${rp.userRole eq 'admin'}">
                                                        <div class="admin-reply mt-2">
                                                            <div class="d-flex align-items-center gap-2 mb-1">
                                                                <span class="badge bg-primary">Quản trị viên</span>
                                                                <strong class="small">${fn:escapeXml(rp.userName)}</strong>
                                                                <span class="text-muted small">
                                                                    <fmt:formatDate value="${rp.createdAt}" pattern="dd/MM/yyyy"/>
                                                                </span>
                                                            </div>
                                                            <p class="mb-0 small">${fn:escapeXml(rp.content)}</p>
                                                        </div>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                
                <c:if test="${empty reviews}">
                    <div class="text-center text-muted py-4">
                        <i class="bi bi-chat-square-text" style="font-size: 2rem;"></i>
                        <p class="mt-2">Chưa có đánh giá nào cho sản phẩm này.</p>
                    </div>
                </c:if>

                <!-- Review Form -->
                <c:if test="${not empty sessionScope.user}">
                    <div class="card bg-light mt-4">
                        <div class="card-body">
                            <h6 class="card-title"><i class="bi bi-pencil"></i> Viết đánh giá</h6>
                            <form action="${pageContext.request.contextPath}/reviews" method="post" id="reviewForm">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="productId" value="${product.id}">
                                <input type="hidden" name="rating" id="ratingValue" value="5">

                                <div class="mb-3">
                                    <label class="form-label fw-semibold">Chấm điểm</label>
                                    <div class="star-select" id="starSelect">
                                        <c:forEach begin="1" end="5" var="i">
                                            <span data-val="${i}" class="${i <= 5 ? 'active' : ''}">★</span>
                                        </c:forEach>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="titlePreset" class="form-label">Tiêu đề</label>
                                    <select id="titlePreset" class="form-select mb-2">
                                        <option value="">-- Chọn tiêu đề mẫu --</option>
                                        <option>Chất lượng rất tốt</option>
                                        <option>Đóng gói cẩn thận</option>
                                        <option>Giao hàng nhanh</option>
                                        <option>Giá cả hợp lý</option>
                                        <option value="_custom">Khác...</option>
                                    </select>
                                    <input type="text" class="form-control" id="customTitle" name="title" 
                                           placeholder="Nhập tiêu đề..." maxlength="150" style="display:none;">
                                </div>

                                <div class="mb-3">
                                    <label for="reviewContent" class="form-label">Nội dung đánh giá</label>
                                    <textarea class="form-control" id="reviewContent" name="content" rows="3" 
                                              required placeholder="Chia sẻ trải nghiệm của bạn..."></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-send"></i> Gửi đánh giá
                                </button>
                                <p class="text-muted small mt-2 mb-0">
                                    <i class="bi bi-info-circle"></i> Đánh giá sẽ được duyệt trước khi hiển thị công khai.
                                </p>
                            </form>
                        </div>
                    </div>
                </c:if>
                
                <c:if test="${empty sessionScope.user}">
                    <div class="alert alert-info mt-4">
                        <i class="bi bi-info-circle"></i>
                        Vui lòng <a href="${pageContext.request.contextPath}/auth?action=login">đăng nhập</a> để đánh giá sản phẩm.
                    </div>
                </c:if>
            </div>
        </div>

        <!-- Recently Viewed -->
        <div class="card shadow-sm mt-4">
            <div class="card-header bg-white">
                <h5 class="mb-0"><i class="bi bi-clock-history"></i> Sản phẩm vừa xem</h5>
            </div>
            <div class="card-body">
                <c:choose>
                    <c:when test="${not empty recentProducts}">
                        <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-6 g-3">
                            <c:forEach var="p" items="${recentProducts}">
                                <div class="col">
                                    <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}" 
                                       class="card recent-card h-100 text-decoration-none">
                                        <img src="${pageContext.request.contextPath}/${p.imagePath}" 
                                             class="card-img-top" alt="${p.name}">
                                        <div class="card-body p-2">
                                            <h6 class="card-title small mb-1 text-truncate text-dark">${p.name}</h6>
                                            <span class="text-primary fw-bold small">
                                                <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/>₫
                                            </span>
                                        </div>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center text-muted py-3">
                            <i class="bi bi-inbox"></i> Chưa có lịch sử xem.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <%@ include file="partials/footer.jsp" %>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var CTX = '${pageContext.request.contextPath}';
        
        // Khởi tạo dropdown Bootstrap rõ ràng (cart/account/nav)
        if (window.bootstrap && bootstrap.Dropdown) {
            document.querySelectorAll('[data-bs-toggle="dropdown"]').forEach(function(el) {
                try { new bootstrap.Dropdown(el); } catch(e) {}
            });
        }

        // Đảm bảo overlay không chặn click khi ẩn
        var successPopup = document.getElementById('successPopup');
        if (successPopup) {
            successPopup.classList.remove('show');
            successPopup.style.display = 'none';
        }

        // ========== Star Rating ==========
        var starSelect = document.getElementById('starSelect');
        var ratingInput = document.getElementById('ratingValue');
        if (starSelect && ratingInput) {
            var stars = starSelect.querySelectorAll('span');
            var currentRating = parseInt(ratingInput.value) || 5;
            function updateStars(rating) {
                stars.forEach(function(star, index) { star.classList.toggle('active', index < rating); });
            }
            stars.forEach(function(star) {
                star.addEventListener('click', function() {
                    currentRating = parseInt(this.dataset.val);
                    ratingInput.value = currentRating;
                    updateStars(currentRating);
                });
                star.addEventListener('mouseenter', function() {
                    updateStars(parseInt(this.dataset.val));
                });
                star.addEventListener('mouseleave', function() {
                    updateStars(currentRating);
                });
            });
            updateStars(currentRating);
        }

        // ========== Success Popup ==========
        var btnContinue = document.getElementById('btnContinueShopping');
        function showSuccessPopup() {
            if (!successPopup) return;
            successPopup.style.display = 'flex';
            successPopup.offsetHeight; // reflow để bật animation
            successPopup.classList.add('show');
            document.body.style.overflow = 'hidden';
        }
        function hideSuccessPopup() {
            if (!successPopup) return;
            successPopup.classList.remove('show');
            document.body.style.overflow = '';
            setTimeout(function() { successPopup.style.display = 'none'; }, 300);
        }
        if (btnContinue) btnContinue.addEventListener('click', hideSuccessPopup);
        if (successPopup) {
            successPopup.addEventListener('click', function(e) {
                if (e.target === successPopup) hideSuccessPopup();
            });
        }
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && successPopup && successPopup.classList.contains('show')) {
                hideSuccessPopup();
            }
        });

        // ========== Add to Cart - DÙNG AJAX để hiện popup mỗi lần bấm ==========
        var addToCartForm = document.getElementById('addToCartForm');
        var addToCartBtn = document.getElementById('addToCartBtn');
        var qtyInput = document.getElementById('quantity');

        function setAddingState(isAdding) {
            if (!addToCartBtn) return;
            if (isAdding) {
                addToCartBtn.disabled = true;
                addToCartBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status"></span> Đang thêm...';
            } else {
                addToCartBtn.disabled = false;
                addToCartBtn.innerHTML = '<i class="bi bi-cart-plus"></i> Thêm vào giỏ hàng';
            }
        }

        function bumpHeaderCartBadge(qty) {
            var badge = document.getElementById('headerCartBadge');
            if (!badge) return;
            var current = parseInt((badge.textContent || '0').replace(/\D/g,''), 10);
            if (isNaN(current)) current = 0;
            var add = parseInt(qty, 10);
            if (isNaN(add) || add < 1) add = 1;
            badge.textContent = (current + add).toString();
        }

        if (addToCartForm && addToCartBtn) {
            addToCartForm.addEventListener('submit', function(e) {
                e.preventDefault(); // chặn submit mặc định
                setAddingState(true);

                var formData = new URLSearchParams(new FormData(addToCartForm));
                fetch(CTX + '/cart', {
                    method: 'POST',
                    headers: { 'X-Requested-With': 'XMLHttpRequest' },
                    body: formData
                }).then(function(res) {
                    if (res.status === 401) {
                        setAddingState(false);
                        window.location.href = CTX + '/auth?action=login';
                        return Promise.reject();
                    }
                    if (!res.ok) throw new Error('HTTP ' + res.status);
                    return res.text();
                }).then(function() {
                    setAddingState(false);
                    bumpHeaderCartBadge(qtyInput ? qtyInput.value : 1);
                    showSuccessPopup();
                }).catch(function() {
                    // nếu đã redirect ở trên thì catch sẽ bỏ qua
                });
            });
        }

        // Không dùng query param ?added=true nữa
    });
    </script>
</body>
</html>