<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<meta charset="UTF-8">

<!-- Bootstrap 5 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<!-- Image Search Modal -->
<div class="modal fade" id="imageSearchModal" tabindex="-1" aria-labelledby="imageSearchModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius:16px;">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title" id="imageSearchModalLabel">
                    <i class="fas fa-camera text-gold me-2"></i>Tìm kiếm bằng hình ảnh
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="image-search-container">
                    <div class="drop-zone" id="dropZone">
                        <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                        <p class="mb-2">Kéo thả hình ảnh vào đây</p>
                        <p class="text-muted small">hoặc</p>
                        <label for="imageFileInput" class="btn btn-gold mt-2">
                            <i class="fas fa-folder-open me-2"></i>Chọn file
                        </label>
                        <input type="file" id="imageFileInput" accept="image/*" hidden>
                    </div>
                    <div class="url-input-section mt-3">
                        <div class="divider-text"><span>hoặc dán URL hình ảnh</span></div>
                        <div class="input-group mt-3">
                            <input type="url" class="form-control" id="imageUrlInput" placeholder="https://example.com/image.jpg">
                            <button class="btn btn-gold" type="button" id="searchByUrlBtn"><i class="fas fa-search"></i></button>
                        </div>
                    </div>
                    <div class="image-preview mt-3 d-none" id="imagePreview">
                        <img src="" alt="Preview" id="previewImg">
                        <button type="button" class="btn-remove-preview" id="removePreview"><i class="fas fa-times"></i></button>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-gold" id="submitImageSearch" disabled>
                    <i class="fas fa-search me-2"></i>Tìm kiếm
                </button>
            </div>
        </div>
    </div>
</div>

<header class="main-header" id="main-header">
    <div class="header-inner">
        <!-- Logo -->
        <div class="header-left">
            <a class="logo" href="${pageContext.request.contextPath}/products?action=list" aria-label="Trang chủ">
                <i class="fas fa-lightbulb" aria-hidden="true"></i>
                <span class="logo-text">WEB BÁN ĐÈN TRANG TRÍ</span>
            </a>
        </div>

        <!-- Search -->
        <div class="header-center">
            <form method="get" action="${pageContext.request.contextPath}/products" class="search-form-lens"
                  autocomplete="off" accept-charset="UTF-8" role="search" aria-label="Tìm kiếm sản phẩm">
                <input type="hidden" name="action" value="search"/>
                <div class="search-box-lens">
                    <div class="search-icon-left"><i class="fas fa-search"></i></div>
                    <input type="text" name="keyword" class="search-input-lens"
                        placeholder="Tìm sản phẩm, đèn led, đèn trang trí..."
                        aria-label="Từ khóa tìm kiếm"
                        value="${fn:escapeXml(param.keyword != null ? param.keyword : '')}"
                        maxlength="100" />
                    <div class="search-actions">
                        <button type="button" class="search-action-btn clear-btn d-none" id="clearSearchBtn" aria-label="Xóa">
                            <i class="fas fa-times"></i>
                        </button>
                        <div class="search-divider"></div>
                        <button type="button" class="search-action-btn lens-btn" data-bs-toggle="modal" data-bs-target="#imageSearchModal" aria-label="Tìm kiếm bằng hình ảnh">
                            <svg class="lens-icon" viewBox="0 -960 960 960" xmlns="http://www.w3.org/2000/svg">
                                <path d="M480-320q-50 0-85-35t-35-85q0-50 35-85t85-35q50 0 85 35t35 85q0 50-35 85t-85 35Zm240 160q-33 0-56.5-23.5T640-240q0-33 23.5-56.5T720-320q33 0 56.5 23.5T800-240q0 33-23.5 56.5T720-160Zm-440 40q-66 0-113-47t-47-113v-80h80v80q0 33 23.5 56.5T280-200h200v80H280Zm480-320v-160q0-33-23.5-56.5T680-680H280q-33 0-56.5 23.5T200-600v120h-80v-120q0-66 47-113t113-47h80l40-80h160l40 80h80q66 0 113 47t47 113v160h-80Z"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Mobile Cart -->
        <div class="header-right-mobile d-lg-none">
            <a href="${pageContext.request.contextPath}/cart" class="mobile-cart-btn">
                <i class="fas fa-shopping-cart"></i>
                <span class="cart-badge-mobile">${sessionScope.cartSize != null ? sessionScope.cartSize : 0}</span>
            </a>
        </div>
    </div>

    <!-- Navigation -->
    <nav class="main-nav navbar navbar-expand-lg" aria-label="Điều hướng chính">
        <div class="container-fluid nav-container">
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMainContent"
                    aria-controls="navbarMainContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarMainContent">
                <ul class="navbar-nav main-menu">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/products?action=list">
                            <i class="fas fa-home"></i> TRANG CHỦ
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/about.jsp">
                            <i class="fas fa-info-circle"></i> GIỚI THIỆU
                        </a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-house-chimney"></i> CHIẾU SÁNG TRONG NHÀ
                        </a>
                        <ul class="dropdown-menu">
                            <c:forEach var="c" items="${categories}">
                                <c:if test="${c.parentId == 1}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=${c.categoryId}">${c.name}</a></li>
                                </c:if>
                            </c:forEach>
                            <c:if test="${empty categories}">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=3">Đèn chùm</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=4">Đèn tường</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=5">Đèn bàn</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=6">Đèn ốp trần</a></li>
                            </c:if>
                        </ul>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-tree"></i> CHIẾU SÁNG NGOÀI TRỜI
                        </a>
                        <ul class="dropdown-menu">
                            <c:forEach var="c" items="${categories}">
                                <c:if test="${c.parentId == 2}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=${c.categoryId}">${c.name}</a></li>
                                </c:if>
                            </c:forEach>
                            <c:if test="${empty categories}">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=7">Đèn sân vườn</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=8">Đèn pha</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/products?action=list&category=9">Đèn trụ cổng</a></li>
                            </c:if>
                        </ul>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/contact.jsp">
                            <i class="fas fa-phone"></i> LIÊN HỆ
                        </a>
                    </li>

                    <!-- Mobile Account Menu -->
                    <li class="nav-item dropdown d-lg-none">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-user"></i> TÀI KHOẢN
                        </a>
                        <ul class="dropdown-menu">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/orders?action=list"><i class="fas fa-box"></i> Đơn hàng của tôi</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-user-edit"></i> Thông tin cá nhân</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a></li>
                                </c:when>
                                <c:otherwise>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth?action=login"><i class="fas fa-right-to-bracket"></i> Đăng nhập</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth?action=register"><i class="fas fa-user-plus"></i> Đăng ký</a></li>
                                </c:otherwise>
                            </c:choose>
                        </ul>
                    </li>
                </ul>

                <!-- Desktop: Account & Cart -->
                <ul class="navbar-nav nav-right-actions d-none d-lg-flex">
                    <!-- Back to Top (trong Navbar) -->
                    <li class="nav-item nav-back-to-top" id="navBackToTop">
                        <button class="nav-link btn-back-to-top" type="button" aria-label="Lên đầu trang" title="Lên đầu trang">
                            <i class="fas fa-arrow-up"></i>
                        </button>
                    </li>

                    <!-- Account -->
                    <li class="nav-item dropdown account-dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-user"></i>
                            <c:if test="${not empty sessionScope.user}">
                                <span class="user-name">
                                    ${fn:substring(sessionScope.user.fullName, 0, 10)}
                                    <c:if test="${fn:length(sessionScope.user.fullName) > 10}">...</c:if>
                                </span>
                            </c:if>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/orders?action=list"><i class="fas fa-box"></i> Đơn hàng của tôi</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile"><i class="fas fa-user-edit"></i> Thông tin cá nhân</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fas fa-sign-out-alt"></i> Đăng xuất</a></li>
                                </c:when>
                                <c:otherwise>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth?action=login"><i class="fas fa-right-to-bracket"></i> Đăng nhập</a></li>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth?action=register"><i class="fas fa-user-plus"></i> Đăng ký</a></li>
                                </c:otherwise>
                            </c:choose>
                        </ul>
                    </li>

                    <!-- Cart -->
                    <li class="nav-item dropdown cart-dropdown">
                        <a class="nav-link dropdown-toggle cart-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-shopping-cart"></i>
                            <span class="cart-badge" id="headerCartBadge">
                                ${sessionScope.cartSize != null ? sessionScope.cartSize : 0}
                            </span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end cart-menu" id="headerCartMenu">
                            <li class="cart-header-item">
                                <i class="fas fa-shopping-cart"></i> Giỏ hàng của bạn
                            </li>
                            <li><hr class="dropdown-divider"></li>
                            <c:choose>
                                <c:when test="${not empty sessionScope.cart}">
                                    <div class="cart-items-container" id="headerCartItems">
                                        <c:forEach var="entry" items="${sessionScope.cart}">
                                            <c:set var="item" value="${entry.value}" />
                                            <li class="cart-item-row" data-id="${item.product.id}">
                                                <img src="${pageContext.request.contextPath}/${item.product.imagePath}" alt="${item.product.name}" class="cart-item-img" loading="lazy" />
                                                <div class="cart-item-info">
                                                    <div class="cart-item-name">${item.product.name}</div>
                                                    <div class="cart-item-price"><fmt:formatNumber value="${item.product.price}" type="number"/>₫</div>
                                                    <div class="cart-item-controls">
                                                        <button class="qty-btn" onclick="updateCartItem(${item.product.id}, -1)">−</button>
                                                        <span class="qty-value">${item.quantity}</span>
                                                        <button class="qty-btn" onclick="updateCartItem(${item.product.id}, 1)">+</button>
                                                        <button class="qty-btn remove" onclick="removeCartItem(${item.product.id})">×</button>
                                                    </div>
                                                    <div class="cart-item-subtotal">
                                                        Tổng: <fmt:formatNumber value="${item.subtotal}" type="number"/>₫
                                                    </div>
                                                </div>
                                            </li>
                                        </c:forEach>
                                    </div>
                                    <li><hr class="dropdown-divider"></li>
                                    <li class="cart-total-row">
                                        <span>Tổng cộng:</span>
                                        <strong id="headerCartTotal">
                                            <c:set var="sum" value="0"/>
                                            <c:forEach var="entry" items="${sessionScope.cart}">
                                                <c:set var="sum" value="${sum + entry.value.subtotal}"/>
                                            </c:forEach>
                                            <fmt:formatNumber value="${sum}" type="number"/>₫
                                        </strong>
                                    </li>
                                    <li class="cart-actions-row">
                                        <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-gold btn-sm">
                                            <i class="fas fa-eye"></i> Xem giỏ
                                        </a>
                                        <a href="${pageContext.request.contextPath}/payment" class="btn btn-gold btn-sm">
                                            <i class="fas fa-credit-card"></i> Thanh toán
                                        </a>
                                    </li>
                                </c:when>
                                <c:otherwise>
                                    <li class="empty-cart-message" id="emptyCartMessage">
                                        <i class="fas fa-shopping-cart fa-2x text-muted"></i>
                                        <p>Giỏ hàng trống</p>
                                        <a href="${pageContext.request.contextPath}/products?action=list" class="btn btn-gold btn-sm">Mua sắm ngay</a>
                                    </li>
                                </c:otherwise>
                            </c:choose>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
</header>

<!-- Mobile Back-to-Top -->
<button id="backToTopMobile" class="d-lg-none" aria-label="Lên đầu trang">
    <i class="fas fa-arrow-up"></i>
</button>

<style>
:root {
    --gold: #d4af37;
    --gold-soft: #e6c763;
    --gold-dark: #b8962e;
    --text: #1a1a1a;
    --muted: #666;
    --bg: #fff;
    --bg-soft: #fafafa;
    --border: #e6e6e6;
    --shadow-sm: 0 2px 8px rgba(0,0,0,.06);
    --shadow-md: 0 8px 24px rgba(0,0,0,.1);
    --shadow-lg: 0 12px 40px rgba(0,0,0,.12);
    --transition: .3s cubic-bezier(.4,0,.2,1);
    --header-bg: rgba(255,255,255,0);
    --header-blur: 0px;
    --header-border: transparent;
    --header-shadow: none;
}

/* ====== LUXURY HEADER ====== */
.main-header {
    position: sticky;
    top: 0;
    z-index: 1050;
    font-family: 'Inter', system-ui, sans-serif;
    background: var(--header-bg);
    backdrop-filter: blur(var(--header-blur));
    -webkit-backdrop-filter: blur(var(--header-blur));
    border-bottom: 1px solid var(--header-border);
    box-shadow: var(--header-shadow);
    transition: background .4s ease, backdrop-filter .4s ease, border-color .4s ease, box-shadow .4s ease;
}

/* Scrolled state – frosted glass */
.main-header.scrolled {
    --header-bg: rgba(255,255,255,.85);
    --header-blur: 20px;
    --header-border: rgba(0,0,0,.06);
    --header-shadow: var(--shadow-md);
}

.header-inner {
    max-width: 1320px;
    margin: 0 auto;
    padding: 14px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
}

.header-left { flex: 0 0 auto; }
.header-center { flex: 1; max-width: 600px; margin: 0 auto; }

/* Logo */
.logo {
    text-decoration: none;
    color: var(--text);
    display: inline-flex;
    align-items: center;
    gap: 10px;
    font-weight: 700;
    font-size: 18px;
    transition: var(--transition);
}
.logo:hover { transform: scale(1.02); }
.logo i { font-size: 26px; color: var(--gold); filter: drop-shadow(0 2px 4px rgba(212,175,55,.3)); }
.logo-text {
    background: linear-gradient(135deg, var(--gold) 0%, #f4e3a4 40%, var(--gold-dark) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: .5px;
}

/* Search Box */
.search-form-lens { width: 100%; }
.search-box-lens {
    display: flex;
    align-items: center;
    background: #f1f3f4;
    border-radius: 24px;
    padding: 0 8px 0 16px;
    height: 46px;
    border: 2px solid transparent;
    transition: var(--transition);
}
.search-box-lens:hover,
.search-box-lens:focus-within {
    background: #fff;
    border-color: var(--gold-soft);
    box-shadow: 0 0 0 4px rgba(212,175,55,.1), var(--shadow-sm);
}
.search-icon-left { color: #9aa0a6; font-size: 16px; margin-right: 12px; }
.search-input-lens {
    flex: 1; border: none; background: transparent;
    font-size: 15px; outline: none; color: var(--text);
}
.search-input-lens::placeholder { color: #9aa0a6; }

.search-actions { display: flex; align-items: center; gap: 2px; }
.search-action-btn {
    width: 36px; height: 36px; border: none; background: transparent;
    border-radius: 50%; display: flex; align-items: center; justify-content: center;
    cursor: pointer; transition: var(--transition); color: #5f6368;
}
.search-action-btn:hover { background: rgba(0,0,0,.06); }
.clear-btn { font-size: 14px; }
.search-divider { width: 1px; height: 24px; background: #dadce0; margin: 0 4px; }
.lens-icon { width: 22px; height: 22px; fill: var(--gold); transition: var(--transition); }
.lens-btn:hover .lens-icon { fill: var(--gold-dark); transform: scale(1.1); }

/* Mobile Cart */
.header-right-mobile { display: flex; align-items: center; }
.mobile-cart-btn {
    position: relative; color: var(--text); font-size: 20px;
    padding: 8px; text-decoration: none; transition: var(--transition);
}
.mobile-cart-btn:hover { color: var(--gold); }
.cart-badge-mobile {
    position: absolute; top: 0; right: -2px;
    background: var(--gold); color: #fff; font-size: 10px; font-weight: 700;
    min-width: 18px; height: 18px; border-radius: 9px;
    display: flex; align-items: center; justify-content: center; padding: 0 5px;
}

/* ====== NAVIGATION ====== */
.main-nav {
    background: transparent;
    border-top: 1px solid rgba(0,0,0,.04);
    padding: 0;
}
.nav-container { max-width: 1320px; margin: 0 auto; padding: 0 20px; }

.navbar-toggler {
    border: 1.5px solid var(--gold);
    padding: 6px 12px;
    border-radius: 8px;
    transition: var(--transition);
}
.navbar-toggler:focus { box-shadow: 0 0 0 3px rgba(212,175,55,.25); }
.navbar-toggler-icon {
    background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='%23d4af37' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e");
}

.main-menu { display: flex; align-items: center; gap: 4px; }
.main-menu .nav-link {
    color: var(--text); font-weight: 500; font-size: 13px;
    letter-spacing: .3px; padding: 12px 14px;
    display: flex; align-items: center; gap: 6px;
    transition: var(--transition); white-space: nowrap;
    border-radius: 8px; position: relative;
}
.main-menu .nav-link::after { content: none; } /* Remove Bootstrap caret override */
.main-menu .nav-link:hover { color: var(--gold); background: rgba(212,175,55,.06); }
.main-menu .nav-link i { font-size: 14px; }

/* Keep Bootstrap dropdown caret for dropdown-toggle */
.main-menu .dropdown-toggle::after { display: inline-block; }

/* Dropdown */
.main-nav .dropdown-menu {
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 14px;
    box-shadow: var(--shadow-lg);
    padding: 8px;
    min-width: 210px;
    animation: dropIn .2s ease;
}
@keyframes dropIn {
    from { opacity: 0; transform: translateY(-10px) scale(.98); }
    to { opacity: 1; transform: translateY(0) scale(1); }
}
.main-nav .dropdown-item {
    padding: 10px 14px; border-radius: 8px; font-size: 14px;
    color: var(--text); display: flex; align-items: center;
    gap: 10px; transition: var(--transition);
}
.main-nav .dropdown-item:hover { background: rgba(212,175,55,.08); color: var(--gold); }
.main-nav .dropdown-item i { width: 18px; text-align: center; font-size: 14px; }

/* ====== NAV RIGHT ACTIONS ====== */
.nav-right-actions {
    display: flex; align-items: center; gap: 6px; margin-left: auto;
}
.nav-right-actions .nav-link {
    color: var(--text); font-size: 14px; padding: 10px 12px;
    display: flex; align-items: center; gap: 6px;
    transition: var(--transition); border-radius: 8px;
}
.nav-right-actions .nav-link:hover { color: var(--gold); background: rgba(212,175,55,.06); }
.user-name { font-size: 13px; font-weight: 500; }

/* Back-to-Top in Navbar */
.nav-back-to-top {
    opacity: 0;
    visibility: hidden;
    transform: translateX(-10px);
    transition: opacity .3s ease, visibility .3s ease, transform .3s ease;
    overflow: hidden;
    max-width: 0;
}
.nav-back-to-top.visible {
    opacity: 1;
    visibility: visible;
    transform: translateX(0);
    max-width: 60px;
}
.btn-back-to-top {
    background: none; border: none; cursor: pointer;
    color: var(--gold) !important; font-size: 16px;
    width: 36px; height: 36px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    transition: var(--transition);
}
.btn-back-to-top:hover {
    background: var(--gold) !important;
    color: #fff !important;
    transform: translateY(-2px);
}

/* Cart Badge */
.cart-toggle { position: relative; }
.cart-badge {
    position: absolute; top: 2px; right: 2px;
    background: var(--gold); color: #fff; font-size: 10px; font-weight: 700;
    min-width: 18px; height: 18px; border-radius: 9px;
    display: flex; align-items: center; justify-content: center; padding: 0 5px;
}

/* Cart Menu */
.cart-menu { width: 350px; max-width: 90vw; padding: 0; border-radius: 14px !important; }
.cart-header-item {
    padding: 14px 16px; font-weight: 600; font-size: 14px;
    background: var(--bg-soft); display: flex; align-items: center; gap: 8px;
    border-radius: 14px 14px 0 0;
}
.cart-items-container { max-height: 280px; overflow-y: auto; }
.cart-item-row {
    display: flex; gap: 12px; padding: 12px 16px;
    border-bottom: 1px solid #f1f1f1; transition: var(--transition);
}
.cart-item-row:hover { background: #fafafa; }
.cart-item-img {
    width: 56px; height: 56px; object-fit: cover;
    border-radius: 10px; border: 1px solid #eee;
}
.cart-item-info { flex: 1; }
.cart-item-name { font-size: 13px; font-weight: 500; line-height: 1.3; margin-bottom: 4px; }
.cart-item-price { color: var(--gold); font-weight: 700; font-size: 13px; }
.cart-item-controls { display: flex; align-items: center; gap: 6px; margin-top: 6px; }
.qty-btn {
    width: 26px; height: 26px; border: none; background: var(--gold);
    color: #fff; border-radius: 8px; font-size: 14px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: var(--transition);
}
.qty-btn:hover { filter: brightness(1.1); transform: scale(1.05); }
.qty-btn.remove { background: #ef4444; }
.qty-value { font-size: 13px; min-width: 20px; text-align: center; font-weight: 500; }
.cart-item-subtotal { font-size: 12px; color: var(--muted); margin-top: 4px; }
.cart-total-row { padding: 12px 16px; display: flex; justify-content: space-between; font-size: 14px; }
.cart-actions-row { padding: 12px 16px; display: flex; gap: 10px; }
.empty-cart-message { padding: 28px 16px; text-align: center; }
.empty-cart-message p { margin: 12px 0; color: var(--muted); }

/* ====== BUTTONS ====== */
.btn-gold {
    background: linear-gradient(135deg, var(--gold) 0%, var(--gold-soft) 100%);
    color: #fff; border: none; font-weight: 600;
    transition: var(--transition);
}
.btn-gold:hover { background: linear-gradient(135deg, var(--gold-dark) 0%, var(--gold) 100%); color: #fff; transform: translateY(-1px); }

.btn-outline-gold {
    border: 1.5px solid var(--gold); color: var(--gold);
    background: transparent; font-weight: 500;
    transition: var(--transition);
}
.btn-outline-gold:hover { background: var(--gold); color: #fff; }
.text-gold { color: var(--gold) !important; }

/* ====== IMAGE SEARCH MODAL ====== */
.drop-zone {
    border: 2px dashed #d1d5db; border-radius: 14px;
    padding: 40px 20px; text-align: center;
    transition: var(--transition); cursor: pointer;
}
.drop-zone:hover, .drop-zone.drag-over {
    border-color: var(--gold); background: rgba(212,175,55,.04);
}
.divider-text { text-align: center; position: relative; }
.divider-text::before, .divider-text::after {
    content: ''; position: absolute; top: 50%; width: 38%; height: 1px; background: #e5e7eb;
}
.divider-text::before { left: 0; }
.divider-text::after { right: 0; }
.divider-text span { background: #fff; padding: 0 12px; color: #9ca3af; font-size: 13px; }

.image-preview { position: relative; display: inline-block; width: 100%; text-align: center; }
.image-preview img { max-width: 100%; max-height: 200px; border-radius: 10px; border: 1px solid #e5e7eb; }
.btn-remove-preview {
    position: absolute; top: -10px; right: calc(50% - 110px);
    width: 28px; height: 28px; border-radius: 50%; border: none;
    background: #ef4444; color: #fff; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: var(--transition);
}
.btn-remove-preview:hover { transform: scale(1.1); }

/* ====== MOBILE BACK-TO-TOP ====== */
#backToTopMobile {
    position: fixed; bottom: 28px; right: 28px;
    width: 44px; height: 44px; border-radius: 50%; border: none;
    background: var(--gold); color: #fff; font-size: 18px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer; box-shadow: var(--shadow-md);
    opacity: 0; visibility: hidden; transform: translateY(15px);
    transition: opacity .3s ease, transform .3s ease, visibility .3s;
    z-index: 9999;
}
#backToTopMobile:hover { background: var(--gold-soft); }
#backToTopMobile.show { opacity: 1; visibility: visible; transform: translateY(0); }

/* ====== RESPONSIVE ====== */
@media (max-width: 992px) {
    .header-inner { flex-wrap: wrap; gap: 12px; }
    .header-center { order: 3; max-width: 100%; width: 100%; }
    .main-menu { flex-direction: column; align-items: flex-start; gap: 0; width: 100%; }
    .main-menu .nav-item { width: 100%; }
    .main-menu .nav-link {
        padding: 12px 16px; border-bottom: 1px solid #f1f1f1; border-radius: 0;
    }
    .main-nav .dropdown-menu {
        border: none; box-shadow: none; padding-left: 20px; background: #fafafa;
        animation: none;
    }
    .navbar-collapse { max-height: 70vh; overflow-y: auto; }
}
@media (max-width: 576px) {
    .logo-text { font-size: 14px; }
    .logo i { font-size: 20px; }
    .header-inner { padding: 10px 14px; }
}
</style>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function(){
    var CTX = '${pageContext.request.contextPath}';
    var header = document.getElementById('main-header');
    var navBackToTop = document.getElementById('navBackToTop');
    var backToTopMobile = document.getElementById('backToTopMobile');
    var lastScroll = 0;

    // ====== SCROLL: Frosted glass + Back-to-Top ======
    window.addEventListener('scroll', function() {
        var y = window.scrollY;

        // Header frosted glass
        if (header) header.classList.toggle('scrolled', y > 30);

        // Desktop: back-to-top in navbar
        if (navBackToTop) navBackToTop.classList.toggle('visible', y > 400);

        // Mobile: floating back-to-top
        if (backToTopMobile) backToTopMobile.classList.toggle('show', y > 400);

        lastScroll = y;
    }, {passive: true});

    // Back-to-top click handlers
    if (navBackToTop) {
        var btn = navBackToTop.querySelector('.btn-back-to-top');
        if (btn) btn.addEventListener('click', function() {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }
    if (backToTopMobile) {
        backToTopMobile.addEventListener('click', function() {
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
    }

    // ====== CART FUNCTIONS ======
    window.updateCartItem = function(id, change) {
        var item = document.querySelector(".cart-item-row[data-id='" + id + "']");
        var qtyEl = item ? item.querySelector('.qty-value') : null;
        var current = qtyEl ? parseInt(qtyEl.textContent, 10) : 1;
        if (isNaN(current) || current < 1) current = 1;
        var newQty = current + (parseInt(change, 10) || 0);
        if (newQty < 1) newQty = 1;

        var body = new URLSearchParams();
        body.append('action', 'update');
        body.append('productId', id);
        body.append('quantity', newQty);

        fetch(CTX + '/cart', {
            method: 'POST',
            headers: {'X-Requested-With': 'XMLHttpRequest'},
            body: body
        }).then(function() { location.reload(); })
          .catch(function() { location.reload(); });
    };

    window.removeCartItem = function(id) {
        var body = new URLSearchParams();
        body.append('action', 'remove');
        body.append('productId', id);

        fetch(CTX + '/cart', {
            method: 'POST',
            headers: {'X-Requested-With': 'XMLHttpRequest'},
            body: body
        }).then(function() { location.reload(); })
          .catch(function() { location.reload(); });
    };

    // ====== CLEAR SEARCH ======
    var searchInput = document.querySelector('.search-input-lens');
    var clearBtn = document.getElementById('clearSearchBtn');
    if (searchInput && clearBtn) {
        searchInput.addEventListener('input', function() {
            clearBtn.classList.toggle('d-none', !this.value);
        });
        clearBtn.addEventListener('click', function() {
            searchInput.value = '';
            clearBtn.classList.add('d-none');
            searchInput.focus();
        });
        if (searchInput.value) clearBtn.classList.remove('d-none');
    }

    // ====== IMAGE SEARCH MODAL ======
    var dropZone = document.getElementById('dropZone');
    var fileInput = document.getElementById('imageFileInput');
    var urlInput = document.getElementById('imageUrlInput');
    var searchByUrlBtn = document.getElementById('searchByUrlBtn');
    var previewContainer = document.getElementById('imagePreview');
    var previewImg = document.getElementById('previewImg');
    var removePreviewBtn = document.getElementById('removePreview');
    var submitBtn = document.getElementById('submitImageSearch');
    var selectedFile = null;

    if (dropZone) {
        ['dragenter','dragover','dragleave','drop'].forEach(function(e) {
            dropZone.addEventListener(e, function(ev) { ev.preventDefault(); ev.stopPropagation(); });
        });
        ['dragenter','dragover'].forEach(function(e) {
            dropZone.addEventListener(e, function() { dropZone.classList.add('drag-over'); });
        });
        ['dragleave','drop'].forEach(function(e) {
            dropZone.addEventListener(e, function() { dropZone.classList.remove('drag-over'); });
        });
        dropZone.addEventListener('drop', function(e) {
            var files = e.dataTransfer.files;
            if (files.length > 0 && files[0].type.startsWith('image/')) handleFile(files[0]);
        });
        dropZone.addEventListener('click', function() { fileInput.click(); });
    }

    if (fileInput) {
        fileInput.addEventListener('change', function() {
            if (this.files.length > 0) handleFile(this.files[0]);
        });
    }

    function handleFile(file) {
        selectedFile = file;
        var reader = new FileReader();
        reader.onload = function(e) {
            previewImg.src = e.target.result;
            previewContainer.classList.remove('d-none');
            dropZone.style.display = 'none';
            submitBtn.disabled = false;
        };
        reader.readAsDataURL(file);
    }

    if (removePreviewBtn) {
        removePreviewBtn.addEventListener('click', function() {
            selectedFile = null;
            previewImg.src = '';
            previewContainer.classList.add('d-none');
            dropZone.style.display = 'block';
            submitBtn.disabled = true;
            fileInput.value = '';
        });
    }

    if (searchByUrlBtn) {
        searchByUrlBtn.addEventListener('click', function() {
            var url = urlInput.value.trim();
            if (url) {
                previewImg.src = url;
                previewContainer.classList.remove('d-none');
                dropZone.style.display = 'none';
                submitBtn.disabled = false;
                selectedFile = null;
            }
        });
    }

    if (submitBtn) {
        submitBtn.addEventListener('click', function() {
            if (selectedFile) {
                var form = document.createElement('form');
                form.method = 'POST';
                form.action = CTX + '/search-image';
                form.enctype = 'multipart/form-data';
                form.style.display = 'none';
                var input = document.createElement('input');
                input.type = 'file'; input.name = 'image_file';
                input.files = fileInput.files;
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            } else if (urlInput.value.trim()) {
                window.location.href = CTX + '/search-image?image_url=' + encodeURIComponent(urlInput.value.trim());
            }
            bootstrap.Modal.getInstance(document.getElementById('imageSearchModal')).hide();
        });
    }
})();
</script>