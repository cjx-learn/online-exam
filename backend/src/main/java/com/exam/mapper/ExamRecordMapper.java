package com.exam.mapper;

import com.exam.entity.ExamRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 考试记录 Mapper 接口
 */
@Mapper
public interface ExamRecordMapper {

    /**
     * 根据ID查询考试记录
     */
    ExamRecord selectById(@Param("id") Long id);

    /**
     * 根据学生ID和考试ID查询考试记录
     */
    ExamRecord selectByStudentIdAndExamId(@Param("studentId") Long studentId, @Param("examId") Long examId);

    /**
     * 根据学生ID查询所有考试记录
     */
    List<ExamRecord> selectByStudentId(@Param("studentId") Long studentId);

    /**
     * 根据考试ID查询所有考试记录
     */
    List<ExamRecord> selectByExamId(@Param("examId") Long examId);

    /**
     * 查询某个学生在某个班级的所有考试记录（包含考试信息）
     */
    List<ExamRecord> selectStudentExamRecordsByClassId(@Param("studentId") Long studentId, @Param("classId") Long classId);

    /**
     * 插入考试记录
     */
    int insert(ExamRecord examRecord);

    /**
     * 更新考试记录
     */
    int update(ExamRecord examRecord);

    /**
     * 删除考试记录
     */
    int deleteById(@Param("id") Long id);
}
