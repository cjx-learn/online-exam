package com.exam.controller;

import com.exam.common.Result;
import com.exam.dto.ExamCreateRequest;
import com.exam.entity.Exam;
import com.exam.entity.Question;
import com.exam.service.ExamService;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 考试控制器
 */
@RestController
@RequestMapping("/exam")
@CrossOrigin
public class ExamController {

    @Autowired
    private ExamService examService;

    /**
     * 根据班级ID获取考试列表
     */
    @GetMapping("/class/{classId}")
    public Result getExamsByClassId(@PathVariable Long classId) {
        try {
            List<Exam> exams = examService.getExamsByClassId(classId);
            return Result.success(exams);
        } catch (Exception e) {
            return Result.error("获取考试列表失败：" + e.getMessage());
        }
    }

    /**
     * 根据ID获取考试详情
     */
    @GetMapping("/{id}")
    public Result getExamById(@PathVariable Long id) {
        try {
            Exam exam = examService.getExamById(id);
            if (exam == null) {
                return Result.error("考试不存在");
            }
            return Result.success(exam);
        } catch (Exception e) {
            return Result.error("获取考试详情失败：" + e.getMessage());
        }
    }

    /**
     * 创建考试
     */
    @PostMapping
    public Result createExam(@RequestBody ExamCreateRequest request) {
        try {
            // 将DTO转换为Exam实体
            Exam exam = new Exam();
            BeanUtils.copyProperties(request, exam);
            
            // 调用service创建考试（包括题目关联）
            Exam createdExam = examService.createExamWithQuestions(exam, request.getQuestionIds());
            
            if (createdExam != null && createdExam.getId() != null) {
                // 返回新创建的考试
                return Result.success(createdExam);
            } else {
                return Result.error("创建考试失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("创建考试失败：" + e.getMessage());
        }
    }

    /**
     * 更新考试
     */
    @PutMapping
    public Result updateExam(@RequestBody Exam exam) {
        try {
            int affectedRows = examService.updateExam(exam);
            if (affectedRows > 0) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败，考试不存在或数据未改变");
            }
        } catch (Exception e) {
            return Result.error("更新考试失败：" + e.getMessage());
        }
    }

    /**
     * 发布考试（更新状态为已发布）
     */
    @PutMapping("/publish/{id}")
    public Result publishExam(@PathVariable Long id) {
        try {
            Exam exam = examService.getExamById(id);
            if (exam == null) {
                return Result.error("考试不存在");
            }
            
            // 更新状态为已发布
            exam.setStatus(1);
            int affectedRows = examService.updateExam(exam);
            
            if (affectedRows > 0) {
                return Result.success("试卷发布成功");
            } else {
                return Result.error("发布失败");
            }
        } catch (Exception e) {
            return Result.error("发布考试失败：" + e.getMessage());
        }
    }

    /**
     * 删除考试
     */
    @DeleteMapping("/{id}")
    public Result deleteExam(@PathVariable Long id) {
        try {
            int affectedRows = examService.deleteExam(id);
            if (affectedRows > 0) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败，考试不存在");
            }
        } catch (Exception e) {
            return Result.error("删除考试失败：" + e.getMessage());
        }
    }

    /**
     * 获取指定考试的题目列表
     */
    @GetMapping("/{id}/questions")
    public Result getExamQuestions(@PathVariable Long id) {
        try {
            List<Question> questions = examService.getQuestionsByExamId(id);
            return Result.success(questions);
        } catch (Exception e) {
            return Result.error("获取试卷题目失败：" + e.getMessage());
        }
    }
}
