package com.exam.service.impl;

import com.exam.entity.Question;
import com.exam.mapper.QuestionMapper;
import com.exam.service.QuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 题目服务实现类
 */
@Service
public class QuestionServiceImpl implements QuestionService {

    @Autowired
    private QuestionMapper questionMapper;

    @Override
    public List<Question> getQuestionsByCourseId(Long courseId, Integer type) {
        return questionMapper.getQuestionsByCourseId(courseId, type);
    }

    @Override
    public void addQuestion(Question question) {
        question.setCreateTime(LocalDateTime.now());
        // TODO: 在实际应用中，这里应该从会话或安全上下文中获取当前登录教师的ID
        if (question.getCreatorId() == null) {
            question.setCreatorId(1L); // 临时默认值，确保能够插入数据
        }
        questionMapper.insert(question);
    }

    @Override
    public boolean deleteQuestion(Long id) {
        return questionMapper.deleteById(id) > 0;
    }

    @Override
    public Question getQuestionById(Long id) {
        return questionMapper.selectById(id);
    }

    @Override
    public boolean updateQuestion(Question question) {
        return questionMapper.update(question) > 0;
    }
}
