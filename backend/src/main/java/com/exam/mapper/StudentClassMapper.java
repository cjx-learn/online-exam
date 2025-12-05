package com.exam.mapper;

import com.exam.entity.StudentClass;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 学生-班级关联Mapper接口
 */
@Mapper
public interface StudentClassMapper {
    
    /**
     * 根据ID查询
     */
    StudentClass selectById(@Param("id") Long id);
    
    /**
     * 查询学生的所有班级关联
     */
    List<StudentClass> selectByStudentId(@Param("studentId") Long studentId);
    
    /**
     * 查询班级的所有学生关联
     */
    List<StudentClass> selectByClassId(@Param("classId") Long classId);
    
    /**
     * 查询学生是否已加入班级
     */
    StudentClass selectByStudentAndClass(@Param("studentId") Long studentId, @Param("classId") Long classId);
    
    /**
     * 插入学生-班级关联
     */
    int insert(StudentClass studentClass);
    
    /**
     * 更新状态
     */
    int updateStatus(@Param("id") Long id, @Param("status") Integer status);
    
    /**
     * 删除关联
     */
    int deleteById(@Param("id") Long id);

    /**
     * 根据学生ID和班级ID删除关联
     */
    int deleteByStudentAndClass(@Param("studentId") Long studentId, @Param("classId") Long classId);
}

