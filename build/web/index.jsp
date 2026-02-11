<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Light Shop - Thế Giới Đèn Trang Trí</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css"/>

    <style>
        :root {
            --primary: #0d6efd;
            --accent: #d4af37;
            --radius-xl: 16px;
            --radius-md: 12px;
            --shadow-hover: 0 15px 30px rgba(0,0,0,0.1);
            --shadow-card: 0 4px 12px rgba(0,0,0,0.05);
        }
        body { background: #fcfcfc; font-family: 'Segoe UI', Roboto, sans-serif; }

        /* ===== BANNER SWIPER (tncstore style) ===== */
        .banner-section { margin-bottom: 2.5rem; }
        .banner-inner {
            max-width: 1200px;
            margin: 0 auto;
            position: relative;
        }

        /* Main slider */
        .swiper-main {
            width: 100%;
            height: 480px;
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-hover);
            overflow: hidden;
        }
        .swiper-main .swiper-slide {
            position: relative;
            background: #000;
        }
        .swiper-main .swiper-slide img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: .9;
            display: block;
        }

        .hero-content {
            position: absolute; bottom: 60px; left: 60px; right: 60px;
            z-index: 10; color: #fff;
            text-shadow: 0 2px 10px rgba(0,0,0,0.6);
            pointer-events: none;
        }
        .hero-content h2 { font-size: 2.5rem; font-weight: 800; margin-bottom: .5rem; letter-spacing: -0.5px; }
        .hero-content p  { font-size: 1.1rem; opacity: .9; margin-bottom: 1.5rem; max-width: 600px; }
        .hero-btn {
            pointer-events: auto;
            background: var(--accent); border: none;
            padding: 10px 28px; font-weight: 600; border-radius: 50px;
            color: #fff; text-decoration: none; transition: .3s;
            display: inline-block;
        }
        .hero-btn:hover { background: #b59020; transform: translateY(-2px); color: #fff; }

        /* Navigation arrows */
        .swiper-main .swiper-button-next,
        .swiper-main .swiper-button-prev {
            color: #fff;
            width: 44px; height: 44px;
            background: rgba(0,0,0,0.3);
            border-radius: 50%;
            transition: .3s;
        }
        .swiper-main .swiper-button-next:hover,
        .swiper-main .swiper-button-prev:hover {
            background: rgba(0,0,0,0.6);
        }
        .swiper-main .swiper-button-next::after,
        .swiper-main .swiper-button-prev::after {
            font-size: 18px;
            font-weight: 700;
        }

        /* Pagination dots trên main slider (tncstore style) */
        .swiper-main .swiper-pagination-bullet {
            width: 12px; height: 12px;
            background: rgba(255,255,255,0.5);
            opacity: 1;
            transition: .3s;
        }
        .swiper-main .swiper-pagination-bullet-active {
            background: #fff;
            width: 30px;
            border-radius: 6px;
        }

        /* Thumbnail slider bên dưới */
        .swiper-thumbs-wrapper {
            max-width: 600px;
            margin: 15px auto 0;
        }
        .swiper-thumbs {
            width: 100%;
            height: 75px;
        }
        .swiper-thumbs .swiper-slide {
            opacity: 0.5;
            cursor: pointer;
            border-radius: 8px;
            overflow: hidden;
            border: 2px solid transparent;
            transition: all .3s ease;
            box-sizing: border-box;
        }
        .swiper-thumbs .swiper-slide-thumb-active {
            opacity: 1;
            border-color: var(--primary);
            box-shadow: 0 3px 10px rgba(13,110,253,0.25);
        }
        .swiper-thumbs .swiper-slide img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        /* ===== PRODUCT CARD ===== */
        .product-card {
            border: none; border-radius: var(--radius-md);
            transition: all .3s ease; background: #fff; height: 100%;
        }
        .product-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-hover); }
        .card-img-wrapper {
            position: relative; overflow: hidden;
            border-radius: var(--radius-md) var(--radius-md) 0 0;
            padding-top: 100%;
        }
        .card-img-top {
            position: absolute; inset: 0;
            width: 100%; height: 100%;
            object-fit: cover;
            transition: transform .5s ease;
        }
        .product-card:hover .card-img-top { transform: scale(1.08); }

        .price-tag { color: #d63384; font-weight: 700; font-size: 1.1rem; }
        .stock-status { font-size: .8rem; font-weight: 500; }
        .btn-view { border-radius: 6px; font-weight: 500; }

        /* ===== PROMO ===== */
        .promo-card {
            background: #fff; border: 1px solid #eef0f3;
            border-radius: var(--radius-md); padding: 20px;
            display: flex; align-items: center; gap: 15px; transition: .3s;
        }
        .promo-card:hover { border-color: var(--primary); box-shadow: var(--shadow-card); }
        .promo-icon {
            width: 50px; height: 50px;
            background: rgba(13,110,253,0.1); color: var(--primary);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem; flex-shrink: 0;
        }

        /* ===== SIDEBAR ===== */
        .filter-card { border: none; box-shadow: var(--shadow-card); border-radius: var(--radius-md); }
        .filter-header {
            background: #fff; border-bottom: 1px solid #f0f0f0;
            padding: 15px; border-radius: var(--radius-md) var(--radius-md) 0 0;
        }

        .bestseller-item {
            width: 60px; height: 60px;
            border-radius: 8px;
            object-fit: cover;
            display: block;
        }

        .bestseller-scroll { max-height: 420px; overflow-y: auto; }
        .bestseller-scroll::-webkit-scrollbar { width: 6px; }
        .bestseller-scroll::-webkit-scrollbar-thumb { background: #d0d5dd; border-radius: 6px; }

        /* AJAX loading */
        .ajax-loading { display: none; text-align: center; padding: 50px 20px; }
        .ajax-loading.show { display: block; }
        #productGrid.fading { opacity: .35; pointer-events: none; transition: .2s; }

        /* Pagination */
        .pagination .page-link {
            border-radius: 8px !important; margin: 0 3px;
            border: none; color: #555; transition: .2s;
        }
        .pagination .page-item.active .page-link {
            background: var(--primary); color: #fff;
            box-shadow: 0 4px 12px rgba(13,110,253,0.3);
        }
        .pagination .page-link:hover { background: #e9ecef; }

        /* Toast thông báo lỗi */
        .ajax-error-toast {
            position: fixed; bottom: 20px; right: 20px; z-index: 9999;
            background: #dc3545; color: #fff; padding: 12px 24px;
            border-radius: 8px; box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            display: none; font-size: 0.9rem; max-width: 360px;
        }
        .ajax-error-toast.show { display: flex; align-items: center; gap: 8px; }

        @media (max-width: 768px) {
            .swiper-main { height: 280px; }
            .hero-content { bottom: 20px; left: 20px; right: 20px; }
            .hero-content h2 { font-size: 1.5rem; }
            .hero-btn { padding: 6px 16px; font-size: .9rem; }
            .swiper-thumbs-wrapper { display: none; }
        }
        @media (max-width: 576px) {
            .swiper-main { height: 200px; }
            .hero-content p { display: none; }
        }
    </style>
</head>
<body>
<%@ include file="partials/header.jsp" %>

<!-- Toast thông báo lỗi AJAX -->
<div class="ajax-error-toast" id="ajaxErrorToast">
    <i class="bi bi-exclamation-triangle-fill"></i>
    <span id="ajaxErrorMsg">Đã xảy ra lỗi, vui lòng thử lại.</span>
</div>

<div class="container py-4">

    <!-- ===== BANNER (tncstore style: main + pagination dots + thumbs bên dưới) ===== -->
    <div class="banner-section">
        <div class="banner-inner">
            <!-- Main Slider -->
            <div class="swiper swiper-main" id="swiperMain">
                <div class="swiper-wrapper">
                    <div class="swiper-slide">
                        <img src="${pageContext.request.contextPath}/images/banner1.jpg" alt="Đèn trang trí phòng khách">
                        <div class="hero-content">
                            <h2>Bừng sáng không gian sống</h2>
                            <p class="d-none d-md-block">Bộ sưu tập đèn chùm pha lê cao cấp mới nhất 2024</p>
                            <a href="#productList" class="hero-btn">Mua ngay <i class="bi bi-arrow-right"></i></a>
                        </div>
                    </div>
                    <div class="swiper-slide">
                        <img src="${pageContext.request.contextPath}/images/banner2.jpg" alt="Đèn ngủ hiện đại">
                        <div class="hero-content">
                            <h2>Ấm áp từng góc nhỏ</h2>
                            <p class="d-none d-md-block">Giảm giá 20% cho toàn bộ mẫu đèn ngủ để bàn</p>
                            <a href="#" class="hero-btn">Xem chi tiết</a>
                        </div>
                    </div>
                    <div class="swiper-slide">
                        <img src="${pageContext.request.contextPath}/images/banner3.jpg" alt="Đèn ngoại thất">
                    </div>
                </div>
                <!-- Navigation arrows -->
                <div class="swiper-button-next"></div>
                <div class="swiper-button-prev"></div>
                <!-- Pagination dots -->
                <div class="swiper-pagination"></div>
            </div>

            <!-- Thumbnail Slider (tách biệt, dưới main) -->
            <div class="swiper-thumbs-wrapper">
                <div class="swiper swiper-thumbs" id="swiperThumbs">
                    <div class="swiper-wrapper">
                        <div class="swiper-slide"><img src="${pageContext.request.contextPath}/images/banner1.jpg" alt="thumb 1"></div>
                        <div class="swiper-slide"><img src="${pageContext.request.contextPath}/images/banner2.jpg" alt="thumb 2"></div>
                        <div class="swiper-slide"><img src="${pageContext.request.contextPath}/images/banner3.jpg" alt="thumb 3"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ===== PROMO ===== -->
    <div class="row g-3 mb-5">
        <div class="col-md-4">
            <div class="promo-card">
                <div class="promo-icon"><i class="bi bi-truck"></i></div>
                <div>
                    <h6 class="fw-bold mb-0">Miễn phí vận chuyển</h6>
                    <small class="text-muted">Đơn hàng > 1.000k</small>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="promo-card">
                <div class="promo-icon"><i class="bi bi-shield-check"></i></div>
                <div>
                    <h6 class="fw-bold mb-0">Bảo hành 12 tháng</h6>
                    <small class="text-muted">Lỗi 1 đổi 1 tận nhà</small>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="promo-card">
                <div class="promo-icon"><i class="bi bi-headset"></i></div>
                <div>
                    <h6 class="fw-bold mb-0">Hỗ trợ 24/7</h6>
                    <small class="text-muted">Tư vấn lắp đặt miễn phí</small>
                </div>
            </div>
        </div>
    </div>

    <div class="row" id="productList">
        <!-- MAIN CONTENT -->
        <div class="col-lg-9 order-lg-2 mb-4">
            <div class="d-flex justify-content-between align-items-center bg-white p-3 rounded shadow-sm mb-4 border">
                <h5 class="mb-0 fw-bold text-uppercase text-secondary">
                    <i class="bi bi-grid-fill me-2"></i>Sản phẩm
                </h5>
                <%--
                    [FIX Sort] Không dùng form submit nữa.
                    Select đổi → JS build URL chuẩn rồi navigate (không AJAX).
                    Lý do: AJAX parse full page lãng phí + gây lỗi khi server không trả partial.
                --%>
                <div class="d-flex align-items-center gap-2">
                    <label for="sortBy" class="small fw-semibold text-muted d-none d-sm-inline">Sắp xếp:</label>
                    <select id="sortBy" class="form-select form-select-sm border-secondary" style="width:160px;">
                        <option value="">Mặc định</option>
                        <option value="price_asc"  ${param.sortBy eq 'price_asc'  ? 'selected' : ''}>Giá tăng dần</option>
                        <option value="price_desc" ${param.sortBy eq 'price_desc' ? 'selected' : ''}>Giá giảm dần</option>
                        <option value="name_asc"   ${param.sortBy eq 'name_asc'   ? 'selected' : ''}>Tên A-Z</option>
                    </select>
                </div>
            </div>

            <div class="ajax-loading" id="ajaxLoading">
                <div class="spinner-border" role="status"><span class="visually-hidden">Đang tải...</span></div>
                <p class="mt-3 text-muted">Đang tải sản phẩm...</p>
            </div>

            <div id="productGrid">
                <div class="row row-cols-2 row-cols-md-3 row-cols-xl-4 g-3 g-md-4">
                    <c:forEach var="p" items="${products}">
                        <div class="col">
                            <div class="card product-card h-100 shadow-sm">
                                <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}" class="card-img-wrapper">
                                    <img src="${pageContext.request.contextPath}/${fn:escapeXml(p.imagePath)}"
                                         class="card-img-top"
                                         alt="${fn:escapeXml(p.name)}"
                                         loading="lazy">
                                </a>
                                <div class="card-body d-flex flex-column p-3">
                                    <h6 class="card-title mb-2" style="font-size:0.95rem; line-height:1.4;">
                                        <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"
                                           class="text-decoration-none text-dark stretched-link">
                                            ${fn:escapeXml(p.name)}
                                        </a>
                                    </h6>
                                    <div class="mt-auto">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <span class="price-tag">
                                                <fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/>₫
                                            </span>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span class="stock-status ${p.quantity > 0 ? 'text-success' : 'text-danger'}">
                                                <i class="bi ${p.quantity > 0 ? 'bi-check-circle' : 'bi-x-circle'}"></i>
                                                    ${p.quantity > 0 ? 'Còn hàng' : 'Hết hàng'}
                                            </span>
                                        </div>
                                        <div class="d-grid mt-2">
                                            <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}"
                                               class="btn btn-outline-primary btn-sm btn-view position-relative z-2">
                                                Xem chi tiết
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <%-- Pagination: sliding window ±2 --%>
            <div class="mt-5" id="paginationWrapper">
                <c:if test="${totalPages > 1}">
                    <%--
                        [FIX Pagination URL] Build URL giữ nguyên tất cả param hiện tại
                        (category, parent, sortBy) để không bị mất khi chuyển trang.
                    --%>
                    <c:url var="pagingUrl" value="products">
                        <c:param name="action" value="list"/>
                        <c:if test="${not empty param.category}">
                            <c:param name="category" value="${fn:escapeXml(param.category)}"/>
                        </c:if>
                        <c:if test="${not empty param.parent}">
                            <c:param name="parent" value="${fn:escapeXml(param.parent)}"/>
                        </c:if>
                        <c:if test="${not empty param.sortBy}">
                            <c:param name="sortBy" value="${fn:escapeXml(param.sortBy)}"/>
                        </c:if>
                    </c:url>
                    <nav aria-label="Page navigation">
                        <ul class="pagination justify-content-center" id="pagination">

                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="${pagingUrl}&page=1" aria-label="Trang đầu">«</a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="${pagingUrl}&page=${currentPage - 1}" aria-label="Trang trước">‹</a>
                                </li>
                            </c:if>

                            <c:set var="startPg" value="${currentPage - 2 < 1 ? 1 : currentPage - 2}"/>
                            <c:set var="endPg" value="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}"/>

                            <c:if test="${startPg > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="${pagingUrl}&page=1">1</a>
                                </li>
                                <c:if test="${startPg > 2}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:if>
                            </c:if>

                            <c:forEach begin="${startPg}" end="${endPg}" var="pg">
                                <li class="page-item ${pg == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="${pagingUrl}&page=${pg}">${pg}</a>
                                </li>
                            </c:forEach>

                            <c:if test="${endPg < totalPages}">
                                <c:if test="${endPg < totalPages - 1}">
                                    <li class="page-item disabled"><span class="page-link">…</span></li>
                                </c:if>
                                <li class="page-item">
                                    <a class="page-link" href="${pagingUrl}&page=${totalPages}">${totalPages}</a>
                                </li>
                            </c:if>

                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="${pagingUrl}&page=${currentPage + 1}" aria-label="Trang sau">›</a>
                                </li>
                                <li class="page-item">
                                    <a class="page-link" href="${pagingUrl}&page=${totalPages}" aria-label="Trang cuối">»</a>
                                </li>
                            </c:if>

                        </ul>
                    </nav>
                </c:if>
            </div>
        </div>

        <!-- SIDEBAR -->
        <div class="col-lg-3 order-lg-1">
            <div class="card filter-card mb-4">
                <div class="filter-header">
                    <h6 class="mb-0 fw-bold text-primary"><i class="bi bi-funnel"></i> Lọc sản phẩm</h6>
                </div>
                <div class="card-body">
                    <%--
                        [FIX Filter] action="search" gửi về ProductServlet đúng.
                        Category select so sánh String-to-String bằng <c:set>.
                    --%>
                    <form action="${pageContext.request.contextPath}/products" method="get" id="filterForm">
                        <input type="hidden" name="action" value="search">
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-muted">Từ khóa</label>
                            <div class="input-group input-group-sm">
                                <span class="input-group-text bg-light"><i class="bi bi-search"></i></span>
                                <input type="text" class="form-control" name="keyword"
                                       value="${fn:escapeXml(searchKeyword)}" placeholder="Tên đèn...">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-muted">Danh mục</label>
                            <select name="category" class="form-select form-select-sm">
                                <option value="">-- Tất cả --</option>
                                <c:forEach var="c" items="${categories}">
                                    <%-- Ép categoryId sang String để so sánh chính xác --%>
                                    <c:set var="catIdStr">${c.categoryId}</c:set>
                                    <option value="${fn:escapeXml(catIdStr)}"
                                        ${fn:trim(param.category) eq fn:trim(catIdStr) ? 'selected' : ''}>
                                        ${fn:escapeXml(c.name)}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold text-muted">Khoảng giá (VNĐ)</label>
                            <div class="d-flex gap-2">
                                <input type="number" class="form-control form-control-sm" name="minPrice"
                                       placeholder="Từ" value="${fn:escapeXml(param.minPrice)}" min="0">
                                <input type="number" class="form-control form-control-sm" name="maxPrice"
                                       placeholder="Đến" value="${fn:escapeXml(param.maxPrice)}" min="0">
                            </div>
                        </div>
                        <div class="d-grid gap-2">
                            <button type="submit" class="btn btn-primary btn-sm fw-bold">
                                <i class="bi bi-search me-1"></i>Áp dụng
                            </button>
                            <a href="${pageContext.request.contextPath}/products?action=list"
                               class="btn btn-outline-secondary btn-sm">
                                <i class="bi bi-x-circle me-1"></i>Bỏ lọc
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card filter-card">
                <div class="filter-header">
                    <h6 class="mb-0 fw-bold text-danger"><i class="bi bi-fire"></i> Bán chạy nhất</h6>
                </div>
                <div class="list-group list-group-flush bestseller-scroll">
                    <c:forEach var="sp" items="${bestSellers}">
                        <a href="${pageContext.request.contextPath}/products?action=detail&id=${sp.id}"
                           class="list-group-item list-group-item-action py-3">
                            <div class="d-flex align-items-center gap-3">
                                <div class="flex-shrink-0">
                                    <img src="${pageContext.request.contextPath}/${fn:escapeXml(sp.imagePath)}"
                                         alt="${fn:escapeXml(sp.name)}"
                                         class="bestseller-item rounded" loading="lazy">
                                </div>
                                <div class="flex-grow-1 min-w-0">
                                    <h6 class="mb-1 text-truncate small fw-bold">${fn:escapeXml(sp.name)}</h6>
                                    <div class="text-danger small fw-bold">
                                        <fmt:formatNumber value="${sp.price}" type="number"/>₫
                                    </div>
                                    <small class="text-muted" style="font-size:0.75rem;">Đã bán: ${sp.soldQuantity}</small>
                                </div>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="partials/footer.jsp" %>
<%@ include file="chat_widget.jsp" %>

<script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", function () {

    // =================================================================
    // [FIX BANNER] Swiper: Khởi tạo thumbs TRƯỚC, main SAU
    // Cả hai KHÔNG loop → đồng bộ chính xác
    // =================================================================

    // 1) Khởi tạo Thumbnail Swiper trước
    var swiperThumbs = new Swiper("#swiperThumbs", {
        spaceBetween: 10,
        slidesPerView: 3,
        watchSlidesProgress: true,   // BẮT BUỘC để main nhận biết thumb active
        freeMode: false,
        loop: false
    });

    // 2) Khởi tạo Main Swiper sau, truyền instance thumbs vào
    var swiperMain = new Swiper("#swiperMain", {
        spaceBetween: 0,
        effect: "fade",
        fadeEffect: { crossFade: true },
        loop: false,
        autoplay: {
            delay: 5000,
            disableOnInteraction: false,
            pauseOnMouseEnter: true
        },
        speed: 700,
        navigation: {
            nextEl: "#swiperMain .swiper-button-next",
            prevEl: "#swiperMain .swiper-button-prev"
        },
        pagination: {
            el: "#swiperMain .swiper-pagination",
            clickable: true
        },
        thumbs: {
            swiper: swiperThumbs    // liên kết với instance thumbs
        }
    });

    // =================================================================
    // [FIX SORT] Đổi sortBy → build URL chuẩn và navigate thẳng
    // Không dùng AJAX (tránh lỗi parse full page)
    // =================================================================
    var sortSelect = document.getElementById("sortBy");
    if (sortSelect) {
        sortSelect.addEventListener("change", function () {
            // Lấy URL hiện tại, cập nhật sortBy param
            var url = new URL(window.location.href);
            var params = url.searchParams;

            // Đảm bảo action=list
            params.set("action", "list");

            // Cập nhật sortBy
            var sortVal = this.value;
            if (sortVal) {
                params.set("sortBy", sortVal);
            } else {
                params.delete("sortBy");
            }

            // Reset về trang 1 khi đổi sort
            params.set("page", "1");

            // Navigate
            window.location.href = url.toString();
        });
    }

    // =================================================================
    // [FIX PAGINATION] Link pagination là link thường, không AJAX
    // (vì server trả full page, không trả partial)
    // Nếu sau này server hỗ trợ partial → chuyển lại AJAX
    // =================================================================
    // Pagination links đã là <a href="..."> bình thường → hoạt động luôn.
    // Không cần JS xử lý thêm.

});
</script>
</body>
</html>