package com.exam.service.impl;

import com.exam.dto.SaveAnswersRequest;
import com.exam.entity.ExamAnswer;
import com.exam.mapper.ExamAnswerMapper;
import com.exam.service.ExamAnswerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

@Service
public class ExamAnswerServiceImpl implements ExamAnswerService {

    @Autowired
    private ExamAnswerMapper examAnswerMapper;

    @Override
    public List<ExamAnswer> getAnswersByRecordId(Long recordId) {
        return examAnswerMapper.selectByRecordId(recordId);
    }

    @Override
    public int saveAnswers(Long recordId, List<SaveAnswersRequest.AnswerItem> answers) {
        if (recordId == null || answers == null || answers.isEmpty()) return 0;
        int affected = 0;
        for (SaveAnswersRequest.AnswerItem item : answers) {
            if (item == null || item.getQuestionId() == null) continue;
            String value = item.getAnswerValue();
            ExamAnswer existed = examAnswerMapper.selectByRecordIdAndQuestionId(recordId, item.getQuestionId());
            if (existed == null) {
                ExamAnswer ea = new ExamAnswer();
                ea.setExamRecordId(recordId);
                ea.setQuestionId(item.getQuestionId());
                ea.setUserAnswer(value);
                ea.setCreateTime(new Date());
                ea.setUpdateTime(new Date());
                affected += examAnswerMapper.insert(ea);
            } else {
                existed.setUserAnswer(value);
                existed.setUpdateTime(new Date());
                affected += examAnswerMapper.update(existed);
            }
        }
        return affected;
    }
}
