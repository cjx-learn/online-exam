package com.exam.mapper;

import com.exam.entity.Exam;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 考试Mapper接口
 */
@Mapper
public interface ExamMapper {

    /**
     * 根据ID查询考试
     */
    Exam selectById(@Param("id") Long id);

    /**
     * 根据班级ID查询考试列表
     */
    List<Exam> selectByClassId(@Param("classId") Long classId);

    /**
     * 插入考试
     */
    int insert(Exam exam);

    /**
     * 更新考试
     */
    int update(Exam exam);

    /**
     * 删除考试
     */
    int deleteById(@Param("id") Long id);
}
