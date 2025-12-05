package com.exam.test;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 生成正确的 BCrypt 密码
 */
public class GenerateCorrectPassword {
    
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String rawPassword = "123456";
        
        System.out.println("=== 生成 BCrypt 密码 ===");
        System.out.println("原始密码: " + rawPassword);
        System.out.println();
        
        // 生成3个不同的加密密码
        for (int i = 1; i <= 3; i++) {
            String encoded = encoder.encode(rawPassword);
            boolean matches = encoder.matches(rawPassword, encoded);
            
            System.out.println("密码 " + i + ":");
            System.out.println(encoded);
            System.out.println("验证结果: " + matches);
            System.out.println();
        }
        
        System.out.println("=== 推荐使用第一个密码 ===");
        System.out.println("复制上面任意一个密码，执行以下 SQL：");
        System.out.println();
        System.out.println("USE online_exam;");
        System.out.println("UPDATE student SET password = '替换为上面生成的密码';");
        System.out.println("UPDATE teacher SET password = '替换为上面生成的密码';");
        System.out.println("UPDATE admin SET password = '替换为上面生成的密码';");
    }
}

