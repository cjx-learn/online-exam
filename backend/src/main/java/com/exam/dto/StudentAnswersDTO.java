package com.exam.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;
import java.util.List;
import java.math.BigDecimal;

/**
 * 学生答案DTO（用于批改）
 */
@Data
public class StudentAnswersDTO {
    private Long id;                      // 学生ID
    private String studentName;           // 学生姓名
    private String studentNo;             // 学号
    private Long examRecordId;            // 考试记录ID
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date submitTime;              // 提交时间
    
    private Boolean isGraded;             // 是否已批改
    private List<SubjectiveQuestionDTO> subjectiveQuestions; // 主观题列表

    /**
     * 主观题DTO
     */
    @Data
    public static class SubjectiveQuestionDTO {
        private Long questionId;          // 题目ID
        private String content;           // 题干
        private Integer score;            // 满分
        private Integer maxScore;         // 满分（同score）
        private String standardAnswer;    // 标准答案
        private String userAnswer;        // 学生答案
        private BigDecimal currentScore;  // 当前得分
        private String comment;           // 批改意见
    }
}
