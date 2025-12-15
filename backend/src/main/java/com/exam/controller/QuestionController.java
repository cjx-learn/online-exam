package com.exam.controller;

import com.exam.common.Result;
import com.exam.entity.Question;
import com.exam.service.QuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 题目（题库）控制器
 */
@RestController
@RequestMapping("/question")
@CrossOrigin
public class QuestionController {

    @Autowired
    private QuestionService questionService;

    /**
     * 根据课程ID获取题目列表
     */
    @GetMapping("/course/{courseId}")
    public Result getQuestionsByCourseId(@PathVariable Long courseId, @RequestParam(required = false) Integer type) {
        try {
            List<Question> questions = questionService.getQuestionsByCourseId(courseId, type);
            return Result.success(questions);
        } catch (Exception e) {
            return Result.error("获取题目列表失败：" + e.getMessage());
        }
    }

    /**
     * 添加题目
     */
    @PostMapping
    public Result addQuestion(@RequestBody Question question) {
        try {
            questionService.addQuestion(question);
            return Result.success("添加题目成功");
        } catch (Exception e) {
            return Result.error("添加题目失败：" + e.getMessage());
        }
    }

    /**
     * 删除题目
     */
    @DeleteMapping("/{id}")
    public Result deleteQuestion(@PathVariable Long id) {
        try {
            boolean success = questionService.deleteQuestion(id);
            if (success) {
                return Result.success("删除题目成功");
            } else {
                return Result.error("删除题目失败");
            }
        } catch (Exception e) {
            return Result.error("删除题目失败：" + e.getMessage());
        }
    }

    /**
     * 根据ID获取题目详情
     */
    @GetMapping("/{id}")
    public Result getQuestionById(@PathVariable Long id) {
        try {
            Question question = questionService.getQuestionById(id);
            if (question == null) {
                return Result.error("题目不存在");
            }
            return Result.success(question);
        } catch (Exception e) {
            return Result.error("获取题目详情失败：" + e.getMessage());
        }
    }

    /**
     * 更新题目
     */
    @PutMapping
    public Result updateQuestion(@RequestBody Question question) {
        try {
            if (question.getId() == null) {
                return Result.error("题目ID不能为空");
            }
            boolean success = questionService.updateQuestion(question);
            if (success) {
                return Result.success("更新题目成功");
            } else {
                return Result.error("更新题目失败");
            }
        } catch (Exception e) {
            return Result.error("更新题目失败：" + e.getMessage());
        }
    }
}
