package com.exam.mapper;

import com.exam.entity.Teacher;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 教师 Mapper 接口
 */
@Mapper
public interface TeacherMapper {

    /**
     * 根据ID查询教师
     */
    Teacher selectById(@Param("id") Long id);

    /**
     * 根据用户名查询教师
     */
    Teacher selectByUsername(@Param("username") String username);

    /**
     * 查询所有教师
     */
    java.util.List<Teacher> selectAll();

    /**
     * 插入教师
     */
    int insert(Teacher teacher);

    /**
     * 更新教师
     */
    int update(Teacher teacher);

    /**
     * 删除教师
     */
    int deleteById(@Param("id") Long id);
}

