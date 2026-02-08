<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<meta charset="UTF-8">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>

<button id="backToTop" aria-label="Lên đầu trang">
    <i class="fas fa-arrow-up"></i>
</button>

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
            <form method="get" action="${pageContext.request.contextPath}/products" class="search-form"
                  autocomplete="off" accept-charset="UTF-8" role="search" aria-label="Tìm kiếm sản phẩm">
                <input type="hidden" name="action" value="search"/>
                <input
                    type="text"
                    name="keyword"
                    class="search-input"
                    placeholder="Tìm sản phẩm, đèn led, đèn trang trí..."
                    aria-label="Từ khóa tìm kiếm"
                    value="${fn:escapeXml(param.keyword != null ? param.keyword : '')}"
                    maxlength="100" />
                <button type="submit" class="search-btn" aria-label="Tìm kiếm">
                    <i class="fas fa-search" aria-hidden="true"></i>
                </button>
            </form>
        </div>

        <!-- Account + Cart -->
        <div class="header-right">
            <!-- Account -->
            <div class="dropdown account-dropdown">
                <button class="dropdown-toggle" type="button" aria-haspopup="true" aria-expanded="false">
                    <i class="fas fa-user" aria-hidden="true"></i>
                    <c:if test="${not empty sessionScope.user}">
                        <span class="hello">
                            Xin chào,
                            ${fn:substring(sessionScope.user.fullName, 0, 15)}
                            <c:if test="${fn:length(sessionScope.user.fullName) > 15}">...</c:if>
                        </span>
                    </c:if>
                </button>
                <div class="dropdown-menu account-menu" role="menu" aria-label="Tài khoản">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <a href="${pageContext.request.contextPath}/orders?action=list">
                                <i class="fas fa-box" aria-hidden="true"></i> Đơn hàng của tôi
                            </a>
                            <a href="${pageContext.request.contextPath}/profile">
                                <i class="fas fa-user-edit" aria-hidden="true"></i> Thông tin cá nhân
                            </a>
                            <a href="${pageContext.request.contextPath}/auth?action=logout">
                                <i class="fas fa-sign-out-alt" aria-hidden="true"></i> Đăng xuất
                            </a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/auth?action=login">
                                <i class="fas fa-right-to-bracket" aria-hidden="true"></i> Đăng nhập
                            </a>
                            <a href="${pageContext.request.contextPath}/auth?action=register">
                                <i class="fas fa-user-plus" aria-hidden="true"></i> Đăng ký
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Cart -->
            <div class="dropdown cart-dropdown">
                <button class="dropdown-toggle" type="button" aria-haspopup="true" aria-expanded="false">
                    <i class="fas fa-shopping-cart" aria-hidden="true"></i>
                    <span class="cart-count" aria-label="Số lượng sản phẩm trong giỏ">
                        ${sessionScope.cartSize != null ? sessionScope.cartSize : 0}
                    </span>
                </button>
                <div class="dropdown-menu cart-menu" role="menu" aria-label="Giỏ hàng">
                    <div class="cart-header">
                        <h4><i class="fas fa-shopping-cart" aria-hidden="true"></i> Giỏ hàng của bạn</h4>
                    </div>
                    <c:choose>
                        <c:when test="${not empty sessionScope.cart}">
                            <div class="cart-items">
                                <c:forEach var="entry" items="${sessionScope.cart}">
                                    <c:set var="item" value="${entry.value}" />
                                    <div class="cart-item" data-id="${item.product.id}">
                                        <img src="${pageContext.request.contextPath}/${item.product.imagePath}" alt="${item.product.name}" loading="lazy" />
                                        <div class="cart-info">
                                            <div class="name">${item.product.name}</div>
                                            <div class="price">
                                                <fmt:formatNumber value="${item.product.price}" type="number"/>₫
                                            </div>
                                            <div class="quantity-controls" aria-label="Điều chỉnh số lượng">
                                                <button class="qty-btn decrease-btn" onclick="updateCartItem(${item.product.id}, -1)" aria-label="Giảm số lượng">-</button>
                                                <span class="quantity" aria-live="polite">${item.quantity}</span>
                                                <button class="qty-btn increase-btn" onclick="updateCartItem(${item.product.id}, 1)" aria-label="Tăng số lượng">+</button>
                                                <button class="qty-btn remove-btn" onclick="removeCartItem(${item.product.id}, this)" aria-label="Xóa sản phẩm">x</button>
                                            </div>
                                            <div class="subtotal">Tổng: <fmt:formatNumber value="${item.subtotal}" type="number"/>₫</div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                            <div class="cart-total">
                                <span>Tổng cộng:</span>
                                <strong>
                                    <c:set var="sum" value="0"/>
                                    <c:forEach var="entry" items="${sessionScope.cart}">
                                        <c:set var="sum" value="${sum + entry.value.subtotal}"/>
                                    </c:forEach>
                                    <fmt:formatNumber value="${sum}" type="number"/>₫
                                </strong>
                            </div>
                            <div class="cart-actions">
                                <a href="${pageContext.request.contextPath}/cart" class="btn-view-cart">
                                    <i class="fas fa-eye" aria-hidden="true"></i> Xem giỏ hàng
                                </a>
                                <a href="${pageContext.request.contextPath}/payment" class="btn-checkout">
                                    <i class="fas fa-credit-card" aria-hidden="true"></i> Thanh toán
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-cart">
                                <i class="fas fa-shopping-cart" aria-hidden="true"></i>
                                <p>Giỏ hàng trống</p>
                                <a href="${pageContext.request.contextPath}/products?action=list" class="btn-shopping">
                                    Tiếp tục mua sắm
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <!-- Navigation -->
    <nav class="main-nav" aria-label="Điều hướng chính">
        <ul class="menu">
            <li><a href="${pageContext.request.contextPath}/products?action=list"><i class="fas fa-home"></i> TRANG CHỦ</a></li>
            <li><a href="${pageContext.request.contextPath}/about.jsp"><i class="fas fa-info-circle"></i> GIỚI THIỆU</a></li>

            <li class="nav-dropdown">
                <a href="#" class="nav-link has-sub"><i class="fas fa-house-chimney"></i> CHIẾU SÁNG TRONG NHÀ <i class="fas fa-caret-down" aria-hidden="true"></i></a>
                <ul class="sub-menu" aria-label="Chiếu sáng trong nhà">
                    <c:forEach var="c" items="${categories}">
                        <c:if test="${c.parentId == 1}">
                            <li><a href="${pageContext.request.contextPath}/products?action=list&category=${c.categoryId}">${c.name}</a></li>
                        </c:if>
                    </c:forEach>
                </ul>
            </li>

            <li class="nav-dropdown">
                <a href="#" class="nav-link has-sub"><i class="fas fa-tree"></i> CHIẾU SÁNG NGOÀI TRỜI <i class="fas fa-caret-down" aria-hidden="true"></i></a>
                <ul class="sub-menu" aria-label="Chiếu sáng ngoài trời">
                    <c:forEach var="c" items="${categories}">
                        <c:if test="${c.parentId == 2}">
                            <li><a href="${pageContext.request.contextPath}/products?action=list&category=${c.categoryId}">${c.name}</a></li>
                        </c:if>
                    </c:forEach>
                </ul>
            </li>

            <li><a href="${pageContext.request.contextPath}/contact.jsp"><i class="fas fa-phone"></i> LIÊN HỆ</a></li>
        </ul>
    </nav>
</header>

<style>
   @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap');

:root{
  --gold:#d4af37; --gold-soft:#e6c763;
  --text:#1a1a1a; --muted:#666;
  --bg:#fff; --bg-soft:#fafafa; --border:#e6e6e6;
  --radius-xs:4px; --radius-sm:8px; --radius-md:12px; --radius-lg:14px;
  --shadow:0 10px 30px rgba(0,0,0,0.08);
  --focus:0 0 0 3px rgba(212,175,55,.35);
  --transition:.2s ease;
  --header-max:1320px; --pad-x:18px; --pad-y:10px;
  --icon:18px; --nav-icon:16px;
  --right-shift: -40px;
}

/* Header shell */
.main-header{
  background:var(--bg);
  border-bottom:1px solid var(--border);
  position:sticky; top:0; z-index:10010;
  font-family:'Inter',system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
  backdrop-filter:blur(6px);
  overflow:visible;
}
.header-inner{
  max-width:var(--header-max);
  margin:0 auto;
  padding:var(--pad-y) var(--pad-x);
  display:grid;
  grid-template-columns: 1fr 1fr 1fr; /* logo | search | account/cart */
  align-items:center; gap:28px; overflow:visible;
}
.header-left{ display:flex; align-items:center; justify-content:flex-start; }
.header-center{ display:flex; align-items:center; justify-content:center; }
.header-right{
  display:flex; align-items:center; justify-content:flex-end; gap:22px;
  position: relative; left: var(--right-shift);
}

/* Logo */
.logo{
  text-decoration:none; color:var(--text);
  display:inline-flex; align-items:center; gap:8px;
  font-weight:600; font-size:20px; letter-spacing:.5px;
  line-height:1; padding:6px 8px; border-radius:var(--radius-sm);
}
.logo i{ font-size:24px; color:var(--gold); filter:drop-shadow(0 0 4px rgba(212,175,55,.4)); }
.logo-text{ background:linear-gradient(90deg,var(--gold) 0%,#f4e3a4 50%,var(--gold) 100%); -webkit-background-clip:text; color:transparent; }

/* Search */
.search-form{ position:relative; display:flex; align-items:center; width:100%; max-width:520px; }
.search-input{
  width:100%; padding:10px 16px 10px 44px; border-radius:50px;
  background:#f5f5f5; border:1px solid var(--border); font-size:14px;
  transition:var(--transition); line-height:1;
}
.search-input:hover{ background:#f1f1f1; }
.search-input:focus{ outline:none; background:var(--bg); border-color:var(--gold); box-shadow:var(--focus); }
.search-btn{
  position:absolute; left:16px; top:50%; transform:translateY(-50%);
  border:none; background:transparent; color:#888; font-size:var(--icon);
  width:24px; height:24px; display:flex; align-items:center; justify-content:center;
  cursor:pointer; transition:var(--transition); line-height:1;
}
.search-btn:hover{ color:var(--gold); }

/* Dropdown base */
.dropdown{ position:relative; overflow:visible; }
.dropdown-toggle{
  background:none; border:none; cursor:pointer; color:var(--text); font-size:var(--icon);
  padding:10px; /* tăng hit area chống “rơi” */
  line-height:1; border-radius:var(--radius-sm);
  display:inline-flex; align-items:center; justify-content:center; gap:8px; transition:var(--transition);
}
.dropdown-toggle i{ font-size:var(--icon); line-height:1; }
.dropdown-toggle .hello{ font-size:13px; color:var(--muted); }
.dropdown-toggle:hover,.dropdown-toggle:focus{ color:var(--gold); }
.dropdown-toggle:focus-visible{ outline:none; box-shadow:var(--focus); }

.cart-count{
  position:absolute; top:-4px; right:-4px;
  background:var(--gold); color:#fff; font-size:11px; font-weight:600; line-height:1;
  padding:2px 6px; border-radius:50px; min-width:20px; text-align:center;
}

/* Dropdown menu – dính sát, mở ngay (no lag), width theo nội dung */
.dropdown-menu{
  position:absolute; right:0; top:100%;
  width:auto; min-width: 220px; max-width: 90vw;
  background:var(--bg);
  border-radius:12px; border:1px solid var(--border);
  padding:0; box-shadow:var(--shadow);
  visibility:hidden; opacity:0; pointer-events:none;
  transition:none; /* loại bỏ lag do opacity/transform */
  overflow:hidden; z-index:10020;
}
.dropdown:hover>.dropdown-menu,
.dropdown:focus-within>.dropdown-menu,
.dropdown.open>.dropdown-menu{
  visibility:visible; opacity:1; pointer-events:auto;
}

/* “Cầu hover” mỏng giữa toggle và menu để tránh rơi khỏi hover */
.dropdown::before{
  content:""; position:absolute; left:0; right:0; top:100%; height:6px; pointer-events:none;
}
.cart-dropdown::before{ height:6px; }

/* Account menu */
.account-menu{ width:auto; min-width: 220px; }
.account-menu a{
  display:flex; align-items:center; gap:8px; padding:10px 14px;
  font-size:14px; color:var(--text); text-decoration:none;
  line-height:1; transition:var(--transition); white-space:nowrap;
}
.account-menu a i{ font-size:var(--icon); }
.account-menu a:hover{ background:#f7f7f7; color:var(--gold); }

/* Cart menu */
.cart-menu{ width:auto; min-width: 280px; max-width: 420px; }
.cart-header{
  padding:10px 14px; font-weight:600; background:var(--bg-soft); border-bottom:1px solid var(--border);
  display:flex; align-items:center; gap:8px; letter-spacing:.3px;
}
.cart-header h4{ margin:0; font-size:14px; display:flex; align-items:center; gap:8px; }

.cart-items{
  max-height:280px; overflow-y:auto; scrollbar-width:thin; scrollbar-color:#ccc transparent;
}
.cart-items::-webkit-scrollbar{ width:8px; }
.cart-items::-webkit-scrollbar-thumb{ background:#c9c9c9; border-radius:10px; }

.cart-item{
  display:flex; gap:12px; padding:10px 12px; border-bottom:1px solid #f1f1f1;
  align-items:flex-start; background:#fff; transition:background .18s ease;
}
.cart-item:hover{ background:#fafafa; }
.cart-item img{
  width:56px; height:56px; object-fit:cover;
  border-radius:8px; border:1px solid #eee; flex-shrink:0;
}
.cart-info .name{ font-size:14px; font-weight:500; line-height:1.35; }
.cart-info .price{ color:var(--gold); font-weight:600; margin:4px 0 2px; font-size:13px; }
.subtotal{ font-size:12px; color:var(--muted); margin-top:6px; }

.quantity-controls{
  display:flex; align-items:center; gap:6px; margin-top:6px; flex-wrap:wrap;
}
.qty-btn{
  padding:4px 8px; border:none; background:var(--gold); color:#fff;
  font-size:13px; border-radius:6px; cursor:pointer;
  display:inline-flex; align-items:center; justify-content:center;
  transition:var(--transition);
}
.qty-btn:hover{ filter:brightness(1.1); }
.remove-btn{ background:#ff5a5a !important; }
.remove-btn:hover{ filter:brightness(1.15); }

.cart-total{
  padding:10px 14px; display:flex; justify-content:space-between; align-items:center;
  border-top:1px solid var(--border); font-size:15px; background:#fff;
}
.cart-actions{
  display:flex; padding:10px; gap:10px; background:#fff;
}
.btn-view-cart,.btn-checkout{
  flex:1; text-align:center; background:var(--gold); color:#fff;
  padding:10px 12px; border-radius:10px;
  font-weight:600; text-decoration:none; font-size:14px;
  letter-spacing:.4px; transition:var(--transition);
  display:inline-flex; align-items:center; justify-content:center; gap:8px;
}
.btn-view-cart i,.btn-checkout i{ font-size:var(--icon); }
.btn-view-cart:hover,.btn-checkout:hover{ background:var(--gold-soft); }

.empty-cart{
  padding:16px 14px; text-align:center; background:#fff;
}
.empty-cart i{
  font-size:40px; color:#bbb; margin-bottom:8px; display:block;
}
.empty-cart p{
  margin:6px 0 10px; color:var(--muted); font-size:14px;
}
.btn-shopping{
  display:inline-block; margin-top:6px; background:var(--gold); color:#fff;
  padding:8px 16px; border-radius:999px; font-size:13px;
  text-decoration:none; font-weight:600; transition:var(--transition);
}
.btn-shopping:hover{ background:var(--gold-soft); }

/* Navigation */
.main-nav{
  background:var(--bg);
  border-top:1px solid var(--border);
  position:relative; z-index:1000; overflow:visible;
}
.menu{
  max-width:var(--header-max); margin:0 auto;
  display:flex; gap:30px; padding:12px var(--pad-x);
  list-style:none; align-items:center; position:relative;
  overflow:visible; justify-content:center;
}
.menu>li{ position:relative; }

.menu a{
  text-decoration:none; color:var(--text);
  font-weight:500; font-size:14px; letter-spacing:.5px;
  padding:6px 2px; display:inline-flex; align-items:center; gap:6px;
  transition:var(--transition); line-height:1; position:relative;
  white-space:nowrap;
}
.menu a i{ font-size:var(--nav-icon); line-height:1; display:inline-block; }
.menu a:hover{ color:var(--gold); }
.menu a::after{
  content:""; position:absolute; left:50%; bottom:-4px;
  width:0%; height:2px; background:var(--gold);
  border-radius:3px; transform:translateX(-50%);
  transition:width .25s ease, transform .25s ease;
}
.menu a:hover::after{ width:100%; transform:translateX(-50%); }

/* Sub-menu – dính sát, mở ngay (no lag), width theo nội dung */
.nav-dropdown{ position:relative; }
.nav-link.has-sub{ cursor:pointer; }
.sub-menu{
  list-style:none; padding:6px 8px; margin:0;
  position:absolute; top:100%; left:0;
  width:auto; min-width: 220px; max-width: 90vw;
  background:var(--bg);
  border:1px solid var(--border);
  border-radius:12px;
  box-shadow:var(--shadow);
  overflow:hidden; visibility:hidden; opacity:0;
  pointer-events:none; transition:none; /* no lag */
  z-index:1005;
}
.nav-dropdown:hover .sub-menu,
.nav-dropdown:focus-within .sub-menu,
.nav-dropdown.open .sub-menu{
  visibility:visible; opacity:1; pointer-events:auto;
}
.sub-menu li a{
  display:block; padding:8px 10px; font-size:14px; color:var(--text);
  text-decoration:none; white-space:nowrap; border-radius:8px; transition:background .15s ease, color .15s ease;
}
.sub-menu li a:hover{ background:#f7f7f7; color:var(--gold); }

/* Back to top */
#backToTop{
  position: fixed; bottom: 28px; right: 28px;
  width: 44px; height: 44px; border-radius: 50%;
  border: none; background: var(--gold); color: #fff; font-size: 18px;
  display: flex; align-items: center; justify-content: center;
  cursor: pointer; box-shadow:var(--shadow);
  opacity: 0; visibility: hidden; transform: translateY(15px);
  transition: opacity .25s ease, transform .25s ease, visibility .25s; z-index: 9999;
}
#backToTop:hover{ background: var(--gold-soft); filter: brightness(1.05); }
#backToTop.show{ opacity: 1; visibility: visible; transform: translateY(0); }

/* Responsive */
@media (max-width:992px){
  .header-inner{ grid-template-columns: 1fr; gap:14px; }
  .header-right{ left: 0; gap:14px; }
  .search-form{ max-width:100%; }
  .menu{ flex-wrap:wrap; gap:18px; justify-content:flex-start; }

  /* Center dropdown on mobile, bỏ translateY để không tạo khe */
  .dropdown-menu{
    right:auto; left:50%;
    transform:translateX(-50%); /* no translateY */
  }
  .dropdown.open>.dropdown-menu{
    transform:translateX(-50%);
  }
}
@media (max-width:640px){
  .main-nav{ border-top:none; }
  .menu{ padding-top:4px; }
}
</style>

<script>
/*
Header JS
- Dropdown hover/focus/click ổn định hơn với LEAVE_DELAY tăng.
- Không set inline style lên .dropdown-menu.
*/
(function(){
  // tăng delay để tránh ẩn quá nhanh khi chuột rời cạnh vài pixel
  var LEAVE_DELAY = 90; // ms
  var CTX = '${pageContext.request.contextPath}';

  function updateCartBadge(count) {
    var cartBadge = document.querySelector('.cart-count');
    if (cartBadge) {
      cartBadge.textContent = count;
      cartBadge.style.animation = 'pulse 0.6s ease';
      setTimeout(function () { cartBadge.style.animation = ''; }, 600);
    }
  }
  window.updateCartBadge = updateCartBadge;

  function updateCartItem(id, change) {
    try {
      var item = document.querySelector(".cart-item[data-id='" + id + "']");
      var qtyEl = item ? item.querySelector('.quantity') : null;
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
      }).then(function () { location.reload(); })
        .catch(function () { location.reload(); });
    } catch (e) {
      console.error(e);
      location.reload();
    }
  }
  window.updateCartItem = updateCartItem;

  function removeCartItem(id) {
    try {
      var body = new URLSearchParams();
      body.append('action', 'remove');
      body.append('productId', id);

      fetch(CTX + '/cart', {
        method: 'POST',
        headers: {'X-Requested-With': 'XMLHttpRequest'},
        body: body
      }).then(function () { location.reload(); })
        .catch(function () { location.reload(); });
    } catch (e) {
      console.error(e);
      location.reload();
    }
  }
  window.removeCartItem = removeCartItem;

  function attachStableDropdowns(){
    var dropdowns = document.querySelectorAll('.main-header .dropdown');
    dropdowns.forEach(function(dd){
      var menu = dd.querySelector('.dropdown-menu');
      var btn  = dd.querySelector('.dropdown-toggle');
      if (!menu || !btn) return;

      var leaveTimer = null;

      function open() {
        clearTimeout(leaveTimer);
        dd.classList.add('open');
      }
      function scheduleClose() {
        clearTimeout(leaveTimer);
        leaveTimer = setTimeout(function(){ dd.classList.remove('open'); }, LEAVE_DELAY);
      }

      dd.addEventListener('mouseenter', open);
      dd.addEventListener('mouseleave', scheduleClose);
      menu.addEventListener('mouseenter', open);
      menu.addEventListener('mouseleave', scheduleClose);
      dd.addEventListener('focusin', open);
      dd.addEventListener('focusout', function(e){
        if (!dd.contains(e.relatedTarget)) scheduleClose();
      });

      btn.addEventListener('click', function(e){
        e.preventDefault();
        clearTimeout(leaveTimer);
        dd.classList.toggle('open');
      });

      document.addEventListener('click', function(ev){
        if (!dd.contains(ev.target)) dd.classList.remove('open');
      });
    });
  }

  function backToTopInit(){
    var backToTop = document.getElementById("backToTop");
    if (!backToTop) return;
    window.addEventListener("scroll", function () {
      if (window.scrollY > 300) backToTop.classList.add("show");
      else backToTop.classList.remove("show");
    }, {passive:true});
    backToTop.addEventListener("click", function () {
      window.scrollTo({ top: 0, behavior: "smooth" });
    });
  }
  function headerShadowInit(){
    var header = document.getElementById('main-header');
    if (!header) return;
    window.addEventListener('scroll', function () {
      header.style.boxShadow = window.scrollY > 20
        ? '0 8px 32px rgba(0,0,0,0.12)'
        : '0 2px 8px rgba(0,0,0,0.08)';
    }, {passive:true});
  }

  document.addEventListener('DOMContentLoaded', function(){
    attachStableDropdowns();
    backToTopInit();
    headerShadowInit();
  });
})();
</script>