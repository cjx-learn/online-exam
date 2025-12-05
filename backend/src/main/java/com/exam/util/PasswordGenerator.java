package com.exam.util;

/**
 * 密码生成器
 * 用于生成数据库初始化脚本中的加密密码
 */
public class PasswordGenerator {
    
    public static void main(String[] args) {
        String rawPassword = "123456";
        
        System.out.println("=== 密码加密工具 ===");
        System.out.println("原始密码: " + rawPassword);
        System.out.println();
        
        // 生成3个不同的加密结果（BCrypt每次加密结果都不同）
        System.out.println("生成的加密密码（每次运行都不同）：");
        for (int i = 1; i <= 3; i++) {
            String encoded = PasswordUtil.encode(rawPassword);
            System.out.println(i + ". " + encoded);
            System.out.println("   验证: " + PasswordUtil.matches(rawPassword, encoded));
        }
        
        System.out.println();
        System.out.println("提示：将以上任意一个加密密码复制到数据库脚本中使用");
        System.out.println("所有账号都可以使用相同的加密密码，也可以使用不同的");
    }
}

