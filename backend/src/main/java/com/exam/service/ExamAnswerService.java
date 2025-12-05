package com.exam.service;

import com.exam.dto.SaveAnswersRequest;
import com.exam.entity.ExamAnswer;

import java.util.List;

public interface ExamAnswerService {
    List<ExamAnswer> getAnswersByRecordId(Long recordId);
    int saveAnswers(Long recordId, List<SaveAnswersRequest.AnswerItem> answers);
}
