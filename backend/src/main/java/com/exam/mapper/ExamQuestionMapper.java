package com.exam.mapper;

import com.exam.entity.Question;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 考试题目关系Mapper接口
 */
@Mapper
public interface ExamQuestionMapper {

    /**
     * 插入考试-题目关系
     */
    @Insert("INSERT INTO exam_question (exam_id, question_id) VALUES (#{examId}, #{questionId})")
    int insert(@Param("examId") Long examId, @Param("questionId") Long questionId);

    /**
     * 插入考试-题目关系（带分值）。从 question 表读取题目分值，若为空则按 0 处理。
     */
    @Insert("INSERT INTO exam_question (exam_id, question_id, score) " +
            "SELECT #{examId}, #{questionId}, COALESCE(q.score, 0) FROM question q WHERE q.id = #{questionId}")
    int insertWithScore(@Param("examId") Long examId, @Param("questionId") Long questionId);

    @Select("SELECT q.id AS id, q.course_id AS courseId, q.type AS type, q.content AS content, q.options AS options, q.answer AS answer, COALESCE(eq.score, q.score) AS score, q.category AS category, q.difficulty AS difficulty, q.creator_id AS creatorId, q.create_time AS createTime FROM exam_question eq JOIN question q ON eq.question_id = q.id WHERE eq.exam_id = #{examId} ORDER BY q.type ASC, eq.id ASC")
    List<Question> selectQuestionsByExamId(@Param("examId") Long examId);
}
