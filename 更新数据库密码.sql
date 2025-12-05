-- 更新现有数据库中的密码为 BCrypt 加密格式
-- 所有账号密码统一为：123456
-- 请在 MySQL 中执行此脚本

USE online_exam;

-- 更新学生表密码
UPDATE student SET password = '$2a$10$N.zmdr9k7NbV8JK1CjhHNOWRdmvHfJhbvFe2sJLYPL.BPY4yyKp0G';

-- 更新教师表密码
UPDATE teacher SET password = '$2a$10$N.zmdr9k7NbV8JK1CjhHNOWRdmvHfJhbvFe2sJLYPL.BPY4yyKp0G';

-- 更新管理员表密码
UPDATE admin SET password = '$2a$10$N.zmdr9k7NbV8JK1CjhHNOWRdmvHfJhbvFe2sJLYPL.BPY4yyKp0G';

-- 验证更新结果
SELECT '学生表' as 表名, COUNT(*) as 更新数量 FROM student WHERE password LIKE '$2a$%'
UNION ALL
SELECT '教师表', COUNT(*) FROM teacher WHERE password LIKE '$2a$%'
UNION ALL
SELECT '管理员表', COUNT(*) FROM admin WHERE password LIKE '$2a$%';



