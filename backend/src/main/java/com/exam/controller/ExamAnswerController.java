package com.exam.controller;

import com.exam.common.Result;
import com.exam.dto.SaveAnswersRequest;
import com.exam.entity.ExamAnswer;
import com.exam.service.ExamAnswerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/examRecord")
@CrossOrigin
public class ExamAnswerController {

    @Autowired
    private ExamAnswerService examAnswerService;

    /**
     * 获取某次考试记录的所有作答
     */
    @GetMapping("/{recordId}/answers")
    public Result getAnswers(@PathVariable Long recordId) {
        try {
            List<ExamAnswer> list = examAnswerService.getAnswersByRecordId(recordId);
            return Result.success(list);
        } catch (Exception e) {
            return Result.error("获取作答失败：" + e.getMessage());
        }
    }

    /**
     * 批量保存或更新作答（幂等：同一(questionId, recordId)覆盖更新）
     */
    @PostMapping("/{recordId}/answers")
    public Result saveAnswers(@PathVariable Long recordId, @RequestBody SaveAnswersRequest request) {
        try {
            int cnt = examAnswerService.saveAnswers(recordId, request != null ? request.getAnswers() : null);
            return Result.success("保存成功", cnt);
        } catch (Exception e) {
            return Result.error("保存作答失败：" + e.getMessage());
        }
    }
}
