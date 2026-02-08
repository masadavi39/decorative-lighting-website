<%@page contentType="text/html;charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác nhận mua hàng</title>
    <style>
        /* giữ nguyên toàn bộ CSS như bản trước */
        :root {
    --bg: #f5f6f7;
    --text: #1f2937;
    --border: #e5e7eb;
    --primary: #2563eb;
    --primary-dark: #1e40af;
    --muted: #6b7280;
    --card-bg: #ffffff;
}
* { box-sizing: border-box; }
body.payment-page { background: var(--bg); color: var(--text); font-family: "Inter","Segoe UI",Arial,sans-serif; margin: 0; }
.payment-content { max-width: 1400px; width: 100%; margin: 24px auto; padding: 0 24px 48px; }
.content-main-cart { display: grid; grid-template-columns: 1.15fr 0.85fr; gap: 28px; align-items: start; }
.content-left, .content-right { background: var(--card-bg); border: 1px solid var(--border); border-radius: 14px; padding: 28px; box-shadow: 0 6px 18px rgba(0,0,0,0.06); }
.title-header h2, .background-white .title { font-size: 1.6rem; font-weight: 800; margin: 0 0 14px; color: #0f172a; }
.background-white .title-row { display: flex; justify-content: space-between; align-items: center; gap: 14px; }
.header-actions { display: flex; gap: 12px; }
.header-actions a { color: #374151; text-decoration: none; display: inline-flex; gap: 8px; align-items: center; padding: 8px 10px; border-radius: 8px; transition: .12s; border: 1px solid var(--border); background: #fafafa; }
.header-actions a:hover { background: #eef2ff; color: #111827; }
.profile-fill { display: flex; align-items: center; gap: 10px; background: #eef2ff; border: 1px solid #d0e2ff; padding: 10px 12px; border-radius: 10px; margin: 6px 0 18px; }
.profile-fill input[type="checkbox"] { width: 18px; height: 18px; cursor: pointer; accent-color: var(--primary); }
.profile-fill label { margin: 0; font-weight: 600; font-size: .92rem; color: #111827; cursor: pointer; }
.profile-fill .pf-hint { margin-left: auto; font-size: .8rem; color: var(--muted); font-style: italic; }
.content-input-form { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; }
.item-input.full { grid-column: 1 / -1; }
label { font-weight: 700; margin-bottom: 6px; display: block; font-size: .96rem; color: #111827; }
.required { color: #dc2626; margin-left: 4px; font-weight: 800; }
input, select, textarea { width: 100%; padding: 12px 14px; border-radius: 10px; border: 1px solid #d8d8d8; background: #fafafa; transition: .18s; font-size: 1rem; color: #111827; }
input:focus, select:focus, textarea:focus { background: #fff; border-color: var(--primary); outline: none; box-shadow: 0 8px 24px rgba(37,99,235,0.10); }
textarea { resize: vertical; }
.select-wrapper { position: relative; display: block; }
.select-wrapper .form-control { appearance: none; padding: 10px 40px 10px 12px; height: 42px; background: #fafafa; border: 1px solid #d1d5db; transition: .18s; font-size: .98rem; border-radius: 10px; }
.select-wrapper::after { content: ""; position: absolute; right: 12px; top: 50%; transform: translateY(-50%); border-left: 6px solid transparent; border-right: 6px solid transparent; border-top: 7px solid #6b7280; pointer-events: none; }
.form-group.tax { padding: 14px 16px; background: #fafafa; border-radius: 12px; margin-top: 12px; cursor: pointer; border: 1px solid #e6e6e6; display: flex; gap: 12px; align-items: center; }
.form-group.tax input[type="checkbox"] { width: 18px; height: 18px; cursor: pointer; }
.content-tax { display: none; flex-direction: column; gap: 12px; margin-top: 12px; }
.content-tax.active { display: flex; }
.box-pay-method { margin-top: 22px; display: flex; flex-direction: column; gap: 14px; }
.item-radio-custom { padding: 16px; border-radius: 12px; border: 1px solid #dcdcdc; background: #fafafa; display: flex; align-items: center; gap: 12px; cursor: pointer; }
.item-radio-custom:hover { border-color: var(--primary); }
.item-radio-custom input { width: 18px; height: 18px; }
.content-info-pay { display: none; background: #f0f4ff; border-radius: 10px; padding: 12px 16px; font-size: .95rem; margin-top: -5px; }
.content-info-pay.active { display: block; }
.product-item { display: grid; grid-template-columns: 64px 1fr; gap: 12px; padding: 12px; border-radius: 10px; background: #fafafa; border: 1px solid #e6e6e6; margin-bottom: 12px; }
.product-item img { width: 64px; height: 64px; object-fit: cover; border-radius: 8px; }
.product-name { font-weight: 700; }
.product-details { font-size: .95rem; display: flex; justify-content: space-between; margin-top: 4px; }
.total-price { border-top: 1px solid var(--border); margin-top: 18px; padding-top: 18px; }
.total-price .item { display: flex; justify-content: space-between; margin-bottom: 12px; }
.total-price .item:last-child { font-weight: 800; color: var(--primary); }
.button-send-cart { width: 100%; margin-top: 22px; padding: 16px; border-radius: 12px; border: none; background: var(--primary); color: #fff; font-size: 1.02rem; font-weight: 700; cursor: pointer; transition: .16s; display: inline-flex; align-items: center; justify-content: center; gap: 8px; }
.button-send-cart:hover { background: var(--primary-dark); }
.info-policy { background: #fafafa; border-radius: 12px; padding: 16px; border: 1px solid #e6e6e6; margin-top: 22px; }
.info-policy .item { display: flex; gap: 10px; margin-bottom: 10px; font-size: .95rem; color: #555; }
.info-policy i { color: var(--primary); }
.qr-box { margin-top: 14px; background: #ffffff; border: 1px solid #e5e7eb; border-radius: 12px; padding: 16px 18px 20px; display: none; }
.qr-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
.qr-header h3 { font-size: 1rem; margin: 0; font-weight: 700; color: #111827; }
.qr-image-wrap { text-align: center; margin: 10px 0 12px; }
.qr-image-wrap img { max-width: 260px; width: 100%; height: auto; display: block; margin: 0 auto; }
.qr-ref { font-size: .8rem; text-align: center; color: #555; margin-top: 4px; }
.qr-actions { display: flex; justify-content: center; gap: 10px; margin-top: 8px; }
.qr-actions button { padding: 8px 14px; border-radius: 8px; border: none; background: var(--primary); color: #fff; font-size: .85rem; font-weight: 700; cursor: pointer; display: inline-flex; gap: 6px; align-items: center; }
.qr-actions button:hover { background: var(--primary-dark); }
.pay-modal{ position: fixed; inset: 0; background: rgba(0,0,0,.45); display: none; align-items: center; justify-content: center; z-index: 99999; }
.pay-modal.show{ display:flex; }
.pay-modal__dialog{ width: min(92vw, 460px); background: #fff; border-radius: 14px; padding: 22px 18px; box-shadow: 0 16px 50px rgba(0,0,0,.2); text-align: center; animation: pmfade .2s ease; }
.pay-modal__icon{ font-size: 44px; margin-bottom: 8px; }
.pay-modal__title{ font-weight: 800; font-size: 1.18rem; margin-bottom: 6px; color: #111827; }
.pay-modal__desc{ font-size: .98rem; color: #374151; margin-bottom: 14px; }
.pay-modal__btn{ padding: 10px 16px; border: none; border-radius: 10px; background: var(--primary); color: #fff; font-weight: 800; cursor: pointer; }
.pay-modal__btn:hover{ background: var(--primary-dark); }
@keyframes pmfade{ from{ opacity:0; transform: translateY(6px); } to{ opacity:1; transform: translateY(0); } }
@media (max-width: 1200px) { .payment-content { max-width: 1200px; padding: 0 20px 40px; } }
@media (max-width: 992px) { .content-main-cart { grid-template-columns: 1fr; } }
.alert.success { background:#d1fae5; color:#065f46; padding:8px 10px; border-radius:6px; font-size:.85rem; margin-top:8px; }
.alert.error { background:#fee2e2; color:#991b1b; padding:8px 10px; border-radius:6px; font-size:.85rem; margin-top:8px; }
input[disabled] { cursor:not-allowed; background:#f3f4f6; }
.coupon-actions { margin-top:6px; display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
.coupon-actions button { background:#2563eb; color:#fff; border:none; padding:6px 12px; font-size:.75rem; border-radius:6px; cursor:pointer; font-weight:600; }
    </style>

    <!-- Prefill coupon -->
    <c:set var="couponPrefill" value="${not empty sessionScope.appliedCouponCode ? sessionScope.appliedCouponCode : ''}"/>
    <c:set var="couponValidPref" value="${sessionScope.couponValid != null ? sessionScope.couponValid : false}"/>
    <c:set var="couponDiscountPref" value="${sessionScope.couponDiscount}"/>
    <c:set var="couponMessagePref" value="${sessionScope.couponMessage}"/>

    <script>
        function addHidden(form, name, value) {
            const i = document.createElement('input');
            i.type='hidden'; i.name=name; i.value=value || '';
            form.appendChild(i);
        }
        function toggleTaxContainer() {
            const cb = document.getElementById("tax_checkbox");
            cb.checked = !cb.checked;
            document.getElementById("js-tax-group").classList.toggle("active", cb.checked);
        }
        // Khôi phục kiểm tra province
        function check_field() {
            const name = document.getElementById('buyer_name').value.trim();
            const phone = document.getElementById('buyer_tel').value.trim();
            const addr  = document.getElementById('buyer_address').value.trim();
            const prov  = document.getElementById('buyer_province').value;
            if (!name || !phone || !addr || !prov) {
                alert("Vui lòng nhập đầy đủ thông tin giao hàng (Họ tên, SĐT, Tỉnh/TP, Địa chỉ)!");
                return false;
            }
            return true;
        }
        function showPay() {
            document.getElementById("text_pay_1").classList.remove("active");
            document.getElementById("text_pay_2").classList.remove("active");
            document.getElementById("text_pay_" + this.value).classList.add("active");
            document.getElementById('paymentId').value = this.value;
            document.getElementById('qrBox').style.display = (this.value === '1') ? 'block' : 'none';
        }

        document.addEventListener('DOMContentLoaded', () => {
            const sel = document.getElementById('shippingMethodSelect');
            const hidden = document.getElementById('shippingMethodHidden');
            if (sel && hidden) { sel.addEventListener('change', ()=> hidden.value = sel.value); hidden.value = sel.value; }

            // Autofill từ "Dùng thông tin tài khoản" (bao gồm province)
            const useProfile = document.getElementById('useProfileInfo');
            const nameEl = document.getElementById('buyer_name');
            const telEl = document.getElementById('buyer_tel');
            const addrEl = document.getElementById('buyer_address');
            const provEl = document.getElementById('buyer_province');

            function applyProfile(checked){
                if(!useProfile) return;
                const fullName = useProfile.dataset.fullname || '';
                const phone    = useProfile.dataset.phone || '';
                const address  = useProfile.dataset.address || '';
                const province = useProfile.dataset.province || '';
                if(checked){
                    if(fullName) nameEl.value = fullName;
                    if(phone)    telEl.value = phone;
                    if(address)  addrEl.value = address;
                    if(province && provEl) {
                        // Chỉ set nếu option tồn tại
                        const opt = Array.from(provEl.options).find(o => o.value === province);
                        if (opt) provEl.value = province;
                    }
                }
            }
            useProfile?.addEventListener('change', e => applyProfile(e.target.checked));
            // Tự động điền ngay khi vào trang nếu đang checked
            applyProfile(useProfile?.checked);

            if (document.querySelector('input[name="pay_method_display"][value="1"]:checked')) {
                document.getElementById('qrBox').style.display = 'block';
            }

            // Áp dụng mã coupon
            document.getElementById('btnApplyCoupon')?.addEventListener('click', (e) => {
                e.preventDefault();
                const code = (document.getElementById('couponCode')?.value || '').trim();
                if (!code) { alert('Vui lòng nhập mã coupon trước khi áp dụng.'); return; }
                const subtotal = '${cartSubtotalServer != null ? cartSubtotalServer : 0}';
                const form = document.createElement('form');
                form.method = 'post';
                form.action = '${pageContext.request.contextPath}/coupon/apply';
                addHidden(form, 'code', code);
                addHidden(form, 'subtotal', subtotal);
                addHidden(form, 'redirect', window.location.pathname + window.location.search);
                document.body.appendChild(form);
                form.submit();
            });

            // In/Tải báo giá: thêm provinceId trở lại
            function submitQuote(path) {
                const f = document.createElement('form');
                f.method='post';
                f.action='${pageContext.request.contextPath}'+path;
                f.target='_blank';
                addHidden(f,'receiverName', document.getElementById('buyer_name').value.trim());
                addHidden(f,'phone',        document.getElementById('buyer_tel').value.trim());
                addHidden(f,'address',      document.getElementById('buyer_address').value.trim());
                addHidden(f,'provinceId',   document.getElementById('buyer_province').value);
                addHidden(f,'shippingMethod', document.getElementById('shippingMethodHidden').value);
                addHidden(f,'paymentId',    document.getElementById('paymentId').value);
                addHidden(f,'note',         document.getElementById('note').value.trim());
                addHidden(f,'couponCode',   (document.getElementById('couponCode')?.value || '').trim());
                document.body.appendChild(f);
                f.submit();
                document.body.removeChild(f);
            }
            document.getElementById('btnPrintQuote')?.addEventListener('click', e => { e.preventDefault(); submitQuote('/invoice/print'); });
            document.getElementById('btnDownloadQuote')?.addEventListener('click', e => { e.preventDefault(); submitQuote('/quote/download'); });

            document.getElementById('btnCopyInfo')?.addEventListener('click', () => {
                const acc = (document.getElementById('bankAccountStatic')?.textContent || '').trim() || 'STK';
                navigator.clipboard.writeText(acc).then(()=>alert('Đã copy: '+acc)).catch(()=>alert('Không copy được.'));
            });
        });
    </script>
</head>
<body class="payment-page">
<%@ include file="partials/header.jsp" %>

<%
    java.util.Map<Integer, model.OrderDetail> cart
            = (java.util.Map<Integer, model.OrderDetail>) session.getAttribute("cart");
    double cartTotal = 0;
    if (cart != null) {
        for (model.OrderDetail it : cart.values()) {
            cartTotal += it.getSubtotal();
        }
    }
    request.setAttribute("cartTotal", cartTotal);
    model.User user = (model.User) session.getAttribute("user");
%>

<div class="payment-content">
    <form method="post" onsubmit="return check_field()" action="${pageContext.request.contextPath}/orders"
          class="content-main-cart" id="checkoutForm">
        <input type="hidden" name="action" value="checkout"/>
        <input type="hidden" name="paymentId" id="paymentId" value="1"/>
        <input type="hidden" name="shippingMethod" id="shippingMethodHidden" value="standard"/>

        <!-- LEFT -->
        <div class="content-left">
            <div class="title-header"><h2>Thông tin giao hàng</h2></div>

            <div class="profile-fill">
                <input type="checkbox"
                       id="useProfileInfo"
                       data-fullname="${user != null ? user.fullName : ''}"
                       data-phone="${user != null ? user.phoneNumber : ''}"
                       data-address="${user != null ? user.address : ''}"
                       data-province="${user != null && user.provinceId != null ? user.provinceId : ''}">
                <label for="useProfileInfo">Dùng thông tin tài khoản</label>
                <div class="pf-hint">Tự động điền nếu đã lưu trong hồ sơ</div>
            </div>

            <div class="content-input-form">
                <div class="item-input">
                    <label>Họ và tên<span class="required">*</span></label>
                    <input type="text" id="buyer_name" name="receiverName" required>
                </div>
                <div class="item-input">
                    <label>Số điện thoại<span class="required">*</span></label>
                    <input type="text" id="buyer_tel" name="phone" required>
                </div>

                <!-- Tỉnh/thành phố từ applicationScope.provinces -->
                <div class="item-input full">
                    <label>Tỉnh/thành phố<span class="required">*</span></label>
                    <div class="select-wrapper">
                        <select name="provinceId" id="buyer_province" class="form-control" required>
                            <option value="">Chọn tỉnh/thành phố</option>
                            <c:forEach var="p" items="${applicationScope.provinces}">
                                <option value="${p.provinceId}"
                                        <c:if test="${user != null && user.provinceId == p.provinceId}">selected</c:if>>
                                    ${p.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="item-input full">
                    <label>Địa chỉ<span class="required">*</span></label>
                    <textarea id="buyer_address" name="address" rows="2" required></textarea>
                </div>

                <div class="item-input">
                    <label>Phương thức giao hàng</label>
                    <div class="select-wrapper">
                        <select id="shippingMethodSelect" class="form-control">
                            <option value="standard" selected>Tiêu chuẩn (30.000₫)</option>
                            <option value="express">Nhanh (60.000₫)</option>
                            <option value="overnight">Hỏa tốc (120.000₫)</option>
                        </select>
                    </div>
                </div>

                <div class="item-input full">
                    <label>Ghi chú</label>
                    <textarea id="note" name="note" rows="2"></textarea>
                </div>

                <div class="item-input full">
                    <label>Mã giảm giá</label>
                    <div style="display:flex; gap:8px; align-items:center;">
                        <input type="text" id="couponCode" name="couponCode" placeholder="Nhập mã coupon (nếu có)" value="${couponPrefill}">
                        <button type="button" id="btnApplyCoupon">Áp dụng mã</button>
                    </div>

                    <c:if test="${couponValidPref}">
                        <div class="alert success">
                            Mã <strong><c:out value='${couponPrefill}'/></strong> đã áp dụng:
                            giảm <strong><fmt:formatNumber value="${couponDiscountPref}" type="number" groupingUsed="true"/>₫</strong>.
                        </div>
                    </c:if>
                    <c:if test="${not empty couponMessagePref && !couponValidPref}">
                        <div class="alert error"><c:out value='${couponMessagePref}'/></div>
                    </c:if>
                </div>
            </div>

            <div id="tax_box_click" class="form-group tax" role="button" aria-expanded="false" onclick="toggleTaxContainer()">
                <input type="checkbox" id="tax_checkbox">
                <label for="tax_checkbox">Xuất hóa đơn công ty</label>
            </div>
            <div id="js-tax-group" class="content-tax" aria-hidden="true">
                <input type="text" name="tax_name" placeholder="Tên công ty" value="${user.companyName}">
                <input type="text" name="tax_code" placeholder="Mã số thuế" value="${user.taxCode}">
                <input type="email" name="tax_email" placeholder="Email nhận hóa đơn" value="${user.taxEmail}">
            </div>

            <div class="box-pay-method">
                <label class="item-radio-custom">
                    <input type="radio" name="pay_method_display" value="1" checked onclick="showPay.call(this)">
                    <span>Thanh toán chuyển khoản</span>
                </label>
                <div class="content-info-pay active" id="text_pay_1">
                    <p><b>Ngân hàng ? - Chi nhánh ?</b></p>
                    <p>Số TK: <span id="bankAccountStatic">?</span></p>
                    <p>Tên TK: ?</p>
                    <p style="margin-top:6px;font-size:.85rem;color:#555;">Quét mã QR bên dưới để chuyển khoản nhanh.</p>
                </div>

                <div class="qr-box" id="qrBox">
                    <div class="qr-header"><h3>Mã QR chuyển khoản</h3></div>
                    <div class="qr-image-wrap">
                        <img id="qrImage" src="${pageContext.request.contextPath}/images/qr.jpg" alt="QR chuyển khoản" loading="lazy">
                    </div>
                    <div class="qr-ref">(Nếu không quét được, hãy nhập số tài khoản ở trên)</div>
                    <div class="qr-actions">
                        <button type="button" id="btnCopyInfo"><i class="fa-solid fa-copy"></i> Copy STK</button>
                    </div>
                </div>

                <label class="item-radio-custom">
                    <input type="radio" name="pay_method_display" value="2" onclick="showPay.call(this)">
                    <span>Thanh toán khi nhận hàng (COD)</span>
                </label>
                <div class="content-info-pay" id="text_pay_2">
                    <p>Thanh toán khi nhận hàng (COD).</p>
                </div>
            </div>
        </div>

        <!-- RIGHT -->
        <div class="content-right">
            <div class="background-white">
                <div class="title-row">
                    <h2 class="title">Thông tin giỏ hàng</h2>
                    <div class="header-actions">
                        <a href="#" id="btnDownloadQuote"><i class="fa-solid fa-download"></i> Tải báo giá</a>
                        <a href="#" id="btnPrintQuote"><i class="fa-solid fa-print"></i> In báo giá</a>
                    </div>
                </div>

                <div class="content-product">
                    <c:forEach var="item" items="${sessionScope.cart.values()}">
                        <div class="product-item">
                            <img src="${pageContext.request.contextPath}/${item.product.imagePath}" alt="thumb">
                            <div>
                                <div class="product-name">${item.product.name}</div>
                                <div class="product-details">
                                    <span class="product-quantity">x${item.quantity}</span>
                                    <span class="product-price"><fmt:formatNumber value="${item.price * item.quantity}" type="number" groupingUsed="true"/>₫</span>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="total-price">
                    <div class="item">
                        <span>Tạm tính</span>
                        <span><fmt:formatNumber value="${cartSubtotalServer != null ? cartSubtotalServer : cartTotal}" type="number" groupingUsed="true"/>₫</span>
                    </div>
                    <c:if test="${couponValidPref}">
                        <div class="item">
                            <span>Giảm theo coupon (<strong><c:out value='${couponPrefill}'/></strong>)</span>
                            <span>-<fmt:formatNumber value="${couponDiscountPref}" type="number" groupingUsed="true"/>₫</span>
                        </div>
                    </c:if>
                    <div class="item">
                        <span>Tổng tiền</span>
                        <span>
                            <fmt:formatNumber
                                    value="${(cartSubtotalServer != null ? cartSubtotalServer : cartTotal) - (couponValidPref && couponDiscountPref != null ? couponDiscountPref : 0)}"
                                    type="number" groupingUsed="true"/>₫
                        </span>
                    </div>
                    <div style="margin-top:6px;color:#6b7280;font-size:.9rem;">
                        Lưu ý: Phí vận chuyển/thuế sẽ được tính khi tạo đơn.
                    </div>
                </div>

                <button type="submit" class="button-send-cart"><i class="fa-solid fa-lock"></i> Xác nhận mua hàng</button>
                <div style="margin-top:12px;">
                    <img src="${pageContext.request.contextPath}/images/pay_cart.png" alt="pay" style="max-width:160px;">
                </div>

                <div class="info-policy">
                    <div class="item"><i class="fa-solid fa-credit-card"></i><span>Hỗ trợ trả góp 0%</span></div>
                    <div class="item"><i class="fa-solid fa-money-bill"></i><span>Hoàn tiền 200% nếu hàng giả</span></div>
                    <div class="item"><i class="fa-solid fa-bolt"></i><span>Giao hàng nhanh toàn quốc</span></div>
                    <div class="item"><i class="fa-solid fa-headset"></i><span>Hỗ trợ kỹ thuật 24/7</span></div>
                </div>
            </div>
        </div>
    </form>

    <div id="paySuccessModal" class="pay-modal" aria-hidden="true">
        <div class="pay-modal__dialog">
            <div class="pay-modal__icon">✅</div>
            <div class="pay-modal__title" id="payModalTitle">Thanh toán thành công</div>
            <div class="pay-modal__desc" id="payModalDesc">Cảm ơn bạn đã mua hàng!</div>
            <button type="button" class="pay-modal__btn" id="payModalBtn">Đóng</button>
        </div>
    </div>
</div>

<%@ include file="partials/footer.jsp" %>
</body>
</html>