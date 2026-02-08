package model;

import java.sql.Timestamp;

public class ProductReviewReply {
    private int replyId;
    private int productReviewId;
    private int userId;
    private String content;
    private Timestamp createdAt;

    // Optional view fields
    private String userName;
    // NEW: role của người trả lời (users.role: 'user' | 'admin')
    private String userRole;

    public int getReplyId() {
        return replyId;
    }
    public void setReplyId(int replyId) {
        this.replyId = replyId;
    }
    public int getProductReviewId() {
        return productReviewId;
    }
    public void setProductReviewId(int productReviewId) {
        this.productReviewId = productReviewId;
    }
    public int getUserId() {
        return userId;
    }
    public void setUserId(int userId) {
        this.userId = userId;
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
    public String getUserName() {
        return userName;
    }
    public void setUserName(String userName) {
        this.userName = userName;
    }
    public String getUserRole() {
        return userRole;
    }
    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }
}