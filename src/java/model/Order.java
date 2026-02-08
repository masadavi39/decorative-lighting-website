package model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Model Order khớp với bảng `orders` (Full v3). totalPrice đã bao gồm: subtotal
 * + shipping_fee + tax - discount_amount (đúng như DB).
 */
public class Order {

    private int orderId;
    private int userId;
    private int paymentId;

    private String receiverName;   // orders.receiver_name
    private String phone;          // orders.phone
    private int provinceId;        // orders.province_id
    private String address;        // orders.address

    private String shippingMethod; // orders.shipping_method
    private double shippingFee;    // orders.shipping_fee

    private String invoiceCompany; // orders.invoice_company
    private String taxCode;        // orders.tax_code
    private String taxEmail;       // orders.tax_email
    private String note;           // orders.note

    private double tax;            // orders.tax
    private double discountAmount; // orders.discount_amount
    private String couponCode;     // orders.coupon_code
    private double totalPrice;     // orders.total_price

    private String status;         // orders.status
    private String paymentStatus;  // orders.payment_status
    private String trackingNumber; // orders.tracking_number

    private Date createdAt;        // orders.created_at
    private Date updatedAt;        // orders.updated_at

    private List<OrderDetail> orderDetails = new ArrayList<>();

    public Order() {
    }

    // Getters & Setters
    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public int getProvinceId() {
        return provinceId;
    }

    public void setProvinceId(int provinceId) {
        this.provinceId = provinceId;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getShippingMethod() {
        return shippingMethod;
    }

    public void setShippingMethod(String shippingMethod) {
        this.shippingMethod = shippingMethod;
    }

    public double getShippingFee() {
        return shippingFee;
    }

    public void setShippingFee(double shippingFee) {
        this.shippingFee = shippingFee;
    }

    public String getInvoiceCompany() {
        return invoiceCompany;
    }

    public void setInvoiceCompany(String invoiceCompany) {
        this.invoiceCompany = invoiceCompany;
    }

    public String getTaxCode() {
        return taxCode;
    }

    public void setTaxCode(String taxCode) {
        this.taxCode = taxCode;
    }

    public String getTaxEmail() {
        return taxEmail;
    }

    public void setTaxEmail(String taxEmail) {
        this.taxEmail = taxEmail;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public double getTax() {
        return tax;
    }

    public void setTax(double tax) {
        this.tax = tax;
    }

    public double getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(double discountAmount) {
        this.discountAmount = discountAmount;
    }

    public String getCouponCode() {
        return couponCode;
    }

    public void setCouponCode(String couponCode) {
        this.couponCode = couponCode;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getTrackingNumber() {
        return trackingNumber;
    }

    public void setTrackingNumber(String trackingNumber) {
        this.trackingNumber = trackingNumber;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<OrderDetail> getOrderDetails() {
        return orderDetails;
    }

    public void setOrderDetails(List<OrderDetail> orderDetails) {
        this.orderDetails = orderDetails;
    }

    // Convenience: tính subtotal từ danh sách chi tiết (không gồm ship/tax/discount)
    public double getSubtotal() {
        if (orderDetails == null) {
            return 0.0;
        }
        return orderDetails.stream().mapToDouble(OrderDetail::getSubtotal).sum();
    }
}
