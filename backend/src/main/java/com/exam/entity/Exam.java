package com.exam.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 考试实体类
 */
@Data
public class Exam implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long classId;       // 所属班级ID(null表示公开考试)
    private String title;       // 考试标题
    private String description; // 考试描述
    private String coverImage;  // 封面图片
    private Integer type;       // 类型: 1-正式考试 2-模拟考试 3-练习
    private Integer duration;   // 考试时长(分钟)
    private BigDecimal totalScore; // 总分
    private BigDecimal passScore;  // 及格分
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime; // 开始时间
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;   // 结束时间
    private Integer allowRetake;   // 允许重考: 0-否 1-是
    private Integer maxAttempts;   // 最大考试次数
    private Integer shuffleQuestions; // 随机题序: 0-否 1-是
    private Integer shuffleOptions; // 随机选项: 0-否 1-是
    private Integer showAnswer;     // 显示答案: 0-否 1-是
    private Integer autoGrade;      // 自动批改: 0-否 1-是
    private Long creatorId;     // 创建人ID(教师ID)
    private Integer status;     // 状态: 0-草稿 1-已发布 2-进行中 3-已结束
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    // ========== 扩展字段（非数据库字段） ==========

    private String className; // 班级名称
    private String creatorName; // 创建人姓名
    private Integer questionCount; // 题目数量
    private Integer studentCount; // 参加学生数量

}
