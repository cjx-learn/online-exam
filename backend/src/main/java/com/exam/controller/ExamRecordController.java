package com.exam.controller;

import com.exam.common.Result;
import com.exam.entity.ExamRecord;
import com.exam.service.ExamRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 考试记录控制器
 */
@RestController
@RequestMapping("/examRecord")
@CrossOrigin
public class ExamRecordController {

    @Autowired
    private ExamRecordService examRecordService;

    /**
     * 根据考试记录ID获取单条考试记录
     */
    @GetMapping("/{id}")
    public Result getExamRecordById(@PathVariable Long id) {
        try {
            ExamRecord examRecord = examRecordService.getExamRecordById(id);
            if (examRecord != null) {
                return Result.success(examRecord);
            } else {
                return Result.error("考试记录不存在");
            }
        } catch (Exception e) {
            return Result.error("获取考试记录失败：" + e.getMessage());
        }
    }

    /**
     * 查询某个学生在某个班级的所有考试记录（包含考试信息）
     * @param studentId 学生ID
     * @param classId 班级ID
     * @return 考试记录列表
     */
    @GetMapping("/student/{studentId}/class/{classId}")
    public Result getStudentExamRecordsByClassId(@PathVariable Long studentId, @PathVariable Long classId) {
        try {
            List<ExamRecord> examRecords = examRecordService.getStudentExamRecordsByClassId(studentId, classId);
            return Result.success(examRecords);
        } catch (Exception e) {
            return Result.error("获取学生考试记录失败：" + e.getMessage());
        }
    }

    /**
     * 根据考试ID查询所有考试记录（用于查看成绩）
     */
    @GetMapping("/exam/{examId}")
    public Result getExamRecordsByExamId(@PathVariable Long examId) {
        try {
            List<ExamRecord> examRecords = examRecordService.getExamRecordsByExamId(examId);
            return Result.success(examRecords);
        } catch (Exception e) {
            return Result.error("获取考试记录失败：" + e.getMessage());
        }
    }

    /**
     * 学生开始考试
     * 如果已存在未完成的记录，则更新其开始时间；否则创建新记录
     * @param studentId 学生ID
     * @param examId 考试ID
     * @return 更新或创建后的考试记录
     */
    @PostMapping("/start")
    public Result startExam(@RequestParam Long studentId, @RequestParam Long examId) {
        try {
            ExamRecord examRecord = examRecordService.startExam(studentId, examId);
            if (examRecord != null) {
                return Result.success("开始考试成功", examRecord);
            } else {
                return Result.error("开始考试失败");
            }
        } catch (Exception e) {
            return Result.error("开始考试失败：" + e.getMessage());
        }
    }

    /**
     * 学生提交考试
     * @param examRecordId 考试记录ID
     * @return 更新后的考试记录
     */
    @PostMapping("/submit")
    public Result submitExam(@RequestParam Long examRecordId) {
        try {
            ExamRecord examRecord = examRecordService.submitExam(examRecordId);
            if (examRecord != null) {
                return Result.success("提交考试成功", examRecord);
            } else {
                return Result.error("提交考试失败，考试记录不存在或状态不正确");
            }
        } catch (Exception e) {
            return Result.error("提交考试失败：" + e.getMessage());
        }
    }
}
