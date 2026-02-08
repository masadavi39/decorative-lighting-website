package model;

import java.sql.Timestamp;
import java.util.List;

public class ProductReview {
    private int productReviewId;
    private int productId;
    private int userId;
    private int rating; // 1-5
    private String title;
    private String content;
    private Timestamp createdAt;
    private boolean approved;

    // Optional view fields
    private String userName;
    // NEW: tên sản phẩm lấy từ products.name (JOIN p.name AS product_name)
    private String productName;

    private List<ProductReviewReply> replies;

    public int getProductReviewId() {
        return productReviewId;
    }
    public void setProductReviewId(int productReviewId) {
        this.productReviewId = productReviewId;
    }
    public int getProductId() {
        return productId;
    }
    public void setProductId(int productId) {
        this.productId = productId;
    }
    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
    }
    public int getRating() {
        return rating;
    }
    public void setRating(int rating) {
        this.rating = rating;
    }
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
    public String getContent() {
        return content;
    }
    public void setContent(String content) {
        this.content = content;
    }
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    public boolean isApproved() {
        return approved;
    }
    public void setApproved(boolean approved) {
        this.approved = approved;
    }

    public String getUserName() {
        return userName;
    }
    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getProductName() {
        return productName;
    }
    public void setProductName(String productName) {
        this.productName = productName;
    }

    public List<ProductReviewReply> getReplies() {
        return replies;
    }
    public void setReplies(List<ProductReviewReply> replies) {
        this.replies = replies;
    }
}