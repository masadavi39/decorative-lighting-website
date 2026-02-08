<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>${product.name} - Chi tiết sản phẩm</title>
  <meta name="description" content="${product.name} - thông tin chi tiết, giá, tồn kho và mô tả sản phẩm.">
  <meta name="viewport" content="width=device-width,initial-scale=1">

  <!-- FULL CSS HOÀN CHỈNH (KHÔNG BỊ THIẾU) -->
  <style>
    /*********** 1. VARIABLES ***********/
    :root {
      --bg:#f5f6f8; --surface:#fff; --border:#e2e6eb; --border-dark:#d0d4da;
      --text:#222; --muted:#6c757d; --heading:#1e2a38;
      --primary:#0066ff; --primary-dark:#004ec2; --accent:#ffb300;
      --success:#1fa751; --warning:#ff9800; --danger:#d63a3a;
      --radius-sm:6px; --radius-md:10px; --radius-lg:14px;
      --shadow:0 4px 14px rgba(0,0,0,.07);
      --transition:.25s cubic-bezier(.25,.8,.25,1);
      --gap-row:42px;
    }

    /*********** 2. BASE ***********/
    *{box-sizing:border-box;margin:0;padding:0}
    body{font-family:"Inter","Arial",sans-serif;background:var(--bg);color:var(--text);line-height:1.55;-webkit-font-smoothing:antialiased;}
    a{color:var(--primary);text-decoration:none;}
    a:hover{text-decoration:underline}
    img{display:block;max-width:100%}
    button{font-family:inherit}

    /*********** 3. LAYOUT ***********/
    .container{max-width:1420px;margin:0 auto;padding:28px 24px 80px;}
    .row-section{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius-lg);padding:26px 30px;margin-bottom:var(--gap-row);box-shadow:var(--shadow);position:relative;}
    .row-section.compact{padding:20px 24px;}
    .row-section h2.section-title{font-size:1.4rem;line-height:1.25;margin-bottom:18px;color:var(--heading);display:flex;align-items:center;gap:8px;font-weight:700;}
    .breadcrumbs{font-size:.82rem;margin-bottom:18px;color:var(--muted);display:flex;flex-wrap:wrap;gap:4px;}
    .breadcrumbs a{color:var(--primary);}

    /*********** 4. HERO (3 CỘT) ***********/
    .hero{display:flex;gap:40px;align-items:flex-start;}
    .hero-media{flex:0 0 520px;display:flex;flex-direction:column;gap:14px;}
    .hero-media .main-image{width:100%;aspect-ratio:4/3;border-radius:var(--radius-md);object-fit:cover;border:1px solid var(--border-dark);background:#f0f3f6;}
    .hero-info{flex:1;display:flex;flex-direction:column;min-width:0;}
    .hero-related{flex:0 0 310px;display:flex;flex-direction:column;gap:18px;max-height:100%;}

    /*********** 5. RELATED LIST ***********/
    .hero-related h3{font-size:1.1rem;margin:0 0 6px;font-weight:700;color:var(--heading);display:flex;align-items:center;gap:6px;}
    .related-list{display:flex;flex-direction:column;gap:12px;overflow-y:auto;padding-right:4px;max-height:640px;}
    .related-list::-webkit-scrollbar{width:10px;}
    .related-list::-webkit-scrollbar-track{background:#eef1f5;border-radius:8px;}
    .related-list::-webkit-scrollbar-thumb{background:#c5ccd4;border-radius:8px;}
    .related-list::-webkit-scrollbar-thumb:hover{background:#aab3bd;}

    /*********** 6. RELATED PRODUCT CARD ***********/
    .prod-card{scroll-snap-align:start;background:#fff;border:1px solid var(--border-dark);border-radius:14px;padding:12px 12px 14px;display:flex;flex-direction:column;gap:8px;position:relative;transition:var(--transition);text-decoration:none;color:inherit;}
    .prod-card:hover{transform:translateY(-4px);box-shadow:0 10px 24px rgba(0,0,0,.12);}
    .prod-card.related{flex-direction:row;align-items:center;gap:12px;padding:10px 12px;}
    .prod-card.related .prod-thumb{width:72px;height:72px;aspect-ratio:1/1;border-radius:12px;object-fit:cover;}
    .prod-card.related .prod-body{display:flex;flex-direction:column;gap:4px;flex:1;min-width:0;}
    .prod-thumb{width:100%;aspect-ratio:1/1;border-radius:10px;object-fit:cover;background:#f0f3f6;border:1px solid var(--border);}
    .prod-title{font-size:.78rem;font-weight:700;line-height:1.25;height:2.4em;overflow:hidden;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;}
    .prod-card.related .prod-title{height:auto;font-size:.75rem;-webkit-line-clamp:3;}
    .prod-price{font-weight:800;color:var(--primary);font-size:.9rem;}
    .prod-card.related .prod-price{font-size:.8rem;}
    .prod-stock{font-size:.65rem;font-weight:600;text-transform:uppercase;letter-spacing:.8px;color:var(--muted);}
    .prod-stock.in{color:var(--success);}
    .prod-stock.out{color:var(--danger);}
    .prod-card.related .prod-stock{font-size:.55rem;}

    /*********** 7. INFO CHÍNH ***********/
    .hero-info h1{font-size:2.05rem;margin:0 0 12px;color:var(--heading);line-height:1.22;letter-spacing:.3px;}
    .status-badge{display:inline-flex;align-items:center;gap:6px;background:var(--success);color:#fff;padding:6px 14px;font-size:.75rem;font-weight:700;border-radius:50px;letter-spacing:.5px;margin-bottom:14px;}
    .status-badge.out{background:var(--danger);}
    .price-line{display:flex;align-items:baseline;gap:16px;margin:8px 0 16px;flex-wrap:wrap;}
    .price-main{font-size:2.3rem;font-weight:800;color:var(--primary);}
    .price-note{font-size:.8rem;color:var(--muted);}

    .quick-info{display:flex;flex-wrap:wrap;gap:10px;margin:8px 0 18px;}
    .chip{background:#f1f4f8;border:1px solid var(--border);padding:7px 14px;font-size:.72rem;font-weight:600;border-radius:50px;display:inline-flex;align-items:center;gap:6px;color:#374151;letter-spacing:.4px;}
    .chip.warn{background:#fff9e6;border-color:#ffe6a3;color:#8a6100;}
    .chip.danger{background:#ffe8e6;border-color:#ffccc7;color:#9f1f1f;}
    .chip.ok{background:#e9fbf0;border-color:#c5f1d5;color:#146c35;}

    /*********** 8. BUY BOX ***********/
    .buy-box{border:1px solid var(--border-dark);border-radius:var(--radius-lg);padding:20px 22px;background:#fdfdfe;margin-top:auto;}
    .buy-box form{display:flex;flex-direction:column;gap:14px;}
    .qty-wrap{display:flex;gap:12px;align-items:center;flex-wrap:wrap;}
    .qty-wrap input[type=number]{width:104px;padding:10px 12px;font-weight:600;text-align:center;border:1px solid var(--border-dark);border-radius:10px;font-size:1rem;background:#fff;}
    .actions{display:flex;flex-wrap:wrap;gap:12px;}
    .button{background:var(--primary);color:#fff;border:none;padding:14px 20px;font-weight:700;border-radius:12px;cursor:pointer;display:inline-flex;align-items:center;gap:8px;font-size:.95rem;box-shadow:0 4px 14px rgba(0,102,255,.2);transition:var(--transition);}
    .button:hover{background:var(--primary-dark);}
    .button.secondary{background:#636c76;box-shadow:0 4px 14px rgba(0,0,0,.15);}
    .button.secondary:hover{background:#4d545c;}
    .button:disabled{opacity:.55;cursor:not-allowed;box-shadow:none;}
    .back-link{margin-top:18px;font-size:.85rem;text-align:center;}

    /*********** 9. DESCRIPTION ***********/
    .description-body{font-size:.95rem;white-space:pre-line;line-height:1.6;}
    .description-empty{color:var(--muted);font-style:italic;}

    /*********** 10. REVIEW LIST ***********/
    .rating-summary{display:flex;align-items:center;gap:14px;margin-bottom:10px;flex-wrap:wrap;}
    .stars{color:#f5a623;font-size:20px;letter-spacing:1px;}
    .review-track{display:grid;grid-auto-flow:column;grid-auto-columns:420px;gap:18px;overflow-x:auto;scroll-snap-type:x mandatory;padding-bottom:6px;}
    .review-track::-webkit-scrollbar{height:10px;}
    .review-track::-webkit-scrollbar-track{background:#eef1f5;border-radius:8px;}
    .review-track::-webkit-scrollbar-thumb{background:#c5ccd4;border-radius:8px;}
    .review-track::-webkit-scrollbar-thumb:hover{background:#aab3bd;}

    .review-card{scroll-snap-align:start;border:1px solid var(--border-dark);background:#fff;border-radius:16px;padding:16px 18px;display:flex;gap:16px;transition:var(--transition);}
    .review-card:hover{box-shadow:0 8px 22px rgba(0,0,0,.12);transform:translateY(-3px);}
    .review-avatar{width:50px;height:50px;border-radius:50%;background:var(--primary);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:800;font-size:1.1rem;flex-shrink:0;box-shadow:0 4px 10px rgba(0,102,255,.4);}
    .review-content{display:flex;flex-direction:column;gap:6px;font-size:.92rem;}
    .review-meta{display:flex;align-items:center;gap:10px;flex-wrap:wrap;font-size:.75rem;color:var(--muted);}

    /*********** 11. REVIEW FORM ***********/
    .review-form{margin-top:10px;border:1px solid var(--border-dark);background:#fafbfc;padding:18px 20px;border-radius:16px;display:flex;flex-direction:column;gap:14px;}
    .star-select{display:flex;gap:6px;font-size:34px;cursor:pointer;user-select:none;}
    .star-select span{color:#ccd1d6;transition:var(--transition);}
    .star-select span.active,.star-select span.hover{color:#f5a623;}
    .review-form select,.review-form input[type=text],.review-form textarea{
      width:100%;padding:12px 14px;border:1px solid var(--border-dark);border-radius:12px;background:#fff;font-size:.9rem;font-family:inherit;
    }
    .review-form textarea{min-height:110px;resize:vertical;}
    .small-note{font-size:.7rem;color:var(--muted);margin-top:-8px;}

    /*********** 12. ADMIN REPLIES ***********/
    .admin-replies{margin-top:8px;padding-left:8px;border-left:3px solid var(--primary);}
    .admin-reply{background:#f5f9ff;border:1px solid #d7e7ff;border-radius:10px;padding:10px 12px;margin-top:8px;}
    .admin-reply .meta{display:flex;align-items:center;gap:8px;font-size:.8rem;color:#445;margin-bottom:4px;}
    .badge-admin{background:var(--primary);color:#fff;border-radius:999px;padding:2px 8px;font-size:.7rem;font-weight:700;letter-spacing:.3px;}

    /*********** 13. ALERTS ***********/
    .alert{padding:14px 18px;border-radius:14px;margin-bottom:22px;font-weight:600;font-size:.85rem;display:flex;align-items:center;gap:8px;}
    .alert.success{background:#d4edda;color:#155724;border:1px solid #c3e6cb;}
    .alert.warn{background:#fff3cd;color:#856404;border:1px solid #ffeeba;}

    /*********** 14. HORIZONTAL SCROLL (RECENT PRODUCTS) ***********/
    .horizontal-scroll{display:grid;grid-auto-flow:column;grid-auto-columns:240px;gap:16px;overflow-x:auto;scroll-snap-type:x mandatory;padding-bottom:4px;}
    .horizontal-scroll::-webkit-scrollbar{height:10px;}
    .horizontal-scroll::-webkit-scrollbar-track{background:#eef1f5;border-radius:8px;}
    .horizontal-scroll::-webkit-scrollbar-thumb{background:#c5ccd4;border-radius:8px;}
    .horizontal-scroll::-webkit-scrollbar-thumb:hover{background:#aab3bd;}

    /*********** 15. UTILITIES ***********/
    .text-muted{color:var(--muted);}
    .dragging{cursor:grabbing;}

    /*********** 16. RESPONSIVE ***********/
    @media (max-width:1400px){
      .hero-media{flex:0 0 480px;}
      .hero-related{flex:0 0 280px;}
    }
    @media (max-width:1200px){
      .hero{flex-direction:column;}
      .hero-related{order:3;max-height:none;}
      .related-list{max-height:none;}
    }
    @media (max-width:640px){
      .row-section{padding:20px 18px;}
      .hero-info h1{font-size:1.65rem;}
      .price-main{font-size:2rem;}
      .horizontal-scroll{grid-auto-columns:200px;}
      .prod-card{padding:10px 10px 12px;}
      .review-track{grid-auto-columns:85vw;}
      .prod-card.related{flex-direction:row;}
      .prod-card.related .prod-thumb{width:64px;height:64px;}
    }
  </style>
</head>
<body>
  <%@ include file="partials/header.jsp" %>

  <div class="container">
    <!-- Breadcrumbs -->
    <div class="breadcrumbs">
      <a href="${pageContext.request.contextPath}/products?action=list">Trang chủ</a>
      <span>›</span>
      <span>${product.name}</span>
    </div>

    <!-- Alerts -->
    <c:if test="${param.added eq 'true'}"><div class="alert success">✅ Sản phẩm đã được thêm vào giỏ hàng!</div></c:if>
    <c:if test="${param.rv eq 'ok'}"><div class="alert success">✅ Đã gửi đánh giá. Chờ duyệt trước khi hiển thị.</div></c:if>
    <c:if test="${param.rv eq 'fail'}"><div class="alert warn">⚠️ Gửi đánh giá thất bại. Vui lòng thử lại.</div></c:if>
    <c:if test="${param.rv eq 'invalid'}">
      <c:choose>
        <c:when test="${param.reason eq 'short'}"><div class="alert warn">⚠️ Nội dung quá ngắn (tối thiểu 5 ký tự).</div></c:when>
        <c:when test="${param.reason eq 'rating'}"><div class="alert warn">⚠️ Điểm đánh giá không hợp lệ.</div></c:when>
        <c:when test="${param.reason eq 'duplicate'}"><div class="alert warn">⚠️ Bạn đã đánh giá sản phẩm này rồi.</div></c:when>
        <c:when test="${param.reason eq 'reply'}"><div class="alert warn">⚠️ Nội dung phản hồi quá ngắn.</div></c:when>
        <c:when test="${param.reason eq 'parse'}"><div class="alert warn">⚠️ Tham số không hợp lệ (productId/rating).</div></c:when>
        <c:otherwise><div class="alert warn">⚠️ Dữ liệu đánh giá không hợp lệ.</div></c:otherwise>
      </c:choose>
    </c:if>

    <!-- HERO -->
    <div class="row-section hero">
      <!-- MEDIA -->
      <div class="hero-media">
        <c:set var="inStock" value="${product.quantity > 0}" />
        <img src="${pageContext.request.contextPath}/${product.imagePath}" alt="${product.name}" class="main-image" loading="lazy">
      </div>

      <!-- INFO -->
      <div class="hero-info">
        <span class="status-badge ${!inStock ? 'out' : ''}">
          <c:choose><c:when test="${inStock}">CÒN HÀNG</c:when><c:otherwise>HẾT HÀNG</c:otherwise></c:choose>
        </span>
        <h1>${product.name}</h1>
        <div class="price-line">
          <div class="price-main"><fmt:formatNumber value="${product.price}" type="number" groupingUsed="true"/>₫</div>
          <div class="price-note">Giá đã gồm VAT (nếu áp dụng)</div>
        </div>

        <div class="quick-info">
          <div class="chip">
            🗂 Danh mục:
            <strong>
              <c:choose>
                <c:when test="${not empty product.categoryName}">${product.categoryName}</c:when>
                <c:otherwise>#${product.categoryId}</c:otherwise>
              </c:choose>
            </strong>
          </div>
          <div class="chip">🏷 Thương hiệu: <strong>${not empty product.manufacturer ? product.manufacturer : '—'}</strong></div>
          <div class="chip ${product.quantity > 20 ? 'ok' : (product.quantity > 0 ? 'warn' : 'danger')}">
            📦 Tồn kho:
            <strong>
              <c:choose>
                <c:when test="${product.quantity > 20}">${product.quantity}</c:when>
                <c:when test="${product.quantity > 0}">${product.quantity} (sắp hết)</c:when>
                <c:otherwise>Hết hàng</c:otherwise>
              </c:choose>
            </strong>
          </div>
            <div class="chip">🔥 Đã bán: <strong><fmt:formatNumber value="${product.soldQuantity}" type="number" groupingUsed="true"/>+</strong></div>
        </div>

        <div class="buy-box">
          <form action="${pageContext.request.contextPath}/cart" method="post">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="productId" value="${product.id}">
            <div class="qty-wrap">
              <label for="qty"><strong>Số lượng</strong></label>
              <input type="number" id="qty" name="quantity" min="1" max="${product.quantity}" value="1" ${!inStock ? 'disabled' : ''}>
            </div>
            <div class="actions">
              <button type="submit" class="button" ${!inStock ? 'disabled' : ''}>🧺 Thêm vào giỏ</button>
              <a href="${pageContext.request.contextPath}/products?action=list" class="button secondary">📋 Danh sách</a>
            </div>
            <div class="back-link">
              <a href="${pageContext.request.contextPath}/products?action=list">⬅ Quay lại danh sách sản phẩm</a>
            </div>
          </form>
        </div>
      </div>

      <!-- RELATED -->
      <div class="hero-related">
        <h3>🔥 Sản phẩm liên quan</h3>
        <div class="related-list">
          <c:forEach var="p" items="${relatedProducts}">
            <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}" class="prod-card related">
              <img src="${pageContext.request.contextPath}/${p.imagePath}" alt="${p.name}" class="prod-thumb" loading="lazy">
              <div class="prod-body">
                <div class="prod-title">${p.name}</div>
                <div class="prod-stock ${p.quantity > 0 ? 'in' : 'out'}">
                  <c:choose><c:when test="${p.quantity > 0}">Còn hàng</c:when><c:otherwise>Hết hàng</c:otherwise></c:choose>
                </div>
                <div class="prod-price"><fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/>₫</div>
              </div>
            </a>
          </c:forEach>
          <c:if test="${empty relatedProducts}">
            <div style="border:1px dashed var(--border-dark);background:#fff;border-radius:14px;padding:16px 14px;font-style:italic;color:var(--muted);text-align:center;">
              Không có sản phẩm liên quan.
            </div>
          </c:if>
        </div>
      </div>
    </div>

    <!-- DESCRIPTION -->
    <div class="row-section">
      <h2 class="section-title">📝 Mô tả sản phẩm</h2>
      <c:choose>
        <c:when test="${not empty product.description}">
          <div class="description-body">${fn:escapeXml(product.description)}</div>
        </c:when>
        <c:otherwise><div class="description-empty">Chưa có mô tả chi tiết cho sản phẩm này.</div></c:otherwise>
      </c:choose>
    </div>

    <!-- REVIEWS -->
    <div class="row-section">
      <h2 class="section-title">⭐ Đánh giá sản phẩm</h2>

      <div class="rating-summary">
        <div class="stars">
          <c:forEach begin="1" end="5" var="i">
            <c:choose><c:when test="${avgRating >= i}">★</c:when><c:otherwise>☆</c:otherwise></c:choose>
          </c:forEach>
        </div>
        <div><strong><fmt:formatNumber value="${avgRating != null ? avgRating : 0}" type="number" maxFractionDigits="1"/></strong>/5</div>
        <div class="text-muted" style="font-size:.8rem;">
          (<fmt:formatNumber value="${reviewCount != null ? reviewCount : 0}" type="number"/> đánh giá)
        </div>
      </div>

      <div class="review-track" style="margin-bottom:14px;">
        <c:forEach var="rv" items="${reviews}">
          <div class="review-card">
            <div class="review-avatar">
              <c:choose>
                <c:when test="${not empty rv.userName}"><c:out value="${fn:substring(rv.userName,0,1)}"/></c:when>
                <c:otherwise>U</c:otherwise>
              </c:choose>
            </div>
            <div class="review-content">
              <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:6px;">
                <strong>
                  <c:choose>
                    <c:when test="${not empty rv.userName}">${rv.userName}</c:when>
                    <c:otherwise>User #${rv.userId}</c:otherwise>
                  </c:choose>
                </strong>
                <span class="stars" style="font-size:16px;">
                  <c:forEach begin="1" end="5" var="i">
                    <c:choose><c:when test="${rv.rating >= i}">★</c:when><c:otherwise>☆</c:otherwise></c:choose>
                  </c:forEach>
                </span>
              </div>
              <div class="review-meta">
                <span><fmt:formatDate value="${rv.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span>
              </div>
              <div style="font-size:.9rem;line-height:1.4;">
                <c:if test="${not empty rv.title}">
                  <strong>${fn:escapeXml(rv.title)}</strong> — 
                </c:if>
                ${fn:escapeXml(rv.content)}
              </div>

              <!-- Admin replies -->
              <c:if test="${not empty rv.replies}">
                <div class="admin-replies">
                  <c:forEach var="rp" items="${rv.replies}">
                    <c:if test="${rp.userRole eq 'admin'}">
                      <div class="admin-reply">
                        <div class="meta">
                          <span class="badge-admin">Quản trị viên</span>
                          <strong>${fn:escapeXml(rp.userName)}</strong>
                          <span>•</span>
                          <span><fmt:formatDate value="${rp.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span>
                        </div>
                        <div style="white-space:pre-line;">${fn:escapeXml(rp.content)}</div>
                      </div>
                    </c:if>
                  </c:forEach>
                </div>
              </c:if>
            </div>
          </div>
        </c:forEach>
        <c:if test="${empty reviews}">
          <div style="scroll-snap-align:start;border:1px dashed var(--border-dark);background:#fff;border-radius:14px;padding:30px 20px;font-style:italic;color:var(--muted);display:flex;align-items:center;justify-content:center;">
            Chưa có đánh giá nào cho sản phẩm này.
          </div>
        </c:if>
      </div>

      <!-- FORM REVIEW -->
      <c:if test="${not empty sessionScope.user}">
        <form action="${pageContext.request.contextPath}/reviews" method="post" id="reviewForm" class="review-form" accept-charset="UTF-8">
          <input type="hidden" name="action" value="add">
          <input type="hidden" name="productId" value="${product.id}">
          <input type="hidden" name="rating" id="ratingValue" value="5">

          <div><strong>Chấm điểm</strong></div>
          <div class="star-select" id="starSelect">
            <c:forEach begin="1" end="5" var="i"><span data-val="${i}">★</span></c:forEach>
          </div>

            <div>
              <select id="titlePreset" name="titlePreset">
                <option value="">-- Tiêu đề mẫu --</option>
                <option>Chất lượng rất tốt</option>
                <option>Đóng gói cẩn thận</option>
                <option>Giao hàng nhanh</option>
                <option>Giá cả hợp lý</option>
                <option value="_custom">Khác...</option>
              </select>
            </div>
            <input type="text" id="customTitle" name="title" placeholder="Nhập tiêu đề..." maxlength="150">

            <div>
              <textarea name="content" required placeholder="Chia sẻ trải nghiệm của bạn (tối thiểu vài từ)"></textarea>
            </div>

            <button class="button" style="justify-content:center;">Gửi đánh giá</button>
            <div class="small-note">Đánh giá sẽ được duyệt trước khi hiển thị công khai.</div>
        </form>
      </c:if>
      <c:if test="${empty sessionScope.user}">
        <div class="alert warn">Vui lòng <a href="${pageContext.request.contextPath}/auth?action=login">đăng nhập</a> để đánh giá.</div>
      </c:if>
    </div>

    <!-- RECENTLY VIEWED -->
    <div class="row-section">
      <h2 class="section-title">🕒 Sản phẩm vừa xem</h2>
      <div class="horizontal-scroll">
        <c:forEach var="p" items="${recentProducts}">
          <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}" class="prod-card">
            <img src="${pageContext.request.contextPath}/${p.imagePath}" alt="${p.name}" class="prod-thumb" loading="lazy">
            <div class="prod-title">${p.name}</div>
            <div class="prod-stock ${p.quantity > 0 ? 'in' : 'out'}">
              <c:choose><c:when test="${p.quantity > 0}">Còn hàng</c:when><c:otherwise>Hết hàng</c:otherwise></c:choose>
            </div>
            <div class="prod-price"><fmt:formatNumber value="${p.price}" type="number" groupingUsed="true"/>₫</div>
          </a>
        </c:forEach>
        <c:if test="${empty recentProducts}">
          <div style="scroll-snap-align:start;border:1px dashed var(--border-dark);background:#fff;border-radius:14px;padding:26px 18px;font-style:italic;color:var(--muted);display:flex;align-items:center;justify-content:center;">
            Chưa có lịch sử xem.
          </div>
        </c:if>
      </div>
    </div>

  </div>

  <%@ include file="partials/footer.jsp" %>

  <!-- SCRIPTS -->
  <script>
    // Star rating UI
    (function(){
      const wrap = document.getElementById('starSelect');
      if(!wrap) return;
      const ratingInput = document.getElementById('ratingValue');
      const stars = Array.from(wrap.querySelectorAll('span'));
      let current = parseInt(ratingInput.value||'5',10);
      function render(){
        stars.forEach(s=>{
          const v = parseInt(s.dataset.val,10);
          s.classList.toggle('active', v <= current);
        });
      }
      stars.forEach(s=>{
        s.addEventListener('mouseenter',()=>{
          const v = parseInt(s.dataset.val,10);
          stars.forEach(t=>t.classList.toggle('hover', parseInt(t.dataset.val,10) <= v));
        });
        s.addEventListener('mouseleave',()=>stars.forEach(t=>t.classList.remove('hover')));
        s.addEventListener('click',()=>{
          current = parseInt(s.dataset.val,10);
          ratingInput.value = current;
          render();
        });
      });
      render();
    })();

    // Preset tiêu đề
    (function(){
      const presetSel = document.getElementById('titlePreset');
      const customTitle = document.getElementById('customTitle');
      if(!presetSel || !customTitle) return;
      function apply(){
        if(presetSel.value === '_custom'){
          customTitle.style.display='block';
          customTitle.value='';
          customTitle.focus();
        }else{
          customTitle.style.display = presetSel.value ? 'none':'block';
          customTitle.value = presetSel.value || '';
        }
      }
      presetSel.addEventListener('change', apply);
      apply();
    })();

    // Drag-to-scroll
    (function(){
      const scrollers = document.querySelectorAll('.horizontal-scroll, .review-track');
      scrollers.forEach(sc=>{
        let isDown=false,startX,scrollLeft;
        sc.addEventListener('mousedown',e=>{
          isDown=true;sc.classList.add('dragging');
          startX=e.pageX - sc.offsetLeft;
          scrollLeft=sc.scrollLeft;
        });
        sc.addEventListener('mouseleave',()=>isDown=false);
        sc.addEventListener('mouseup',()=>{isDown=false;sc.classList.remove('dragging');});
        sc.addEventListener('mousemove',e=>{
          if(!isDown) return;
          e.preventDefault();
          const x=e.pageX - sc.offsetLeft;
          const walk=(x - startX)*1.2;
          sc.scrollLeft = scrollLeft - walk;
        });
      });
    })();
  </script>
</body>
</html>