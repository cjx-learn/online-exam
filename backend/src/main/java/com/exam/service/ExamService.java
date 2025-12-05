package com.exam.service;

import com.exam.entity.Exam;
import com.exam.entity.ExamRecord;
import com.exam.entity.Question;
import com.exam.entity.StudentClass;
import com.exam.mapper.ExamMapper;
import com.exam.mapper.ExamQuestionMapper;
import com.exam.mapper.ExamRecordMapper;
import com.exam.mapper.StudentClassMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Date;
import java.time.ZoneId;

/**
 * 考试服务类
 */
@Service
public class ExamService {

    @Autowired
    private ExamMapper examMapper;

    @Autowired
    private ExamQuestionMapper examQuestionMapper;

    @Autowired
    private StudentClassMapper studentClassMapper;

    @Autowired
    private ExamRecordMapper examRecordMapper;

    /**
     * 根据班级ID获取考试列表
     */
    public List<Exam> getExamsByClassId(Long classId) {
        return examMapper.selectByClassId(classId);
    }

    /**
     * 根据ID获取考试详情
     */
    public Exam getExamById(Long id) {
        return examMapper.selectById(id);
    }

    /**
     * 创建考试
     */
    public int createExam(Exam exam) {
        return examMapper.insert(exam);
    }

    /**
     * 创建考试并关联题目
     */
    @Transactional(rollbackFor = Exception.class)
    public Exam createExamWithQuestions(Exam exam, List<Long> questionIds) {
        // 1. 插入考试基本信息
        int result = examMapper.insert(exam);
        if (result <= 0) {
            throw new RuntimeException("创建考试失败");
        }

        // 2. 关联题目（写入每题分值到 exam_question.score）
        if (questionIds != null && !questionIds.isEmpty()) {
            for (Long questionId : questionIds) {
                int insertResult = examQuestionMapper.insertWithScore(exam.getId(), questionId);
                if (insertResult <= 0) {
                    throw new RuntimeException("关联题目失败：questionId=" + questionId);
                }
            }
        }

        // 3. 为该班级的在读学生预创建考试记录，保证学生端可见（幂等）
        if (exam.getClassId() != null) {
            List<StudentClass> members = studentClassMapper.selectByClassId(exam.getClassId());
            if (members != null && !members.isEmpty()) {
                Date now = new Date();
                for (StudentClass sc : members) {
                    // 仅为状态正常的学生创建记录（status: 1-正常）
                    if (sc.getStatus() != null && sc.getStatus() != 1) {
                        continue;
                    }
                    // 幂等：若已存在则跳过
                    ExamRecord existed = examRecordMapper.selectByStudentIdAndExamId(sc.getStudentId(), exam.getId());
                    if (existed == null) {
                        ExamRecord record = new ExamRecord();
                        record.setExamId(exam.getId());
                        record.setStudentId(sc.getStudentId());
                        record.setAttemptNumber(1);
                        // 确保start_time非空：优先使用考试计划开始时间，否则使用当前时间
                        Date plannedStart = (exam.getStartTime() != null)
                                ? Date.from(exam.getStartTime().atZone(ZoneId.systemDefault()).toInstant())
                                : new Date();
                        record.setStartTime(plannedStart);
                        record.setStatus(0); // 0-未开始/未提交
                        record.setCreateTime(now);
                        record.setUpdateTime(now);
                        examRecordMapper.insert(record);
                    }
                }
            }
        }

        // 4. 返回创建的考试（包含ID）
        return exam;
    }

    /**
     * 更新考试
     */
    public int updateExam(Exam exam) {
        return examMapper.update(exam);
    }

    /**
     * 删除考试
     */
    public int deleteExam(Long id) {
        return examMapper.deleteById(id);
    }

    /**
     * 获取考试的题目列表
     */
    public List<Question> getQuestionsByExamId(Long examId) {
        return examQuestionMapper.selectQuestionsByExamId(examId);
    }
}
