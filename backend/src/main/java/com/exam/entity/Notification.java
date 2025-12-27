package com.exam.entity;

import java.time.LocalDateTime;

public class Notification {
    private Long id;
    private Long userId;
    private Integer userRole;  // 0-学生 1-教师 2-管理员
    private String type;       // exam_publish/grade_release/grading_complete/system
    private String title;
    private String content;
    private Long relatedId;
    private String relatedType; // exam/class/grade
    private Integer isRead;    // 0-未读 1-已读
    private LocalDateTime createTime;
    private LocalDateTime readTime;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public Integer getUserRole() { return userRole; }
    public void setUserRole(Integer userRole) { this.userRole = userRole; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Long getRelatedId() { return relatedId; }
    public void setRelatedId(Long relatedId) { this.relatedId = relatedId; }

    public String getRelatedType() { return relatedType; }
    public void setRelatedType(String relatedType) { this.relatedType = relatedType; }

    public Integer getIsRead() { return isRead; }
    public void setIsRead(Integer isRead) { this.isRead = isRead; }

    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }

    public LocalDateTime getReadTime() { return readTime; }
    public void setReadTime(LocalDateTime readTime) { this.readTime = readTime; }
}
