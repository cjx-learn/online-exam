package com.exam.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 批改列表DTO
 */
@Data
public class GradingListDTO {
    private Long id;              // 考试ID
    private String examName;      // 考试名称
    private String title;         // 考试标题
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;       // 考试开始时间
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;         // 考试结束时间
    
    private Integer pendingCount; // 待批改数量
    private Integer gradedCount;  // 已批改数量
}
