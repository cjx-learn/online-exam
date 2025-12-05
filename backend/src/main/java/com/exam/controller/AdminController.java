package com.exam.controller;

import com.exam.common.Result;
import com.exam.entity.Student;
import com.exam.entity.Teacher;
import com.exam.mapper.ClassMapper;
import com.exam.mapper.CourseMapper;
import com.exam.mapper.StudentMapper;
import com.exam.mapper.TeacherMapper;
import com.exam.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 管理员Controller
 */
@RestController
@RequestMapping("/admin")
@CrossOrigin
public class AdminController {
    
    @Autowired
    private CourseMapper courseMapper;
    
    @Autowired
    private TeacherMapper teacherMapper;
    
    @Autowired
    private StudentMapper studentMapper;
    
    @Autowired
    private ClassMapper classMapper;
    
    /**
     * 获取系统统计数据
     * GET /admin/stats
     */
    @GetMapping("/stats")
    public Result getStats() {
        try {
            Map<String, Object> stats = new HashMap<>();
            
            // 课程总数
            int courseCount = courseMapper.selectAll().size();
            stats.put("courseCount", courseCount);
            
            // 教师数量
            int teacherCount = teacherMapper.selectAll().size();
            stats.put("teacherCount", teacherCount);
            
            // 学生数量
            int studentCount = studentMapper.selectAll().size();
            stats.put("studentCount", studentCount);
            
            // 班级数量
            int classCount = classMapper.selectAll().size();
            stats.put("classCount", classCount);
            
            return Result.success(stats);
        } catch (Exception e) {
            return Result.error("获取统计数据失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取教师列表
     * GET /admin/teacher/list
     */
    @GetMapping("/teacher/list")
    public Result getTeacherList() {
        try {
            List<Teacher> teachers = teacherMapper.selectAll();
            return Result.success(teachers);
        } catch (Exception e) {
            return Result.error("获取教师列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取学生列表
     * GET /admin/student/list
     */
    @GetMapping("/student/list")
    public Result getStudentList() {
        try {
            List<Student> students = studentMapper.selectAll();
            return Result.success(students);
        } catch (Exception e) {
            return Result.error("获取学生列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新教师状态
     * POST /admin/teacher/status
     */
    @PostMapping("/teacher/status")
    public Result updateTeacherStatus(@RequestBody Map<String, Object> params) {
        try {
            Long id = Long.valueOf(params.get("id").toString());
            Integer status = Integer.valueOf(params.get("status").toString());
            
            Teacher teacher = new Teacher();
            teacher.setId(id);
            teacher.setStatus(status);
            
            int result = teacherMapper.update(teacher);
            if (result > 0) {
                return Result.success("状态更新成功");
            } else {
                return Result.error("状态更新失败");
            }
        } catch (Exception e) {
            return Result.error("状态更新失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新学生状态
     * POST /admin/student/status
     */
    @PostMapping("/student/status")
    public Result updateStudentStatus(@RequestBody Map<String, Object> params) {
        try {
            Long id = Long.valueOf(params.get("id").toString());
            Integer status = Integer.valueOf(params.get("status").toString());
            
            Student student = new Student();
            student.setId(id);
            student.setStatus(status);
            
            int result = studentMapper.update(student);
            if (result > 0) {
                return Result.success("状态更新成功");
            } else {
                return Result.error("状态更新失败");
            }
        } catch (Exception e) {
            return Result.error("状态更新失败：" + e.getMessage());
        }
    }
    
    /**
     * 重置教师密码
     * POST /admin/teacher/resetPassword
     */
    @PostMapping("/teacher/resetPassword")
    public Result resetTeacherPassword(@RequestBody Map<String, Object> params) {
        try {
            Long id = Long.valueOf(params.get("id").toString());
            
            // 生成默认密码123456的BCrypt哈希
            String encodedPassword = PasswordUtil.encode("123456");
            
            Teacher teacher = new Teacher();
            teacher.setId(id);
            teacher.setPassword(encodedPassword);
            
            int result = teacherMapper.update(teacher);
            if (result > 0) {
                return Result.success("密码重置成功");
            } else {
                return Result.error("密码重置失败");
            }
        } catch (Exception e) {
            return Result.error("密码重置失败：" + e.getMessage());
        }
    }
    
    /**
     * 重置学生密码
     * POST /admin/student/resetPassword
     */
    @PostMapping("/student/resetPassword")
    public Result resetStudentPassword(@RequestBody Map<String, Object> params) {
        try {
            Long id = Long.valueOf(params.get("id").toString());
            
            // 生成默认密码123456的BCrypt哈希
            String encodedPassword = PasswordUtil.encode("123456");
            
            Student student = new Student();
            student.setId(id);
            student.setPassword(encodedPassword);
            
            int result = studentMapper.update(student);
            if (result > 0) {
                return Result.success("密码重置成功");
            } else {
                return Result.error("密码重置失败");
            }
        } catch (Exception e) {
            return Result.error("密码重置失败：" + e.getMessage());
        }
    }
}

