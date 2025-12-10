package com.exam.entity;

import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 学生实体类
 */
@Data
public class Student implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String username;
    private String password;
    private String realName;
    private String studentNo;  // 学号
    private String major;      // 专业
    private String email;
    private String phone;
    private String avatar;     // 头像URL
    private Integer status;    // 0-禁用 1-启用
    private String currentToken; // 当前登录Token（用于单设备限制）
    private Date createTime;
    private Date updateTime;
}

