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
            result.put("major", student.getMajor());
            result.put("email", student.getEmail());
            result.put("phone", student.getPhone());
            result.put("avatar", student.getAvatar());
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
            result.put("teacherNo", teacher.getTeacherNo());
            result.put("department", teacher.getDepartment());
            result.put("title", teacher.getTitle());
            result.put("email", teacher.getEmail());
            result.put("phone", teacher.getPhone());
            result.put("avatar", teacher.getAvatar());
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
            result.put("email", admin.getEmail());
            result.put("phone", admin.getPhone());
            result.put("avatar", admin.getAvatar());
            return result;
            
        } else {
            throw new RuntimeException("无效的用户角色");
        }
    }
    
    /**
     * 更新用户信息（邮箱、手机号）
     * 根据角色和用户ID更新对应表
     */
    public void updateUser(Long userId, String email, String phone, Integer role) {
        if (role == null) {
            // 兼容旧逻辑，依次查找
            role = findUserRole(userId);
        }
        
        if (role == 0) {
            // 学生
            Student student = studentMapper.selectById(userId);
            if (student != null) {
                student.setEmail(email);
                student.setPhone(phone);
                studentMapper.update(student);
                return;
            }
        } else if (role == 1) {
            // 教师
            Teacher teacher = teacherMapper.selectById(userId);
            if (teacher != null) {
                teacher.setEmail(email);
                teacher.setPhone(phone);
                teacherMapper.update(teacher);
                return;
            }
        } else if (role == 2) {
            // 管理员
            Admin admin = adminMapper.selectById(userId);
            if (admin != null) {
                admin.setEmail(email);
                admin.setPhone(phone);
                adminMapper.update(admin);
                return;
            }
        }
        
        throw new RuntimeException("用户不存在");
    }
    
    /**
     * 修改密码
     * 根据角色和用户ID修改对应表的密码
     */
    public boolean changePassword(Long userId, String oldPassword, String newPassword, Integer role) {
        if (role == null) {
            // 兼容旧逻辑，依次查找
            role = findUserRole(userId);
        }
        
        if (role == 0) {
            // 学生
            Student student = studentMapper.selectById(userId);
            if (student != null) {
                if (!PasswordUtil.matches(oldPassword, student.getPassword())) {
                    return false;
                }
                String encryptedPassword = PasswordUtil.encode(newPassword);
                student.setPassword(encryptedPassword);
                studentMapper.update(student);
                return true;
            }
        } else if (role == 1) {
            // 教师
            Teacher teacher = teacherMapper.selectById(userId);
            if (teacher != null) {
                if (!PasswordUtil.matches(oldPassword, teacher.getPassword())) {
                    return false;
                }
                String encryptedPassword = PasswordUtil.encode(newPassword);
                teacher.setPassword(encryptedPassword);
                teacherMapper.update(teacher);
                return true;
            }
        } else if (role == 2) {
            // 管理员
            Admin admin = adminMapper.selectById(userId);
            if (admin != null) {
                if (!PasswordUtil.matches(oldPassword, admin.getPassword())) {
                    return false;
                }
                String encryptedPassword = PasswordUtil.encode(newPassword);
                admin.setPassword(encryptedPassword);
                adminMapper.update(admin);
                return true;
            }
        }
        
        throw new RuntimeException("用户不存在");
    }
    
    /**
     * 查找用户角色（兼容旧逻辑）
     */
    private Integer findUserRole(Long userId) {
        if (studentMapper.selectById(userId) != null) return 0;
        if (teacherMapper.selectById(userId) != null) return 1;
        if (adminMapper.selectById(userId) != null) return 2;
        return null;
    }
    
    /**
     * 更新用户完整信息
     * 根据角色和用户ID更新对应表的所有可修改字段
     */
    public void updateUserInfo(Long id, Integer role, String realName, String email, String phone,
                              String teacherNo, String department, String title,
                              String studentNo, String major, String avatar) {
        if (role == null) {
            role = findUserRole(id);
        }
        
        if (role == 0) {
            // 学生
            Student student = studentMapper.selectById(id);
            if (student != null) {
                if (realName != null) student.setRealName(realName);
                if (studentNo != null) student.setStudentNo(studentNo);
                if (major != null) student.setMajor(major);
                if (email != null) student.setEmail(email);
                if (phone != null) student.setPhone(phone);
                if (avatar != null) student.setAvatar(avatar);
                
                studentMapper.update(student);
                return;
            }
        } else if (role == 1) {
            // 教师
            Teacher teacher = teacherMapper.selectById(id);
            if (teacher != null) {
                if (realName != null) teacher.setRealName(realName);
                if (teacherNo != null) teacher.setTeacherNo(teacherNo);
                if (department != null) teacher.setDepartment(department);
                if (title != null) teacher.setTitle(title);
                if (email != null) teacher.setEmail(email);
                if (phone != null) teacher.setPhone(phone);
                if (avatar != null) teacher.setAvatar(avatar);
                
                teacherMapper.update(teacher);
                return;
            }
        } else if (role == 2) {
            // 管理员
            Admin admin = adminMapper.selectById(id);
            if (admin != null) {
                if (realName != null) admin.setRealName(realName);
                if (email != null) admin.setEmail(email);
                if (phone != null) admin.setPhone(phone);
                if (avatar != null) admin.setAvatar(avatar);
                
                adminMapper.update(admin);
                return;
            }
        }
        
        throw new RuntimeException("用户不存在");
    }
}

