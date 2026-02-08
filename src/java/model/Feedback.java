package model;

import java.util.Date;

/**
 * Represents a feedback or contact message submitted by a user. Each feedback
 * entry contains the sender's name, email address, message content and the
 * timestamp when it was created. This model can be persisted in the database
 * via {@link dao.FeedbackDAO}.
 */
public class Feedback {
    private int id;
    private String name;
    private String email;
    private String message;
    private Date createdAt;

    public Feedback() {}

    public Feedback(String name, String email, String message) {
        this.name = name;
        this.email = email;
        this.message = message;
        this.createdAt = new Date();
    }

    // ===== Getters & Setters =====
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
}
