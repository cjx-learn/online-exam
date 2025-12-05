package com.exam.mapper;

import com.exam.entity.Course;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 课程Mapper接口
 */
@Mapper
public interface CourseMapper {
    
    /**
     * 查询所有启用的课程
     */
    List<Course> selectAll();
    
    /**
     * 根据ID查询课程
     */
    Course selectById(@Param("id") Long id);
    
    /**
     * 根据课程代码查询
     */
    Course selectByCode(@Param("code") String code);
    
    /**
     * 根据分类查询课程
     */
    List<Course> selectByCategory(@Param("category") String category);
    
    /**
     * 插入课程
     */
    int insert(Course course);
    
    /**
     * 更新课程
     */
    int update(Course course);
    
    /**
     * 删除课程（软删除，设置status=0）
     */
    int delete(@Param("id") Long id);

    /**
     * 根据ID查询课程名称
     */
    String selectNameById(@Param("id") Long id);
}

