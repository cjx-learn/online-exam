-- 添加 current_token 字段用于单设备登录限制
-- 只为学生和管理员添加，教师不限制多设备登录

-- 学生表添加 current_token
ALTER TABLE student ADD COLUMN current_token VARCHAR(1000) COMMENT '当前登录Token（用于单设备限制）';

-- 管理员表添加 current_token
ALTER TABLE admin ADD COLUMN current_token VARCHAR(1000) COMMENT '当前登录Token（用于单设备限制）';

-- 为现有数据设置为NULL
UPDATE student SET current_token = NULL;
UPDATE admin SET current_token = NULL;
