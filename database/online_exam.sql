/*
 Navicat Premium Data Transfer

 Source Server         : cjx
 Source Server Type    : MySQL
 Source Server Version : 80040
 Source Host           : 127.0.0.1:3306
 Source Schema         : online_exam

 Target Server Type    : MySQL
 Target Server Version : 80040
 File Encoding         : 65001

 Date: 18/12/2025 20:54:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt加密)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `super_admin` tinyint NOT NULL DEFAULT 0 COMMENT '超级管理员: 0-否 1-是',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `current_token` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前登录Token（用于单设备限制）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '管理员表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'System Admin', '/uploads/avatars/2025/12/07/aed5735c31a44effbe65050d6379285f.jpg', 'admin@exam.com', '13700001001', 1, 1, '2025-11-08 15:36:20', '2025-12-18 17:31:05', NULL);
INSERT INTO `admin` VALUES (2, 'admin2', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'Sub Admin', NULL, 'admin2@exam.com', '13700001002', 0, 1, '2025-11-08 15:36:20', '2025-12-10 18:28:14', NULL);

-- ----------------------------
-- Table structure for answer_record
-- ----------------------------
DROP TABLE IF EXISTS `answer_record`;
CREATE TABLE `answer_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `exam_record_id` bigint NOT NULL COMMENT '考试记录ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `user_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用户答案',
  `is_correct` tinyint NULL DEFAULT NULL COMMENT '是否正确: 0-错误 1-正确 null-待批改',
  `score` decimal(5, 2) NULL DEFAULT NULL COMMENT '得分',
  `teacher_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '教师评语',
  `graded_by` bigint NULL DEFAULT NULL COMMENT '批改人ID(教师ID)',
  `graded_time` datetime NULL DEFAULT NULL COMMENT '批改时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam_record`(`exam_record_id` ASC) USING BTREE,
  INDEX `idx_question`(`question_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 222 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '答题记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for class
-- ----------------------------
DROP TABLE IF EXISTS `class`;
CREATE TABLE `class`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '班级ID',
  `course_id` bigint NULL DEFAULT NULL COMMENT '课程ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '班级/课程名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '课程代码',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '课程描述',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图片URL',
  `semester` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学期(如2025年秋冬学期)',
  `school_year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学年(如2024-2025)',
  `credit` decimal(3, 1) NULL DEFAULT NULL COMMENT '学分',
  `invite_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '邀请码(唯一)',
  `teacher_id` bigint NOT NULL COMMENT '主讲教师ID',
  `assistant_teachers` json NULL COMMENT '助教ID列表(JSON数组)',
  `max_students` int NULL DEFAULT NULL COMMENT '最大学生数(null表示不限)',
  `ai_enabled` tinyint NOT NULL DEFAULT 1 COMMENT 'AI功能启用: 0-否 1-是',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-归档 1-进行中 2-未开始',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_invite_code`(`invite_code` ASC) USING BTREE,
  INDEX `idx_teacher`(`teacher_id` ASC) USING BTREE,
  INDEX `idx_semester`(`semester` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 22 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '班级/课程表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for course
-- ----------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '课程ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '课程名称',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '课程代码(如CS301)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '课程描述',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '课程封面图片URL',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '课程分类(如计算机、数学、英语)',
  `credit` decimal(3, 1) NULL DEFAULT NULL COMMENT '学分',
  `hours` int NULL DEFAULT NULL COMMENT '学时',
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开课院系',
  `level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '课程级别(本科/研究生)',
  `prerequisite` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '先修课程',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-停用 1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '课程表(由管理员管理)' ROW_FORMAT = Dynamic;


-- ----------------------------
-- Records of course
-- ----------------------------
INSERT INTO `course` VALUES (1, 'Operating System', 'CS301', 'Operating System Principles and Implementation', NULL, 'Computer Science', 4.0, 64, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (2, 'Data Structures', 'CS202', 'Data Structures and Algorithms Design', NULL, 'Computer Science', 4.0, 64, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (3, 'Java Web Design', 'CS403', 'Java Web Application Development', NULL, 'Computer Science', 3.0, 48, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (4, 'Database Systems', 'CS302', 'Database System Principles', NULL, 'Computer Science', 4.0, 64, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (5, 'Computer Networks', 'CS304', 'Computer Networks', NULL, 'Computer Science', 3.5, 56, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (6, 'Software Engineering', 'CS401', 'Software Engineering', NULL, 'Computer Science', 3.0, 48, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (7, 'Intro to AI', 'CS501', 'Introduction to Artificial Intelligence', NULL, 'Computer Science', 3.0, 48, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (8, 'Machine Learning', 'CS502', 'Machine Learning', NULL, 'Computer Science', 3.5, 56, 'School of Computer Science', 'Graduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (9, 'Advanced Math I', 'MATH101', 'Advanced Mathematics I', NULL, 'Mathematics', 5.0, 80, 'School of Mathematics', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (10, 'Advanced Math II', 'MATH102', 'Advanced Mathematics II', NULL, 'Mathematics', 5.0, 80, 'School of Mathematics', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (11, 'Linear Algebra', 'MATH201', 'Linear Algebra', NULL, 'Mathematics', 3.0, 48, 'School of Mathematics', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (12, 'Probability Stats', 'MATH202', 'Probability and Statistics', NULL, 'Mathematics', 3.5, 56, 'School of Mathematics', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (13, 'College English I', 'ENG101', 'College English I', NULL, 'English', 3.0, 48, 'School of Foreign Languages', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (14, 'College English II', 'ENG102', 'College English II', NULL, 'English', 3.0, 48, 'School of Foreign Languages', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (15, 'College Physics', 'PHY101', 'College Physics', NULL, 'Physics', 4.0, 64, 'School of Physics', 'Undergraduate', NULL, 1, '2025-11-08 16:13:05', '2025-11-08 16:13:05');
INSERT INTO `course` VALUES (16, 'DATA Techology', 'CS2025', '', NULL, 'Computer Science', 3.0, 48, 'School of Computer Science', 'Undergraduate', NULL, 1, '2025-11-08 17:02:44', '2025-11-08 17:02:44');
INSERT INTO `course` VALUES (17, '计算机网络', 'DS402', '', NULL, 'Computer', 3.0, 48, 'School of Computer', 'Undergraduate', NULL, 1, '2025-11-17 16:03:56', '2025-11-17 16:03:56');
INSERT INTO `course` VALUES (18, 'DATA STUDENT', 'CS111', '', NULL, 'Computer Science', 3.0, 48, '', 'Undergraduate', NULL, 1, '2025-11-17 22:21:58', '2025-11-17 22:21:58');

-- ----------------------------
-- Table structure for exam
-- ----------------------------
DROP TABLE IF EXISTS `exam`;
CREATE TABLE `exam`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '考试ID',
  `class_id` bigint NULL DEFAULT NULL COMMENT '所属班级ID(null表示公开考试)',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '考试标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '考试描述',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图片',
  `type` tinyint NOT NULL DEFAULT 1 COMMENT '类型: 1-正式考试 2-模拟考试 3-练习',
  `duration` int NOT NULL COMMENT '考试时长(分钟)',
  `total_score` decimal(6, 2) NOT NULL DEFAULT 100.00 COMMENT '总分',
  `pass_score` decimal(6, 2) NOT NULL DEFAULT 60.00 COMMENT '及格分',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime NOT NULL COMMENT '结束时间',
  `allow_retake` tinyint NOT NULL DEFAULT 0 COMMENT '允许重考: 0-否 1-是',
  `max_attempts` int NULL DEFAULT 1 COMMENT '最大考试次数',
  `shuffle_questions` tinyint NOT NULL DEFAULT 0 COMMENT '随机题序: 0-否 1-是',
  `shuffle_options` tinyint NOT NULL DEFAULT 0 COMMENT '随机选项: 0-否 1-是',
  `show_answer` tinyint NOT NULL DEFAULT 0 COMMENT '显示答案: 0-否 1-是',
  `auto_grade` tinyint NOT NULL DEFAULT 1 COMMENT '自动批改: 0-否 1-是',
  `creator_id` bigint NOT NULL COMMENT '创建人ID(教师ID)',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-草稿 1-已发布 2-进行中 3-已结束',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_time`(`start_time` ASC, `end_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 55 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '考试表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for exam_question
-- ----------------------------
DROP TABLE IF EXISTS `exam_question`;
CREATE TABLE `exam_question`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `exam_id` bigint NOT NULL COMMENT '考试ID',
  `question_id` bigint NOT NULL COMMENT '题目ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序',
  `score` decimal(5, 2) NOT NULL COMMENT '本次考试中的分值',
  `is_required` tinyint NOT NULL DEFAULT 1 COMMENT '是否必答: 0-否 1-是',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam`(`exam_id` ASC) USING BTREE,
  INDEX `idx_question`(`question_id` ASC) USING BTREE,
  INDEX `idx_sort`(`exam_id` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 298 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '考试题目关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for exam_record
-- ----------------------------
DROP TABLE IF EXISTS `exam_record`;
CREATE TABLE `exam_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `exam_id` bigint NOT NULL COMMENT '考试ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `attempt_number` int NOT NULL DEFAULT 1 COMMENT '第几次尝试',
  `start_time` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '提交时间',
  `duration` int NULL DEFAULT NULL COMMENT '实际用时(分钟)',
  `total_score` decimal(6, 2) NULL DEFAULT NULL COMMENT '得分',
  `objective_score` decimal(6, 2) NULL DEFAULT NULL COMMENT '客观题得分',
  `subjective_score` decimal(6, 2) NULL DEFAULT NULL COMMENT '主观题得分',
  `pass_status` tinyint NULL DEFAULT NULL COMMENT '及格状态: 0-不及格 1-及格',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '状态: 0-未开始 1-进行中 2-已提交 3-已批改',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam`(`exam_id` ASC) USING BTREE,
  INDEX `idx_student`(`student_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 74 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '考试记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for question
-- ----------------------------
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '题目ID',
  `type` tinyint NOT NULL COMMENT '题目类型: 1-单选 2-多选 3-判断 4-填空 5-简答 6-编程',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '分类/标签',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '题目内容(支持Markdown)',
  `image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '题目图片URL',
  `options` json NULL COMMENT '选项(JSON格式: [{key:"A",value:"选项内容"}])',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '答案(多选用逗号分隔)',
  `analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '解析',
  `difficulty` tinyint NOT NULL DEFAULT 2 COMMENT '难度: 1-简单 2-中等 3-困难 4-极难',
  `score` decimal(5, 2) NOT NULL DEFAULT 5.00 COMMENT '默认分值',
  `use_count` int NOT NULL DEFAULT 0 COMMENT '使用次数',
  `correct_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '正确率(%)',
  `creator_id` bigint NOT NULL COMMENT '创建人ID(教师ID)',
  `is_public` tinyint NOT NULL DEFAULT 0 COMMENT '是否公开: 0-私有 1-公开',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `course_id` bigint NULL DEFAULT NULL COMMENT '课程ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_difficulty`(`difficulty` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_id` ASC) USING BTREE,
  INDEX `idx_public`(`is_public` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 145 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '题库表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '学生ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt加密)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `student_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '学号',
  `gender` tinyint NULL DEFAULT NULL COMMENT '性别: 0-女 1-男',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `major` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '专业',
  `grade` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '年级',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `current_token` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前登录Token（用于单设备限制）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_student_no`(`student_no` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student
-- ----------------------------
INSERT INTO `student` VALUES (1, 'student1', '$2a$10$ItD5NsBJq9dK93hA3iY7COR/vPNnkPeOkkMa2wIvtEIXTSkOziIbC', 'Zhang San', '2024001', 1, '/uploads/avatars/2025/12/17/bc1b11c6fd60491e9b77a93de4ba65ee.jpg', '1813876172@qq.com', '16691760624', 'Computer Science', '2024', 1, '2025-11-08 15:36:20', '2025-12-18 18:12:32', NULL);
INSERT INTO `student` VALUES (2, 'student2', '$2a$10$Xj0iIHy9RO8ntJqzRGtFzefy3kUYspBxNHAYu7/PAQKca4I6PVIau', 'Li Si', '2024002', 0, '/uploads/avatars/2025/12/16/d92bd50c1096424b96504523dc141f55.jpg', 'aaa', 'eee', 'Software Engineering', '2024', 1, '2025-11-08 15:36:20', '2025-12-16 11:33:31', NULL);
INSERT INTO `student` VALUES (3, 'student3', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'Wang Wu', '2024003', 1, NULL, 'wangwu@exam.com', '13800001003', 'Information Security', '2024', 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20', NULL);

-- ----------------------------
-- Table structure for student_class
-- ----------------------------
DROP TABLE IF EXISTS `student_class`;
CREATE TABLE `student_class`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `student_id` bigint NOT NULL COMMENT '学生ID',
  `class_id` bigint NOT NULL COMMENT '班级ID',
  `join_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-已退出 1-正常',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_class`(`student_id` ASC, `class_id` ASC) USING BTREE,
  INDEX `idx_student`(`student_id` ASC) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '学生-班级关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student_class
-- ----------------------------
INSERT INTO `student_class` VALUES (8, 1, 19, '2025-11-11 23:24:25', 1, '2025-11-11 23:24:24');
INSERT INTO `student_class` VALUES (9, 1, 18, '2025-11-11 23:25:06', 1, '2025-11-11 23:25:05');
INSERT INTO `student_class` VALUES (10, 1, 17, '2025-11-11 23:25:20', 1, '2025-11-11 23:25:20');
INSERT INTO `student_class` VALUES (11, 1, 16, '2025-11-11 23:25:35', 1, '2025-11-11 23:25:35');
INSERT INTO `student_class` VALUES (12, 1, 15, '2025-11-11 23:25:52', 1, '2025-11-11 23:25:52');
INSERT INTO `student_class` VALUES (13, 1, 14, '2025-11-11 23:26:05', 1, '2025-11-11 23:26:05');
INSERT INTO `student_class` VALUES (14, 1, 13, '2025-11-11 23:26:25', 1, '2025-11-11 23:26:24');
INSERT INTO `student_class` VALUES (15, 2, 14, '2025-11-14 14:15:34', 1, '2025-11-14 14:15:34');
INSERT INTO `student_class` VALUES (16, 1, 20, '2025-11-17 16:05:20', 1, '2025-11-17 16:05:20');

-- ----------------------------
-- Table structure for teacher
-- ----------------------------
DROP TABLE IF EXISTS `teacher`;
CREATE TABLE `teacher`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '教师ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户名',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '密码(BCrypt加密)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `teacher_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '工号',
  `gender` tinyint NULL DEFAULT NULL COMMENT '性别: 0-女 1-男',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `department` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '院系/部门',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职称',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '手机号',
  `introduction` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '个人简介',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用 1-启用',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `current_token` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前登录Token（用于单设备限制）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_teacher_no`(`teacher_no` ASC) USING BTREE,
  INDEX `idx_department`(`department` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '教师表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teacher
-- ----------------------------
INSERT INTO `teacher` VALUES (1, 'teacher1', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'Liu Yang', 'T001', 1, '/uploads/avatars/2025/12/09/d77d3fcd7ce94ba682b5f64c8732de47.jpg', 'Computer Science', 'Professor', '1813876172@qq.com', '166917606241', NULL, 1, '2025-11-08 15:36:20', '2025-12-18 18:31:57', NULL);
INSERT INTO `teacher` VALUES (2, 'teacher2', '$2a$10$n96nzpUP2eyT4aWy2o2fQeM1hZVGLoIPPF4HXSS4zkWstVe2ciP4G', 'Yu Jingze', 'T002', 1, NULL, 'Computer Science', 'Associate Professor', 'yujingze@exam.com', '13900001002', NULL, 1, '2025-11-08 15:36:20', '2025-12-10 18:30:33', NULL);
INSERT INTO `teacher` VALUES (3, 'teacher3', '$2a$10$zT03hBeuW2yL5klae5yBcetg3wBw3oIEWkAQtnQSmK.QrJV46RvwG', 'Chen Xiaopan', 'T003', 0, NULL, 'Software Engineering', 'Lecturer', 'chenxiaopan@exam.com', '13900001003', NULL, 1, '2025-11-08 15:36:20', '2025-11-17 22:20:53', NULL);

-- ----------------------------
-- View structure for v_exam_statistics
-- ----------------------------
DROP VIEW IF EXISTS `v_exam_statistics`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_exam_statistics` AS select `e`.`id` AS `exam_id`,`e`.`title` AS `exam_title`,`e`.`class_id` AS `class_id`,count(distinct `er`.`student_id`) AS `participant_count`,avg(`er`.`total_score`) AS `avg_score`,max(`er`.`total_score`) AS `max_score`,min(`er`.`total_score`) AS `min_score`,sum((case when (`er`.`pass_status` = 1) then 1 else 0 end)) AS `pass_count`,sum((case when (`er`.`pass_status` = 0) then 1 else 0 end)) AS `fail_count` from (`exam` `e` left join `exam_record` `er` on(((`e`.`id` = `er`.`exam_id`) and (`er`.`status` = 3)))) group by `e`.`id`,`e`.`title`,`e`.`class_id`;

-- ----------------------------
-- View structure for v_student_classes
-- ----------------------------
DROP VIEW IF EXISTS `v_student_classes`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_student_classes` AS select `sc`.`student_id` AS `student_id`,`c`.`id` AS `class_id`,`c`.`name` AS `class_name`,`c`.`code` AS `class_code`,`c`.`semester` AS `semester`,`c`.`school_year` AS `school_year`,`c`.`invite_code` AS `invite_code`,`c`.`ai_enabled` AS `ai_enabled`,`t`.`id` AS `teacher_id`,`t`.`real_name` AS `teacher_name`,`sc`.`join_time` AS `join_time`,`sc`.`status` AS `status` from ((`student_class` `sc` join `class` `c` on((`sc`.`class_id` = `c`.`id`))) join `teacher` `t` on((`c`.`teacher_id` = `t`.`id`))) where ((`sc`.`status` = 1) and (`c`.`status` = 1));

SET FOREIGN_KEY_CHECKS = 1;
