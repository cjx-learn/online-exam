package com.exam.entity;

import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 管理员实体类
 */
@Data
public class Admin implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String username;
    private String password;
    private String realName;
    private String email;
    private String phone;
    private Integer superAdmin; // 0-否 1-是
    private Integer status;     // 0-禁用 1-启用
    private Date createTime;
    private Date updateTime;
}

