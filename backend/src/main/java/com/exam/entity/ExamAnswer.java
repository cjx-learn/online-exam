package com.exam.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * 学生作答记录实体
 */
@Data
public class ExamAnswer implements Serializable {
    private Long id;
    private Long examRecordId; // 考试记录ID
    private Long questionId;   // 题目ID
    private String userAnswer; // 作答值，使用JSON字符串存储（单选/判断: "A"；多选: "[\"A\",\"C\"]"；主观题: 纯文本）

    // 评分相关字段（可为空）
    private Integer isCorrect; // 0/1，客观题可用
    private BigDecimal score;  // 得分
    private String teacherComment; // 评语
    private Long gradedBy; // 批改老师ID

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date gradedTime; // 批改时间

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    private Date updateTime;
}
