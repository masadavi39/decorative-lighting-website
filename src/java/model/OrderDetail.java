package model;

import java.util.Date;

/**
*
*/
public class OrderDetail {
    private int orderDetailId; // order_detail_id
    private int orderId;       // order_id
    private int productId;     // product_id
    private int quantity;      // quantity
    private double price;      // price

    private Date createdAt;    // created_at
    private Date updatedAt;    // updated_at

    private Product product;   // optional: để hiển thị tên ảnh, v.v.

    public OrderDetail() {}

    public OrderDetail(int orderDetailId, int orderId, int productId, int quantity, double price) {
        this.orderDetailId = orderDetailId;
        this.orderId = orderId;
        this.productId = productId;
        this.quantity = quantity;
        this.price = price;
    }

    // Getters & Setters
    public int getOrderDetailId() { return orderDetailId; }
    public void setOrderDetailId(int orderDetailId) { this.orderDetailId = orderDetailId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public double getSubtotal() { return price * quantity; }
}