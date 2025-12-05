package com.exam.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * 密码加密工具类
 */
@Component
public class PasswordUtil {

    private static final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    /**
     * 加密密码
     * @param rawPassword 原始密码
     * @return 加密后的密码
     */
    public static String encode(String rawPassword) {
        return encoder.encode(rawPassword);
    }

    /**
     * 验证密码（兼容明文和加密）
     * @param rawPassword 原始密码
     * @param encodedPassword 加密后的密码或明文密码
     * @return 是否匹配
     */
    public static boolean matches(String rawPassword, String encodedPassword) {
        // 如果是 BCrypt 格式（以 $2a$ 或 $2b$ 或 $2y$ 开头）
        if (encodedPassword != null && encodedPassword.startsWith("$2")) {
            return encoder.matches(rawPassword, encodedPassword);
        }
        // 否则按明文比较（兼容旧数据）
        return rawPassword.equals(encodedPassword);
    }

    /**
     * 生成测试密码（用于生成数据库初始密码）
     * 仅供开发测试使用
     */
    public static void main(String[] args) {
        String password = "123456";
        String encoded = encode(password);
        System.out.println("原始密码: " + password);
        System.out.println("加密后: " + encoded);
        System.out.println("验证结果: " + matches(password, encoded));
    }
}

