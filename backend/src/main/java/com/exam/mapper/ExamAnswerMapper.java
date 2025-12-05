package com.exam.mapper;

import com.exam.entity.ExamAnswer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ExamAnswerMapper {
    List<ExamAnswer> selectByRecordId(@Param("recordId") Long recordId);
    ExamAnswer selectByRecordIdAndQuestionId(@Param("recordId") Long recordId, @Param("questionId") Long questionId);
    int insert(ExamAnswer examAnswer);
    int update(ExamAnswer examAnswer);
}
