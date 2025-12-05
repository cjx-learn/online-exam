package com.exam.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 题目实体类
 */
@Data
public class Question {
    private Long id;
    private Long courseId; // 课程ID，关联到 Course
    private Integer type; // 题型：1-单选，2-多选，3-判断，4-填空，5-简答
    private String content; // 题干
    private String options; // 选项 (JSON格式，仅适用于选择题)
    private String answer; // 答案
    private Double score; // 分值
    private String category; // 知识点
    private Integer difficulty; // 难度：1-简单，2-中等，3-困难
    private Long creatorId; // 创建人ID
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime; // 创建时间

    // 辅助字段，前端展示用
    private String courseName; // 课程名称
}
