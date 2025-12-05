package com.exam.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 班级/课程实体类
 */
@Data
public class Class {
    /**
     * 班级ID
     */
    private Long id;
    
    /**
     * 课程ID（关联course表）
     */
    private Long courseId;
    
    /**
     * 班级/课程名称
     */
    private String name;
    
    /**
     * 课程代码
     */
    private String code;
    
    /**
     * 课程描述
     */
    private String description;
    
    /**
     * 封面图片URL
     */
    private String coverImage;
    
    /**
     * 学期（如：2025年秋冬学期）
     */
    private String semester;
    
    /**
     * 学年（如：2024-2025）
     */
    private String schoolYear;
    
    /**
     * 学分
     */
    private BigDecimal credit;
    
    /**
     * 邀请码（唯一）
     */
    private String inviteCode;
    
    /**
     * 主讲教师ID
     */
    private Long teacherId;
    
    /**
     * 助教ID列表（JSON数组）
     */
    private String assistantTeachers;
    
    /**
     * 最大学生数（null表示不限）
     */
    private Integer maxStudents;
    
    /**
     * AI功能启用：0-否 1-是
     */
    private Integer aiEnabled;
    
    /**
     * 状态：0-归档 1-进行中 2-未开始
     */
    private Integer status;
    
    /**
     * 创建时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    /**
     * 更新时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
    
    // ========== 扩展字段（非数据库字段） ==========
    
    /**
     * 主讲教师姓名
     */
    private String teacherName;
    
    /**
     * 当前学生数
     */
    private Integer studentCount;
}

