package model;

import java.util.Map;

public class ChatMessageDTO {
    private int id;
    private String userId;
    private String sender;   // USER / ADMIN
    private String type;     // text / products / system
    private String content;
    private Map<String, Object> meta; // products list, quick replies, etc.
    private String intent;
    private String sentiment;
    private String createdAt;

    public ChatMessageDTO() {}

    public ChatMessageDTO(int id, String userId, String sender, String type, String content,
                          Map<String, Object> meta, String intent, String sentiment, String createdAt) {
        this.id = id;
        this.userId = userId;
        this.sender = sender;
        this.type = type;
        this.content = content;
        this.meta = meta;
        this.intent = intent;
        this.sentiment = sentiment;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getSender() { return sender; }
    public void setSender(String sender) { this.sender = sender; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Map<String, Object> getMeta() { return meta; }
    public void setMeta(Map<String, Object> meta) { this.meta = meta; }

    public String getIntent() { return intent; }
    public void setIntent(String intent) { this.intent = intent; }

    public String getSentiment() { return sentiment; }
    public void setSentiment(String sentiment) { this.sentiment = sentiment; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}