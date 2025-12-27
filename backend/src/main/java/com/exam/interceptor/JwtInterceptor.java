package com.exam.interceptor;

import com.exam.entity.Admin;
import com.exam.entity.Student;
import com.exam.entity.Teacher;
import com.exam.mapper.AdminMapper;
import com.exam.mapper.StudentMapper;
import com.exam.mapper.TeacherMapper;
import com.exam.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * JWT 拦截器
 * 用于验证Token有效性，并对所有角色实施单设备登录限制
 */
@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private TeacherMapper teacherMapper;

    @Autowired
    private AdminMapper adminMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 允许OPTIONS请求通过
        if ("OPTIONS".equals(request.getMethod())) {
            return true;
        }

        // 获取请求头中的Token
        String token = request.getHeader("Authorization");
        
        if (token == null || token.trim().isEmpty()) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"message\":\"未登录或登录已过期\"}");
            return false;
        }

        // 移除 "Bearer " 前缀（如果有）
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }

        // 验证Token格式和有效期
        if (!jwtUtil.validateToken(token)) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"message\":\"Token无效或已过期\"}");
            return false;
        }

        // 获取用户ID
        Long userId = jwtUtil.getUserIdFromToken(token);
        if (userId == null) {
            response.setStatus(401);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"code\":401,\"message\":\"Token解析失败\"}");
            return false;
        }

        // 从Token中获取角色信息
        Integer role = jwtUtil.getRoleFromToken(token);
        
        System.out.println("[JWT拦截器] 请求路径: " + request.getRequestURI());
        System.out.println("[JWT拦截器] 用户ID: " + userId);
        System.out.println("[JWT拦截器] 角色: " + role + " (0=学生, 1=教师, 2=管理员)");
        System.out.println("[JWT拦截器] Token(前20字符): " + token.substring(0, Math.min(20, token.length())));
        
        // 根据角色判断是否需要单设备验证
        if (role != null && role == 0) {
            // 学生：需要验证单设备登录
            System.out.println("[JWT拦截器] 学生角色，开始单设备验证");
            Student student = studentMapper.selectById(userId);
            if (student == null) {
                System.out.println("[JWT拦截器] 学生不存在: " + userId);
                response.setStatus(401);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":401,\"message\":\"用户不存在\"}");
                return false;
            }
            
            String dbToken = student.getCurrentToken();
            System.out.println("[JWT拦截器] 数据库Token(前20字符): " + (dbToken != null ? dbToken.substring(0, Math.min(20, dbToken.length())) : "null"));
            System.out.println("[JWT拦截器] Token长度 - 请求:" + token.length() + ", 数据库:" + (dbToken != null ? dbToken.length() : 0));
            System.out.println("[JWT拦截器] Token相等: " + token.equals(dbToken));
            
            // 验证Token是否是最新的（单设备限制）
            if (dbToken == null || !token.equals(dbToken)) {
                System.out.println("[JWT拦截器] Token不匹配，拒绝访问");
                response.setStatus(401);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":401,\"message\":\"您的账号已在其他设备登录，请重新登录\"}");
                return false;
            }
            System.out.println("[JWT拦截器] 学生Token验证通过");
            
        } else if (role != null && role == 2) {
            // 管理员：需要验证单设备登录
            System.out.println("[JWT拦截器] 管理员角色，开始单设备验证");
            Admin admin = adminMapper.selectById(userId);
            if (admin == null) {
                System.out.println("[JWT拦截器] 管理员不存在: " + userId);
                response.setStatus(401);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":401,\"message\":\"用户不存在\"}");
                return false;
            }
            
            String dbToken = admin.getCurrentToken();
            System.out.println("[JWT拦截器] 数据库Token(前20字符): " + (dbToken != null ? dbToken.substring(0, Math.min(20, dbToken.length())) : "null"));
            System.out.println("[JWT拦截器] Token相等: " + token.equals(dbToken));
            
            // 验证Token是否是最新的（单设备限制）
            if (dbToken == null || !token.equals(dbToken)) {
                System.out.println("[JWT拦截器] Token不匹配，拒绝访问");
                response.setStatus(401);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":401,\"message\":\"您的账号已在其他设备登录，请重新登录\"}");
                return false;
            }
            System.out.println("[JWT拦截器] 管理员Token验证通过");
        } else if (role != null && role == 1) {
            // 教师：需要验证单设备登录
            System.out.println("[JWT拦截器] 教师角色，开始单设备验证");
            Teacher teacher = teacherMapper.selectById(userId);
            if (teacher == null) {
                System.out.println("[JWT拦截器] 教师不存在: " + userId);
                response.setStatus(401);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":401,\"message\":\"用户不存在\"}");
                return false;
            }
            
            String dbToken = teacher.getCurrentToken();
            System.out.println("[JWT拦截器] 数据库Token(前20字符): " + (dbToken != null ? dbToken.substring(0, Math.min(20, dbToken.length())) : "null"));
            System.out.println("[JWT拦截器] Token相等: " + token.equals(dbToken));
            
            // 验证Token是否是最新的（单设备限制）
            if (dbToken == null || !token.equals(dbToken)) {
                System.out.println("[JWT拦截器] Token不匹配，拒绝访问");
                response.setStatus(401);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"code\":401,\"message\":\"您的账号已在其他设备登录，请重新登录\"}");
                return false;
            }
            System.out.println("[JWT拦截器] 教师Token验证通过");
        } else {
            System.out.println("[JWT拦截器] 未知角色或旧Token（无角色信息），跳过单设备验证");
        }

        // 将userId和role存入request attribute，供后续使用
        request.setAttribute("userId", userId);
        request.setAttribute("role", role);
        
        return true;
    }
}
