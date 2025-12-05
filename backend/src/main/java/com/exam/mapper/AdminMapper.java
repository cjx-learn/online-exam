package com.exam.mapper;

import com.exam.entity.Admin;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 管理员 Mapper 接口
 */
@Mapper
public interface AdminMapper {

    /**
     * 根据ID查询管理员
     */
    Admin selectById(@Param("id") Long id);

    /**
     * 根据用户名查询管理员
     */
    Admin selectByUsername(@Param("username") String username);

    /**
     * 插入管理员
     */
    int insert(Admin admin);

    /**
     * 更新管理员
     */
    int update(Admin admin);

    /**
     * 删除管理员
     */
    int deleteById(@Param("id") Long id);
}

