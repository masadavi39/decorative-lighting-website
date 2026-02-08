<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Web bán đèn trang trí</title>
        <style>
            :root{
                --bg-color:#f8f9fa;
                --text-color:#333;
                --muted:#556;
                --card-bg:#fff;
                --shadow:rgba(0,0,0,0.1);
                --heading:#2c3e50;
                --primary:#007bff;      /* xanh dương */
                --success:#28a745;
                --danger:#e74c3c;
                --border:#dcdcdc;
                --input-bg:#fff;
                --input-text:#222;
                --input-border:#cfcfcf;
                --chip-bg:#eef4ff;
            }
            body.dark{
                --bg-color:#121416;
                --text-color:#e9e9e9;
                --muted:#a7b0c0;
                --card-bg:#1a1f25;
                --shadow:rgba(0,0,0,0.4);
                --heading:#cde1ff;
                --primary:#4ea3ff;
                --success:#48d06b;
                --danger:#ff6b6b;
                --border:#2b323b;
                --input-bg:#11161c;
                --input-text:#e9e9e9;
                --input-border:#2c3440;
                --chip-bg:#1e2a38;
            }

            *{margin:0;padding:0;box-sizing:border-box}
            body{
                font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;
                background:var(--bg-color);
                color:var(--text-color);
                line-height:1.6;
                transition:background .3s,color .3s;
            }
            .container{max-width:1400px;margin:0 auto;padding:20px}

            /* Banner */
            .banner{width:100%;margin:20px 0;border-radius:12px;overflow:hidden;box-shadow:0 8px 20px var(--shadow)}
            .banner-slider{position:relative;height:400px}
            .slide{position:absolute;width:100%;height:100%;opacity:0;transition:opacity 1s ease}
            .slide.active{opacity:1}
            .slide img{width:100%;height:400px;object-fit:cover}
            .prev,.next{
                position:absolute;top:50%;transform:translateY(-50%);
                background:rgba(0,0,0,.45);color:#fff;border:none;
                padding:12px 16px;cursor:pointer;font-size:18px;border-radius:10px;
                transition:background .2s
            }
            .prev:hover,.next:hover{background:rgba(0,0,0,.7)}
            .prev{left:10px} .next{right:10px}
            .banner-thumbs{display:flex;justify-content:center;gap:10px;padding:14px;background:var(--bg-color)}
            .banner-thumbs img{width:80px;height:60px;object-fit:cover;border-radius:8px;cursor:pointer;opacity:.6;transition:opacity .2s,transform .2s}
            .banner-thumbs img.active,.banner-thumbs img:hover{opacity:1;transform:translateY(-2px)}

            /* Layout */
            .main-content{display:flex;gap:30px;margin-top:30px}
            .products-section{flex:3}
            .sidebar{flex:1;display:flex;flex-direction:column;gap:20px}

            /* Cards */
            .bestseller-box,.search-box{
                background:var(--card-bg);padding:20px;border-radius:14px;
                box-shadow:0 6px 16px var(--shadow);border:1px solid var(--border)
            }
            h2{color:var(--heading);text-align:center;margin-bottom:22px;font-size:2rem}
            h3{color:var(--heading);margin-bottom:14px;text-align:left}

            /* Sort */
            .products-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;gap:10px;flex-wrap:wrap}
            .sort-form{
                display:flex;align-items:center;gap:8px;background:var(--card-bg);
                padding:6px 10px;border-radius:10px;box-shadow:0 4px 10px var(--shadow);border:1px solid var(--border)
            }
            .sort-form label{font-weight:600;font-size:.95rem}
            .sort-form select{
                padding:10px 12px;border-radius:8px;border:1px solid var(--input-border);
                background:var(--input-bg);color:var(--input-text);cursor:pointer;font-size:.95rem;
                transition:border-color .2s,box-shadow .2s;appearance:none;
                background-image:url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>');
                background-repeat:no-repeat;background-position:right 12px center;padding-right:32px
            }
            .sort-form select:hover{border-color:var(--primary)}

            /* Grid */
            .product-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:20px;margin-bottom:30px}
            .product-card{
                background:var(--card-bg);border-radius:14px;padding:16px;text-align:center;
                box-shadow:0 6px 16px var(--shadow);transition:transform .2s,border-color .2s;
                border:1px solid var(--border);display:flex;flex-direction:column
            }
            .product-card:hover{transform:translateY(-4px)}
            .product-card a img{width:100%;height:180px;object-fit:cover;border-radius:10px;margin-bottom:12px;display:block}
            .product-card h3{font-size:1.06rem;margin-bottom:6px;color:var(--text-color)}
            .product-card .price{color:var(--primary);font-weight:700;font-size:1.06rem;margin-bottom:6px}
            .product-card .button:not(.secondary){margin-top:auto;margin-bottom:0}
            .stock{font-size:.9rem;margin-bottom:10px;color:var(--muted)}
            .stock.in{color:var(--success)} .stock.out{color:var(--danger)}

            /* Buttons */
            .button{
                background:var(--primary);color:#fff;border:none;padding:10px 16px;
                border-radius:10px;cursor:pointer;text-decoration:none;display:inline-block;
                margin:5px;transition:transform .15s,opacity .2s,filter .2s
            }
            .button:hover{transform:translateY(-2px);filter:brightness(0.98)}
            .button.secondary{background:#6c757d}
            .button.secondary:hover{opacity:.92}

            /* Pagination */
            .pagination{text-align:center;margin:24px 0}
            .pagination .button{margin:0 2px}
            .pagination .button.active{background:#28a745}
            .pagination input{
                width:70px;padding:8px;border-radius:8px;border:1px solid var(--input-border);
                background:var(--input-bg);color:var(--input-text)
            }

            /* Theme toggle */
            .theme-toggle{
                position:fixed;bottom:20px;right:20px;background:#ffc107;color:#000;
                border:none;padding:10px 15px;border-radius:12px;cursor:pointer;font-weight:700;
                box-shadow:0 4px 12px var(--shadow);z-index:999
            }
            .theme-toggle:hover{filter:brightness(.95)}

            /* Advanced search */
            .search-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:8px}
            .adv-toggle{
                background:transparent;border:1px solid var(--border);color:var(--text-color);
                padding:8px 12px;border-radius:10px;cursor:pointer;transition:border-color .2s
            }
            .adv-toggle:hover{border-color:var(--primary)}
            .adv-body{overflow:hidden;max-height:0;transition:max-height .35s ease,padding .25s ease}
            .adv-body.open{max-height:600px;padding-top:12px}
            .form-grid{display:grid;grid-template-columns:1fr;gap:15px}
            .form-row{display:grid;grid-template-columns:auto 1fr;align-items:center;gap:15px}
            .form-row.price-group{grid-template-columns:1fr}
            .form-row.price-group label{grid-column:1 / -1;margin-bottom:-5px;font-weight:700}
            .form-row input,.form-row select{
                width:100%;padding:12px 14px;border-radius:10px;border:1px solid var(--input-border);
                background:var(--input-bg);color:var(--input-text);outline:none;
                transition:border-color .2s,box-shadow .2s;appearance:none;
                background-image:url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>');
                background-repeat:no-repeat;background-position:right 12px center;padding-right:34px
            }
            .form-row input:focus,.form-row select:focus{border-color:var(--primary);box-shadow:0 0 0 3px rgba(0,123,255,.25)}
            body.dark .form-row input:focus,body.dark .form-row select:focus{box-shadow:0 0 0 3px rgba(78,163,255,.4)}
            .price-inputs{display:flex;flex-direction:column;gap:10px}
            .price-input-row{display:flex;align-items:center;gap:10px}
            .price-input-row span{font-weight:600;color:var(--text-color);width:50px;flex-shrink:0}
            .search-actions{display:flex;justify-content:flex-end;gap:10px;margin-top:10px}

            @media (max-width:992px){
                .product-grid{grid-template-columns:repeat(2,1fr)}
                .sidebar{flex:1}
            }
            @media (max-width:576px){
                .product-grid{grid-template-columns:1fr}
                .form-row{grid-template-columns:1fr;gap:8px}
                .form-row.price-group{grid-template-columns:1fr}
            }

            /* Success popup */
            .success-form{position:fixed;inset:0;display:none;justify-content:center;align-items:center;background:rgba(0,0,0,.45);backdrop-filter:blur(2px);z-index:9999}
            .success-form.active{display:flex}
            .success-form .content-container{
                background:var(--card-bg);color:var(--text-color);padding:28px 36px;border-radius:16px;
                box-shadow:0 16px 40px rgba(0,0,0,.30);max-width:520px;width:calc(100% - 40px);
                text-align:center;transform:translateY(10px) scale(.96);opacity:0;
                transition:transform .3s cubic-bezier(.19,.71,.27,1),opacity .3s ease;
            }
            .success-form.active .content-container{transform:translateY(0) scale(1);opacity:1;}
            .success-icon{width:72px;height:72px;margin:0 auto 16px;display:block}
            .success-icon circle,.success-icon path{stroke:var(--primary)}
            .success-text{font-size:1.05rem;font-weight:700}
            .success-icon.spin-once{animation:icon-spin-once .6s cubic-bezier(.22,.8,.35,1.01);transform-origin:50% 50%;}
            @keyframes icon-spin-once{
                0%{transform:rotate(-180deg) scale(.85);opacity:.35}
                50%{opacity:1}
                100%{transform:rotate(0) scale(1);opacity:1}
            }

            .promo-section div h4{color:var(--primary);font-size:1.1rem;margin-bottom:6px}
            .promo-section div p{font-size:.95rem;color:var(--text-color)}
        </style>
    </head>
    <body>
        <%@ include file="partials/header.jsp" %>

        <div class="container">
            <div class="banner">
                <div class="banner-slider">
                    <div class="slide active"><img src="${pageContext.request.contextPath}/images/banner1.jpg" alt="Banner 1" width="1600" height="400" loading="eager"></div>
                    <div class="slide"><img src="${pageContext.request.contextPath}/images/banner2.jpg" alt="Banner 2" width="1600" height="400" loading="lazy"></div>
                    <div class="slide"><img src="${pageContext.request.contextPath}/images/banner3.jpg" alt="Banner 3"width="1600" height="400" loading="lazy"></div>
                    <button class="prev" aria-label="Slide trước">❮</button>
                    <button class="next" aria-label="Slide sau">❯</button>
                </div>
                <div class="banner-thumbs" aria-label="Chọn slide">
                    <img src="${pageContext.request.contextPath}/images/banner1.jpg" class="thumb active" alt="Thumb 1">
                    <img src="${pageContext.request.contextPath}/images/banner2.jpg" class="thumb" alt="Thumb 2">
                    <img src="${pageContext.request.contextPath}/images/banner3.jpg" class="thumb" alt="Thumb 3">
                </div>
            </div>
            <div class="promo-section" style="margin-bottom:25px;display:flex;gap:20px;flex-wrap:wrap;justify-content:center;">
                <div style="flex:1;min-width:200px;background:var(--chip-bg);padding:20px;border-radius:14px;text-align:center;box-shadow:0 6px 16px var(--shadow);">
                    <h4 style="margin-bottom:10px;">🚚 Miễn phí giao hàng</h4><p>Cho đơn hàng từ 1.000.000₫ trở lên</p>
                </div>
                <div style="flex:1;min-width:200px;background:var(--chip-bg);padding:20px;border-radius:14px;text-align:center;box-shadow:0 6px 16px var(--shadow);">
                    <h4 style="margin-bottom:10px;">🛠 Bảo hành</h4><p>Bảo hành sản phẩm 12 tháng, yên tâm sử dụng</p>
                </div>
                <div style="flex:1;min-width:200px;background:var(--chip-bg);padding:20px;border-radius:14px;text-align:center;box-shadow:0 6px 16px var(--shadow);">
                    <h4 style="margin-bottom:10px;">🔄 Đổi trả dễ dàng</h4><p>Đổi trả trong 7 ngày nếu sản phẩm lỗi</p>
                </div>
            </div>

            <div class="main-content">
                <div class="products-section">
                    <div class="products-header">
                        <h2>💡 Danh sách sản phẩm</h2>
                        <form id="sortForm" method="get" action="${pageContext.request.contextPath}/products" class="sort-form">
                            <input type="hidden" name="action" value="list"/>
                            <c:if test="${param.category != null}">
                                <input type="hidden" name="category" value="${param.category}"/>
                            </c:if>
                            <c:if test="${param.parent != null}">
                                <input type="hidden" name="parent" value="${param.parent}"/>
                            </c:if>
                            <input type="hidden" name="page" value="1"/>
                            <label for="sortBy">Sắp xếp:</label>
                            <select name="sortBy" id="sortBy" onchange="this.form.submit()">
                                <option value="">-- Mặc định --</option>
                                <option value="price_asc" ${param.sortBy eq 'price_asc' ? 'selected' : ''}>Giá ↑</option>
                                <option value="price_desc" ${param.sortBy eq 'price_desc' ? 'selected' : ''}>Giá ↓</option>
                                <option value="name_asc" ${param.sortBy eq 'name_asc' ? 'selected' : ''}>Tên A-Z</option>
                                <option value="name_desc" ${param.sortBy eq 'name_desc' ? 'selected' : ''}>Tên Z-A</option>
                            </select>
                        </form>
                    </div>

                    <div class="product-grid">
                        <c:forEach var="p" items="${products}">
                            <div class="product-card">
                                <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}">
                                    <img src="${pageContext.request.contextPath}/${p.imagePath}" alt="${p.name}"/>
                                </a>
                                <h3>${p.name}</h3>
                                <p class="price">${p.price}₫</p>
                                <c:set var="stockClass" value="${p.quantity > 0 ? 'stock in' : 'stock out'}"/>
                                <p class="${stockClass}">Kho: ${p.quantity}</p>
                                <c:choose>
                                    <c:when test="${p.quantity > 0}">
                                        <button type="button" class="button add-to-cart-btn" data-product-id="${p.id}">🛒 Thêm vào giỏ</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" class="button" disabled style="opacity:.7;cursor:not-allowed;">Hết hàng</button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>

                    <c:url var="pagingUrl" value="products">
                        <c:param name="action" value="list"/>
                        <c:if test="${not empty param.category}">
                            <c:param name="category" value="${param.category}"/>
                        </c:if>
                        <c:if test="${not empty param.parent}">
                            <c:param name="parent" value="${param.parent}"/>
                        </c:if>
                        <c:if test="${not empty param.sortBy}">
                            <c:param name="sortBy" value="${param.sortBy}"/>
                        </c:if>
                    </c:url>
                    
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="${pagingUrl}&page=1" class="button">« Đầu</a>
                            <a href="${pagingUrl}&page=${currentPage - 1}" class="button">‹ Trước</a>
                        </c:if>
                        <c:forEach begin="1" end="${totalPages}" var="pageNum">
                            <a href="${pagingUrl}&page=${pageNum}" class="button ${pageNum == currentPage ? 'active' : ''}">${pageNum}</a>
                        </c:forEach>
                        <c:if test="${currentPage < totalPages}">
                            <a href="${pagingUrl}&page=${currentPage + 1}" class="button">Tiếp ›</a>
                            <a href="${pagingUrl}&page=${totalPages}" class="button">Cuối »</a>
                        </c:if>
                        <form action="${pagingUrl}" method="get" style="display:inline-block;margin-left:15px;">
                            <input type="hidden" name="action" value="list"/>
                            <c:if test="${not empty param.category}">
                                <input type="hidden" name="category" value="${param.category}"/>
                            </c:if>
                            <c:if test="${not empty param.parent}">
                                <input type="hidden" name="parent" value="${param.parent}"/>
                            </c:if>
                            <c:if test="${not empty param.sortBy}">
                                <input type="hidden" name="sortBy" value="${param.sortBy}"/>
                            </c:if>
                            <label for="goPage">Trang:</label>
                            <input type="number" name="page" id="goPage" min="1" max="${totalPages}" required value="${currentPage}" style="width:60px;">
                            <button type="submit" class="button">Đi</button>
                        </form>
                    </div>
                </div>

                <div class="sidebar">
                    <div class="search-box">
                        <div class="search-head">
                            <h3 style="margin:0;">🔍 Tìm kiếm nâng cao</h3>
                            <button id="toggleAdvBtn" type="button" class="adv-toggle" aria-expanded="false">Mở rộng</button>
                        </div>
                        <div id="advBody" class="adv-body">
                            <form action="${pageContext.request.contextPath}/products" method="get">
                                <input type="hidden" name="action" value="search">
                                <div class="form-grid">
                                    <div class="form-row">
                                        <label for="keyword">Tên SP:</label>
                                        <input type="text" id="keyword" name="keyword" placeholder="Nhập tên sản phẩm..." value="${searchKeyword != null ? searchKeyword : ''}">
                                    </div>
                                    <div class="form-row price-group">
                                        <label>Khoảng giá:</label>
                                        <div class="price-inputs">
                                            <div class="price-input-row">
                                                <span>Từ:</span>
                                                <input type="number" id="minPrice" name="minPrice" placeholder="0" value="${param.minPrice}">
                                            </div>
                                            <div class="price-input-row">
                                                <span>Đến:</span>
                                                <input type="number" id="maxPrice" name="maxPrice" placeholder="1000000" value="${param.maxPrice}">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-row">
                                        <label for="category">Danh mục:</label>
                                        <select id="category" name="category">
                                            <option value="">-- Chọn --</option>
                                            <c:forEach var="c" items="${categories}">
                                                <option value="${c.categoryId}" ${param.category eq c.categoryId ? 'selected' : ''}>${c.name}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="search-actions">
                                        <button type="reset" class="adv-toggle" onclick="window.location.href='${pageContext.request.contextPath}/products?action=list'">Xóa lọc</button>
                                        <button type="submit" class="button">Tìm kiếm</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="bestseller-box">
                        <h3 style="margin-bottom:14px;">🔥 Sản phẩm bán chạy</h3>
                        <c:forEach var="sp" items="${bestSellers}">
                            <div class="bestseller-item" style="display:flex;gap:12px;margin-bottom:16px;padding-bottom:12px;border-bottom:1px solid var(--border)">
                                <a href="${pageContext.request.contextPath}/products?action=detail&id=${sp.id}">
                                    <img src="${pageContext.request.contextPath}/${sp.imagePath}" alt="${sp.name}" style="width:80px;height:80px;object-fit:cover;border-radius:8px">
                                </a>
                                <div class="bestseller-info" style="display:flex;flex-direction:column;gap:4px;justify-content:center">
                                    <a href="${pageContext.request.contextPath}/products?action=detail&id=${sp.id}" style="text-decoration:none;color:var(--text-color)">
                                        <h4 style="font-size:.95rem;margin:0">${sp.name}</h4>
                                    </a>
                                    <span class="price" style="color:var(--primary);font-weight:700">${sp.price}₫</span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>

        <c:if test="${not empty debugLog}">
            <div style="background:#222;color:#fff;padding:12px;border-radius:8px;margin:20px 0;font-family:consolas,monospace">
                <b>DEBUG:</b><br />${debugLog}
            </div>
        </c:if>

        <div id="successPopup" class="success-form" aria-hidden="true">
            <div class="content-container" role="dialog" aria-modal="true" aria-live="assertive">
                <svg class="success-icon" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                  <circle cx="24" cy="24" r="18" stroke-width="2.5" />
                  <path d="M16 24.5l6 6 10-12" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                <div class="success-text">Thêm sản phẩm vào giỏ hàng thành công !</div>
            </div>
        </div>

        <%@ include file="partials/footer.jsp" %>

        <%@ include file="chat_widget.jsp" %>
        <script>
            /* Banner logic */
            const slides = document.querySelectorAll('.slide');
            const thumbs = document.querySelectorAll('.thumb');
            let currentSlide = 0;
            function showSlide(i) {
                slides.forEach((s, idx) => s.classList.toggle('active', idx === i));
                thumbs.forEach((t, idx) => t.classList.toggle('active', idx === i));
                currentSlide = i;
            }
            document.querySelector('.next').onclick = () => showSlide((currentSlide + 1) % slides.length);
            document.querySelector('.prev').onclick = () => showSlide((currentSlide - 1 + slides.length) % slides.length);
            thumbs.forEach((t, i) => t.addEventListener('click', () => showSlide(i)));
            setInterval(() => document.querySelector('.next').click(), 5000);

            /* Dark / Light */
            const themeBtn = document.getElementById('themeToggle');
            function applySavedTheme() {
                const saved = localStorage.getItem('theme');
                const dark = saved === 'dark';
                document.body.classList.toggle('dark', dark);
                if (themeBtn) themeBtn.textContent = dark ? '🌙 Chế độ tối' : '🌞 Chế độ sáng';
            }
            applySavedTheme();
            if (themeBtn) {
                themeBtn.addEventListener('click', () => {
                    document.body.classList.toggle('dark');
                    const dark = document.body.classList.contains('dark');
                    localStorage.setItem('theme', dark ? 'dark' : 'light');
                    themeBtn.textContent = dark ? '🌙 Chế độ tối' : '🌞 Chế độ sáng';
                });
            }

            /* Advanced Search toggle */
            const advBtn = document.getElementById('toggleAdvBtn');
            const advBody = document.getElementById('advBody');
            function setAdv(open) {
                advBody.classList.toggle('open', open);
                advBtn.setAttribute('aria-expanded', String(open));
                advBtn.textContent = open ? 'Thu gọn' : 'Mở rộng';
            }
            setAdv(localStorage.getItem('adv_open') !== 'false');
            advBtn.addEventListener('click', () => {
                const open = !advBody.classList.contains('open');
                setAdv(open);
                localStorage.setItem('adv_open', open ? 'true' : 'false');
            });
            
            /* Popup giỏ hàng */
            const successPopup = document.getElementById('successPopup');
            let popupTimer = null;
            // Bật lại reload sau khi đóng popup (mặc định: true)
            function showSuccessPopup({message='Thêm sản phẩm vào giỏ hàng thành công !',duration=1200,reloadAfter=true,spin=true}={}) {
                if(!successPopup) return;
                const textEl = successPopup.querySelector('.success-text');
                if(textEl) textEl.textContent = message;
                const icon = successPopup.querySelector('.success-icon');
                if(icon){
                    icon.classList.remove('spin-once');
                    if(spin){ void icon.offsetWidth; icon.classList.add('spin-once'); }
                }
                clearTimeout(popupTimer);
                successPopup.classList.add('active');
                successPopup.style.display='flex';
                successPopup.setAttribute('aria-hidden','false');
                document.body.style.overflow='hidden';
                popupTimer = setTimeout(()=>closeSuccessPopup(reloadAfter), duration);
                function onOverlay(e){ if(e.target===successPopup){ cleanup(); closeSuccessPopup(reloadAfter); } }
                function onEsc(e){ if(e.key==='Escape'){ cleanup(); closeSuccessPopup(reloadAfter); } }
                function cleanup(){
                    successPopup.removeEventListener('click',onOverlay);
                    document.removeEventListener('keydown',onEsc);
                    clearTimeout(popupTimer);
                }
                successPopup.addEventListener('click',onOverlay,{once:true});
                document.addEventListener('keydown',onEsc,{once:true});
            }
            function closeSuccessPopup(reload=false){
                successPopup.classList.remove('active');
                successPopup.style.display='none';
                successPopup.setAttribute('aria-hidden','true');
                document.body.style.overflow='';
                if(reload) location.reload();
            }

            /* Add to cart AJAX */
            document.addEventListener('DOMContentLoaded', () => {
                document.querySelectorAll('.add-to-cart-btn').forEach(btn => {
                    btn.addEventListener('click', async function (e) {
                        e.preventDefault();
                        const id = this.dataset.productId;
                        if (this.disabled) return;
                        
                        const originalText = this.textContent;
                        this.disabled = true; this.style.opacity = '.7';

                        try {
                            const res = await fetch('${pageContext.request.contextPath}/cart', {
                                method:'POST',
                                headers:{'Content-Type':'application/x-www-form-urlencoded','X-Requested-With':'XMLHttpRequest'},
                                body:new URLSearchParams({action:'add',productId:id,quantity:1})
                            });
                            const result = await res.json();
                            if(result.success){
                                // Gọi popup và reload lại trang để cart cập nhật
                                showSuccessPopup({reloadAfter:true,duration:1200,spin:true});
                                this.textContent='✅ Đã thêm'; this.style.backgroundColor='var(--success)';
                                setTimeout(()=>{ this.textContent=originalText; this.style.backgroundColor=''; },1500);
                            }else{
                                this.textContent='❌ Lỗi';
                                this.style.backgroundColor='var(--danger)';
                                setTimeout(()=>{ this.textContent=originalText; this.style.backgroundColor=''; },1500);
                            }
                        } catch(err){
                            console.error(err);
                            this.textContent='❌ Lỗi mạng'; this.style.backgroundColor='var(--danger)';
                            setTimeout(()=>{ this.textContent=originalText; this.style.backgroundColor=''; },1500);
                        } finally {
                            this.disabled=false;
                            this.style.opacity='';
                        }
                    });
                });
            });
        </script>
    </body>
</html>