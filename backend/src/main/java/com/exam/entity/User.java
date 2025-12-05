package com.exam.entity;

import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 用户实体类
 */
@Data
public class User implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String username;
    private String password;
    private String realName;
    private Integer role; // 0-学生 1-教师 2-管理员
    private String email;
    private String phone;
    private Integer status; // 0-禁用 1-启用
    private Date createTime;
    private Date updateTime;
}

