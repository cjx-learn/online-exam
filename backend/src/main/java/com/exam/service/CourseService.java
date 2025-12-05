package com.exam.service;

import com.exam.entity.Course;
import com.exam.mapper.CourseMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 课程服务类
 */
@Service
public class CourseService {
    
    @Autowired
    private CourseMapper courseMapper;
    
    /**
     * 获取所有启用的课程
     */
    public List<Course> getAllCourses() {
        return courseMapper.selectAll();
    }
    
    /**
     * 根据ID获取课程
     */
    public Course getCourseById(Long id) {
        return courseMapper.selectById(id);
    }
    
    /**
     * 根据课程代码获取课程
     */
    public Course getCourseByCode(String code) {
        return courseMapper.selectByCode(code);
    }
    
    /**
     * 根据分类获取课程
     */
    public List<Course> getCoursesByCategory(String category) {
        return courseMapper.selectByCategory(category);
    }
    
    /**
     * 创建课程（管理员功能）
     */
    public Course createCourse(Course course) {
        // 检查课程代码是否已存在
        Course existing = courseMapper.selectByCode(course.getCode());
        if (existing != null) {
            throw new RuntimeException("课程代码已存在");
        }
        course.setStatus(1);
        courseMapper.insert(course);
        return course;
    }
    
    /**
     * 更新课程（管理员功能）
     */
    public boolean updateCourse(Course course) {
        return courseMapper.update(course) > 0;
    }
    
    /**
     * 删除课程（管理员功能）
     */
    public boolean deleteCourse(Long id) {
        return courseMapper.delete(id) > 0;
    }
}

