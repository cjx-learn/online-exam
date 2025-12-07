-- 为用户表添加头像字段
-- 执行此脚本为学生、教师、管理员表添加头像列

USE online_exam;

-- 学生表添加头像字段
ALTER TABLE student 
ADD COLUMN avatar VARCHAR(255) DEFAULT NULL COMMENT '头像URL' AFTER phone;

-- 教师表添加头像字段
ALTER TABLE teacher 
ADD COLUMN avatar VARCHAR(255) DEFAULT NULL COMMENT '头像URL' AFTER phone;

-- 管理员表添加头像字段
ALTER TABLE admin 
ADD COLUMN avatar VARCHAR(255) DEFAULT NULL COMMENT '头像URL' AFTER phone;

-- 验证结果
SELECT '学生表' as 表名, COUNT(*) as 记录数 FROM student;
SELECT '教师表' as 表名, COUNT(*) as 记录数 FROM teacher;
SELECT '管理员表' as 表名, COUNT(*) as 记录数 FROM admin;
