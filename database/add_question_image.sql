-- 给题目表添加图片字段
-- 可以存储单张图片的URL路径

USE online_exam;

-- 添加图片字段到 question 表
ALTER TABLE question ADD COLUMN image VARCHAR(500) COMMENT '题目图片URL' AFTER content;

-- 查看修改后的表结构
DESC question;
