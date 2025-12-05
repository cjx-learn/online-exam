package com.exam.service;

import com.exam.dto.GradingListDTO;
import com.exam.dto.StudentAnswersDTO;

import java.util.List;

/**
 * 批改服务接口
 */
public interface GradingService {
    /**
     * 获取班级的待批改考试列表
     */
    List<GradingListDTO> getGradingListByClass(Long classId);

    /**
     * 获取某个考试在某个班级的学生答案列表（用于批改）
     */
    List<StudentAnswersDTO> getStudentAnswersByExamAndClass(Long examId, Long classId);

    /**
     * 保存批改结果
     */
    boolean saveGradingResult(Long examRecordId, List<GradingResultDTO> gradingResults);

    /**
     * 批改结果DTO
     */
    class GradingResultDTO {
        private Long questionId;
        private java.math.BigDecimal score;
        private String comment;

        public Long getQuestionId() {
            return questionId;
        }

        public void setQuestionId(Long questionId) {
            this.questionId = questionId;
        }

        public java.math.BigDecimal getScore() {
            return score;
        }

        public void setScore(java.math.BigDecimal score) {
            this.score = score;
        }

        public String getComment() {
            return comment;
        }

        public void setComment(String comment) {
            this.comment = comment;
        }
    }
}
