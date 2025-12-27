-- 消息通知表
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `user_id` bigint NOT NULL COMMENT '接收者ID',
  `user_role` tinyint NOT NULL COMMENT '接收者角色: 0-学生 1-教师 2-管理员',
  `type` varchar(50) NOT NULL COMMENT '通知类型: exam_publish/grade_release/grading_complete/system',
  `title` varchar(200) NOT NULL COMMENT '通知标题',
  `content` text COMMENT '通知内容',
  `related_id` bigint DEFAULT NULL COMMENT '关联ID(如考试ID、班级ID等)',
  `related_type` varchar(50) DEFAULT NULL COMMENT '关联类型: exam/class/grade',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读 1-已读',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `read_time` datetime DEFAULT NULL COMMENT '阅读时间',
  PRIMARY KEY (`id`),
  INDEX `idx_user` (`user_id`, `user_role`),
  INDEX `idx_read` (`is_read`),
  INDEX `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='消息通知表';
