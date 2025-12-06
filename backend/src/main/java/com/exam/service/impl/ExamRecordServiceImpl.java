package com.exam.service.impl;

import com.exam.entity.Exam;
import com.exam.entity.ExamAnswer;
import com.exam.entity.ExamRecord;
import com.exam.entity.Question;
import com.exam.mapper.ExamAnswerMapper;
import com.exam.mapper.ExamMapper;
import com.exam.mapper.ExamQuestionMapper;
import com.exam.mapper.ExamRecordMapper;
import com.exam.mapper.UserMapper;
import com.exam.service.ExamRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 考试记录 服务实现类
 */
@Service
public class ExamRecordServiceImpl implements ExamRecordService {

    @Autowired
    private ExamRecordMapper examRecordMapper;
    @Autowired
    private ExamMapper examMapper;
    @Autowired
    private ExamQuestionMapper examQuestionMapper;
    @Autowired
    private ExamAnswerMapper examAnswerMapper;
    @Autowired
    private UserMapper userMapper;

    @Override
    public ExamRecord getExamRecordById(Long id) {
        return examRecordMapper.selectById(id);
    }

    @Override
    public ExamRecord getExamRecordByStudentIdAndExamId(Long studentId, Long examId) {
        return examRecordMapper.selectByStudentIdAndExamId(studentId, examId);
    }

    @Override
    public List<ExamRecord> getExamRecordsByStudentId(Long studentId) {
        return examRecordMapper.selectByStudentId(studentId);
    }

    @Override
    public List<ExamRecord> getExamRecordsByExamId(Long examId) {
        return examRecordMapper.selectByExamId(examId);
    }

    @Override
    public List<ExamRecord> getStudentExamRecordsByClassId(Long studentId, Long classId) {
        // 先获取该班级的所有考试
        List<Exam> exams = examMapper.selectByClassId(classId);
        
        // 对每个考试自动提交过期记录
        if (exams != null) {
            for (Exam exam : exams) {
                if (exam != null && exam.getId() != null) {
                    autoSubmitExpiredExams(exam.getId());
                }
            }
        }
        
        return examRecordMapper.selectStudentExamRecordsByClassId(studentId, classId);
    }

    @Override
    public int createExamRecord(ExamRecord examRecord) {
        examRecord.setCreateTime(new Date());
        examRecord.setUpdateTime(new Date());
        return examRecordMapper.insert(examRecord);
    }

    @Override
    public int updateExamRecord(ExamRecord examRecord) {
        examRecord.setUpdateTime(new Date());
        return examRecordMapper.update(examRecord);
    }

    @Override
    public int deleteExamRecord(Long id) {
        return examRecordMapper.deleteById(id);
    }

    @Override
    public ExamRecord startExam(Long studentId, Long examId) {
        // 尝试查找学生已存在的未完成考试记录
        ExamRecord existingRecord = examRecordMapper.selectByStudentIdAndExamId(studentId, examId);

        if (existingRecord != null && existingRecord.getStatus() == 0) {
            // 如果存在未完成的记录，更新其开始时间
            existingRecord.setStartTime(new Date());
            existingRecord.setUpdateTime(new Date());
            examRecordMapper.update(existingRecord);
            return existingRecord;
        } else if (existingRecord == null) {
            // 如果不存在记录，创建新的考试记录
            ExamRecord newRecord = new ExamRecord();
            newRecord.setStudentId(studentId);
            newRecord.setExamId(examId);
            newRecord.setAttemptNumber(1); // 默认为第一次尝试
            newRecord.setStartTime(new Date());
            newRecord.setStatus(0); // 0-未提交/进行中
            // 其他字段保持默认或NULL
            newRecord.setCreateTime(new Date());
            newRecord.setUpdateTime(new Date());
            examRecordMapper.insert(newRecord);
            return newRecord;
        } else {
            // 存在记录但状态不是未完成 (例如已提交、已批改)，不进行操作，返回现有记录
            // TODO: 这里可以根据需求返回错误或者返回一个新的考试记录（如果允许多次尝试）
            return existingRecord;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ExamRecord submitExam(Long examRecordId) {
        ExamRecord examRecord = examRecordMapper.selectById(examRecordId);
        // 只有状态为 0（未开始/未提交）的记录才能提交并触发批改
        if (examRecord == null || examRecord.getStatus() == null || examRecord.getStatus() != 0) {
            return null;
        }

        Date now = new Date();
        examRecord.setSubmitTime(now);

        // 根据考试配置决定是否自动批改客观题
        Exam exam = examMapper.selectById(examRecord.getExamId());
        if (exam != null && (exam.getAutoGrade() == null || exam.getAutoGrade() == 1)) {
            autoGradeObjectiveQuestions(exam, examRecord, now);
        } else {
            // 不启用自动批改时，仅标记为已提交待批改
            examRecord.setStatus(1); // 1-已提交待批改
        }

        examRecord.setUpdateTime(now);
        examRecordMapper.update(examRecord);
        return examRecord;
    }

    /**
     * 自动批改客观题（单选、多选、判断），并更新考试记录分数与状态。
     */
    private void autoGradeObjectiveQuestions(Exam exam, ExamRecord examRecord, Date now) {
        // 1. 查询本场考试的所有试题（包含每题分值）
        List<Question> questions = examQuestionMapper.selectQuestionsByExamId(examRecord.getExamId());
        if (questions == null || questions.isEmpty()) {
            // 无题目时直接标记为已提交待批改
            examRecord.setStatus(1);
            return;
        }

        // 2. 查询本次考试记录下学生的所有作答
        List<ExamAnswer> answers = examAnswerMapper.selectByRecordId(examRecord.getId());
        Map<Long, ExamAnswer> answerMap = new HashMap<>();
        if (answers != null) {
            for (ExamAnswer ea : answers) {
                if (ea != null && ea.getQuestionId() != null) {
                    answerMap.put(ea.getQuestionId(), ea);
                }
            }
        }

        BigDecimal objectiveScore = BigDecimal.ZERO;
        boolean hasObjective = false;
        boolean hasSubjective = false;

        for (Question q : questions) {
            if (q == null || q.getId() == null || q.getType() == null) {
                continue;
            }
            int type = q.getType();
            double qScoreDouble = q.getScore() != null ? q.getScore() : 0.0;
            BigDecimal fullScore = BigDecimal.valueOf(qScoreDouble);

            // 客观题：1-单选，2-多选，3-判断
            if (type == 1 || type == 2 || type == 3) {
                hasObjective = true;
                ExamAnswer ea = answerMap.get(q.getId());
                String userAnswer = ea != null ? ea.getUserAnswer() : null;
                boolean correct = isObjectiveAnswerCorrect(q.getAnswer(), userAnswer);
                BigDecimal awarded = correct ? fullScore : BigDecimal.ZERO;
                objectiveScore = objectiveScore.add(awarded);

                if (ea != null) {
                    ea.setIsCorrect(correct ? 1 : 0);
                    ea.setScore(awarded);
                    ea.setGradedTime(now);
                    // 自动批改不设置 gradedBy，由人工批改主观题时再填充
                    examAnswerMapper.update(ea);
                }
            }
            // 主观题：4-填空，5-简答（暂不自动评分）
            else if (type == 4 || type == 5) {
                hasSubjective = true;
            }
        }

        // 3. 汇总分数并更新考试记录
        if (hasObjective) {
            examRecord.setObjectiveScore(objectiveScore);
        }

        BigDecimal subjectiveScore = examRecord.getSubjectiveScore();
        BigDecimal totalScore = null;
        if (subjectiveScore != null) {
            totalScore = objectiveScore.add(subjectiveScore);
        } else if (hasObjective) {
            totalScore = objectiveScore;
        }
        if (totalScore != null) {
            examRecord.setTotalScore(totalScore);
        }

        // 及格与否（依赖考试表的 passScore）
        if (exam.getPassScore() != null && totalScore != null) {
            examRecord.setPassStatus(totalScore.compareTo(exam.getPassScore()) >= 0 ? 1 : 0);
        }

        // 没有主观题时，可直接视为已全部批改；否则保留为待批改状态，交由老师批改主观题
        if (!hasSubjective) {
            examRecord.setStatus(2); // 2-已批改
        } else {
            examRecord.setStatus(1); // 1-已提交待批改
        }
    }

    /**
     * 比较客观题答案是否正确：支持单选、多选、判断题；
     * - 多选和单选统一按“集合完全相等”判断；
     * - 判断题支持 A/B 与 T/F 或 正确/错误 的映射；
     * - 忽略顺序、大小写和多余空格；
     * - 支持 "A,B" 或 JSON 数组字符串 "[\"A\",\"B\"]" 两种格式。
     */
    private boolean isObjectiveAnswerCorrect(String correctAnswer, String userAnswerRaw) {
        Set<String> correctSet = parseAnswerToSet(correctAnswer);
        Set<String> userSet = parseAnswerToSet(userAnswerRaw);
        
        // 对于判断题，需要统一答案格式
        correctSet = normalizeJudgmentAnswers(correctSet);
        userSet = normalizeJudgmentAnswers(userSet);
        
        return !correctSet.isEmpty() && correctSet.equals(userSet);
    }
    
    /**
     * 规范化判断题答案：将 A、T、正确 统一为 T；将 B、F、错误 统一为 F
     */
    private Set<String> normalizeJudgmentAnswers(Set<String> answers) {
        Set<String> normalized = new HashSet<>();
        for (String answer : answers) {
            String upper = answer.toUpperCase();
            if ("A".equals(upper) || "T".equals(upper) || "TRUE".equals(upper) || "正确".equals(answer)) {
                normalized.add("T");
            } else if ("B".equals(upper) || "F".equals(upper) || "FALSE".equals(upper) || "错误".equals(answer)) {
                normalized.add("F");
            } else {
                // 非判断题答案，保持原样
                normalized.add(upper);
            }
        }
        return normalized;
    }

    private Set<String> parseAnswerToSet(String value) {
        Set<String> set = new HashSet<>();
        if (value == null) {
            return set;
        }
        String normalized = value.trim();
        if (normalized.isEmpty()) {
            return set;
        }

        // 如果是 JSON 数组字符串，先去掉前后的方括号
        if (normalized.startsWith("[") && normalized.endsWith("]")) {
            normalized = normalized.substring(1, normalized.length() - 1);
        }

        // 去掉引号并统一分隔符
        normalized = normalized.replace("\"", "").replace("'", "");
        normalized = normalized.replace('，', ',');

        String[] parts = normalized.split(",");
        for (String part : parts) {
            String key = part.trim();
            if (!key.isEmpty()) {
                set.add(key.toUpperCase());
            }
        }
        return set;
    }
    
    @Override
    public int autoSubmitExpiredExams(Long examId) {
        if (examId == null) {
            return 0;
        }
        
        // 获取考试信息
        Exam exam = examMapper.selectById(examId);
        if (exam == null || exam.getEndTime() == null) {
            return 0;
        }
        
        // 检查考试是否已结束
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        if (now.isBefore(exam.getEndTime())) {
            // 考试尚未结束，不自动提交
            return 0;
        }
        
        // 获取该考试的所有记录
        List<ExamRecord> records = examRecordMapper.selectByExamId(examId);
        if (records == null || records.isEmpty()) {
            return 0;
        }
        
        int count = 0;
        Date submitTime = new Date();
        
        // 遍历所有记录，自动提交状态为0（未提交）的记录
        for (ExamRecord record : records) {
            if (record.getStatus() != null && record.getStatus() == 0) {
                // 自动提交该记录
                record.setSubmitTime(submitTime);
                
                // 自动批改客观题
                if (exam.getAutoGrade() == null || exam.getAutoGrade() == 1) {
                    autoGradeObjectiveQuestions(exam, record, submitTime);
                } else {
                    // 不启用自动批改时，仅标记为已提交待批改
                    record.setStatus(1);
                }
                
                record.setUpdateTime(submitTime);
                examRecordMapper.update(record);
                count++;
            }
        }
        
        return count;
    }

    @Override
    public Map<String, Object> getStudentAnalysis(Long recordId) {
        Map<String, Object> result = new HashMap<>();
        
        // 1. 获取学生的考试记录
        ExamRecord studentRecord = examRecordMapper.selectById(recordId);
        if (studentRecord == null) {
            return null;
        }
        
        // 2. 获取考试信息
        Exam exam = examMapper.selectById(studentRecord.getExamId());
        if (exam == null) {
            return null;
        }
        
        // 3. 获取同一考试的所有学生记录（用于排名和平均分计算）
        List<ExamRecord> allRecords = examRecordMapper.selectByExamId(studentRecord.getExamId());
        
        // 4. 计算班级排名
        int rank = 1;
        BigDecimal studentScore = studentRecord.getTotalScore() != null ? studentRecord.getTotalScore() : BigDecimal.ZERO;
        if (allRecords != null) {
            for (ExamRecord record : allRecords) {
                BigDecimal score = record.getTotalScore() != null ? record.getTotalScore() : BigDecimal.ZERO;
                if (score.compareTo(studentScore) > 0) {
                    rank++;
                }
            }
        }
        
        // 5. 计算班级平均分
        BigDecimal totalSum = BigDecimal.ZERO;
        int validCount = 0;
        if (allRecords != null) {
            for (ExamRecord record : allRecords) {
                if (record.getTotalScore() != null) {
                    totalSum = totalSum.add(record.getTotalScore());
                    validCount++;
                }
            }
        }
        BigDecimal classAverage = validCount > 0 ? totalSum.divide(BigDecimal.valueOf(validCount), 2, BigDecimal.ROUND_HALF_UP) : BigDecimal.ZERO;
        
        // 6. 计算知识点掌握度（基于题目分类）
        List<Question> questions = examQuestionMapper.selectQuestionsByExamId(studentRecord.getExamId());
        List<ExamAnswer> answers = examAnswerMapper.selectByRecordId(recordId);
        Map<Long, ExamAnswer> answerMap = new HashMap<>();
        if (answers != null) {
            for (ExamAnswer ea : answers) {
                if (ea != null && ea.getQuestionId() != null) {
                    answerMap.put(ea.getQuestionId(), ea);
                }
            }
        }
        
        // 按分类统计得分
        Map<String, BigDecimal> categoryScores = new HashMap<>();
        Map<String, BigDecimal> categoryTotals = new HashMap<>();
        
        if (questions != null) {
            for (Question q : questions) {
                if (q == null) continue;
                String category = q.getCategory() != null && !q.getCategory().trim().isEmpty() ? q.getCategory() : "其他";
                BigDecimal fullScore = BigDecimal.valueOf(q.getScore() != null ? q.getScore() : 0.0);
                
                // 累加该分类的总分
                categoryTotals.put(category, categoryTotals.getOrDefault(category, BigDecimal.ZERO).add(fullScore));
                
                // 累加学生在该分类的得分
                ExamAnswer ea = answerMap.get(q.getId());
                BigDecimal studentAnswerScore = ea != null && ea.getScore() != null ? ea.getScore() : BigDecimal.ZERO;
                categoryScores.put(category, categoryScores.getOrDefault(category, BigDecimal.ZERO).add(studentAnswerScore));
            }
        }
        
        // 计算每个分类的掌握度百分比
        List<Map<String, Object>> knowledgePoints = new java.util.ArrayList<>();
        for (String category : categoryTotals.keySet()) {
            BigDecimal total = categoryTotals.get(category);
            BigDecimal score = categoryScores.getOrDefault(category, BigDecimal.ZERO);
            double percentage = 0;
            if (total.compareTo(BigDecimal.ZERO) > 0) {
                percentage = score.divide(total, 4, BigDecimal.ROUND_HALF_UP).multiply(BigDecimal.valueOf(100)).doubleValue();
            }
            
            Map<String, Object> point = new HashMap<>();
            point.put("name", category);
            point.put("score", score);
            point.put("total", total);
            point.put("percentage", Math.round(percentage * 10) / 10.0); // 保留1位小数
            knowledgePoints.add(point);
        }
        
        // 7. 获取学生信息
        String studentName = "未知";
        String studentIdStr = "未知";
        try {
            if (studentRecord.getStudentId() != null) {
                com.exam.entity.User student = userMapper.selectById(studentRecord.getStudentId());
                if (student != null) {
                    studentName = (student.getRealName() != null && !student.getRealName().isEmpty()) 
                                  ? student.getRealName() 
                                  : (student.getUsername() != null ? student.getUsername() : "未知");
                    studentIdStr = student.getId() != null ? student.getId().toString() : "未知";
                }
            }
        } catch (Exception e) {
            System.err.println("获取学生信息失败: " + e.getMessage());
        }
        
        // 8. 组装返回数据
        result.put("studentScore", studentScore);
        result.put("classAverage", classAverage);
        result.put("rank", rank);
        result.put("totalStudents", allRecords != null ? allRecords.size() : 0);
        result.put("knowledgePoints", knowledgePoints);
        result.put("examTitle", exam.getTitle());
        result.put("passScore", exam.getPassScore());
        result.put("objectiveScore", studentRecord.getObjectiveScore());
        result.put("subjectiveScore", studentRecord.getSubjectiveScore());
        result.put("studentName", studentName);
        result.put("studentId", studentIdStr);
        result.put("courseName", exam.getTitle()); // 使用考试标题作为课程名称
        
        return result;
    }
}
