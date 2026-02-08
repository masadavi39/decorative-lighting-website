<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false" %>
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
            --primary:#007bff;
            --success:#28a745;
            --danger:#e74c3c;
            --border:#dcdcdc;
            --input-bg:#fff;
            --input-text:#222;
            --input-border:#cfcfcf;
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
        }
        *{margin:0;padding:0;box-sizing:border-box}
        body{font-family:'Arial',sans-serif;background:var(--bg-color);color:var(--text-color);transition:background .3s,color .3s}
        .container{max-width:1400px;margin:0 auto;padding:20px}
        h2{color:var(--heading);text-align:center;margin-bottom:22px;font-size:2rem}
        .products-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;gap:10px;flex-wrap:wrap}
        /* Grid */
        .product-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:20px;}
        .product-card{background:var(--card-bg);border-radius:12px;padding:16px;text-align:center;box-shadow:0 2px 10px var(--shadow);transition:transform .25s;border:1px solid var(--border);}
        .product-card:hover{transform:translateY(-5px);}
        .product-card img{width:100%;height:180px;object-fit:cover;border-radius:8px;margin-bottom:12px;}
        .product-card h3{font-size:1.05rem;margin-bottom:6px;color:var(--text-color);}
        .product-card .price{color:var(--primary);font-weight:bold;font-size:1.06rem;margin-bottom:6px;}
        .stock{font-size:.9rem;margin-bottom:10px;color:var(--muted);}
        .stock.in{color:var(--success);}
        .stock.out{color:var(--danger);}
        .button{background:var(--primary);color:#fff;border:none;padding:10px 16px;border-radius:8px;cursor:pointer;text-decoration:none;display:inline-block;margin:5px;transition:transform .2s,opacity .2s;}
        .button:hover{transform:translateY(-2px);}
        .button.secondary{background:#6c757d;}
        .button.secondary:hover{opacity:.9;}
        .pagination{text-align:center;margin:24px 0;}
        .pagination .button{margin:0 2px;}
        .pagination .button.active{background:#28a745;}
        .pagination input{width:70px;padding:8px;border-radius:6px;border:1px solid var(--input-border);background:var(--input-bg);color:var(--input-text);}
        .theme-toggle{position:fixed;bottom:20px;right:20px;background:#ffc107;color:#000;border:none;padding:10px 15px;border-radius:10px;cursor:pointer;font-weight:700;box-shadow:0 2px 8px var(--shadow);}
        .theme-toggle:hover{filter:brightness(.95);}
        @media (max-width:992px){
            .product-grid{grid-template-columns:repeat(2,1fr);}
        }
        @media (max-width:576px){
            .product-grid{grid-template-columns:1fr;}
        }
    </style>
</head>
<body>
<%@ include file="partials/header.jsp" %>
<div class="container">


    <div class="product-grid">
        <c:forEach var="p" items="${products}">
            <div class="product-card">
                <img src="${pageContext.request.contextPath}/${p.imagePath}" alt="${p.name}">
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
                <a href="${pageContext.request.contextPath}/products?action=detail&id=${p.id}" class="button secondary">Xem chi tiết</a>
            </div>
        </c:forEach>
        <c:if test="${fn:length(products)==0}">
            <div style="grid-column:1/-1;text-align:center;padding:36px;color:#888;">Không tìm thấy sản phẩm nào.</div>
        </c:if>
    </div>

    <!-- PHÂN TRANG -->
    <c:if test="${totalPages > 1}">
        <div class="pagination">
            <c:if test="${currentPage > 1}">
                <a href="?action=list&page=1" class="button">« Đầu</a>
                <a href="?action=list&page=${currentPage - 1}" class="button">‹ Trước</a>
            </c:if>
            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                <a href="?action=list&page=${pageNum}" class="button ${pageNum == currentPage ? 'active' : ''}">${pageNum}</a>
            </c:forEach>
            <c:if test="${currentPage < totalPages}">
                <a href="?action=list&page=${currentPage + 1}" class="button">Tiếp ›</a>
                <a href="?action=list&page=${totalPages}" class="button">Cuối »</a>
            </c:if>
            <form action="" method="get" style="display:inline-block;margin-left:15px;">
                <input type="hidden" name="action" value="list"/>
                <label for="goPage" style="margin-right:6px;">Đến trang:</label>
                <input type="number" name="page" id="goPage" min="1" max="${totalPages}" required value="${currentPage}" style="width:60px;">
                <button type="submit" class="button">Đi</button>
            </form>
        </div>
    </c:if>

</div>
<button id="themeToggle" class="theme-toggle">🌞 Chế độ sáng</button>
<%@ include file="partials/footer.jsp" %>

<script>
    // Dark/Light mode
    const themeBtn=document.getElementById('themeToggle');
    function applySavedTheme(){
        const saved=localStorage.getItem('theme');
        const isDark = saved==='dark';
        if(isDark){ document.body.classList.add('dark'); themeBtn.textContent='🌙 Chế độ tối'; }
        else{ document.body.classList.remove('dark'); themeBtn.textContent='🌞 Chế độ sáng'; }
    }
    applySavedTheme();
    themeBtn.addEventListener('click',()=>{
        document.body.classList.toggle('dark');
        const dark=document.body.classList.contains('dark');
        localStorage.setItem('theme',dark?'dark':'light');
        themeBtn.textContent=dark?'🌙 Chế độ tối':'🌞 Chế độ sáng';
    });

    // Add to cart (AJAX)
    document.addEventListener('DOMContentLoaded',function(){
        document.querySelectorAll('.add-to-cart-btn').forEach(btn=>{
            btn.addEventListener('click',async function(e){
                e.preventDefault();
                const id=this.dataset.productId;
                this.disabled=true;
                try{
                    const res=await fetch('${pageContext.request.contextPath}/cart',{
                        method:'POST',
                        headers:{'Content-Type':'application/x-www-form-urlencoded','X-Requested-With':'XMLHttpRequest'},
                        body:new URLSearchParams({action:'add',productId:id,quantity:1})
                    });
                    const result=await res.json();
                    if(result.success){ alert("Đã thêm vào giỏ hàng!"); }
                    else{ alert(result.message||"Không thể thêm sản phẩm"); }
                }catch(err){ console.error(err); }
                finally{ this.disabled=false; }
            });
        });
    });
</script>
</body>
</html>
