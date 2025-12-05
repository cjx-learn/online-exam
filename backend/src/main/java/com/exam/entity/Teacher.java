package com.exam.entity;

import lombok.Data;
import java.io.Serializable;
import java.util.Date;

/**
 * 教师实体类
 */
@Data
public class Teacher implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    private Long id;
    private String username;
    private String password;
    private String realName;
    private String teacherNo;  // 工号
    private String department; // 院系/部门
    private String title;      // 职称
    private String email;
    private String phone;
    private Integer status;    // 0-禁用 1-启用
    private Date createTime;
    private Date updateTime;
}

