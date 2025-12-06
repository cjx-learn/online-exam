package com.exam.controller;

import com.exam.common.Result;
import com.exam.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 用户控制器
 */
@RestController
@RequestMapping("/user")
public class UserController {
    
    @Autowired
    private UserService userService;
    
    /**
     * 测试接口
     */
    @GetMapping("/test")
    public Result<String> test() {
        return Result.success("后端接口连接成功！");
    }
    
    /**
     * 用户登录
     */
    @PostMapping("/login")
    public Result<?> login(@RequestBody LoginRequest request) {
        try {
            Map<String, Object> result = userService.login(
                request.getUsername(), 
                request.getPassword(), 
                request.getRole()
            );
            return Result.success("登录成功", result);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 用户注册
     */
    @PostMapping("/register")
    public Result<?> register(@RequestBody RegisterRequest request) {
        // TODO: 实现注册逻辑
        return Result.success("注册成功");
    }
    
    /**
     * 登录请求
     */
    @lombok.Data
    static class LoginRequest {
        private String username;
        private String password;
        private Integer role;  // 0-学生 1-教师 2-管理员
    }
    
    /**
     * 更新用户信息
     */
    @PostMapping("/update")
    public Result<?> updateUser(@RequestBody UpdateUserRequest request) {
        try {
            userService.updateUser(request.getId(), request.getEmail(), request.getPhone(), request.getRole());
            return Result.success("更新成功");
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 修改密码
     */
    @PostMapping("/changePassword")
    public Result<?> changePassword(@RequestBody ChangePasswordRequest request) {
        try {
            boolean success = userService.changePassword(
                request.getId(), 
                request.getOldPassword(), 
                request.getNewPassword(),
                request.getRole()
            );
            if (success) {
                return Result.success("密码修改成功");
            } else {
                return Result.error("旧密码错误");
            }
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
    
    /**
     * 注册请求
     */
    @lombok.Data
    static class RegisterRequest {
        private String username;
        private String password;
        private String realName;
        private String email;
    }
    
    /**
     * 更新用户请求
     */
    @lombok.Data
    static class UpdateUserRequest {
        private Long id;
        private String email;
        private String phone;
        private Integer role;  // 0-学生 1-教师 2-管理员
    }
    
    /**
     * 修改密码请求
     */
    @lombok.Data
    static class ChangePasswordRequest {
        private Long id;
        private String oldPassword;
        private String newPassword;
        private Integer role;  // 0-学生 1-教师 2-管理员
    }
}

