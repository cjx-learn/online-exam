package com.exam.mapper;

import com.exam.entity.Question;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 题目Mapper接口
 */
@Mapper
public interface QuestionMapper {

    /**
     * 根据ID查询题目
     */
    Question selectById(@Param("id") Long id);

    /**
     * 根据课程ID获取题目列表
     */
    List<Question> getQuestionsByCourseId(@Param("courseId") Long courseId, @Param("type") Integer type);

    /**
     * 插入题目
     */
    int insert(Question question);

    /**
     * 更新题目
     */
    int update(Question question);

    /**
     * 删除题目
     */
    int deleteById(@Param("id") Long id);
}
