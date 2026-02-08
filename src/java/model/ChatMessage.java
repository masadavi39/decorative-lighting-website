package model;

public class ChatMessage {
    private String userId;   // ID của người chat (User ID hoặc Session ID)
    private String sender;   // "USER" hoặc "ADMIN"
    private String content;  // Nội dung chat

    public ChatMessage(String userId, String sender, String content) {
        this.userId = userId;
        this.sender = sender;
        this.content = content;
    }

    // Getters và Setters
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}