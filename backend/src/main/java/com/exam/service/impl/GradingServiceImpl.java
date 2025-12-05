package com.exam.service.impl;

import com.exam.dto.GradingListDTO;
import com.exam.dto.StudentAnswersDTO;
import com.exam.entity.*;
import com.exam.mapper.*;
import com.exam.service.GradingService;
import com.exam.service.ExamRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;
import java.math.BigDecimal;

/**
 * 批改服务实现
 */
@Service
public class GradingServiceImpl implements GradingService {

    @Autowired
    private ExamMapper examMapper;

    @Autowired
    private ExamRecordMapper examRecordMapper;

    @Autowired
    private ExamAnswerMapper examAnswerMapper;

    @Autowired
    private QuestionMapper questionMapper;

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private StudentClassMapper studentClassMapper;
    
    @Autowired
    private ExamQuestionMapper examQuestionMapper;
    
    @Autowired
    private ExamRecordService examRecordService;

    @Override
    public List<GradingListDTO> getGradingListByClass(Long classId) {
        // 获取该班级的所有考试
        List<Exam> exams = examMapper.selectByClassId(classId);
        
        // 获取该班级的所有在读学生
        List<StudentClass> studentClasses = studentClassMapper.selectByClassId(classId);
        List<Long> activeStudentIds = studentClasses.stream()
                .filter(sc -> sc.getStatus() != null && sc.getStatus() == 1)
                .map(StudentClass::getStudentId)
                .collect(Collectors.toList());
        
        if (activeStudentIds.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<GradingListDTO> result = new ArrayList<>();
        
        for (Exam exam : exams) {
            // 先自动提交所有过期未提交的考试记录
            examRecordService.autoSubmitExpiredExams(exam.getId());
            
            // 获取该考试的所有主观题
            List<Question> allQuestions = examQuestionMapper.selectQuestionsByExamId(exam.getId());
            List<Question> subjectiveQuestions = allQuestions.stream()
                    .filter(q -> q != null && (q.getType() == 4 || q.getType() == 5))
                    .collect(Collectors.toList());
            
            // 如果没有主观题，跳过
            if (subjectiveQuestions.isEmpty()) {
                continue;
            }
            
            // 获取该考试的所有考试记录
            List<ExamRecord> records = examRecordMapper.selectByExamId(exam.getId());
            Map<Long, ExamRecord> recordMap = records.stream()
                    .collect(Collectors.toMap(ExamRecord::getStudentId, r -> r, (r1, r2) -> r1));
            
            // 统计待批改和已批改的数量
            int pendingCount = 0;
            int gradedCount = 0;
            
            // 遍历所有在读学生
            for (Long studentId : activeStudentIds) {
                ExamRecord record = recordMap.get(studentId);
                
                // 如果学生没有考试记录，说明所有主观题都待批改
                if (record == null) {
                    pendingCount += subjectiveQuestions.size();
                    continue;
                }
                
                // 获取该考试记录的所有答案
                List<ExamAnswer> answers = examAnswerMapper.selectByRecordId(record.getId());
                Map<Long, ExamAnswer> answerMap = new HashMap<>();
                for (ExamAnswer ans : answers) {
                    if (ans != null && ans.getQuestionId() != null) {
                        answerMap.put(ans.getQuestionId(), ans);
                    }
                }
                
                // 遍历所有主观题，统计批改状态
                for (Question question : subjectiveQuestions) {
                    ExamAnswer answer = answerMap.get(question.getId());
                    
                    if (answer == null || answer.getScore() == null) {
                        // 未批改
                        pendingCount++;
                    } else {
                        // 已批改
                        gradedCount++;
                    }
                }
            }
            
            // 只有有主观题的考试才加入列表
            if (pendingCount > 0 || gradedCount > 0) {
                GradingListDTO dto = new GradingListDTO();
                dto.setId(exam.getId());
                dto.setExamName(exam.getTitle());
                dto.setTitle(exam.getTitle());
                dto.setStartTime(exam.getStartTime());
                dto.setEndTime(exam.getEndTime());
                dto.setPendingCount(pendingCount);
                dto.setGradedCount(gradedCount);
                result.add(dto);
            }
        }
        
        return result;
    }

    @Override
    public List<StudentAnswersDTO> getStudentAnswersByExamAndClass(Long examId, Long classId) {
        // 获取考试信息
        Exam exam = examMapper.selectById(examId);
        if (exam == null) {
            throw new RuntimeException("考试不存在");
        }
        
        // 检查考试是否已结束
        Date now = new Date();
        if (exam.getEndTime() != null) {
            Date endTime = Date.from(exam.getEndTime().atZone(java.time.ZoneId.systemDefault()).toInstant());
            if (endTime.after(now)) {
                throw new RuntimeException("考试尚未结束，暂时无法批改");
            }
        }
        
        // 先自动提交所有过期未提交的考试记录
        examRecordService.autoSubmitExpiredExams(examId);
        
        // 获取该班级的所有学生关联（只获取状态正常的学生）
        List<StudentClass> studentClasses = studentClassMapper.selectByClassId(classId);
        if (studentClasses == null || studentClasses.isEmpty()) {
            return new ArrayList<>();
        }
        
        // 获取该考试的所有考试记录
        List<ExamRecord> records = examRecordMapper.selectByExamId(examId);
        
        Map<Long, ExamRecord> recordMap = records.stream()
                .collect(Collectors.toMap(ExamRecord::getStudentId, r -> r));
        
        // 获取该考试的所有主观题
        List<Question> allQuestions = examQuestionMapper.selectQuestionsByExamId(examId);
        List<Question> subjectiveQuestions = allQuestions.stream()
                .filter(q -> q != null && (q.getType() == 4 || q.getType() == 5))
                .collect(Collectors.toList());
        
        // 如果没有主观题，直接返回空列表
        if (subjectiveQuestions.isEmpty()) {
            return new ArrayList<>();
        }
        
        List<StudentAnswersDTO> result = new ArrayList<>();
        
        for (StudentClass studentClass : studentClasses) {
            // 只处理状态正常的学生
            if (studentClass.getStatus() == null || studentClass.getStatus() != 1) {
                continue;
            }
            
            Long studentId = studentClass.getStudentId();
            ExamRecord record = recordMap.get(studentId);
            
            // 如果学生没有考试记录，为其创建一个（状态为0-未开始）
            if (record == null) {
                record = new ExamRecord();
                record.setExamId(examId);
                record.setStudentId(studentId);
                record.setAttemptNumber(1);
                // 使用考试计划开始时间或当前时间
                Date startTime = (exam.getStartTime() != null)
                        ? Date.from(exam.getStartTime().atZone(java.time.ZoneId.systemDefault()).toInstant())
                        : now;
                record.setStartTime(startTime);
                record.setStatus(0); // 0-未开始/未提交
                record.setCreateTime(now);
                record.setUpdateTime(now);
                examRecordMapper.insert(record);
                
                // 添加到 map 中
                recordMap.put(studentId, record);
            }
            
            // 获取学生信息
            Student student = studentMapper.selectById(studentId);
            if (student == null) {
                continue;
            }
            
            // 获取该考试记录的所有答案
            List<ExamAnswer> answers = examAnswerMapper.selectByRecordId(record.getId());
            Map<Long, ExamAnswer> answerMap = new HashMap<>();
            if (answers != null) {
                for (ExamAnswer ans : answers) {
                    if (ans != null && ans.getQuestionId() != null) {
                        answerMap.put(ans.getQuestionId(), ans);
                    }
                }
            }
            
            // 构建主观题列表（基于考试的主观题，而不是学生的答案）
            List<StudentAnswersDTO.SubjectiveQuestionDTO> subjectiveQuestionsDTO = new ArrayList<>();
            
            for (Question question : subjectiveQuestions) {
                ExamAnswer answer = answerMap.get(question.getId());
                
                StudentAnswersDTO.SubjectiveQuestionDTO qDto = new StudentAnswersDTO.SubjectiveQuestionDTO();
                qDto.setQuestionId(question.getId());
                qDto.setContent(question.getContent());
                qDto.setScore(question.getScore() != null ? question.getScore().intValue() : 0);
                qDto.setMaxScore(question.getScore() != null ? question.getScore().intValue() : 0);
                qDto.setStandardAnswer(question.getAnswer());
                
                // 如果学生有答案记录，使用答案记录的数据；否则为空
                if (answer != null) {
                    qDto.setUserAnswer(answer.getUserAnswer());
                    qDto.setCurrentScore(answer.getScore());
                    qDto.setComment(answer.getTeacherComment());
                } else {
                    qDto.setUserAnswer(null); // 未作答
                    qDto.setCurrentScore(null);
                    qDto.setComment(null);
                }
                
                subjectiveQuestionsDTO.add(qDto);
            }
            
            // 构建学生答题信息
            StudentAnswersDTO dto = new StudentAnswersDTO();
            dto.setId(student.getId());
            dto.setStudentName(student.getRealName());
            dto.setStudentNo(student.getStudentNo());
            dto.setExamRecordId(record.getId());
            dto.setSubmitTime(record.getSubmitTime());
            
            // 判断是否已批改：所有主观题都有得分则为已批改
            boolean isGraded = subjectiveQuestionsDTO.stream()
                    .allMatch(q -> q.getCurrentScore() != null);
            dto.setIsGraded(isGraded);
            
            dto.setSubjectiveQuestions(subjectiveQuestionsDTO);
            result.add(dto);
        }
        
        return result;
    }

    @Override
    public boolean saveGradingResult(Long examRecordId, List<GradingResultDTO> gradingResults) {
        if (examRecordId == null || gradingResults == null || gradingResults.isEmpty()) {
            return false;
        }
        
        Date gradedTime = new Date();
        
        for (GradingResultDTO result : gradingResults) {
            if (result.getQuestionId() == null) {
                continue;
            }
            
            // 查找对应的答案记录
            ExamAnswer answer = examAnswerMapper.selectByRecordIdAndQuestionId(
                    examRecordId, result.getQuestionId());
            
            if (answer != null) {
                // 更新已有答案记录
                answer.setScore(result.getScore() != null ? result.getScore() : BigDecimal.ZERO);
                answer.setTeacherComment(result.getComment());
                answer.setGradedTime(gradedTime);
                examAnswerMapper.update(answer);
            } else {
                // 如果答案记录不存在，创建一个（学生未作答的情况）
                answer = new ExamAnswer();
                answer.setExamRecordId(examRecordId);
                answer.setQuestionId(result.getQuestionId());
                answer.setUserAnswer(null); // 未作答
                answer.setScore(result.getScore() != null ? result.getScore() : BigDecimal.ZERO);
                answer.setTeacherComment(result.getComment());
                answer.setIsCorrect(null);
                answer.setGradedTime(gradedTime);
                answer.setCreateTime(gradedTime);
                answer.setUpdateTime(gradedTime);
                examAnswerMapper.insert(answer);
            }
        }
        
        // 检查该考试记录的所有主观题是否都已批改，并计算主观题总分
        ExamRecord examRecord = examRecordMapper.selectById(examRecordId);
        if (examRecord != null) {
            // 获取该考试的所有题目
            List<Question> allQuestions = examQuestionMapper.selectQuestionsByExamId(examRecord.getExamId());
            
            // 获取该考试记录的所有答案
            List<ExamAnswer> allAnswers = examAnswerMapper.selectByRecordId(examRecordId);
            Map<Long, ExamAnswer> answerMap = new HashMap<>();
            for (ExamAnswer ans : allAnswers) {
                if (ans != null && ans.getQuestionId() != null) {
                    answerMap.put(ans.getQuestionId(), ans);
                }
            }
            
            boolean allSubjectiveGraded = true;
            BigDecimal subjectiveScoreSum = BigDecimal.ZERO;
            
            // 基于考试的主观题来检查是否都已批改
            for (Question question : allQuestions) {
                // 只检查主观题（type 4, 5）
                if (question != null && (question.getType() == 4 || question.getType() == 5)) {
                    ExamAnswer answer = answerMap.get(question.getId());
                    
                    if (answer == null || answer.getScore() == null) {
                        // 该主观题尚未批改
                        allSubjectiveGraded = false;
                        break;
                    } else {
                        // 累加主观题得分
                        subjectiveScoreSum = subjectiveScoreSum.add(answer.getScore());
                    }
                }
            }
            
            // 如果所有主观题都已批改，更新主观题总分和状态
            if (allSubjectiveGraded) {
                examRecord.setSubjectiveScore(subjectiveScoreSum);
                
                // 计算总分（客观题得分 + 主观题得分）
                BigDecimal totalScore = subjectiveScoreSum;
                if (examRecord.getObjectiveScore() != null) {
                    totalScore = totalScore.add(examRecord.getObjectiveScore());
                }
                examRecord.setTotalScore(totalScore);
                
                examRecord.setStatus(2);
                examRecord.setUpdateTime(new Date());
                examRecordMapper.update(examRecord);
            }
        }
        
        return true;
    }
}
