package com.exam.controller;

import com.exam.common.Result;
import com.exam.dto.GradingListDTO;
import com.exam.dto.StudentAnswersDTO;
import com.exam.service.GradingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.math.BigDecimal;

/**
 * 批改控制器
 */
@RestController
@RequestMapping("/grading")
@CrossOrigin
public class GradingController {

    @Autowired
    private GradingService gradingService;

    /**
     * 获取班级的待批改考试列表
     */
    @GetMapping("/class/{classId}")
    public Result getGradingListByClass(@PathVariable Long classId) {
        try {
            List<GradingListDTO> list = gradingService.getGradingListByClass(classId);
            return Result.success(list);
        } catch (Exception e) {
            return Result.error("获取批改列表失败：" + e.getMessage());
        }
    }

    /**
     * 获取某个考试在某个班级的学生答案列表（用于批改）
     */
    @GetMapping("/exam/{examId}/class/{classId}")
    public Result getStudentAnswersByExamAndClass(
            @PathVariable Long examId,
            @PathVariable Long classId) {
        try {
            List<StudentAnswersDTO> list = gradingService.getStudentAnswersByExamAndClass(examId, classId);
            return Result.success(list);
        } catch (Exception e) {
            return Result.error("获取学生答案失败：" + e.getMessage());
        }
    }

    /**
     * 保存批改结果
     */
    @PostMapping("/save")
    public Result saveGradingResult(@RequestBody Map<String, Object> request) {
        try {
            Long examRecordId = ((Number) request.get("examRecordId")).longValue();
            List<Map<String, Object>> answers = (List<Map<String, Object>>) request.get("answers");
            
            List<GradingService.GradingResultDTO> gradingResults = new java.util.ArrayList<>();
            for (Map<String, Object> answer : answers) {
                GradingService.GradingResultDTO dto = new GradingService.GradingResultDTO();
                dto.setQuestionId(((Number) answer.get("questionId")).longValue());
                
                Object scoreObj = answer.get("score");
                if (scoreObj != null) {
                    dto.setScore(new BigDecimal(scoreObj.toString()));
                }
                
                dto.setComment((String) answer.get("comment"));
                gradingResults.add(dto);
            }
            
            boolean success = gradingService.saveGradingResult(examRecordId, gradingResults);
            if (success) {
                return Result.success("批改保存成功");
            } else {
                return Result.error("批改保存失败");
            }
        } catch (Exception e) {
            return Result.error("保存批改结果失败：" + e.getMessage());
        }
    }
}
