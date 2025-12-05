package com.exam.controller;

import com.exam.common.Result;
import com.exam.entity.Class;
import com.exam.service.ClassService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 班级控制器
 */
@RestController
@RequestMapping("/class")
@CrossOrigin
public class ClassController {
    
    @Autowired
    private ClassService classService;
    
    /**
     * 获取学生的所有班级
     */
    @GetMapping("/student/{studentId}")
    public Result getStudentClasses(@PathVariable Long studentId) {
        try {
            List<Class> classList = classService.getStudentClasses(studentId);
            return Result.success(classList);
        } catch (Exception e) {
            return Result.error("获取班级列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取教师的所有班级
     */
    @GetMapping("/teacher/{teacherId}")
    public Result getTeacherClasses(@PathVariable Long teacherId) {
        try {
            List<Class> classList = classService.getTeacherClasses(teacherId);
            return Result.success(classList);
        } catch (Exception e) {
            return Result.error("获取班级列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取所有班级
     */
    @GetMapping("/all")
    public Result getAllClasses() {
        try {
            List<Class> classList = classService.getAllClasses();
            return Result.success(classList);
        } catch (Exception e) {
            return Result.error("获取班级列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 根据ID获取班级详情
     */
    @GetMapping("/{id}")
    public Result getClassById(@PathVariable Long id) {
        try {
            Class classEntity = classService.getClassById(id);
            if (classEntity == null) {
                return Result.error("班级不存在");
            }
            return Result.success(classEntity);
        } catch (Exception e) {
            return Result.error("获取班级详情失败：" + e.getMessage());
        }
    }
    
    /**
     * 获取班级的所有学生
     */
    @GetMapping("/{id}/students")
    public Result getClassStudents(@PathVariable Long id) {
        try {
            List students = classService.getClassStudents(id);
            return Result.success(students);
        } catch (Exception e) {
            return Result.error("获取学生列表失败：" + e.getMessage());
        }
    }
    
    /**
     * 根据邀请码查询班级
     */
    @GetMapping("/invite/{inviteCode}")
    public Result getClassByInviteCode(@PathVariable String inviteCode) {
        try {
            Class classEntity = classService.getClassByInviteCode(inviteCode);
            if (classEntity == null) {
                return Result.error("邀请码不存在");
            }
            return Result.success(classEntity);
        } catch (Exception e) {
            return Result.error("查询失败：" + e.getMessage());
        }
    }
    
    /**
     * 创建班级
     */
    @PostMapping
    public Result createClass(@RequestBody Class classEntity) {
        try {
            Class created = classService.createClass(classEntity);
            return Result.success(created);
        } catch (Exception e) {
            return Result.error("创建班级失败：" + e.getMessage());
        }
    }
    
    /**
     * 更新班级
     */
    @PutMapping
    public Result updateClass(@RequestBody Class classEntity) {
        try {
            boolean success = classService.updateClass(classEntity);
            if (success) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            return Result.error("更新班级失败：" + e.getMessage());
        }
    }
    
    /**
     * 删除班级（软删除）
     */
    @DeleteMapping("/{id}")
    public Result deleteClass(@PathVariable Long id) {
        try {
            boolean success = classService.deleteClass(id);
            if (success) {
                return Result.success("删除成功");
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            return Result.error("删除班级失败：" + e.getMessage());
        }
    }
    
    /**
     * 学生加入班级
     */
    @PostMapping("/join")
    public Result joinClass(@RequestBody JoinRequest request) {
        try {
            boolean success = classService.joinClass(request.getStudentId(), request.getInviteCode());
            if (success) {
                return Result.success("加入班级成功");
            } else {
                return Result.error("加入班级失败");
            }
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 学生退出班级
     */
    @PostMapping("/quit")
    public Result quitClass(@RequestBody QuitRequest request) {
        try {
            boolean success = classService.quitClass(request.getStudentId(), request.getClassId());
            if (success) {
                return Result.success("退出班级成功");
            } else {
                return Result.error("退出班级失败");
            }
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 老师将学生从班级中移除
     * DELETE /api/class/{classId}/student/{studentId}
     */
    @DeleteMapping("/{classId}/student/{studentId}")
    public Result removeStudentFromClass(@PathVariable Long classId, @PathVariable Long studentId) {
        try {
            boolean success = classService.removeStudentFromClass(classId, studentId);
            if (success) {
                return Result.success("学生已从班级中移除");
            } else {
                return Result.error("从班级中移除学生失败");
            }
        } catch (Exception e) {
            return Result.error("移除学生失败：" + e.getMessage());
        }
    }
    
    // ========== 内部类：请求参数 ==========
    
    /**
     * 加入班级请求
     */
    static class JoinRequest {
        private Long studentId;
        private String inviteCode;
        
        public Long getStudentId() {
            return studentId;
        }
        
        public void setStudentId(Long studentId) {
            this.studentId = studentId;
        }
        
        public String getInviteCode() {
            return inviteCode;
        }
        
        public void setInviteCode(String inviteCode) {
            this.inviteCode = inviteCode;
        }
    }
    
    /**
     * 退出班级请求
     */
    static class QuitRequest {
        private Long studentId;
        private Long classId;
        
        public Long getStudentId() {
            return studentId;
        }
        
        public void setStudentId(Long studentId) {
            this.studentId = studentId;
        }
        
        public Long getClassId() {
            return classId;
        }
        
        public void setClassId(Long classId) {
            this.classId = classId;
        }
    }
}

