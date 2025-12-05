package com.exam.service;

import com.exam.entity.Student;
import com.exam.entity.Teacher;
import com.exam.entity.Admin;
import com.exam.mapper.StudentMapper;
import com.exam.mapper.TeacherMapper;
import com.exam.mapper.AdminMapper;
import com.exam.util.JwtUtil;
import com.exam.util.PasswordUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 用户服务类
 */
@Service
public class UserService {

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private TeacherMapper teacherMapper;

    @Autowired
    private AdminMapper adminMapper;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 用户登录
     */
    public Map<String, Object> login(String username, String password, Integer role) {
        String[] roleNames = {"学生", "教师", "管理员"};
        
        // 根据角色从不同表查询
        if (role == 0) {
            // 学生登录
            Student student = studentMapper.selectByUsername(username);
            if (student == null) {
                throw new RuntimeException("学生账号不存在");
            }
            // 使用BCrypt验证密码
            if (!PasswordUtil.matches(password, student.getPassword())) {
                throw new RuntimeException("密码错误");
            }
            if (student.getStatus() == 0) {
                throw new RuntimeException("账号已被禁用");
            }
            
            String token = jwtUtil.generateToken(student.getId(), student.getUsername());
            Map<String, Object> result = new HashMap<>();
            result.put("token", token);
            result.put("userId", student.getId());
            result.put("username", student.getUsername());
            result.put("realName", student.getRealName());
            result.put("role", 0);
            result.put("studentNo", student.getStudentNo());
            result.put("className", student.getClassName());
            return result;
            
        } else if (role == 1) {
            // 教师登录
            Teacher teacher = teacherMapper.selectByUsername(username);
            if (teacher == null) {
                throw new RuntimeException("教师账号不存在");
            }
            // 使用BCrypt验证密码
            if (!PasswordUtil.matches(password, teacher.getPassword())) {
                throw new RuntimeException("密码错误");
            }
            if (teacher.getStatus() == 0) {
                throw new RuntimeException("账号已被禁用");
            }
            
            String token = jwtUtil.generateToken(teacher.getId(), teacher.getUsername());
            Map<String, Object> result = new HashMap<>();
            result.put("token", token);
            result.put("userId", teacher.getId());
            result.put("username", teacher.getUsername());
            result.put("realName", teacher.getRealName());
            result.put("role", 1);
            result.put("department", teacher.getDepartment());
            result.put("title", teacher.getTitle());
            return result;
            
        } else if (role == 2) {
            // 管理员登录
            Admin admin = adminMapper.selectByUsername(username);
            if (admin == null) {
                throw new RuntimeException("管理员账号不存在");
            }
            // 使用BCrypt验证密码
            if (!PasswordUtil.matches(password, admin.getPassword())) {
                throw new RuntimeException("密码错误");
            }
            if (admin.getStatus() == 0) {
                throw new RuntimeException("账号已被禁用");
            }
            
            String token = jwtUtil.generateToken(admin.getId(), admin.getUsername());
            Map<String, Object> result = new HashMap<>();
            result.put("token", token);
            result.put("userId", admin.getId());
            result.put("username", admin.getUsername());
            result.put("realName", admin.getRealName());
            result.put("role", 2);
            result.put("superAdmin", admin.getSuperAdmin());
            return result;
            
        } else {
            throw new RuntimeException("无效的用户角色");
        }
    }
    
    /**
     * 更新用户信息（邮箱、手机号）
     * 根据用户ID从学生、教师、管理员表中查找并更新
     */
    public void updateUser(Long userId, String email, String phone) {
        // 先尝试从学生表更新
        Student student = studentMapper.selectById(userId);
        if (student != null) {
            student.setEmail(email);
            student.setPhone(phone);
            studentMapper.update(student);
            return;
        }
        
        // 尝试从教师表更新
        Teacher teacher = teacherMapper.selectById(userId);
        if (teacher != null) {
            teacher.setEmail(email);
            teacher.setPhone(phone);
            teacherMapper.update(teacher);
            return;
        }
        
        // 尝试从管理员表更新
        Admin admin = adminMapper.selectById(userId);
        if (admin != null) {
            admin.setEmail(email);
            admin.setPhone(phone);
            adminMapper.update(admin);
            return;
        }
        
        throw new RuntimeException("用户不存在");
    }
    
    /**
     * 修改密码
     * 根据用户ID从学生、教师、管理员表中查找并修改密码
     */
    public boolean changePassword(Long userId, String oldPassword, String newPassword) {
        // 先尝试从学生表查找
        Student student = studentMapper.selectById(userId);
        if (student != null) {
            // 验证旧密码
            if (!PasswordUtil.matches(oldPassword, student.getPassword())) {
                return false;
            }
            // 加密新密码
            String encryptedPassword = PasswordUtil.encode(newPassword);
            student.setPassword(encryptedPassword);
            studentMapper.update(student);
            return true;
        }
        
        // 尝试从教师表查找
        Teacher teacher = teacherMapper.selectById(userId);
        if (teacher != null) {
            // 验证旧密码
            if (!PasswordUtil.matches(oldPassword, teacher.getPassword())) {
                return false;
            }
            // 加密新密码
            String encryptedPassword = PasswordUtil.encode(newPassword);
            teacher.setPassword(encryptedPassword);
            teacherMapper.update(teacher);
            return true;
        }
        
        // 尝试从管理员表查找
        Admin admin = adminMapper.selectById(userId);
        if (admin != null) {
            // 验证旧密码
            if (!PasswordUtil.matches(oldPassword, admin.getPassword())) {
                return false;
            }
            // 加密新密码
            String encryptedPassword = PasswordUtil.encode(newPassword);
            admin.setPassword(encryptedPassword);
            adminMapper.update(admin);
            return true;
        }
        
        throw new RuntimeException("用户不存在");
    }
}

