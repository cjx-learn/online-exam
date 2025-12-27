package com.exam.mapper;

import com.exam.entity.Class;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 班级Mapper接口
 */
@Mapper
public interface ClassMapper {
    
    /**
     * 根据ID查询班级
     */
    Class selectById(@Param("id") Long id);
    
    /**
     * 根据邀请码查询班级
     */
    Class selectByInviteCode(@Param("inviteCode") String inviteCode);
    
    /**
     * 根据班级名称查询班级
     */
    Class selectByName(@Param("name") String name);
    
    /**
     * 根据教师ID和班级名称查询班级
     */
    Class selectByTeacherIdAndName(@Param("teacherId") Long teacherId, @Param("name") String name);
    
    /**
     * 查询教师的所有班级
     */
    List<Class> selectByTeacherId(@Param("teacherId") Long teacherId);
    
    /**
     * 查询所有班级
     */
    List<Class> selectAll();
    
    /**
     * 查询学生加入的所有班级（带教师信息）
     */
    List<Class> selectByStudentId(@Param("studentId") Long studentId);
    
    /**
     * 插入班级
     */
    int insert(Class classEntity);
    
    /**
     * 更新班级
     */
    int update(Class classEntity);
    
    /**
     * 删除班级
     */
    int deleteById(@Param("id") Long id);
    
    /**
     * 查询班级的学生数
     */
    int countStudents(@Param("classId") Long classId);
}

