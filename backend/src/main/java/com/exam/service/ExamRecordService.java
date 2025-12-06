package com.exam.service;

import com.exam.entity.ExamRecord;
import java.util.List;

/**
 * 考试记录 服务接口
 */
public interface ExamRecordService {

    /**
     * 根据ID查询考试记录
     */
    ExamRecord getExamRecordById(Long id);

    /**
     * 根据学生ID和考试ID查询考试记录
     */
    ExamRecord getExamRecordByStudentIdAndExamId(Long studentId, Long examId);

    /**
     * 根据学生ID查询所有考试记录
     */
    List<ExamRecord> getExamRecordsByStudentId(Long studentId);

    /**
     * 根据考试ID查询所有考试记录
     */
    List<ExamRecord> getExamRecordsByExamId(Long examId);

    /**
     * 查询某个学生在某个班级的所有考试记录（包含考试信息）
     */
    List<ExamRecord> getStudentExamRecordsByClassId(Long studentId, Long classId);

    /**
     * 创建考试记录
     */
    int createExamRecord(ExamRecord examRecord);

    /**
     * 更新考试记录
     */
    int updateExamRecord(ExamRecord examRecord);

    /**
     * 删除考试记录
     */
    int deleteExamRecord(Long id);

    /**
     * 学生开始考试
     * 如果已存在未完成的记录，则更新其开始时间；否则创建新记录
     * @param studentId 学生ID
     * @param examId 考试ID
     * @return 更新或创建后的考试记录
     */
    ExamRecord startExam(Long studentId, Long examId);

    /**
     * 学生提交考试
     * @param examRecordId 考试记录ID
     * @return 更新后的考试记录
     */
    ExamRecord submitExam(Long examRecordId);
    
    /**
     * 自动提交已过期的考试
     * 将所有状态为0（未提交）且考试时间已结束的记录自动提交
     * @param examId 考试ID
     * @return 自动提交的记录数量
     */
    int autoSubmitExpiredExams(Long examId);

    /**
     * 获取学生的学情分析数据
     * @param recordId 考试记录ID
     * @return 包含知识点掌握度、班级排名、平均分对比等数据的Map
     */
    java.util.Map<String, Object> getStudentAnalysis(Long recordId);
}
