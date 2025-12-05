package com.exam.controller;

import com.exam.common.Result;
import com.exam.entity.Course;
import com.exam.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 课程管理Controller
 */
@RestController
@RequestMapping("/course")
public class CourseController {
    
    @Autowired
    private CourseService courseService;
    
    /**
     * 获取所有启用的课程
     * GET /api/course/list
     */
    @GetMapping("/list")
    public Result getAllCourses() {
        try {
            List<Course> courses = courseService.getAllCourses();
            return Result.success(courses);
        } catch (Exception e) {
            return Result.error("获取课程列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 根据ID获取课程详情
     * GET /api/course/{id}
     */
    @GetMapping("/{id}")
    public Result getCourseById(@PathVariable Long id) {
        try {
            Course course = courseService.getCourseById(id);
            if (course == null) {
                return Result.error("课程不存在");
            }
            return Result.success(course);
        } catch (Exception e) {
            return Result.error("获取课程详情失败：" + e.getMessage());
        }
    }
    
    /**
     * 根据分类获取课程
     * GET /api/course/category/{category}
     */
    @GetMapping("/category/{category}")
    public Result getCoursesByCategory(@PathVariable String category) {
        try {
            List<Course> courses = courseService.getCoursesByCategory(category);
            return Result.success(courses);
        } catch (Exception e) {
            return Result.error("获取课程列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 创建课程（管理员功能）
     * POST /api/course/create
     */
    @PostMapping("/create")
    public Result createCourse(@RequestBody Course course) {
        try {
            Course created = courseService.createCourse(course);
            return Result.success(created);
        } catch (Exception e) {
            return Result.error("创建课程失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新课程（管理员功能）
     * PUT /api/course/update
     */
    @PutMapping("/update")
    public Result updateCourse(@RequestBody Course course) {
        try {
            boolean success = courseService.updateCourse(course);
            if (success) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            return Result.error("更新课程失败：" + e.getMessage());
        }
    }
    
    /**
     * 删除课程（管理员功能）
     * DELETE /api/course/{id}
     */
    @DeleteMapping("/{id}")
    public Result deleteCourse(@PathVariable Long id) {
        try {
            boolean success = courseService.deleteCourse(id);
            if (success) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            return Result.error("删除课程失败：" + e.getMessage());
        }
    }
}

