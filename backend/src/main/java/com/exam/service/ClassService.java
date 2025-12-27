package com.exam.service;

import com.exam.entity.Class;
import com.exam.entity.Course;
import com.exam.entity.Student;
import com.exam.entity.StudentClass;
import com.exam.mapper.ClassMapper;
import com.exam.mapper.CourseMapper;
import com.exam.mapper.StudentClassMapper;
import com.exam.mapper.StudentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * 班级服务类
 */
@Service
public class ClassService {
    
    @Autowired
    private ClassMapper classMapper;
    
    @Autowired
    private StudentClassMapper studentClassMapper;
    
    @Autowired
    private CourseMapper courseMapper;
    
    @Autowired
    private StudentMapper studentMapper;
    
    /**
     * 获取学生的所有班级
     */
    public List<Class> getStudentClasses(Long studentId) {
        return classMapper.selectByStudentId(studentId);
    }
    
    /**
     * 获取教师的所有班级
     */
    public List<Class> getTeacherClasses(Long teacherId) {
        return classMapper.selectByTeacherId(teacherId);
    }
    
    /**
     * 获取班级的所有学生
     */
    public List<Student> getClassStudents(Long classId) {
        // 查询班级-学生关联
        List<StudentClass> studentClassList = studentClassMapper.selectByClassId(classId);
        
        if (studentClassList == null || studentClassList.isEmpty()) {
            return new ArrayList<>();
        }
        
        // 提取学生ID列表
        List<Long> studentIds = studentClassList.stream()
                .map(StudentClass::getStudentId)
                .collect(Collectors.toList());
        
        // 批量查询学生信息
        if (studentIds.isEmpty()) {
            return new ArrayList<>();
        }
        
        return studentMapper.selectByIds(studentIds);
    }
    
    /**
     * 根据ID获取班级详情
     */
    public Class getClassById(Long id) {
        Class classEntity = classMapper.selectById(id);
        if (classEntity != null) {
            // 查询学生数
            int studentCount = classMapper.countStudents(id);
            classEntity.setStudentCount(studentCount);
        }
        return classEntity;
    }
    
    /**
     * 根据邀请码获取班级
     */
    public Class getClassByInviteCode(String inviteCode) {
        return classMapper.selectByInviteCode(inviteCode);
    }
    
    /**
     * 创建班级
     */
    @Transactional
    public Class createClass(Class classEntity) {
        // 1. 检查同一教师下班级名称是否重复
        if (classEntity.getTeacherId() != null) {
            Class existingClass = classMapper.selectByTeacherIdAndName(classEntity.getTeacherId(), classEntity.getName());
            if (existingClass != null) {
                throw new RuntimeException("您已创建过同名班级，请使用其他名称");
            }
        }

        // 2. 如果指定了课程ID，从课程表同步信息
        if (classEntity.getCourseId() != null) {
            Course course = courseMapper.selectById(classEntity.getCourseId());
            if (course == null) {
                throw new RuntimeException("课程不存在");
            }
            // 同步课程信息到班级表
            classEntity.setCode(course.getCode());
            classEntity.setCredit(course.getCredit());
            // 如果没有指定描述，使用课程描述
            if (classEntity.getDescription() == null || classEntity.getDescription().isEmpty()) {
                classEntity.setDescription(course.getDescription());
            }
        }
        
        // 3. 生成唯一邀请码
        classEntity.setInviteCode(generateInviteCode());
        classEntity.setStatus(1); // 默认进行中
        classEntity.setAiEnabled(1); // 默认启用AI
        classMapper.insert(classEntity);
        return classEntity;
    }
    
    /**
     * 更新班级
     */
    public boolean updateClass(Class classEntity) {
        return classMapper.update(classEntity) > 0;
    }
    
    /**
     * 删除班级（硬删除，级联删除相关数据）
     */
    @Transactional
    public boolean deleteClass(Long id) {
        // 1. 删除班级-学生关联
        studentClassMapper.deleteByClassId(id);
        
        // 2. 删除班级
        return classMapper.deleteById(id) > 0;
    }
    
    /**
     * 学生加入班级
     */
    @Transactional
    public boolean joinClass(Long studentId, String inviteCode) {
        // 1. 查询班级
        Class classEntity = classMapper.selectByInviteCode(inviteCode);
        if (classEntity == null) {
            throw new RuntimeException("邀请码不存在");
        }
        
        if (classEntity.getStatus() != 1) {
            throw new RuntimeException("该班级已归档");
        }
        
        // 2. 检查是否已加入
        StudentClass existing = studentClassMapper.selectByStudentAndClass(studentId, classEntity.getId());
        if (existing != null) {
            if (existing.getStatus() == 1) {
                throw new RuntimeException("您已经加入该班级");
            } else {
                // 重新激活
                studentClassMapper.updateStatus(existing.getId(), 1);
                return true;
            }
        }
        
        // 3. 检查人数限制
        if (classEntity.getMaxStudents() != null) {
            int currentCount = classMapper.countStudents(classEntity.getId());
            if (currentCount >= classEntity.getMaxStudents()) {
                throw new RuntimeException("班级人数已满");
            }
        }
        
        // 4. 加入班级
        StudentClass studentClass = new StudentClass();
        studentClass.setStudentId(studentId);
        studentClass.setClassId(classEntity.getId());
        studentClass.setJoinTime(LocalDateTime.now());
        studentClass.setStatus(1);
        
        return studentClassMapper.insert(studentClass) > 0;
    }
    
    /**
     * 学生退出班级
     */
    public boolean quitClass(Long studentId, Long classId) {
        StudentClass studentClass = studentClassMapper.selectByStudentAndClass(studentId, classId);
        if (studentClass == null) {
            throw new RuntimeException("未加入该班级");
        }
        return studentClassMapper.updateStatus(studentClass.getId(), 0) > 0;
    }
    
    /**
     * 生成唯一邀请码
     */
    private String generateInviteCode() {
        // 生成8位随机邀请码
        String code = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        // 检查是否重复
        if (classMapper.selectByInviteCode(code) != null) {
            return generateInviteCode(); // 递归重试
        }
        return code;
    }
    
    /**
     * 获取所有班级
     */
    public List<Class> getAllClasses() {
        return classMapper.selectAll();
    }
    
    /**
     * 老师将学生从班级中移除
     */
    @Transactional
    public boolean removeStudentFromClass(Long classId, Long studentId) {
        // 1. 检查班级和学生是否存在关联
        StudentClass studentClass = studentClassMapper.selectByStudentAndClass(studentId, classId);
        if (studentClass == null) {
            throw new RuntimeException("学生未加入该班级");
        }
        // 2. 删除关联记录
        return studentClassMapper.deleteByStudentAndClass(studentId, classId) > 0;
    }
}

