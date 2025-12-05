package com.exam;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 在线考试系统启动类
 */
@SpringBootApplication
@MapperScan("com.exam.mapper")
public class OnlineExamApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(OnlineExamApplication.class, args);
        System.out.println("在线考试系统启动成功！");
        System.out.println("访问地址: http://localhost:8080/api");
    }
}

