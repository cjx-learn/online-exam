package com.exam.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 考试记录实体类
 */
@Data
public class ExamRecord implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id; // 考试记录ID
    private Long examId; // 考试ID
    private Long studentId; // 学生ID
    private Integer attemptNumber; // 学生此次考试是第几次尝试
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date startTime; // 学生开始考试时间
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date submitTime; // 学生提交考试时间
    
    private Integer duration; // 实际考试时长 (分钟)
    private BigDecimal totalScore; // 总得分
    private BigDecimal objectiveScore; // 客观题得分
    private BigDecimal subjectiveScore; // 主观题得分
    private Integer passStatus; // 是否及格: 0-否, 1-是 (这里使用 Integer 以匹配 tinyint)
    private String ipAddress; // IP地址
    private Integer status; // 考试记录状态: 0-未开始/未提交, 1-已提交待批改, 2-已批改
    // private String teacherComment; // 教师评语 -- 数据库中没有此字段，暂时移除

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime; // 记录创建时间
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime; // 记录更新时间

    // 扩展字段 (非数据库字段，用于前端展示)
    private String examTitle; // 考试标题
    private String examDescription; // 考试描述
    private String studentName; // 学生姓名
    private String studentNo; // 学生学号

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date examStartTime; // 考试的开始时间

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date examEndTime; // 考试的结束时间
    
    private Boolean isGraded; // 是否已批改（用于主观题）
}
