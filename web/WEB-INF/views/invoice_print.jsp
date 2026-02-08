<%@page contentType="text/html; charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
    String receiver = (String) request.getAttribute("inv_receiver");
    String phone    = (String) request.getAttribute("inv_phone");
    String addr     = (String) request.getAttribute("inv_address");
    String note     = (String) request.getAttribute("inv_note");
    String coupon   = (String) request.getAttribute("inv_coupon");
    String method   = (String) request.getAttribute("inv_method");
    double subtotal = (Double) request.getAttribute("inv_subtotal");
    double tax      = (Double) request.getAttribute("inv_tax");
    double ship     = (Double) request.getAttribute("inv_ship");
    double discount = request.getAttribute("inv_discount") != null ? (Double) request.getAttribute("inv_discount") : 0d;
    double total    = (Double) request.getAttribute("inv_total");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Invoice Preview</title>
<style>
    @page { size: A4; margin: 22mm 18mm; }
    body { font-family: 'Segoe UI', Arial, sans-serif; color:#111; }
    .invoice-wrap { max-width:900px; margin:0 auto; }
    h1 { font-size:22px; margin:0 0 4px; }
    .top-meta { margin-bottom:30px; }
    .grid-info { display:flex; justify-content:space-between; font-size:13px; margin-bottom:20px; }
    .section-block { width:48%; }
    .section-block h4 { margin:0 0 6px; font-size:14px; }
    table { width:100%; border-collapse:collapse; font-size:13px; margin-top:10px; }
    th, td { border:1px solid #444; padding:6px 8px; text-align:left; }
    th { background:#f2f2f2; }
    .summary { width:320px; float:right; margin-top:20px; border:1px solid #444; }
    .summary table { border:none; width:100%; }
    .summary td { border:none; padding:6px 10px; }
    .summary tr.total td { font-weight:700; background:#f2f2f2; }
    .signature { margin-top:70px; text-align:right; font-style:italic; }
    .terms { font-size:12px; margin-top:40px; }
    .print-actions { position:fixed; top:10px; right:10px; background:#fff; border:1px solid #ddd; padding:8px 12px; border-radius:6px; box-shadow:0 2px 8px rgba(0,0,0,.15); }
    .print-actions button { margin-right:6px; cursor:pointer; }
    @media print { .print-actions { display:none; } body { margin:0; } }
</style>
</head>
<body>
<div class="print-actions">
    <button onclick="window.print()">In (Ctrl+P)</button>
    <button onclick="window.close()">Đóng</button>
</div>

<div class="invoice-wrap">
    <h1><strong><c:out value="${inv_receiver != null && inv_receiver != '' ? inv_receiver : 'Khách hàng'}"/></strong></h1>
    <div class="top-meta" style="font-size:13px; line-height:1.4;">
        <div><c:out value="${inv_address != null && inv_address != '' ? inv_address : 'Địa chỉ chưa cung cấp'}"/></div>
        <div><c:out value="${inv_phone != null && inv_phone != '' ? inv_phone : 'SĐT chưa cung cấp'}"/></div>
    </div>

    <div class="grid-info">
        <div class="section-block">
            <h4>Bill To</h4>
            <div><c:out value="${inv_receiver}"/></div>
            <div><c:out value="${inv_address}"/></div>
            <div><c:out value="${inv_phone}"/></div>
        </div>
        <div class="section-block">
            <h4>Ship Method</h4>
            <div>
                <c:choose>
                    <c:when test="${inv_method == 'express'}">Giao nhanh (Express)</c:when>
                    <c:when test="${inv_method == 'overnight'}">Hỏa tốc (Overnight)</c:when>
                    <c:otherwise>Tiêu chuẩn (Standard)</c:otherwise>
                </c:choose>
            </div>
            <h4 style="margin-top:14px;">Thông tin đơn</h4>
            <div>Ngày: <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()) %></div>
            <div>Mẫu: Quote Preview</div>
            <c:if test="${not empty inv_coupon}">
                <div>Mã giảm giá: <span style="background:#2563eb;color:#fff;border-radius:4px;padding:2px 6px;"><c:out value="${inv_coupon}"/></span></div>
            </c:if>
        </div>
    </div>

    <table>
        <thead>
        <tr><th style="width:60px;">QTY</th><th>MÔ TẢ</th><th style="width:110px;">ĐƠN GIÁ</th><th style="width:110px;">THÀNH TIỀN</th></tr>
        </thead>
        <tbody>
        <c:forEach var="it" items="${inv_items}">
            <tr>
                <td><c:out value="${it.quantity}"/></td>
                <td>
                    <c:choose>
                        <c:when test="${not empty it.product and not empty it.product.name}"><c:out value="${it.product.name}"/></c:when>
                        <c:otherwise>Sản phẩm #<c:out value="${it.productId}"/></c:otherwise>
                    </c:choose>
                </td>
                <td><c:out value="${it.price}"/>₫</td>
                <td><c:out value="${it.quantity * it.price}"/>₫</td>
            </tr>
        </c:forEach>
        </tbody>
    </table>

    <div class="summary">
        <table>
            <tr><td>Tạm tính</td><td style="text-align:right;"><c:out value="${inv_subtotal}"/>₫</td></tr>
            <tr><td>Thuế (10%)</td><td style="text-align:right;"><c:out value="${inv_tax}"/>₫</td></tr>
            <tr><td>Phí vận chuyển</td><td style="text-align:right;"><c:out value="${inv_ship}"/>₫</td></tr>
            <c:if test="${inv_discount != null && inv_discount > 0}">
                <tr><td>Giảm giá</td><td style="text-align:right;">-<c:out value="${inv_discount}"/>₫</td></tr>
            </c:if>
            <tr class="total"><td><strong>TỔNG CỘNG</strong></td><td style="text-align:right;"><strong><c:out value="${inv_total}"/>₫</strong></td></tr>
        </table>
    </div>
    <div style="clear:both;"></div>

    <div class="terms" style="margin-top:40px;">
        <strong>Terms & Conditions</strong><br>
        Thanh toán trong vòng 15 ngày. Hỗ trợ bảo hành theo chính sách công ty.
        <c:if test="${not empty inv_note}">
            <br><strong>Ghi chú:</strong> <em><c:out value="${inv_note}"/></em>
        </c:if>
    </div>
</div>

<script>
window.addEventListener('load', ()=>{ setTimeout(()=>window.print(), 300); });
</script>
</body>
</html>