package com.exam.service;

import com.exam.entity.Question;

import java.util.List;

/**
 * 题目服务接口
 */
public interface QuestionService {

    /**
     * 根据课程ID获取题目列表
     */
    List<Question> getQuestionsByCourseId(Long courseId, Integer type);

    /**
     * 添加题目
     */
    void addQuestion(Question question);

    /**
     * 删除题目
     */
    boolean deleteQuestion(Long id);

    /**
     * 根据ID获取题目详情
     */
    Question getQuestionById(Long id);

    /**
     * 更新题目
     */
    boolean updateQuestion(Question question);

}
