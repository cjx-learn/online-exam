package com.exam.mapper;

import com.exam.entity.Student;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 学生 Mapper 接口
 */
@Mapper
public interface StudentMapper {

    /**
     * 根据ID查询学生
     */
    Student selectById(@Param("id") Long id);

    /**
     * 根据用户名查询学生
     */
    Student selectByUsername(@Param("username") String username);

    /**
     * 查询所有学生
     */
    List<Student> selectAll();

    /**
     * 根据ID列表批量查询学生
     */
    List<Student> selectByIds(@Param("ids") List<Long> ids);

    /**
     * 插入学生
     */
    int insert(Student student);

    /**
     * 更新学生
     */
    int update(Student student);

    /**
     * 删除学生
     */
    int deleteById(@Param("id") Long id);
}

