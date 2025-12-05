package com.exam.test;

import com.exam.util.PasswordUtil;

/**
 * 密码测试程序
 * 用于验证 BCrypt 是否正常工作
 */
public class PasswordTest {
    
    public static void main(String[] args) {
        String rawPassword = "123456";
        String dbPassword = "$2a$10$N.zmdr9k7NbV8JK1CjhHNOWRdmvHfJhbvFe2sJLYPL.BPY4yyKp0G";
        
        System.out.println("=== 密码验证测试 ===");
        System.out.println("原始密码: " + rawPassword);
        System.out.println("数据库密码: " + dbPassword);
        System.out.println();
        
        try {
            boolean result = PasswordUtil.matches(rawPassword, dbPassword);
            System.out.println("验证结果: " + result);
            
            if (result) {
                System.out.println("✅ 密码验证成功！BCrypt 工作正常");
            } else {
                System.out.println("❌ 密码验证失败！请检查：");
                System.out.println("1. Maven 依赖是否正确加载");
                System.out.println("2. spring-security-crypto 是否已下载");
                System.out.println("3. bcprov-jdk15on 是否已下载");
            }
        } catch (Exception e) {
            System.out.println("❌ 发生错误: " + e.getMessage());
            e.printStackTrace();
            System.out.println();
            System.out.println("请执行以下步骤：");
            System.out.println("1. 在 IDEA 中点击 Maven 刷新图标");
            System.out.println("2. 或执行: mvn clean install");
        }
    }
}

