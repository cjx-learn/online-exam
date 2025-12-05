package com.exam.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 创建考试请求DTO
 */
@Data
public class ExamCreateRequest implements Serializable {

    private static final long serialVersionUID = 1L;

    private Long classId;       // 所属班级ID
    private String title;       // 考试标题
    private String description; // 考试描述
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

    // 题目ID列表
    private List<Long> questionIds;
}
