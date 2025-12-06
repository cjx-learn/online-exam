package com.exam.controller;

import com.exam.common.Result;
import com.exam.entity.Student;
import com.exam.entity.Teacher;
import com.exam.mapper.ClassMapper;
import com.exam.mapper.CourseMapper;
import com.exam.mapper.StudentMapper;
import com.exam.mapper.TeacherMapper;
import com.exam.service.ExcelImportService;
import com.exam.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
    private ExcelImportService excelImportService;
    
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
    
    /**
     * 更新班级状态
     * POST /admin/class/status
     */
    @PostMapping("/class/status")
    public Result updateClassStatus(@RequestBody Map<String, Object> params) {
        try {
            Long id = Long.valueOf(params.get("id").toString());
            Integer status = Integer.valueOf(params.get("status").toString());
            
            com.exam.entity.Class classEntity = new com.exam.entity.Class();
            classEntity.setId(id);
            classEntity.setStatus(status);
            
            int result = classMapper.update(classEntity);
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
     * 批量导入课程
     * POST /admin/import/course
     */
    @PostMapping("/import/course")
    public Result importCourses(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return Result.error("请选择文件");
            }
            Map<String, Object> result = excelImportService.importCourses(file);
            return Result.success("导入完成", result);
        } catch (Exception e) {
            return Result.error("导入失败：" + e.getMessage());
        }
    }
    
    /**
     * 批量导入学生
     * POST /admin/import/student
     */
    @PostMapping("/import/student")
    public Result importStudents(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return Result.error("请选择文件");
            }
            Map<String, Object> result = excelImportService.importStudents(file);
            return Result.success("导入完成", result);
        } catch (Exception e) {
            return Result.error("导入失败：" + e.getMessage());
        }
    }
    
    /**
     * 批量导入教师
     * POST /admin/import/teacher
     */
    @PostMapping("/import/teacher")
    public Result importTeachers(@RequestParam("file") MultipartFile file) {
        try {
            if (file.isEmpty()) {
                return Result.error("请选择文件");
            }
            Map<String, Object> result = excelImportService.importTeachers(file);
            return Result.success("导入完成", result);
        } catch (Exception e) {
            return Result.error("导入失败：" + e.getMessage());
        }
    }
    
    /**
     * 添加教师
     * POST /admin/teacher/add
     */
    @PostMapping("/teacher/add")
    public Result addTeacher(@RequestBody Teacher teacher) {
        try {
            // 检查用户名是否已存在
            if (teacherMapper.selectByUsername(teacher.getUsername()) != null) {
                return Result.error("用户名已存在");
            }
            // 设置默认密码
            teacher.setPassword(PasswordUtil.encode("123456"));
            teacher.setStatus(1);
            teacherMapper.insert(teacher);
            return Result.success("添加成功，默认密码为123456");
        } catch (Exception e) {
            return Result.error("添加失败：" + e.getMessage());
        }
    }
    
    /**
     * 添加学生
     * POST /admin/student/add
     */
    @PostMapping("/student/add")
    public Result addStudent(@RequestBody Student student) {
        try {
            // 检查用户名是否已存在
            if (studentMapper.selectByUsername(student.getUsername()) != null) {
                return Result.error("用户名已存在");
            }
            // 设置默认密码
            student.setPassword(PasswordUtil.encode("123456"));
            student.setStatus(1);
            studentMapper.insert(student);
            return Result.success("添加成功，默认密码为123456");
        } catch (Exception e) {
            return Result.error("添加失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新教师信息
     * PUT /admin/teacher/update
     */
    @PutMapping("/teacher/update")
    public Result updateTeacher(@RequestBody Teacher teacher) {
        try {
            // 不更新密码
            teacher.setPassword(null);
            int result = teacherMapper.update(teacher);
            if (result > 0) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            return Result.error("更新失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新学生信息
     * PUT /admin/student/update
     */
    @PutMapping("/student/update")
    public Result updateStudent(@RequestBody Student student) {
        try {
            // 不更新密码
            student.setPassword(null);
            int result = studentMapper.update(student);
            if (result > 0) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            return Result.error("更新失败：" + e.getMessage());
        }
    }
    
    /**
     * 删除教师
     * DELETE /admin/teacher/{id}
     */
    @DeleteMapping("/teacher/{id}")
    public Result deleteTeacher(@PathVariable Long id) {
        try {
            int result = teacherMapper.deleteById(id);
            if (result > 0) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            return Result.error("删除失败：" + e.getMessage());
        }
    }
    
    /**
     * 删除学生
     * DELETE /admin/student/{id}
     */
    @DeleteMapping("/student/{id}")
    public Result deleteStudent(@PathVariable Long id) {
        try {
            int result = studentMapper.deleteById(id);
            if (result > 0) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            return Result.error("删除失败：" + e.getMessage());
        }
    }
}
