<%@page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page import="java.util.Map, model.OrderDetail" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Giỏ hàng của bạn</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:"Segoe UI", Arial, sans-serif; background:#f5f7fa; color:#333; }
        .page { max-width:1200px; margin:36px auto; padding:0 16px; }
        .layout { display:flex; gap:28px; align-items:flex-start; }
        .left { flex:2; background:#fff; border-radius:10px; padding:22px; box-shadow:0 2px 8px rgba(0,0,0,0.05); }
        .right { flex:1; background:#fff; border-radius:10px; padding:22px; box-shadow:0 2px 8px rgba(0,0,0,0.05); height:fit-content; position:sticky; top:28px; }
        h1 { font-size:1.6rem; margin-bottom:14px; color:#222; }
        table { width:100%; border-collapse:collapse; margin-bottom:18px; }
        th, td { padding:12px; border-bottom:1px solid #eee; text-align:center; vertical-align:middle; }
        th { background:#fbfcfe; color:#666; font-weight:600; }
        .product-cell { text-align:left; display:flex; gap:12px; align-items:center; }
        .product-thumb { width:72px; height:72px; object-fit:cover; border-radius:6px; background:#f2f2f2; }
        .product-name { font-weight:600; color:#222; }
        input.qty-input { width:66px; padding:6px; border:1px solid #ddd; border-radius:6px; text-align:center; }
        .btn { display:inline-block; padding:8px 12px; border-radius:6px; border:0; cursor:pointer; font-weight:600; }
        .btn.primary { background:#007bff; color:#fff; }
        .btn.danger { background:#dc3545; color:#fff; }
        .btn.ghost { background:transparent; border:1px solid #ddd; color:#333; }
        .promo { background:#fff8e6; border:1px dashed #f2c94c; padding:12px; border-radius:8px; margin:12px 0; font-size:0.95rem; }
        .continue { margin-left:auto; }
        .summary-title { font-size:1.15rem; font-weight:700; margin-bottom:12px; }
        .summary-row { display:flex; justify-content:space-between; padding:8px 0; font-size:0.98rem; }
        .summary-row.total { font-size:1.15rem; font-weight:800; color:#d63031; border-top:1px solid #eee; padding-top:12px; margin-top:8px; }
        .voucher { margin-top:14px; }
        .voucher input { width:100%; padding:10px; border-radius:8px; border:1px solid #ddd; }
        .checkout-full { width:100%; margin-top:18px; padding:12px 10px; border-radius:8px; background:#007bff; color:#fff; border:0; font-weight:700; cursor:pointer; }
        .checkout-full:disabled { background:#ccc; cursor:not-allowed; }
        .empty { text-align:center; padding:54px 16px; color:#666; }
        .empty h3 { font-size:1.3rem; margin-bottom:8px; }
        @media (max-width:900px){
            .layout{ flex-direction:column; }
            .right{ position:relative; top:auto; }
        }
        .alert.success { background:#d1fae5; color:#065f46; padding:8px 10px; border-radius:6px; font-size:.9rem; margin-top:8px; }
        .alert.error { background:#fee2e2; color:#991b1b; padding:8px 10px; border-radius:6px; font-size:.9rem; margin-top:8px; }
    </style>
</head>
<body>
<%@ include file="partials/header.jsp" %>
<%
    Map<Integer, OrderDetail> cart = (Map<Integer, OrderDetail>) session.getAttribute("cart");
    double total = 0;
    int totalQty = 0;
    if (cart != null) {
        for (OrderDetail it : cart.values()) {
            total += it.getSubtotal();
            totalQty += it.getQuantity();
        }
    }
    request.setAttribute("cartTotal", total);
    request.setAttribute("cartTotalQty", totalQty);
%>

<div class="page">
    <div class="layout">
        <!-- LEFT -->
        <div class="left">
            <h1>🛒 Giỏ hàng của bạn</h1>

            <c:choose>
                <c:when test="${empty sessionScope.cart}">
                    <div class="empty">
                        <h3>Giỏ hàng trống</h3>
                        <p>Bạn chưa thêm sản phẩm nào vào giỏ.</p>
                        <br>
                        <a href="${pageContext.request.contextPath}/products?action=list" class="btn primary">
                            Tiếp tục mua sắm
                        </a>
                    </div>
                </c:when>

                <c:otherwise>
                    <form id="cartForm" method="post" action="${pageContext.request.contextPath}/cart" onsubmit="return false;">
                        <input type="hidden" name="action" value="">
                        <table>
                            <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" id="selectAll" style="transform:scale(1.2); margin-right:4px;">
                                    <label for="selectAll">Chọn tất cả</label>
                                </th>
                                <th>Giá</th>
                                <th>Số lượng</th>
                                <th>Tổng</th>
                                <th>Hành động</th>
                            </tr>
                            </thead>
                            <tbody id="cartBody">
                            <c:forEach var="item" items="${sessionScope.cart.values()}">
                                <tr id="item-row-${item.product.id}">
                                    <td style="text-align:left;">
                                        <div class="product-cell">
                                            <input type="checkbox" class="item-checkbox"
                                                   value="${item.product.id}" checked
                                                   style="margin-right:8px; transform:scale(1.2);">
                                            <img src="${pageContext.request.contextPath}/${item.product.imagePath}"
                                                 alt="${item.product.name}" class="product-thumb">
                                            <div>
                                                <div class="product-name">${item.product.name}</div>
                                                <div style="font-size:0.9rem; color:#666;">Mã: ${item.product.id}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="item-price" data-price="${item.product.price}">
                                        <span class="price-text"><script>fmt:formatNumber(new Intl.NumberFormat('vi-VN').format(${item.product.price}));</script>₫</span>
                                    </td>
                                    <td>
                                        <div style="display:inline-flex; align-items:center; gap:6px;">
                                            <button type="button" class="btn ghost qty-btn" data-action="minus"
                                                    data-id="${item.product.id}">−</button>
                                            <input type="number" name="quantity_${item.product.id}"
                                                   value="${item.quantity}" min="1" class="qty-input"
                                                   data-id="${item.product.id}">
                                            <button type="button" class="btn ghost qty-btn" data-action="plus"
                                                    data-id="${item.product.id}">+</button>
                                        </div>
                                    </td>
                                    <td class="item-subtotal" data-id="${item.product.id}">
                                        <span class="subtotal-text"><script>fmt:formatNumber(new Intl.NumberFormat('vi-VN').format(${item.subtotal}));</script>₫</span>
                                    </td>
                                    <td>
                                        <button type="button" class="btn danger remove-btn"
                                                data-id="${item.product.id}">Xóa</button>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </form>

                    <div class="promo">
                        <strong>Khuyến mãi áp dụng:</strong><br>
                        - Giảm 4% trên tổng đơn hàng.<br>
                        - Tặng bàn di chuột, miễn phí vận chuyển.<br>
                        - Hỗ trợ đổi trả 1:1.
                    </div>

                    <div style="display:flex; gap:12px; align-items:center; margin-top:12px;">
                        <div class="continue" style="margin-left:auto;">
                            <a href="${pageContext.request.contextPath}/products?action=list" class="btn ghost">
                                ⬅ Tiếp tục mua sắm
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- RIGHT -->
        <div class="right">
            <div class="summary-title">Tóm tắt đơn hàng</div>
            <div class="summary-row"><span>Tổng số lượng</span><span id="totalQty" aria-live="polite">${cartTotalQty}</span></div>
            <div class="summary-row"><span>Tạm tính</span><span id="totalAmount"><script>fmt:formatNumber(new Intl.NumberFormat('vi-VN').format(${cartTotal}));</script>₫</span></div>

            <!-- Dòng giảm theo coupon (ẩn khi chưa áp dụng) -->
            <div class="summary-row" id="rowCoupon" style="display:none;">
                <span>Giảm theo coupon</span><span id="couponDiscount">-0₫</span>
            </div>

            <div class="summary-row total"><span>Tổng cộng</span><span id="grandTotal" aria-live="polite"><script>fmt:formatNumber(new Intl.NumberFormat('vi-VN').format(${cartTotal}));</script>₫</span></div>

            <form action="${pageContext.request.contextPath}/payment" method="post" id="toPaymentForm" style="margin-top: 14px;">
                <div class="voucher">
                    <label for="voucher">Nhập mã voucher</label>
                    <div style="display:flex; gap:8px;">
                        <input type="text" id="voucher" name="couponCode" placeholder="Nhập mã khuyến mãi..." style="flex:1;">
                        <button type="button" class="btn primary" id="btnApplyVoucher">Áp dụng</button>
                    </div>
                    <div id="voucherMsg" style="margin-top:6px; font-size:0.9rem; color:#555;"></div>
                </div>
                <button type="submit" class="checkout-full" id="checkoutBtn">Tiến hành thanh toán</button>
            </form>
        </div>
    </div>
</div>

<script>
    function formatVnd(n) { return new Intl.NumberFormat('vi-VN').format(n) + '₫'; }

    document.addEventListener('DOMContentLoaded', () => {
        var contextPath = "${pageContext.request.contextPath}";
        var cartBody = document.getElementById('cartBody');
        var selectAll = document.getElementById('selectAll');
        var checkoutBtn = document.getElementById('checkoutBtn');

        var totalQtyEl = document.getElementById('totalQty');
        var totalAmountEl = document.getElementById('totalAmount');
        var grandTotalEl = document.getElementById('grandTotal');

        var appliedCoupon = null; // {code, discount}

        function getRows() {
            if (!cartBody) return [];
            return Array.prototype.slice.call(cartBody.querySelectorAll('tr[id^="item-row-"]'));
        }

        function updateCartTotals() {
            var totalQty = 0, totalAmount = 0;
            var rows = getRows();
            for (var i=0; i<rows.length; i++) {
                var row = rows[i];
                var checkbox = row.querySelector('.item-checkbox');
                if (!checkbox || !checkbox.checked) continue;
                var qtyInput = row.querySelector('.qty-input');
                var priceCell = row.querySelector('.item-price');
                var price = parseFloat(priceCell.dataset.price);
                var qty = parseInt(qtyInput.value) || 0;
                totalQty += qty;
                totalAmount += price * qty;
            }
            if (totalQtyEl) totalQtyEl.textContent = totalQty;
            if (totalAmountEl) totalAmountEl.textContent = formatVnd(totalAmount);
            var discount = appliedCoupon ? appliedCoupon.discount : 0;
            if (grandTotalEl) grandTotalEl.textContent = formatVnd(Math.max(0, totalAmount - discount));
        }

        function syncSelectAll() {
            if (!selectAll) return;
            var rows = getRows();
            var allChecked = rows.length > 0 && rows.every(function(r){
                var cb = r.querySelector('.item-checkbox'); return cb && cb.checked;
            });
            selectAll.checked = allChecked;
            toggleCheckoutButton();
        }

        function toggleCheckoutButton() {
            if (!checkoutBtn) return;
            var anyChecked = getRows().some(function(r){
                var cb = r.querySelector('.item-checkbox'); return cb && cb.checked;
            });
            checkoutBtn.disabled = !anyChecked;
        }

        function updateRowSubtotal(row) {
            var qtyInput = row.querySelector('.qty-input');
            var priceCell = row.querySelector('.item-price');
            var subtotalCell = row.querySelector('.item-subtotal .subtotal-text');
            var price = parseFloat(priceCell.dataset.price);
            var qty = parseInt(qtyInput.value) || 1;
            if (subtotalCell) subtotalCell.textContent = formatVnd(price * qty);
        }

        // Áp dụng voucher (preview) – sau đó LƯU VÀO SESSION qua CouponServlet
        var btnApplyVoucher = document.getElementById('btnApplyVoucher');
        if (btnApplyVoucher) {
            btnApplyVoucher.addEventListener('click', function(){
                var codeEl = document.getElementById('voucher');
                var msg = document.getElementById('voucherMsg');
                var code = (codeEl && codeEl.value ? codeEl.value.trim() : "");
                if (!code) { if (msg) msg.textContent = 'Vui lòng nhập mã'; return; }

                var subtotal = 0;
                var rows = getRows();
                for (var i=0; i<rows.length; i++){
                    var row = rows[i];
                    var cb = row.querySelector('.item-checkbox');
                    if (!cb || !cb.checked) continue;
                    var price = parseFloat(row.querySelector('.item-price').dataset.price);
                    var qty = parseInt(row.querySelector('.qty-input').value) || 0;
                    subtotal += price * qty;
                }
                if (!(subtotal > 0)) { if (msg) msg.textContent = 'Chưa chọn sản phẩm nào.'; return; }

                // Preview qua OrdersServlet (giữ nguyên):
                fetch(contextPath + '/orders?action=validateCoupon&code=' + encodeURIComponent(code) + '&subtotal=' + encodeURIComponent(subtotal), {
                    headers: {'X-Requested-With': 'XMLHttpRequest'}
                }).then(function(res){
                    if (res.status === 401) {
                        if (msg) msg.textContent = 'Bạn cần đăng nhập để áp dụng mã';
                        return { valid:false };
                    }
                    return res.text().then(function(t){
                        try { return JSON.parse(t); } catch(e){ return {valid:false, message:'Lỗi máy chủ'}; }
                    });
                }).then(function(data){
                    if (!data || !data.valid) {
                        appliedCoupon = null;
                        var rowCp2 = document.getElementById('rowCoupon');
                        var disEl2 = document.getElementById('couponDiscount');
                        if (rowCp2) rowCp2.style.display = 'none';
                        if (disEl2) disEl2.textContent = '-0₫';
                        if (msg && data && data.message) msg.textContent = data.message;
                        updateCartTotals();
                        return;
                    }
                    appliedCoupon = { code: data.code, discount: data.discount };

                    // HIỂN THỊ GIẢM GIÁ + GHI ĐÈ GIÁ TRỊ VÀO Ô INPUT
                    var rowCp = document.getElementById('rowCoupon');
                    var disEl = document.getElementById('couponDiscount');
                    if (rowCp) rowCp.style.display = 'flex';
                    if (disEl) disEl.textContent = '-' + formatVnd(data.discount);

                    // Đồng bộ giá trị vào input voucher để POST sang /payment
                    var inputCode = document.getElementById('voucher');
                    if (inputCode) inputCode.value = data.code || code;

                    if (msg) msg.textContent = data.message || 'Áp dụng thành công';
                    updateCartTotals();

                    // LƯU COUPON VÀO SESSION để payment_confirmed.jsp đọc lại
                    try {
                        var fd = new FormData();
                        fd.append('code', data.code || code);
                        fd.append('subtotal', String(subtotal));
                        // Gửi ngầm, không redirect
                        fetch(contextPath + '/coupon/apply', {
                            method:'POST',
                            body: fd,
                            headers: {'X-Requested-With':'XMLHttpRequest'}
                        }).catch(function(){});
                    } catch(e) {}
                }).catch(function(){
                    appliedCoupon = null;
                    var rowCp3 = document.getElementById('rowCoupon');
                    var disEl3 = document.getElementById('couponDiscount');
                    if (rowCp3) rowCp3.style.display = 'none';
                    if (disEl3) disEl3.textContent = '-0₫';
                    if (msg) msg.textContent = 'Lỗi kết nối, thử lại sau.';
                    updateCartTotals();
                });
            });
        }

        // Delegation: remove / qty +/- (AJAX)
        if (cartBody) {
            cartBody.addEventListener('click', function(e){
                var btn = e.target.closest('button'); if (!btn) return;

                // Xóa
                if (btn.classList.contains('remove-btn')) {
                    var id = btn.dataset.id;
                    var fd = new URLSearchParams({action: 'remove', productId: id});
                    fetch(contextPath + '/cart', {
                        method: 'POST', headers: {'X-Requested-With': 'XMLHttpRequest'}, body: fd
                    }).then(function(res){
                        return res.text().then(function(t){
                            try { return JSON.parse(t); } catch(e){ return {success:false, message:'Lỗi máy chủ'}; }
                        });
                    }).then(function(data){
                        if (data.success) {
                            var row = document.getElementById('item-row-' + id);
                            if (row) row.remove();
                            updateCartTotals();
                            syncSelectAll();
                        } else {
                            alert(data.message || 'Không thể xóa.');
                        }
                    }).catch(function(){
                        alert('Lỗi mạng.');
                    });
                    return;
                }

                // Plus / Minus
                if (btn.classList.contains('qty-btn')) {
                    var id2 = btn.dataset.id;
                    var row2 = document.getElementById('item-row-' + id2);
                    if (!row2) return;
                    var input = row2.querySelector('.qty-input');
                    var val = parseInt(input.value) || 1;
                    if (btn.dataset.action === 'plus') val++;
                    else if (btn.dataset.action === 'minus' && val > 1) val--;
                    input.value = val;
                    updateRowSubtotal(row2);
                    updateCartTotals();

                    var fd2 = new URLSearchParams({action: 'update', productId: id2, quantity: val});
                    fetch(contextPath + '/cart', {
                        method: 'POST', headers: {'X-Requested-With': 'XMLHttpRequest'}, body: fd2
                    }).then(function(res){
                        return res.text().then(function(t){
                            try { return JSON.parse(t); } catch(e){ return {success:false, message:'Lỗi máy chủ'}; }
                        });
                    }).then(function(data){
                        if (!data.success) {
                            alert(data.message || 'Cập nhật server thất bại. Giỏ hàng sẽ được đồng bộ lại.');
                            location.reload();
                        }
                    }).catch(function(){
                        alert('Lỗi kết nối. Trang sẽ reload để đồng bộ.');
                        location.reload();
                    });
                }
            });

            cartBody.addEventListener('change', function(e){
                var target = e.target;
                if (target.classList.contains('item-checkbox')) { syncSelectAll(); updateCartTotals(); }
                if (target.classList.contains('qty-input')) {
                    var row = target.closest('tr'); if (!row) return;
                    var val = parseInt(target.value) || 1;
                    if (val < 1) { val = 1; target.value = val; }
                    updateRowSubtotal(row);
                    updateCartTotals();

                    var id3 = target.dataset.id;
                    var fd3 = new URLSearchParams({action: 'update', productId: id3, quantity: val});
                    fetch(contextPath + '/cart', {
                        method: 'POST', headers: {'X-Requested-With': 'XMLHttpRequest'}, body: fd3
                    }).then(function(res){
                        return res.text().then(function(t){
                            try { return JSON.parse(t); } catch(e){ return {success:false, message:'Lỗi máy chủ'}; }
                        });
                    }).then(function(data){
                        if (!data.success) {
                            alert(data.message || 'Cập nhật số lượng thất bại.');
                            location.reload();
                        }
                    }).catch(function(){
                        alert('Lỗi cập nhật server.');
                        location.reload();
                    });
                }
            });
        }

        // Chọn tất cả
        if (selectAll) {
            selectAll.addEventListener('change', function(){
                var rows = getRows();
                for (var i=0; i<rows.length; i++){
                    var cb = rows[i].querySelector('.item-checkbox');
                    if (cb) cb.checked = selectAll.checked;
                }
                toggleCheckoutButton();
                updateCartTotals();
            });
        }

        // Init
        updateCartTotals();
        syncSelectAll();
    });
</script>

<%@ include file="partials/footer.jsp" %>
</body>
</html>