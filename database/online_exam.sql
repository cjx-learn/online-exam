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

 Date: 27/12/2025 13:04:07
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '绠＄悊鍛業D',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀵嗙爜(BCrypt鍔犲瘑)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐪熷疄濮撳悕',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶村儚URL',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '閭??',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鎵嬫満鍙',
  `super_admin` tinyint NOT NULL DEFAULT 0 COMMENT '瓒呯骇绠＄悊鍛? 0-鍚?1-鏄',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-绂佺敤 1-鍚?敤',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `current_token` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '褰撳墠鐧诲綍Token锛堢敤浜庡崟璁惧?闄愬埗锛',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '绠＄悊鍛樿〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'System Admin', '/uploads/avatars/2025/12/07/aed5735c31a44effbe65050d6379285f.jpg', 'admin@exam.com', '13700001001', 1, 1, '2025-11-08 15:36:20', '2025-12-18 17:31:05', 'eyJhbGciOiJIUzUxMiJ9.eyJyb2xlIjoyLCJleHAiOjE3NjY2NTUwNjUsInVzZXJJZCI6MSwiaWF0IjoxNzY2MDUwMjY1LCJ1c2VybmFtZSI6ImFkbWluIn0.D7flCe5GOVHy3-lCf7jNSVEzfNARFISJh43f4K8lkq5dxI5Rutlmvs7s4c1ctqa_sJL2QhENpiKNsJRM7HeG7w');
INSERT INTO `admin` VALUES (2, 'admin2', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'Sub Admin', NULL, 'admin2@exam.com', '13700001002', 0, 1, '2025-11-08 15:36:20', '2025-12-10 18:28:14', 'eyJhbGciOiJIUzUxMiJ9.eyJyb2xlIjoyLCJleHAiOjE3NjU5NjcyOTQsInVzZXJJZCI6MiwiaWF0IjoxNzY1MzYyNDk0LCJ1c2VybmFtZSI6ImFkbWluMiJ9.ImaXDq784SJYwM8bDpf83dm3tCDkpdbIa7mhM6Vr1ql01yhdkyk0HFZEsW6cNmUYPhUe5ockmSEAMR-0HgGrtw');

-- ----------------------------
-- Table structure for announcement
-- ----------------------------
DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍏?憡ID',
  `class_id` bigint NULL DEFAULT NULL COMMENT '鎵?睘鐝?骇ID(null琛ㄧず鍏ㄥ眬鍏?憡)',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏍囬?',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍐呭?',
  `attachments` json NULL COMMENT '闄勪欢鍒楄〃(JSON)',
  `type` tinyint NOT NULL DEFAULT 1 COMMENT '绫诲瀷: 1-鏅?? 2-閲嶈? 3-绱ф?',
  `is_top` tinyint NOT NULL DEFAULT 0 COMMENT '鏄?惁缃?《: 0-鍚?1-鏄',
  `publisher_id` bigint NOT NULL COMMENT '鍙戝竷浜篒D',
  `publisher_role` tinyint NOT NULL COMMENT '鍙戝竷浜鸿?鑹? 1-绠＄悊鍛?2-鏁欏笀',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-鑽夌? 1-宸插彂甯',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE,
  INDEX `idx_publisher`(`publisher_id` ASC, `publisher_role` ASC) USING BTREE,
  INDEX `idx_top`(`is_top` ASC, `create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '閫氱煡鍏?憡琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of announcement
-- ----------------------------
INSERT INTO `announcement` VALUES (1, 1, 'Midterm Exam Notice', 'Midterm exam on April 15, 9:00-11:00 AM.', NULL, 2, 1, 1, 2, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `announcement` VALUES (2, 2, 'Homework Reminder', 'Homework deadline: May 5.', NULL, 1, 0, 2, 2, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `announcement` VALUES (3, NULL, 'System Maintenance Notice', 'System maintenance on Saturday 2:00-4:00 AM.', NULL, 3, 1, 1, 1, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');

-- ----------------------------
-- Table structure for announcement_read
-- ----------------------------
DROP TABLE IF EXISTS `announcement_read`;
CREATE TABLE `announcement_read`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `announcement_id` bigint NOT NULL COMMENT '鍏?憡ID',
  `student_id` bigint NOT NULL COMMENT '瀛︾敓ID',
  `read_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '闃呰?鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_announcement_student`(`announcement_id` ASC, `student_id` ASC) USING BTREE,
  INDEX `idx_announcement`(`announcement_id` ASC) USING BTREE,
  INDEX `idx_student`(`student_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鍏?憡闃呰?璁板綍琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of announcement_read
-- ----------------------------

-- ----------------------------
-- Table structure for answer_record
-- ----------------------------
DROP TABLE IF EXISTS `answer_record`;
CREATE TABLE `answer_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁板綍ID',
  `exam_record_id` bigint NOT NULL COMMENT '鑰冭瘯璁板綍ID',
  `question_id` bigint NOT NULL COMMENT '棰樼洰ID',
  `user_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '鐢ㄦ埛绛旀?',
  `is_correct` tinyint NULL DEFAULT NULL COMMENT '鏄?惁姝ｇ‘: 0-閿欒? 1-姝ｇ‘ null-寰呮壒鏀',
  `score` decimal(5, 2) NULL DEFAULT NULL COMMENT '寰楀垎',
  `teacher_comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '鏁欏笀璇勮?',
  `graded_by` bigint NULL DEFAULT NULL COMMENT '鎵规敼浜篒D(鏁欏笀ID)',
  `graded_time` datetime NULL DEFAULT NULL COMMENT '鎵规敼鏃堕棿',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam_record`(`exam_record_id` ASC) USING BTREE,
  INDEX `idx_question`(`question_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 225 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '绛旈?璁板綍琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of answer_record
-- ----------------------------
INSERT INTO `answer_record` VALUES (63, 35, 16, 'A', 1, 5.00, NULL, NULL, '2025-11-14 16:51:33', '2025-11-14 16:49:22', '2025-11-14 16:51:32');
INSERT INTO `answer_record` VALUES (64, 35, 48, 'B', 0, 0.00, NULL, NULL, '2025-11-14 16:51:33', '2025-11-14 16:49:22', '2025-11-14 16:51:32');
INSERT INTO `answer_record` VALUES (65, 35, 64, 'C', 0, 0.00, NULL, NULL, '2025-11-14 16:51:33', '2025-11-14 16:49:22', '2025-11-14 16:51:32');
INSERT INTO `answer_record` VALUES (66, 35, 96, 'D', 0, 0.00, NULL, NULL, '2025-11-14 16:51:33', '2025-11-14 16:49:22', '2025-11-14 16:51:32');
INSERT INTO `answer_record` VALUES (67, 36, 109, 'D', 0, 0.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (68, 36, 107, 'A', 1, 5.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (69, 36, 106, 'B', 0, 0.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (70, 36, 37, '[\"A\"]', 0, 0.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (71, 36, 85, '[\"B\"]', 0, 0.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (72, 36, 5, 'A', 0, 0.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (73, 36, 53, 'B', 0, 0.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (74, 36, 101, 'B', 0, 0.00, NULL, NULL, '2025-11-14 23:49:35', '2025-11-14 23:49:12', '2025-11-14 23:49:35');
INSERT INTO `answer_record` VALUES (75, 36, 117, 'asfdsaf', NULL, 5.00, NULL, NULL, '2025-11-15 00:19:54', '2025-11-14 23:49:12', '2025-11-15 00:19:54');
INSERT INTO `answer_record` VALUES (76, 36, 116, 'safsaf', NULL, 5.00, NULL, NULL, '2025-11-15 00:19:54', '2025-11-14 23:49:12', '2025-11-15 00:19:54');
INSERT INTO `answer_record` VALUES (77, 36, 115, 'safsa', NULL, 5.00, NULL, NULL, '2025-11-15 00:19:54', '2025-11-14 23:49:12', '2025-11-15 00:19:54');
INSERT INTO `answer_record` VALUES (78, 36, 114, 'safsaf', NULL, 5.00, NULL, NULL, '2025-11-15 00:19:54', '2025-11-14 23:49:12', '2025-11-15 00:19:54');
INSERT INTO `answer_record` VALUES (79, 36, 21, 'safsaf', NULL, 20.00, NULL, NULL, '2025-11-15 00:19:54', '2025-11-14 23:49:12', '2025-11-15 00:19:54');
INSERT INTO `answer_record` VALUES (80, 36, 69, 'asfsafas', NULL, 20.00, NULL, NULL, '2025-11-15 00:19:54', '2025-11-14 23:49:12', '2025-11-15 00:19:54');
INSERT INTO `answer_record` VALUES (81, 37, 16, 'A', 1, 5.00, NULL, NULL, '2025-11-17 16:08:00', '2025-11-17 16:07:46', '2025-11-17 16:08:00');
INSERT INTO `answer_record` VALUES (82, 37, 48, 'B', 0, 0.00, NULL, NULL, '2025-11-17 16:08:00', '2025-11-17 16:07:46', '2025-11-17 16:08:00');
INSERT INTO `answer_record` VALUES (83, 37, 64, '', 0, 0.00, NULL, NULL, '2025-11-17 16:08:00', '2025-11-17 16:07:46', '2025-11-17 16:08:00');
INSERT INTO `answer_record` VALUES (84, 37, 96, '', 0, 0.00, NULL, NULL, '2025-11-17 16:08:00', '2025-11-17 16:07:46', '2025-11-17 16:08:00');
INSERT INTO `answer_record` VALUES (85, 37, 80, '你好', NULL, NULL, NULL, NULL, NULL, '2025-11-17 16:07:46', '2025-11-17 16:07:59');
INSERT INTO `answer_record` VALUES (86, 37, 32, '我是', NULL, NULL, NULL, NULL, NULL, '2025-11-17 16:07:46', '2025-11-17 16:07:59');
INSERT INTO `answer_record` VALUES (87, 38, 67, '[\"A\",\"D\"]', 0, 0.00, NULL, NULL, '2025-11-17 19:39:54', '2025-11-17 19:39:13', '2025-11-17 19:39:54');
INSERT INTO `answer_record` VALUES (88, 38, 19, '[\"B\",\"C\"]', 0, 0.00, NULL, NULL, '2025-11-17 19:39:54', '2025-11-17 19:39:13', '2025-11-17 19:39:54');
INSERT INTO `answer_record` VALUES (89, 38, 35, 'A', 0, 0.00, NULL, NULL, '2025-11-17 19:39:54', '2025-11-17 19:39:13', '2025-11-17 19:39:54');
INSERT INTO `answer_record` VALUES (90, 38, 83, 'A', 0, 0.00, NULL, NULL, '2025-11-17 19:39:54', '2025-11-17 19:39:13', '2025-11-17 19:39:54');
INSERT INTO `answer_record` VALUES (91, 38, 99, 'ahsai', NULL, 11.00, NULL, NULL, '2025-11-17 20:23:18', '2025-11-17 19:39:13', '2025-11-17 20:23:17');
INSERT INTO `answer_record` VALUES (92, 38, 51, 'wyaubdab', NULL, 14.00, NULL, NULL, '2025-11-17 20:23:22', '2025-11-17 19:39:13', '2025-11-17 20:23:22');
INSERT INTO `answer_record` VALUES (93, 39, 67, '[]', 0, 0.00, NULL, NULL, '2025-11-17 19:41:08', '2025-11-17 19:39:16', '2025-11-17 19:41:08');
INSERT INTO `answer_record` VALUES (94, 39, 19, '[\"A\"]', 0, 0.00, NULL, NULL, '2025-11-17 19:41:08', '2025-11-17 19:39:16', '2025-11-17 19:41:08');
INSERT INTO `answer_record` VALUES (95, 39, 35, 'A', 0, 0.00, NULL, NULL, '2025-11-17 19:41:08', '2025-11-17 19:39:16', '2025-11-17 19:41:08');
INSERT INTO `answer_record` VALUES (96, 39, 83, 'A', 0, 0.00, NULL, NULL, '2025-11-17 19:41:08', '2025-11-17 19:39:16', '2025-11-17 19:41:08');
INSERT INTO `answer_record` VALUES (97, 39, 99, '李四来了', NULL, 11.00, NULL, NULL, '2025-11-17 20:23:20', '2025-11-17 19:39:16', '2025-11-17 20:23:20');
INSERT INTO `answer_record` VALUES (98, 39, 51, '加油李四，csssss\na\nefd\n a\nfe\n ef\naw\nfe\nf\na', NULL, 16.00, NULL, NULL, '2025-11-17 20:23:24', '2025-11-17 19:39:16', '2025-11-17 20:23:24');
INSERT INTO `answer_record` VALUES (99, 40, 67, '[\"A\",\"C\"]', 1, 8.00, NULL, NULL, '2025-11-17 20:25:33', '2025-11-17 20:25:18', '2025-11-17 20:25:32');
INSERT INTO `answer_record` VALUES (100, 40, 19, '[\"B\",\"C\"]', 0, 0.00, NULL, NULL, '2025-11-17 20:25:33', '2025-11-17 20:25:18', '2025-11-17 20:25:32');
INSERT INTO `answer_record` VALUES (101, 40, 35, 'A', 1, 10.00, NULL, NULL, '2025-11-17 20:25:33', '2025-11-17 20:25:18', '2025-11-17 20:25:32');
INSERT INTO `answer_record` VALUES (102, 40, 83, 'A', 1, 10.00, NULL, NULL, '2025-11-17 20:25:33', '2025-11-17 20:25:18', '2025-11-17 20:25:32');
INSERT INTO `answer_record` VALUES (103, 40, 99, 'ajdbauiwdbai', NULL, 0.00, NULL, NULL, '2025-11-17 21:05:52', '2025-11-17 20:25:18', '2025-11-17 21:05:51');
INSERT INTO `answer_record` VALUES (104, 40, 51, 'vsuidabvsiubs', NULL, 20.00, NULL, NULL, '2025-11-17 21:05:55', '2025-11-17 20:25:18', '2025-11-17 21:05:55');
INSERT INTO `answer_record` VALUES (105, 43, 19, '[\"A\"]', 0, 0.00, NULL, NULL, '2025-11-17 20:43:03', '2025-11-17 20:42:40', '2025-11-17 20:43:03');
INSERT INTO `answer_record` VALUES (106, 43, 67, '[\"A\"]', 0, 0.00, NULL, NULL, '2025-11-17 20:43:03', '2025-11-17 20:42:40', '2025-11-17 20:43:03');
INSERT INTO `answer_record` VALUES (107, 43, 35, 'A', 1, 10.00, NULL, NULL, '2025-11-17 20:43:03', '2025-11-17 20:42:40', '2025-11-17 20:43:03');
INSERT INTO `answer_record` VALUES (108, 43, 83, 'A', 1, 10.00, NULL, NULL, '2025-11-17 20:43:03', '2025-11-17 20:42:40', '2025-11-17 20:43:03');
INSERT INTO `answer_record` VALUES (109, 43, 51, 'aa', NULL, 19.00, NULL, NULL, '2025-11-18 10:27:36', '2025-11-17 20:42:40', '2025-11-18 10:27:36');
INSERT INTO `answer_record` VALUES (110, 43, 99, 'aa', NULL, 20.00, NULL, NULL, '2025-11-17 22:30:47', '2025-11-17 20:42:40', '2025-11-17 22:30:47');
INSERT INTO `answer_record` VALUES (111, 42, 51, NULL, NULL, 6.00, NULL, NULL, '2025-11-18 10:27:34', '2025-11-17 21:04:48', '2025-11-18 10:27:34');
INSERT INTO `answer_record` VALUES (112, 42, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:30:47', '2025-11-17 21:05:00', '2025-11-17 22:30:46');
INSERT INTO `answer_record` VALUES (113, 44, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:05:31', '2025-11-17 21:05:14', '2025-11-17 21:05:30');
INSERT INTO `answer_record` VALUES (114, 45, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:05:33', '2025-11-17 21:05:17', '2025-11-17 21:05:33');
INSERT INTO `answer_record` VALUES (115, 44, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:05:36', '2025-11-17 21:05:21', '2025-11-17 21:05:35');
INSERT INTO `answer_record` VALUES (116, 45, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:05:40', '2025-11-17 21:05:23', '2025-11-17 21:05:40');
INSERT INTO `answer_record` VALUES (117, 41, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:07:35', '2025-11-17 21:05:52', '2025-11-17 21:07:35');
INSERT INTO `answer_record` VALUES (118, 41, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:06:00', '2025-11-17 21:05:56', '2025-11-17 21:05:59');
INSERT INTO `answer_record` VALUES (119, 47, 19, '[\"A\"]', 0, 0.00, NULL, NULL, '2025-11-17 21:15:01', '2025-11-17 21:14:45', '2025-11-17 21:15:01');
INSERT INTO `answer_record` VALUES (120, 47, 67, '[\"A\"]', 0, 0.00, NULL, NULL, '2025-11-17 21:15:01', '2025-11-17 21:14:45', '2025-11-17 21:15:01');
INSERT INTO `answer_record` VALUES (121, 47, 35, 'A', 1, 10.00, NULL, NULL, '2025-11-17 21:15:01', '2025-11-17 21:14:45', '2025-11-17 21:15:01');
INSERT INTO `answer_record` VALUES (122, 47, 83, 'A', 1, 10.00, NULL, NULL, '2025-11-17 21:15:01', '2025-11-17 21:14:45', '2025-11-17 21:15:01');
INSERT INTO `answer_record` VALUES (123, 47, 51, 'aa', NULL, 0.00, NULL, NULL, '2025-11-17 21:21:42', '2025-11-17 21:14:45', '2025-11-17 21:21:41');
INSERT INTO `answer_record` VALUES (124, 47, 99, 'bb', NULL, 0.00, NULL, NULL, '2025-11-17 21:21:46', '2025-11-17 21:14:45', '2025-11-17 21:21:45');
INSERT INTO `answer_record` VALUES (125, 46, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:21:41', '2025-11-17 21:17:25', '2025-11-17 21:21:40');
INSERT INTO `answer_record` VALUES (126, 46, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:21:45', '2025-11-17 21:17:30', '2025-11-17 21:21:44');
INSERT INTO `answer_record` VALUES (127, 48, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:52:25', '2025-11-17 21:49:33', '2025-11-17 21:52:24');
INSERT INTO `answer_record` VALUES (128, 49, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:52:31', '2025-11-17 21:49:41', '2025-11-17 21:52:31');
INSERT INTO `answer_record` VALUES (129, 48, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:52:37', '2025-11-17 21:49:49', '2025-11-17 21:52:36');
INSERT INTO `answer_record` VALUES (130, 49, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:52:41', '2025-11-17 21:49:52', '2025-11-17 21:52:41');
INSERT INTO `answer_record` VALUES (131, 50, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:57:01', '2025-11-17 21:55:40', '2025-11-17 21:57:01');
INSERT INTO `answer_record` VALUES (132, 51, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:57:04', '2025-11-17 21:55:47', '2025-11-17 21:57:04');
INSERT INTO `answer_record` VALUES (133, 50, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:57:08', '2025-11-17 21:55:54', '2025-11-17 21:57:07');
INSERT INTO `answer_record` VALUES (134, 51, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 21:57:11', '2025-11-17 21:55:58', '2025-11-17 21:57:10');
INSERT INTO `answer_record` VALUES (135, 52, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:05:40', '2025-11-17 21:58:36', '2025-11-17 22:05:40');
INSERT INTO `answer_record` VALUES (136, 53, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:05:43', '2025-11-17 21:58:40', '2025-11-17 22:05:43');
INSERT INTO `answer_record` VALUES (137, 52, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:05:53', '2025-11-17 21:58:43', '2025-11-17 22:05:52');
INSERT INTO `answer_record` VALUES (138, 53, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:05:49', '2025-11-17 21:58:53', '2025-11-17 22:05:48');
INSERT INTO `answer_record` VALUES (139, 54, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:07:28', '2025-11-17 22:07:27', '2025-11-17 22:07:27');
INSERT INTO `answer_record` VALUES (140, 55, 51, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:07:33', '2025-11-17 22:07:32', '2025-11-17 22:07:32');
INSERT INTO `answer_record` VALUES (141, 54, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:07:36', '2025-11-17 22:07:36', '2025-11-17 22:07:36');
INSERT INTO `answer_record` VALUES (142, 55, 99, NULL, NULL, 0.00, NULL, NULL, '2025-11-17 22:07:39', '2025-11-17 22:07:39', '2025-11-17 22:07:39');
INSERT INTO `answer_record` VALUES (143, 57, 118, 'C', 0, 0.00, NULL, NULL, '2025-11-17 22:12:40', '2025-11-17 22:11:55', '2025-11-17 22:33:17');
INSERT INTO `answer_record` VALUES (144, 57, 67, '[\"D\",\"B\",\"C\",\"A\"]', 0, 0.00, NULL, NULL, '2025-11-17 22:12:40', '2025-11-17 22:11:55', '2025-11-17 22:33:17');
INSERT INTO `answer_record` VALUES (145, 57, 19, '[\"A\",\"B\",\"D\",\"C\"]', 0, 0.00, NULL, NULL, '2025-11-17 22:12:40', '2025-11-17 22:11:55', '2025-11-17 22:33:17');
INSERT INTO `answer_record` VALUES (146, 57, 35, 'A', 1, 10.00, NULL, NULL, '2025-11-17 22:12:40', '2025-11-17 22:11:55', '2025-11-17 22:33:17');
INSERT INTO `answer_record` VALUES (147, 57, 83, 'B', 0, 0.00, NULL, NULL, '2025-11-17 22:12:40', '2025-11-17 22:11:55', '2025-11-17 22:33:17');
INSERT INTO `answer_record` VALUES (148, 57, 51, 'a A a 2$ %22) E_@)E@R\"\"@\n\"\'】\n；f}F :fkmf', NULL, 2.00, NULL, NULL, '2025-11-17 22:17:25', '2025-11-17 22:11:55', '2025-11-17 22:33:17');
INSERT INTO `answer_record` VALUES (149, 57, 99, '', NULL, 0.00, NULL, NULL, '2025-11-17 22:17:37', '2025-11-17 22:11:55', '2025-11-17 22:33:17');
INSERT INTO `answer_record` VALUES (150, 56, 118, 'C', 0, 0.00, NULL, NULL, '2025-11-17 22:12:29', '2025-11-17 22:11:59', '2025-11-17 22:12:29');
INSERT INTO `answer_record` VALUES (151, 56, 67, '[\"A\",\"B\",\"C\",\"D\"]', 0, 0.00, NULL, NULL, '2025-11-17 22:12:29', '2025-11-17 22:11:59', '2025-11-17 22:12:29');
INSERT INTO `answer_record` VALUES (152, 56, 19, '[\"C\"]', 0, 0.00, NULL, NULL, '2025-11-17 22:12:29', '2025-11-17 22:11:59', '2025-11-17 22:12:29');
INSERT INTO `answer_record` VALUES (153, 56, 35, 'A', 1, 10.00, NULL, NULL, '2025-11-17 22:12:29', '2025-11-17 22:11:59', '2025-11-17 22:12:29');
INSERT INTO `answer_record` VALUES (154, 56, 83, 'B', 0, 0.00, NULL, NULL, '2025-11-17 22:12:29', '2025-11-17 22:11:59', '2025-11-17 22:12:29');
INSERT INTO `answer_record` VALUES (155, 56, 51, '头有点痛用户的体验', NULL, 15.00, NULL, NULL, '2025-11-17 22:17:21', '2025-11-17 22:11:59', '2025-11-17 22:17:21');
INSERT INTO `answer_record` VALUES (156, 56, 99, '', NULL, 0.00, NULL, NULL, '2025-11-17 22:17:33', '2025-11-17 22:11:59', '2025-11-17 22:17:33');
INSERT INTO `answer_record` VALUES (157, 58, 118, 'A', 1, 5.00, NULL, NULL, '2025-11-17 22:31:46', '2025-11-17 22:31:28', '2025-11-17 22:31:46');
INSERT INTO `answer_record` VALUES (158, 58, 67, '[\"A\",\"C\"]', 1, 8.00, NULL, NULL, '2025-11-17 22:31:46', '2025-11-17 22:31:28', '2025-11-17 22:31:46');
INSERT INTO `answer_record` VALUES (159, 58, 19, '[\"A\",\"C\"]', 1, 8.00, NULL, NULL, '2025-11-17 22:31:46', '2025-11-17 22:31:28', '2025-11-17 22:31:46');
INSERT INTO `answer_record` VALUES (160, 58, 83, 'A', 1, 10.00, NULL, NULL, '2025-11-17 22:31:46', '2025-11-17 22:31:28', '2025-11-17 22:31:46');
INSERT INTO `answer_record` VALUES (161, 58, 35, 'B', 0, 0.00, NULL, NULL, '2025-11-17 22:31:46', '2025-11-17 22:31:28', '2025-11-17 22:31:46');
INSERT INTO `answer_record` VALUES (162, 58, 99, 'faafa', NULL, NULL, NULL, NULL, NULL, '2025-11-17 22:31:28', '2025-11-17 22:31:46');
INSERT INTO `answer_record` VALUES (163, 58, 51, 'afafafa', NULL, NULL, NULL, NULL, NULL, '2025-11-17 22:31:28', '2025-11-17 22:31:46');
INSERT INTO `answer_record` VALUES (164, 62, 118, 'B', 0, 0.00, NULL, NULL, '2025-11-18 10:26:52', '2025-11-18 10:26:29', '2025-11-18 10:26:51');
INSERT INTO `answer_record` VALUES (165, 62, 19, '[\"B\"]', 0, 0.00, NULL, NULL, '2025-11-18 10:26:52', '2025-11-18 10:26:29', '2025-11-18 10:26:51');
INSERT INTO `answer_record` VALUES (166, 62, 67, '[\"C\"]', 0, 0.00, NULL, NULL, '2025-11-18 10:26:52', '2025-11-18 10:26:29', '2025-11-18 10:26:51');
INSERT INTO `answer_record` VALUES (167, 62, 35, 'B', 0, 0.00, NULL, NULL, '2025-11-18 10:26:52', '2025-11-18 10:26:29', '2025-11-18 10:26:51');
INSERT INTO `answer_record` VALUES (168, 62, 83, 'A', 1, 10.00, NULL, NULL, '2025-11-18 10:26:52', '2025-11-18 10:26:29', '2025-11-18 10:26:51');
INSERT INTO `answer_record` VALUES (169, 62, 99, 'sds', NULL, NULL, NULL, NULL, NULL, '2025-11-18 10:26:29', '2025-11-18 10:26:51');
INSERT INTO `answer_record` VALUES (170, 62, 51, 'asfas', NULL, NULL, NULL, NULL, NULL, '2025-11-18 10:26:29', '2025-11-18 10:26:51');
INSERT INTO `answer_record` VALUES (171, 64, 118, 'B', 0, 0.00, NULL, NULL, '2025-12-06 20:24:07', '2025-11-25 10:20:07', '2025-12-06 20:24:07');
INSERT INTO `answer_record` VALUES (172, 64, 19, '[\"B\",\"C\",\"D\",\"A\"]', 0, 0.00, NULL, NULL, '2025-12-06 20:24:07', '2025-11-25 10:20:07', '2025-12-06 20:24:07');
INSERT INTO `answer_record` VALUES (173, 64, 67, '[\"B\",\"A\"]', 0, 0.00, NULL, NULL, '2025-12-06 20:24:07', '2025-11-25 10:20:07', '2025-12-06 20:24:07');
INSERT INTO `answer_record` VALUES (174, 64, 35, 'B', 0, 0.00, NULL, NULL, '2025-12-06 20:24:07', '2025-11-25 10:20:07', '2025-12-06 20:24:07');
INSERT INTO `answer_record` VALUES (175, 64, 83, 'B', 0, 0.00, NULL, NULL, '2025-12-06 20:24:07', '2025-11-25 10:20:07', '2025-12-06 20:24:07');
INSERT INTO `answer_record` VALUES (176, 64, 51, '', NULL, NULL, NULL, NULL, NULL, '2025-11-25 10:20:07', '2025-11-25 10:20:29');
INSERT INTO `answer_record` VALUES (177, 64, 99, '', NULL, NULL, NULL, NULL, NULL, '2025-11-25 10:20:07', '2025-11-25 10:20:29');
INSERT INTO `answer_record` VALUES (178, 66, 120, 'D', 0, 0.00, NULL, NULL, '2025-12-05 11:22:57', '2025-12-05 11:22:47', '2025-12-05 11:22:56');
INSERT INTO `answer_record` VALUES (179, 66, 121, '[\"B\",\"A\",\"C\"]', 1, 10.00, NULL, NULL, '2025-12-05 11:22:57', '2025-12-05 11:22:47', '2025-12-05 11:22:56');
INSERT INTO `answer_record` VALUES (180, 66, 122, 'A', 1, 3.00, NULL, NULL, '2025-12-05 11:22:57', '2025-12-05 11:22:47', '2025-12-05 11:22:56');
INSERT INTO `answer_record` VALUES (181, 66, 123, 'afsaf', NULL, 2.00, NULL, NULL, '2025-12-05 11:23:55', '2025-12-05 11:22:47', '2025-12-05 11:23:55');
INSERT INTO `answer_record` VALUES (182, 66, 124, 'safsa', NULL, 4.00, NULL, NULL, '2025-12-05 11:24:01', '2025-12-05 11:22:47', '2025-12-05 11:24:01');
INSERT INTO `answer_record` VALUES (183, 67, 135, 'A', 1, 5.00, NULL, NULL, '2025-12-07 23:22:54', '2025-12-07 23:22:32', '2025-12-07 23:22:53');
INSERT INTO `answer_record` VALUES (184, 67, 136, 'A', 1, 5.00, NULL, NULL, '2025-12-07 23:22:54', '2025-12-07 23:22:32', '2025-12-07 23:22:53');
INSERT INTO `answer_record` VALUES (185, 67, 137, '[\"C\",\"B\"]', 0, 0.00, NULL, NULL, '2025-12-07 23:22:54', '2025-12-07 23:22:32', '2025-12-07 23:22:53');
INSERT INTO `answer_record` VALUES (186, 67, 138, 'B', 1, 3.00, NULL, NULL, '2025-12-07 23:22:54', '2025-12-07 23:22:32', '2025-12-07 23:22:53');
INSERT INTO `answer_record` VALUES (187, 67, 139, '6', NULL, NULL, NULL, NULL, NULL, '2025-12-07 23:22:32', '2025-12-07 23:22:53');
INSERT INTO `answer_record` VALUES (188, 67, 140, '6', NULL, NULL, NULL, NULL, NULL, '2025-12-07 23:22:32', '2025-12-07 23:22:53');
INSERT INTO `answer_record` VALUES (189, 68, 136, 'B', 0, 0.00, NULL, NULL, '2025-12-07 23:24:28', '2025-12-07 23:24:18', '2025-12-07 23:24:28');
INSERT INTO `answer_record` VALUES (190, 68, 135, 'A', 1, 5.00, NULL, NULL, '2025-12-07 23:24:28', '2025-12-07 23:24:18', '2025-12-07 23:24:28');
INSERT INTO `answer_record` VALUES (191, 68, 137, '[\"A\",\"B\"]', 0, 0.00, NULL, NULL, '2025-12-07 23:24:28', '2025-12-07 23:24:18', '2025-12-07 23:24:28');
INSERT INTO `answer_record` VALUES (192, 68, 138, 'A', 0, 0.00, NULL, NULL, '2025-12-07 23:24:28', '2025-12-07 23:24:18', '2025-12-07 23:24:28');
INSERT INTO `answer_record` VALUES (193, 68, 139, '6', NULL, 1.00, NULL, NULL, '2025-12-07 23:26:35', '2025-12-07 23:24:18', '2025-12-07 23:26:34');
INSERT INTO `answer_record` VALUES (194, 68, 140, '6', NULL, 10.00, NULL, NULL, '2025-12-12 00:26:52', '2025-12-07 23:24:18', '2025-12-12 00:26:52');
INSERT INTO `answer_record` VALUES (195, 69, 143, 'A', 1, 5.00, NULL, NULL, '2025-12-09 23:46:12', '2025-12-09 23:45:55', '2025-12-09 23:46:12');
INSERT INTO `answer_record` VALUES (196, 69, 16, 'B', 0, 0.00, NULL, NULL, '2025-12-09 23:46:12', '2025-12-09 23:45:55', '2025-12-09 23:46:12');
INSERT INTO `answer_record` VALUES (197, 69, 48, 'C', 0, 0.00, NULL, NULL, '2025-12-09 23:46:12', '2025-12-09 23:45:55', '2025-12-09 23:46:12');
INSERT INTO `answer_record` VALUES (198, 69, 64, 'A', 1, 5.00, NULL, NULL, '2025-12-09 23:46:12', '2025-12-09 23:45:55', '2025-12-09 23:46:12');
INSERT INTO `answer_record` VALUES (199, 69, 96, 'B', 0, 0.00, NULL, NULL, '2025-12-09 23:46:12', '2025-12-09 23:45:55', '2025-12-09 23:46:12');
INSERT INTO `answer_record` VALUES (200, 69, 32, '', NULL, NULL, NULL, NULL, NULL, '2025-12-09 23:45:55', '2025-12-09 23:46:12');
INSERT INTO `answer_record` VALUES (201, 69, 80, '', NULL, NULL, NULL, NULL, NULL, '2025-12-09 23:45:55', '2025-12-09 23:46:12');
INSERT INTO `answer_record` VALUES (202, 70, 136, 'A', 1, 5.00, NULL, NULL, '2025-12-17 22:11:08', '2025-12-17 22:05:18', '2025-12-17 22:11:09');
INSERT INTO `answer_record` VALUES (203, 70, 135, 'A', 1, 5.00, NULL, NULL, '2025-12-17 22:11:08', '2025-12-17 22:05:18', '2025-12-17 22:11:09');
INSERT INTO `answer_record` VALUES (204, 70, 137, '[\"B\"]', 0, 0.00, NULL, NULL, '2025-12-17 22:11:08', '2025-12-17 22:05:18', '2025-12-17 22:11:09');
INSERT INTO `answer_record` VALUES (205, 70, 139, '', NULL, NULL, NULL, NULL, NULL, '2025-12-17 22:05:18', '2025-12-17 22:11:09');
INSERT INTO `answer_record` VALUES (206, 70, 140, '', NULL, NULL, NULL, NULL, NULL, '2025-12-17 22:05:18', '2025-12-17 22:11:09');
INSERT INTO `answer_record` VALUES (207, 71, 136, 'B', 0, 0.00, NULL, NULL, '2025-12-18 18:02:34', '2025-12-17 22:16:32', '2025-12-18 18:02:34');
INSERT INTO `answer_record` VALUES (208, 71, 135, 'B', 0, 0.00, NULL, NULL, '2025-12-18 18:02:34', '2025-12-17 22:16:32', '2025-12-18 18:02:34');
INSERT INTO `answer_record` VALUES (209, 71, 137, '[\"B\"]', 0, 0.00, NULL, NULL, '2025-12-18 18:02:34', '2025-12-17 22:16:32', '2025-12-18 18:02:34');
INSERT INTO `answer_record` VALUES (210, 71, 139, '4155', NULL, NULL, NULL, NULL, NULL, '2025-12-17 22:16:32', '2025-12-18 18:02:33');
INSERT INTO `answer_record` VALUES (211, 71, 140, '你好：\n$x_{n}$$x_{n}$$\\lim_{x \\to \\infty} f(x)$$x^{2}$$\\sum_{i=1}^{n}$$x^{2}$$\\lim_{x \\to \\infty}$', NULL, NULL, NULL, NULL, NULL, '2025-12-17 22:16:32', '2025-12-18 18:02:33');
INSERT INTO `answer_record` VALUES (212, 72, 136, 'C', 0, 0.00, NULL, NULL, '2025-12-17 22:26:36', '2025-12-17 22:19:47', '2025-12-17 22:26:35');
INSERT INTO `answer_record` VALUES (213, 72, 135, 'B', 0, 0.00, NULL, NULL, '2025-12-17 22:26:36', '2025-12-17 22:19:47', '2025-12-17 22:26:35');
INSERT INTO `answer_record` VALUES (214, 72, 137, '[\"C\"]', 0, 0.00, NULL, NULL, '2025-12-17 22:26:36', '2025-12-17 22:19:47', '2025-12-17 22:26:35');
INSERT INTO `answer_record` VALUES (215, 72, 139, '1212', NULL, NULL, NULL, NULL, NULL, '2025-12-17 22:19:47', '2025-12-17 22:26:35');
INSERT INTO `answer_record` VALUES (216, 72, 140, '', NULL, NULL, NULL, NULL, NULL, '2025-12-17 22:19:47', '2025-12-17 22:26:35');
INSERT INTO `answer_record` VALUES (217, 73, 136, 'B', 0, 0.00, NULL, NULL, '2025-12-18 18:09:33', '2025-12-18 18:09:19', '2025-12-18 18:09:32');
INSERT INTO `answer_record` VALUES (218, 73, 135, 'A', 1, 5.00, NULL, NULL, '2025-12-18 18:09:33', '2025-12-18 18:09:19', '2025-12-18 18:09:32');
INSERT INTO `answer_record` VALUES (219, 73, 137, '[\"D\"]', 0, 0.00, NULL, NULL, '2025-12-18 18:09:33', '2025-12-18 18:09:19', '2025-12-18 18:09:32');
INSERT INTO `answer_record` VALUES (220, 73, 139, '', NULL, 1.00, NULL, NULL, '2025-12-18 18:12:15', '2025-12-18 18:09:19', '2025-12-18 18:12:14');
INSERT INTO `answer_record` VALUES (221, 73, 140, '$\\sum_{i=1}^{n}$$\\sum_{i=1}^{n}$$x^{2}$', NULL, 2.00, NULL, NULL, '2025-12-18 18:12:20', '2025-12-18 18:09:19', '2025-12-18 18:12:20');
INSERT INTO `answer_record` VALUES (222, 77, 139, NULL, NULL, 1.00, NULL, NULL, '2025-12-20 19:39:47', '2025-12-20 19:39:46', '2025-12-20 19:39:46');
INSERT INTO `answer_record` VALUES (223, 77, 140, NULL, NULL, 1.00, NULL, NULL, '2025-12-20 19:39:51', '2025-12-20 19:39:50', '2025-12-20 19:39:50');
INSERT INTO `answer_record` VALUES (224, 76, 139, NULL, NULL, 1.00, NULL, NULL, '2025-12-20 20:52:19', '2025-12-20 20:52:18', '2025-12-20 20:52:18');
INSERT INTO `answer_record` VALUES (225, 76, 140, NULL, NULL, 1.00, NULL, NULL, '2025-12-20 20:52:23', '2025-12-20 20:52:22', '2025-12-20 20:52:22');

-- ----------------------------
-- Table structure for class
-- ----------------------------
DROP TABLE IF EXISTS `class`;
CREATE TABLE `class`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鐝?骇ID',
  `course_id` bigint NULL DEFAULT NULL COMMENT '璇剧▼ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐝?骇/璇剧▼鍚嶇О',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '璇剧▼浠ｇ爜',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '璇剧▼鎻忚堪',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '灏侀潰鍥剧墖URL',
  `semester` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '瀛︽湡(濡?2025骞寸?鍐??鏈?',
  `school_year` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '瀛﹀勾(濡?2024-2025)',
  `credit` decimal(3, 1) NULL DEFAULT NULL COMMENT '瀛﹀垎',
  `invite_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閭??鐮?鍞?竴)',
  `teacher_id` bigint NOT NULL COMMENT '涓昏?鏁欏笀ID',
  `assistant_teachers` json NULL COMMENT '鍔╂暀ID鍒楄〃(JSON鏁扮粍)',
  `max_students` int NULL DEFAULT NULL COMMENT '鏈?ぇ瀛︾敓鏁?null琛ㄧず涓嶉檺)',
  `ai_enabled` tinyint NOT NULL DEFAULT 1 COMMENT 'AI鍔熻兘鍚?敤: 0-鍚?1-鏄',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-褰掓。 1-杩涜?涓?2-鏈?紑濮',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_invite_code`(`invite_code` ASC) USING BTREE,
  INDEX `idx_teacher`(`teacher_id` ASC) USING BTREE,
  INDEX `idx_semester`(`semester` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_course_id`(`course_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鐝?骇/璇剧▼琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of class
-- ----------------------------
INSERT INTO `class` VALUES (13, 2, 'Operating System', 'CS202', 'Data Structures and Algorithms Design', NULL, '2025 Fall-Winter', '2024-2025', 4.0, '12DB8DC0', 1, NULL, NULL, 1, 1, '2025-11-10 21:31:55', '2025-11-10 21:31:55');
INSERT INTO `class` VALUES (14, 16, 'DATA Techology', 'CS2025', '', NULL, '2025 Fall-Winter', '2024-2025', 3.0, '1AC07808', 1, NULL, NULL, 1, 1, '2025-11-10 21:32:02', '2025-11-10 21:32:02');
INSERT INTO `class` VALUES (15, 4, 'Database Systems', 'CS302', 'Database System Principles', NULL, '2025 Fall-Winter', '2024-2025', 4.0, '5EDE3403', 1, NULL, NULL, 1, 1, '2025-11-10 21:32:19', '2025-11-10 21:32:19');
INSERT INTO `class` VALUES (16, 5, 'Computer Networks', 'CS304', 'Computer Networks', NULL, '2025 Fall-Winter', '2024-2025', 3.5, '6DD96086', 1, NULL, NULL, 1, 1, '2025-11-10 21:32:42', '2025-11-10 21:32:42');
INSERT INTO `class` VALUES (17, 12, 'Probability Stats', 'MATH202', 'Probability and Statistics', NULL, '2025 Fall-Winter', '2024-2025', 3.5, '231C3CD6', 1, NULL, NULL, 1, 1, '2025-11-10 21:32:47', '2025-11-10 21:32:47');
INSERT INTO `class` VALUES (18, 2, 'Data Structures', 'CS202', 'Data Structures and Algorithms Design', NULL, '2025 Fall-Winter', '2024-2025', 4.0, 'C0859F53', 1, NULL, NULL, 1, 1, '2025-11-10 21:39:34', '2025-11-10 21:39:34');
INSERT INTO `class` VALUES (19, 13, 'Probability Statsd', 'ENG101', 'College English I', NULL, '2025 Fall-Winter', '2024-2025', 3.0, '58A8566C', 1, NULL, NULL, 1, 1, '2025-11-10 21:40:01', '2025-11-10 21:40:01');
INSERT INTO `class` VALUES (20, 17, '计算机网络1', 'DS402', '1', NULL, '2025 Fall-Winter', '2024-2025', 3.0, '4793EC47', 1, NULL, NULL, 1, 1, '2025-11-17 16:04:32', '2025-11-17 16:04:32');
INSERT INTO `class` VALUES (21, 18, 'DATA STUDENT-1班', 'CS111', '', NULL, '2025 Fall-Winter', '2024-2025', 3.0, 'AC80826C', 1, NULL, NULL, 1, 1, '2025-11-17 22:22:50', '2025-11-17 22:22:50');

-- ----------------------------
-- Table structure for course
-- ----------------------------
DROP TABLE IF EXISTS `course`;
CREATE TABLE `course`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璇剧▼ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇剧▼鍚嶇О',
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璇剧▼浠ｇ爜(濡?CS301)',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '璇剧▼鎻忚堪',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '璇剧▼灏侀潰鍥剧墖URL',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '璇剧▼鍒嗙被(濡?璁＄畻鏈恒?鏁板?銆佽嫳璇?',
  `credit` decimal(3, 1) NULL DEFAULT NULL COMMENT '瀛﹀垎',
  `hours` int NULL DEFAULT NULL COMMENT '瀛︽椂',
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '寮??闄㈢郴',
  `level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '璇剧▼绾у埆(鏈??/鐮旂┒鐢?',
  `prerequisite` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍏堜慨璇剧▼',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-鍋滅敤 1-鍚?敤',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_code`(`code` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '璇剧▼琛?鐢辩?鐞嗗憳绠＄悊)' ROW_FORMAT = Dynamic;

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
INSERT INTO `course` VALUES (17, '计算机网络', 'DS402', '', NULL, 'Compueter', 3.0, 48, 'School of Compueter', 'Undergraduate', NULL, 1, '2025-11-17 16:03:56', '2025-11-17 16:03:56');
INSERT INTO `course` VALUES (18, 'DATA STUDENT', 'CS111', '', NULL, 'bajbdaidawu', 3.0, 48, '', 'Undergraduate', NULL, 1, '2025-11-17 22:21:58', '2025-11-17 22:21:58');

-- ----------------------------
-- Table structure for discussion
-- ----------------------------
DROP TABLE IF EXISTS `discussion`;
CREATE TABLE `discussion`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁ㄨ?ID',
  `class_id` bigint NOT NULL COMMENT '鎵?睘鐝?骇ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏍囬?',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍐呭?',
  `images` json NULL COMMENT '鍥剧墖鍒楄〃(JSON)',
  `author_id` bigint NOT NULL COMMENT '浣滆?ID',
  `author_role` tinyint NOT NULL COMMENT '浣滆?瑙掕壊: 1-瀛︾敓 2-鏁欏笀',
  `is_top` tinyint NOT NULL DEFAULT 0 COMMENT '鏄?惁缃?《: 0-鍚?1-鏄',
  `is_excellent` tinyint NOT NULL DEFAULT 0 COMMENT '鏄?惁绮惧崕: 0-鍚?1-鏄',
  `view_count` int NOT NULL DEFAULT 0 COMMENT '娴忚?娆℃暟',
  `reply_count` int NOT NULL DEFAULT 0 COMMENT '鍥炲?鏁',
  `like_count` int NOT NULL DEFAULT 0 COMMENT '鐐硅禐鏁',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-鍒犻櫎 1-姝ｅ父',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE,
  INDEX `idx_author`(`author_id` ASC, `author_role` ASC) USING BTREE,
  INDEX `idx_top`(`is_top` ASC, `create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '璁ㄨ?甯栬〃' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of discussion
-- ----------------------------
INSERT INTO `discussion` VALUES (1, 1, 'Process Scheduling Question', 'What is the difference between FCFS and SJF?', NULL, 1, 1, 0, 0, 25, 3, 0, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `discussion` VALUES (2, 2, 'List Reversal Solution', 'Share a recursive solution for list reversal', NULL, 2, 1, 0, 0, 18, 2, 0, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `discussion` VALUES (3, 3, 'Spring Boot Auto-Configuration', 'How does Spring Boot auto-configuration work?', NULL, 1, 1, 0, 0, 32, 5, 0, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');

-- ----------------------------
-- Table structure for discussion_reply
-- ----------------------------
DROP TABLE IF EXISTS `discussion_reply`;
CREATE TABLE `discussion_reply`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鍥炲?ID',
  `discussion_id` bigint NOT NULL COMMENT '璁ㄨ?ID',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '鐖跺洖澶岻D(null琛ㄧず鐩存帴鍥炲?璁ㄨ?)',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鍥炲?鍐呭?',
  `author_id` bigint NOT NULL COMMENT '浣滆?ID',
  `author_role` tinyint NOT NULL COMMENT '浣滆?瑙掕壊: 1-瀛︾敓 2-鏁欏笀',
  `like_count` int NOT NULL DEFAULT 0 COMMENT '鐐硅禐鏁',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-鍒犻櫎 1-姝ｅ父',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_discussion`(`discussion_id` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE,
  INDEX `idx_author`(`author_id` ASC, `author_role` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '璁ㄨ?鍥炲?琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of discussion_reply
-- ----------------------------

-- ----------------------------
-- Table structure for exam
-- ----------------------------
DROP TABLE IF EXISTS `exam`;
CREATE TABLE `exam`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鑰冭瘯ID',
  `class_id` bigint NULL DEFAULT NULL COMMENT '鎵?睘鐝?骇ID(null琛ㄧず鍏?紑鑰冭瘯)',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鑰冭瘯鏍囬?',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '鑰冭瘯鎻忚堪',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '灏侀潰鍥剧墖',
  `type` tinyint NOT NULL DEFAULT 1 COMMENT '绫诲瀷: 1-姝ｅ紡鑰冭瘯 2-妯℃嫙鑰冭瘯 3-缁冧範',
  `duration` int NOT NULL COMMENT '鑰冭瘯鏃堕暱(鍒嗛挓)',
  `total_score` decimal(6, 2) NOT NULL DEFAULT 100.00 COMMENT '鎬诲垎',
  `pass_score` decimal(6, 2) NOT NULL DEFAULT 60.00 COMMENT '鍙婃牸鍒',
  `start_time` datetime NOT NULL COMMENT '寮??鏃堕棿',
  `end_time` datetime NOT NULL COMMENT '缁撴潫鏃堕棿',
  `allow_retake` tinyint NOT NULL DEFAULT 0 COMMENT '鍏佽?閲嶈?: 0-鍚?1-鏄',
  `max_attempts` int NULL DEFAULT 1 COMMENT '鏈?ぇ鑰冭瘯娆℃暟',
  `shuffle_questions` tinyint NOT NULL DEFAULT 0 COMMENT '闅忔満棰樺簭: 0-鍚?1-鏄',
  `shuffle_options` tinyint NOT NULL DEFAULT 0 COMMENT '闅忔満閫夐」: 0-鍚?1-鏄',
  `show_answer` tinyint NOT NULL DEFAULT 0 COMMENT '鏄剧ず绛旀?: 0-鍚?1-鏄',
  `auto_grade` tinyint NOT NULL DEFAULT 1 COMMENT '鑷?姩鎵规敼: 0-鍚?1-鏄',
  `creator_id` bigint NOT NULL COMMENT '鍒涘缓浜篒D(鏁欏笀ID)',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '鐘舵?: 0-鑽夌? 1-宸插彂甯?2-杩涜?涓?3-宸茬粨鏉',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_time`(`start_time` ASC, `end_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 59 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鑰冭瘯琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam
-- ----------------------------
INSERT INTO `exam` VALUES (30, 19, '测试', NULL, NULL, 1, 1012, 40.00, 24.00, '2025-11-14 00:00:00', '2025-11-14 16:51:32', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-14 16:49:01', '2025-11-14 16:49:01');
INSERT INTO `exam` VALUES (31, 18, '第一次测试', NULL, NULL, 1, 1440, 121.00, 73.00, '2025-11-14 00:00:00', '2025-11-15 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-14 23:48:47', '2025-11-14 23:48:47');
INSERT INTO `exam` VALUES (32, 19, '第一次测试', NULL, NULL, 1, 1440, 64.00, 38.00, '2025-11-17 00:00:00', '2025-11-18 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 16:07:17', '2025-11-17 16:07:17');
INSERT INTO `exam` VALUES (33, 14, '第一次测试', NULL, NULL, 1, 1187, 76.00, 46.00, '2025-11-17 00:00:00', '2025-11-17 19:47:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 19:39:02', '2025-11-17 19:39:02');
INSERT INTO `exam` VALUES (34, 14, '第二次测试', NULL, NULL, 1, 1228, 76.00, 46.00, '2025-11-17 00:00:00', '2025-11-17 20:28:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 20:24:46', '2025-11-17 20:24:46');
INSERT INTO `exam` VALUES (35, 14, '第三次测试', NULL, NULL, 1, 1247, 76.00, 46.00, '2025-11-17 00:00:00', '2025-11-17 20:46:55', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 20:42:18', '2025-11-17 20:42:18');
INSERT INTO `exam` VALUES (36, 14, '第四次测试', NULL, NULL, 1, 2, 76.00, 46.00, '2025-11-17 20:54:59', '2025-11-17 20:57:27', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 20:55:27', '2025-11-17 20:55:27');
INSERT INTO `exam` VALUES (37, 14, '第五次测试', NULL, NULL, 1, 3, 76.00, 46.00, '2025-11-17 21:14:12', '2025-11-17 21:17:12', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 21:14:34', '2025-11-17 21:14:34');
INSERT INTO `exam` VALUES (38, 14, '第六次测试', NULL, NULL, 1, 4, 76.00, 46.00, '2025-11-17 21:41:51', '2025-11-17 21:45:51', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 21:42:30', '2025-11-17 21:42:30');
INSERT INTO `exam` VALUES (39, 14, 'safsa', NULL, NULL, 1, 2, 76.00, 46.00, '2025-11-17 21:52:59', '2025-11-17 21:54:59', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 21:53:17', '2025-11-17 21:53:17');
INSERT INTO `exam` VALUES (40, 14, 'afsafsa', NULL, NULL, 1, 1, 76.00, 46.00, '2025-11-17 21:57:23', '2025-11-17 21:58:23', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 21:57:39', '2025-11-17 21:57:39');
INSERT INTO `exam` VALUES (41, 14, '测试', NULL, NULL, 1, 1, 76.00, 46.00, '2025-11-17 22:06:15', '2025-11-17 22:07:15', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 22:06:47', '2025-11-17 22:06:47');
INSERT INTO `exam` VALUES (42, 14, '最终测试', NULL, NULL, 1, 5, 81.00, 49.00, '2025-11-17 22:11:13', '2025-11-17 22:16:13', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 22:11:40', '2025-11-17 22:11:40');
INSERT INTO `exam` VALUES (43, 14, '2412412', NULL, NULL, 1, 5760, 81.00, 49.00, '2025-11-17 00:00:00', '2025-11-21 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 22:28:58', '2025-11-17 22:28:58');
INSERT INTO `exam` VALUES (44, 14, '期末考试1', NULL, NULL, 1, 2280, 81.00, 49.00, '2025-11-19 00:00:00', '2025-11-20 14:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-17 22:35:11', '2025-11-17 22:35:11');
INSERT INTO `exam` VALUES (45, 14, '1111', NULL, NULL, 1, 1440, 81.00, 49.00, '2025-11-18 00:00:00', '2025-11-19 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-18 10:26:06', '2025-11-18 10:26:06');
INSERT INTO `exam` VALUES (46, 14, 'dafsafsa', NULL, NULL, 1, 15222, 81.00, 49.00, '2025-11-25 10:17:32', '2025-12-06 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-11-25 10:17:51', '2025-11-25 10:17:51');
INSERT INTO `exam` VALUES (47, 18, '第四次测试', NULL, NULL, 1, 683, 43.00, 26.00, '2025-12-05 00:00:00', '2025-12-05 11:23:25', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-05 11:22:13', '2025-12-05 11:22:13');
INSERT INTO `exam` VALUES (48, 20, 'zCzc', NULL, NULL, 1, 24545, 48.00, 29.00, '2025-12-07 22:55:21', '2025-12-25 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-07 22:59:06', '2025-12-07 22:59:06');
INSERT INTO `exam` VALUES (49, 20, '111', NULL, NULL, 1, 2, 48.00, 29.00, '2025-12-07 23:23:35', '2025-12-07 23:25:35', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-07 23:23:56', '2025-12-07 23:23:56');
INSERT INTO `exam` VALUES (50, 19, 'safsa', NULL, NULL, 1, 2, 69.00, 41.00, '2025-12-09 23:44:28', '2025-12-09 23:46:28', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-09 23:45:14', '2025-12-09 23:45:14');
INSERT INTO `exam` VALUES (51, 20, 'asnsafas', NULL, NULL, 1, 18837, 45.00, 27.00, '2025-12-17 22:02:54', '2025-12-31 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-17 22:03:33', '2025-12-17 22:03:33');
INSERT INTO `exam` VALUES (52, 20, 'safsaf', NULL, NULL, 1, 18826, 45.00, 27.00, '2025-12-17 22:14:30', '2025-12-31 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-17 22:14:48', '2025-12-17 22:14:48');
INSERT INTO `exam` VALUES (53, 20, 'sdafas', NULL, NULL, 1, 18825, 45.00, 27.00, '2025-12-17 22:14:49', '2025-12-31 00:00:00', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-17 22:15:12', '2025-12-17 22:15:12');
INSERT INTO `exam` VALUES (54, 20, 'adsa', NULL, NULL, 1, 2, 45.00, 27.00, '2025-12-18 18:08:22', '2025-12-18 18:10:22', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-18 18:08:45', '2025-12-18 18:08:45');
INSERT INTO `exam` VALUES (55, 20, 'safasfsacsac', NULL, NULL, 1, 2, 45.00, 27.00, '2025-12-20 18:54:34', '2025-12-20 18:56:34', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-20 18:54:54', '2025-12-20 18:54:54');
INSERT INTO `exam` VALUES (56, 20, 'asfdsafsa', NULL, NULL, 1, 2, 45.00, 27.00, '2025-12-20 19:01:23', '2025-12-20 19:03:23', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-20 19:01:45', '2025-12-20 19:01:45');
INSERT INTO `exam` VALUES (57, 20, 'ffasfsa', NULL, NULL, 1, 2, 45.00, 27.00, '2025-12-20 19:08:12', '2025-12-20 19:10:12', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-20 19:08:27', '2025-12-20 19:08:27');
INSERT INTO `exam` VALUES (58, 20, 'safsa', NULL, NULL, 1, 2, 45.00, 27.00, '2025-12-20 19:30:36', '2025-12-20 19:32:36', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-20 19:30:51', '2025-12-20 19:30:51');
INSERT INTO `exam` VALUES (59, 20, 'dasfa', NULL, NULL, 1, 2, 45.00, 27.00, '2025-12-20 19:37:26', '2025-12-20 19:39:26', 0, 1, 0, 0, 0, 1, 1, 1, '2025-12-20 19:37:43', '2025-12-20 19:37:43');

-- ----------------------------
-- Table structure for exam_question
-- ----------------------------
DROP TABLE IF EXISTS `exam_question`;
CREATE TABLE `exam_question`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `exam_id` bigint NOT NULL COMMENT '鑰冭瘯ID',
  `question_id` bigint NOT NULL COMMENT '棰樼洰ID',
  `sort_order` int NOT NULL DEFAULT 0 COMMENT '鎺掑簭',
  `score` decimal(5, 2) NOT NULL COMMENT '鏈??鑰冭瘯涓?殑鍒嗗?',
  `is_required` tinyint NOT NULL DEFAULT 1 COMMENT '鏄?惁蹇呯瓟: 0-鍚?1-鏄',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam`(`exam_id` ASC) USING BTREE,
  INDEX `idx_question`(`question_id` ASC) USING BTREE,
  INDEX `idx_sort`(`exam_id` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 322 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鑰冭瘯棰樼洰鍏宠仈琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_question
-- ----------------------------
INSERT INTO `exam_question` VALUES (141, 30, 16, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (142, 30, 48, 0, 15.00, 1);
INSERT INTO `exam_question` VALUES (143, 30, 64, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (144, 30, 96, 0, 15.00, 1);
INSERT INTO `exam_question` VALUES (145, 31, 109, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (146, 31, 107, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (147, 31, 106, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (148, 31, 37, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (149, 31, 85, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (150, 31, 117, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (151, 31, 116, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (152, 31, 115, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (153, 31, 114, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (154, 31, 21, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (155, 31, 69, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (156, 31, 5, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (157, 31, 53, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (158, 31, 101, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (159, 32, 16, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (160, 32, 48, 0, 15.00, 1);
INSERT INTO `exam_question` VALUES (161, 32, 64, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (162, 32, 96, 0, 15.00, 1);
INSERT INTO `exam_question` VALUES (163, 32, 80, 0, 12.00, 1);
INSERT INTO `exam_question` VALUES (164, 32, 32, 0, 12.00, 1);
INSERT INTO `exam_question` VALUES (165, 33, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (166, 33, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (167, 33, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (168, 33, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (169, 33, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (170, 33, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (171, 34, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (172, 34, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (173, 34, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (174, 34, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (175, 34, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (176, 34, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (177, 35, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (178, 35, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (179, 35, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (180, 35, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (181, 35, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (182, 35, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (183, 36, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (184, 36, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (185, 36, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (186, 36, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (187, 36, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (188, 36, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (189, 37, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (190, 37, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (191, 37, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (192, 37, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (193, 37, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (194, 37, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (195, 38, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (196, 38, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (197, 38, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (198, 38, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (199, 38, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (200, 38, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (201, 39, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (202, 39, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (203, 39, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (204, 39, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (205, 39, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (206, 39, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (207, 40, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (208, 40, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (209, 40, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (210, 40, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (211, 40, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (212, 40, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (213, 41, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (214, 41, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (215, 41, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (216, 41, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (217, 41, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (218, 41, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (219, 42, 118, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (220, 42, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (221, 42, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (222, 42, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (223, 42, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (224, 42, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (225, 42, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (226, 43, 118, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (227, 43, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (228, 43, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (229, 43, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (230, 43, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (231, 43, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (232, 43, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (233, 44, 118, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (234, 44, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (235, 44, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (236, 44, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (237, 44, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (238, 44, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (239, 44, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (240, 45, 118, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (241, 45, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (242, 45, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (243, 45, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (244, 45, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (245, 45, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (246, 45, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (247, 46, 118, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (248, 46, 19, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (249, 46, 67, 0, 8.00, 1);
INSERT INTO `exam_question` VALUES (250, 46, 51, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (251, 46, 99, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (252, 46, 35, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (253, 46, 83, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (254, 47, 120, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (255, 47, 121, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (256, 47, 123, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (257, 47, 124, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (258, 47, 122, 0, 3.00, 1);
INSERT INTO `exam_question` VALUES (259, 48, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (260, 48, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (261, 48, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (262, 48, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (263, 48, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (264, 48, 138, 0, 3.00, 1);
INSERT INTO `exam_question` VALUES (265, 49, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (266, 49, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (267, 49, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (268, 49, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (269, 49, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (270, 49, 138, 0, 3.00, 1);
INSERT INTO `exam_question` VALUES (271, 50, 143, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (272, 50, 16, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (273, 50, 48, 0, 15.00, 1);
INSERT INTO `exam_question` VALUES (274, 50, 64, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (275, 50, 96, 0, 15.00, 1);
INSERT INTO `exam_question` VALUES (276, 50, 32, 0, 12.00, 1);
INSERT INTO `exam_question` VALUES (277, 50, 80, 0, 12.00, 1);
INSERT INTO `exam_question` VALUES (278, 51, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (279, 51, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (280, 51, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (281, 51, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (282, 51, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (283, 52, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (284, 52, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (285, 52, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (286, 52, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (287, 52, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (288, 53, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (289, 53, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (290, 53, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (291, 53, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (292, 53, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (293, 54, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (294, 54, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (295, 54, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (296, 54, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (297, 54, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (298, 55, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (299, 55, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (300, 55, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (301, 55, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (302, 55, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (303, 56, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (304, 56, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (305, 56, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (306, 56, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (307, 56, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (308, 57, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (309, 57, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (310, 57, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (311, 57, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (312, 57, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (313, 58, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (314, 58, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (315, 58, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (316, 58, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (317, 58, 140, 0, 20.00, 1);
INSERT INTO `exam_question` VALUES (318, 59, 136, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (319, 59, 135, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (320, 59, 137, 0, 10.00, 1);
INSERT INTO `exam_question` VALUES (321, 59, 139, 0, 5.00, 1);
INSERT INTO `exam_question` VALUES (322, 59, 140, 0, 20.00, 1);

-- ----------------------------
-- Table structure for exam_record
-- ----------------------------
DROP TABLE IF EXISTS `exam_record`;
CREATE TABLE `exam_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璁板綍ID',
  `exam_id` bigint NOT NULL COMMENT '鑰冭瘯ID',
  `student_id` bigint NOT NULL COMMENT '瀛︾敓ID',
  `attempt_number` int NOT NULL DEFAULT 1 COMMENT '绗?嚑娆¤?璇',
  `start_time` datetime NULL DEFAULT NULL COMMENT '寮??鏃堕棿',
  `submit_time` datetime NULL DEFAULT NULL COMMENT '鎻愪氦鏃堕棿',
  `duration` int NULL DEFAULT NULL COMMENT '瀹為檯鐢ㄦ椂(鍒嗛挓)',
  `total_score` decimal(6, 2) NULL DEFAULT NULL COMMENT '寰楀垎',
  `objective_score` decimal(6, 2) NULL DEFAULT NULL COMMENT '瀹㈣?棰樺緱鍒',
  `subjective_score` decimal(6, 2) NULL DEFAULT NULL COMMENT '涓昏?棰樺緱鍒',
  `pass_status` tinyint NULL DEFAULT NULL COMMENT '鍙婃牸鐘舵?: 0-涓嶅強鏍?1-鍙婃牸',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP鍦板潃',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '鐘舵?: 0-鏈?紑濮?1-杩涜?涓?2-宸叉彁浜?3-宸叉壒鏀',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_exam`(`exam_id` ASC) USING BTREE,
  INDEX `idx_student`(`student_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 78 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鑰冭瘯璁板綍琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of exam_record
-- ----------------------------
INSERT INTO `exam_record` VALUES (35, 30, 1, 1, '2025-11-14 16:49:19', '2025-11-14 16:51:33', NULL, 5.00, 5.00, NULL, 0, NULL, 2, '2025-11-14 16:49:01', '2025-11-14 16:51:32');
INSERT INTO `exam_record` VALUES (36, 31, 1, 1, '2025-11-14 23:49:10', '2025-11-14 23:49:35', NULL, 5.00, 5.00, NULL, 0, NULL, 2, '2025-11-14 23:48:47', '2025-11-15 00:19:54');
INSERT INTO `exam_record` VALUES (37, 32, 1, 1, '2025-11-17 16:07:40', '2025-11-17 16:08:00', NULL, 5.00, 5.00, NULL, 0, NULL, 1, '2025-11-17 16:07:17', '2025-11-17 16:08:00');
INSERT INTO `exam_record` VALUES (38, 33, 1, 1, '2025-11-17 19:39:11', '2025-11-17 19:39:54', NULL, 25.00, 0.00, 25.00, 0, NULL, 2, '2025-11-17 19:39:02', '2025-11-17 20:23:22');
INSERT INTO `exam_record` VALUES (39, 33, 2, 1, '2025-11-17 19:39:12', '2025-11-17 19:41:08', NULL, 27.00, 0.00, 27.00, 0, NULL, 2, '2025-11-17 19:39:02', '2025-11-17 20:23:24');
INSERT INTO `exam_record` VALUES (40, 34, 1, 1, '2025-11-17 20:25:15', '2025-11-17 20:25:33', NULL, 48.00, 28.00, 20.00, 0, NULL, 2, '2025-11-17 20:24:47', '2025-11-17 21:05:55');
INSERT INTO `exam_record` VALUES (41, 34, 2, 1, '2025-11-17 00:00:00', '2025-11-17 20:43:15', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 20:24:47', '2025-11-17 21:07:35');
INSERT INTO `exam_record` VALUES (42, 35, 1, 1, '2025-11-17 00:00:00', '2025-11-17 20:46:58', NULL, 6.00, 0.00, 6.00, 0, NULL, 2, '2025-11-17 20:42:18', '2025-11-18 10:27:34');
INSERT INTO `exam_record` VALUES (43, 35, 2, 1, '2025-11-17 20:42:37', '2025-11-17 20:43:03', NULL, 59.00, 20.00, 39.00, 0, NULL, 2, '2025-11-17 20:42:18', '2025-11-18 10:27:36');
INSERT INTO `exam_record` VALUES (44, 36, 1, 1, '2025-11-17 20:54:59', '2025-11-17 20:57:30', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 20:55:27', '2025-11-17 21:05:35');
INSERT INTO `exam_record` VALUES (45, 36, 2, 1, '2025-11-17 20:54:59', '2025-11-17 20:57:30', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 20:55:27', '2025-11-17 21:05:40');
INSERT INTO `exam_record` VALUES (46, 37, 1, 1, '2025-11-17 21:14:12', '2025-11-17 21:17:14', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 21:14:34', '2025-11-17 21:21:44');
INSERT INTO `exam_record` VALUES (47, 37, 2, 1, '2025-11-17 21:14:42', '2025-11-17 21:15:01', NULL, 20.00, 20.00, 0.00, 0, NULL, 2, '2025-11-17 21:14:34', '2025-11-17 21:21:45');
INSERT INTO `exam_record` VALUES (48, 38, 1, 1, '2025-11-17 21:41:51', '2025-11-17 21:49:26', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 21:42:30', '2025-11-17 21:52:36');
INSERT INTO `exam_record` VALUES (49, 38, 2, 1, '2025-11-17 21:41:51', '2025-11-17 21:49:26', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 21:42:30', '2025-11-17 21:52:41');
INSERT INTO `exam_record` VALUES (50, 39, 1, 1, '2025-11-17 21:52:59', '2025-11-17 21:55:25', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 21:53:17', '2025-11-17 21:57:07');
INSERT INTO `exam_record` VALUES (51, 39, 2, 1, '2025-11-17 21:52:59', '2025-11-17 21:55:25', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 21:53:17', '2025-11-17 21:57:10');
INSERT INTO `exam_record` VALUES (52, 40, 1, 1, '2025-11-17 21:57:23', '2025-11-17 21:58:29', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 21:57:39', '2025-11-17 22:05:52');
INSERT INTO `exam_record` VALUES (53, 40, 2, 1, '2025-11-17 21:57:23', '2025-11-17 21:58:29', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 21:57:39', '2025-11-17 22:05:48');
INSERT INTO `exam_record` VALUES (54, 41, 1, 1, '2025-11-17 22:06:15', '2025-11-17 22:07:20', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 22:06:47', '2025-11-17 22:07:36');
INSERT INTO `exam_record` VALUES (55, 41, 2, 1, '2025-11-17 22:06:15', '2025-11-17 22:07:20', NULL, 0.00, 0.00, 0.00, 0, NULL, 2, '2025-11-17 22:06:47', '2025-11-17 22:07:39');
INSERT INTO `exam_record` VALUES (56, 42, 1, 1, '2025-11-17 22:11:57', '2025-11-17 22:12:29', NULL, 25.00, 10.00, 15.00, 0, NULL, 2, '2025-11-17 22:11:40', '2025-11-17 22:17:33');
INSERT INTO `exam_record` VALUES (57, 42, 2, 1, '2025-11-17 22:11:48', '2025-11-17 22:12:40', NULL, 12.00, 10.00, 2.00, 0, NULL, 2, '2025-11-17 22:11:40', '2025-11-17 22:17:36');
INSERT INTO `exam_record` VALUES (58, 43, 1, 1, '2025-11-17 22:31:27', '2025-11-17 22:31:46', NULL, 31.00, 31.00, NULL, 0, NULL, 1, '2025-11-17 22:28:58', '2025-11-17 22:31:46');
INSERT INTO `exam_record` VALUES (59, 43, 2, 1, '2025-11-17 00:00:00', '2025-11-25 09:56:03', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-11-17 22:28:58', '2025-11-25 09:56:02');
INSERT INTO `exam_record` VALUES (60, 44, 1, 1, '2025-11-19 00:00:00', '2025-11-25 09:56:03', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-11-17 22:35:11', '2025-11-25 09:56:03');
INSERT INTO `exam_record` VALUES (61, 44, 2, 1, '2025-11-19 00:00:00', '2025-11-25 09:56:03', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-11-17 22:35:11', '2025-11-25 09:56:03');
INSERT INTO `exam_record` VALUES (62, 45, 1, 1, '2025-11-18 10:26:25', '2025-11-18 10:26:52', NULL, 10.00, 10.00, NULL, 0, NULL, 1, '2025-11-18 10:26:06', '2025-11-18 10:26:51');
INSERT INTO `exam_record` VALUES (63, 45, 2, 1, '2025-11-18 00:00:00', '2025-11-25 09:56:03', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-11-18 10:26:06', '2025-11-25 09:56:03');
INSERT INTO `exam_record` VALUES (64, 46, 1, 1, '2025-12-05 10:59:28', '2025-12-06 20:24:07', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-11-25 10:17:51', '2025-12-06 20:24:07');
INSERT INTO `exam_record` VALUES (65, 46, 2, 1, '2025-11-25 10:17:32', '2025-12-06 20:24:07', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-11-25 10:17:51', '2025-12-06 20:24:07');
INSERT INTO `exam_record` VALUES (66, 47, 1, 1, '2025-12-05 11:22:44', '2025-12-05 11:22:57', NULL, 19.00, 13.00, 6.00, 0, NULL, 2, '2025-12-05 11:22:13', '2025-12-05 11:24:01');
INSERT INTO `exam_record` VALUES (67, 48, 1, 1, '2025-12-07 23:22:13', '2025-12-07 23:22:54', NULL, 13.00, 13.00, NULL, 0, NULL, 1, '2025-12-07 22:59:06', '2025-12-07 23:22:53');
INSERT INTO `exam_record` VALUES (68, 49, 1, 1, '2025-12-07 23:24:10', '2025-12-07 23:24:28', NULL, 16.00, 5.00, 11.00, 0, NULL, 2, '2025-12-07 23:23:56', '2025-12-12 00:26:52');
INSERT INTO `exam_record` VALUES (69, 50, 1, 1, '2025-12-09 23:45:48', '2025-12-09 23:46:12', NULL, 10.00, 10.00, NULL, 0, NULL, 1, '2025-12-09 23:45:14', '2025-12-09 23:46:12');
INSERT INTO `exam_record` VALUES (70, 51, 1, 1, '2025-12-17 22:10:24', '2025-12-17 22:11:08', NULL, 10.00, 10.00, NULL, 0, NULL, 1, '2025-12-17 22:03:33', '2025-12-17 22:11:07');
INSERT INTO `exam_record` VALUES (71, 52, 1, 1, '2025-12-18 17:58:45', '2025-12-18 18:02:34', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-12-17 22:14:48', '2025-12-18 18:02:34');
INSERT INTO `exam_record` VALUES (72, 53, 1, 1, '2025-12-17 22:20:53', '2025-12-17 22:26:36', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-12-17 22:15:12', '2025-12-17 22:26:35');
INSERT INTO `exam_record` VALUES (73, 54, 1, 1, '2025-12-18 18:08:59', '2025-12-18 18:09:33', NULL, 8.00, 5.00, 3.00, 0, NULL, 2, '2025-12-18 18:08:45', '2025-12-18 18:12:20');
INSERT INTO `exam_record` VALUES (74, 55, 1, 1, '2025-12-20 18:54:34', '2025-12-20 19:01:19', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-12-20 18:54:54', '2025-12-20 19:01:19');
INSERT INTO `exam_record` VALUES (75, 56, 1, 1, '2025-12-20 19:01:23', '2025-12-20 19:08:54', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-12-20 19:01:45', '2025-12-20 19:08:54');
INSERT INTO `exam_record` VALUES (76, 57, 1, 1, '2025-12-20 19:08:12', '2025-12-20 19:28:08', NULL, 2.00, 0.00, 2.00, 0, NULL, 2, '2025-12-20 19:08:27', '2025-12-20 20:52:22');
INSERT INTO `exam_record` VALUES (77, 58, 1, 1, '2025-12-20 19:30:36', '2025-12-20 19:36:51', NULL, 2.00, 0.00, 2.00, 0, NULL, 2, '2025-12-20 19:30:51', '2025-12-20 19:39:50');
INSERT INTO `exam_record` VALUES (78, 59, 1, 1, '2025-12-20 19:37:26', '2025-12-20 19:39:55', NULL, 0.00, 0.00, NULL, 0, NULL, 1, '2025-12-20 19:37:43', '2025-12-20 19:39:54');

-- ----------------------------
-- Table structure for homework
-- ----------------------------
DROP TABLE IF EXISTS `homework`;
CREATE TABLE `homework`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '浣滀笟ID',
  `class_id` bigint NOT NULL COMMENT '鎵?睘鐝?骇ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '浣滀笟鏍囬?',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '浣滀笟鎻忚堪',
  `attachments` json NULL COMMENT '闄勪欢鍒楄〃(JSON)',
  `deadline` datetime NOT NULL COMMENT '鎴??鏃堕棿',
  `total_score` decimal(5, 2) NOT NULL DEFAULT 100.00 COMMENT '鎬诲垎',
  `allow_late` tinyint NOT NULL DEFAULT 0 COMMENT '鍏佽?杩熶氦: 0-鍚?1-鏄',
  `late_penalty` decimal(5, 2) NULL DEFAULT NULL COMMENT '杩熶氦鎵ｅ垎',
  `creator_id` bigint NOT NULL COMMENT '鍒涘缓浜篒D(鏁欏笀ID)',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-鑽夌? 1-宸插彂甯?2-宸茬粨鏉',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_id` ASC) USING BTREE,
  INDEX `idx_deadline`(`deadline` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '浣滀笟琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of homework
-- ----------------------------
INSERT INTO `homework` VALUES (1, 1, 'OS Lab Report 1', 'Process Scheduling Algorithm Lab', NULL, '2025-04-30 23:59:59', 100.00, 0, NULL, 1, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `homework` VALUES (2, 2, 'DS Programming Assignment', 'Binary Search Tree Implementation', NULL, '2025-05-05 23:59:59', 100.00, 0, NULL, 2, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `homework` VALUES (3, 3, 'Spring Boot Project', 'Simple Blog System Development', NULL, '2025-05-10 23:59:59', 100.00, 0, NULL, 3, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');

-- ----------------------------
-- Table structure for homework_submission
-- ----------------------------
DROP TABLE IF EXISTS `homework_submission`;
CREATE TABLE `homework_submission`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鎻愪氦ID',
  `homework_id` bigint NOT NULL COMMENT '浣滀笟ID',
  `student_id` bigint NOT NULL COMMENT '瀛︾敓ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '浣滀笟鍐呭?',
  `attachments` json NULL COMMENT '闄勪欢鍒楄〃(JSON)',
  `submit_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鎻愪氦鏃堕棿',
  `is_late` tinyint NOT NULL DEFAULT 0 COMMENT '鏄?惁杩熶氦: 0-鍚?1-鏄',
  `score` decimal(5, 2) NULL DEFAULT NULL COMMENT '寰楀垎',
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '鏁欏笀鍙嶉?',
  `graded_by` bigint NULL DEFAULT NULL COMMENT '鎵规敼浜篒D(鏁欏笀ID)',
  `graded_time` datetime NULL DEFAULT NULL COMMENT '鎵规敼鏃堕棿',
  `status` tinyint NOT NULL DEFAULT 0 COMMENT '鐘舵?: 0-宸叉彁浜?1-宸叉壒鏀',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_homework_student`(`homework_id` ASC, `student_id` ASC) USING BTREE,
  INDEX `idx_homework`(`homework_id` ASC) USING BTREE,
  INDEX `idx_student`(`student_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '浣滀笟鎻愪氦琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of homework_submission
-- ----------------------------

-- ----------------------------
-- Table structure for material
-- ----------------------------
DROP TABLE IF EXISTS `material`;
CREATE TABLE `material`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '璧勬枡ID',
  `class_id` bigint NOT NULL COMMENT '鎵?睘鐝?骇ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '璧勬枡鏍囬?',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '璧勬枡鎻忚堪',
  `type` tinyint NOT NULL COMMENT '绫诲瀷: 1-璇句欢 2-瑙嗛? 3-鏂囨。 4-浠ｇ爜 5-鍏朵粬',
  `file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢URL',
  `file_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鏂囦欢鍚',
  `file_size` bigint NULL DEFAULT NULL COMMENT '鏂囦欢澶у皬(瀛楄妭)',
  `download_count` int NOT NULL DEFAULT 0 COMMENT '涓嬭浇娆℃暟',
  `uploader_id` bigint NOT NULL COMMENT '涓婁紶浜篒D(鏁欏笀ID)',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-绂佺敤 1-鍚?敤',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_uploader`(`uploader_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀛︿範璧勬枡琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of material
-- ----------------------------
INSERT INTO `material` VALUES (1, 1, 'OS Chapter 1 Slides', 'OS Overview', 1, '/files/os-chapter1.pdf', 'os-chapter1.pdf', 2048576, 0, 1, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `material` VALUES (2, 2, 'DS Video Tutorial', 'Linked List Tutorial', 2, '/files/ds-linkedlist.mp4', 'ds-linkedlist.mp4', 52428800, 0, 2, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `material` VALUES (3, 3, 'Spring Boot Sample Code', 'RESTful API Example', 4, '/files/springboot-demo.zip', 'springboot-demo.zip', 1048576, 0, 3, 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');

-- ----------------------------
-- Table structure for notification
-- ----------------------------
DROP TABLE IF EXISTS `notification`;
CREATE TABLE `notification`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '閫氱煡ID',
  `user_id` bigint NOT NULL COMMENT '鎺ユ敹鑰匢D',
  `user_role` tinyint NOT NULL COMMENT '鎺ユ敹鑰呰?鑹? 0-瀛︾敓 1-鏁欏笀 2-绠＄悊鍛',
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閫氱煡绫诲瀷: exam_publish/grade_release/grading_complete/system',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '閫氱煡鏍囬?',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '閫氱煡鍐呭?',
  `related_id` bigint NULL DEFAULT NULL COMMENT '鍏宠仈ID(濡傝?璇旾D銆佺彮绾?D绛?',
  `related_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '鍏宠仈绫诲瀷: exam/class/grade',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '鏄?惁宸茶?: 0-鏈?? 1-宸茶?',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `read_time` datetime NULL DEFAULT NULL COMMENT '闃呰?鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC, `user_role` ASC) USING BTREE,
  INDEX `idx_read`(`is_read` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '娑堟伅閫氱煡琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notification
-- ----------------------------
INSERT INTO `notification` VALUES (6, 1, 0, 'grading_complete', '试卷批改完成', '您的「ffasfsa」试卷已批改完成，请查看成绩。', 57, 'exam', 0, '2025-12-20 20:52:18', NULL);
INSERT INTO `notification` VALUES (7, 1, 0, 'grading_complete', '试卷批改完成', '您的「ffasfsa」试卷已批改完成，请查看成绩。', 57, 'exam', 0, '2025-12-20 20:52:22', NULL);

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏃ュ織ID',
  `user_id` bigint NOT NULL COMMENT '鐢ㄦ埛ID',
  `user_role` tinyint NOT NULL COMMENT '鐢ㄦ埛瑙掕壊: 1-瀛︾敓 2-鏁欏笀 3-绠＄悊鍛',
  `operation` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鎿嶄綔绫诲瀷',
  `method` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '璇锋眰鏂规硶',
  `params` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '璇锋眰鍙傛暟',
  `ip_address` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP鍦板潃',
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐢ㄦ埛浠ｇ悊',
  `execution_time` int NULL DEFAULT NULL COMMENT '鎵ц?鏃堕棿(姣??)',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-澶辫触 1-鎴愬姛',
  `error_msg` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '閿欒?淇℃伅',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user`(`user_id` ASC, `user_role` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鎿嶄綔鏃ュ織琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------

-- ----------------------------
-- Table structure for question
-- ----------------------------
DROP TABLE IF EXISTS `question`;
CREATE TABLE `question`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '棰樼洰ID',
  `type` tinyint NOT NULL COMMENT '棰樼洰绫诲瀷: 1-鍗曢? 2-澶氶? 3-鍒ゆ柇 4-濉?┖ 5-绠?瓟 6-缂栫▼',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鍒嗙被/鏍囩?',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '棰樼洰鍐呭?(鏀?寔Markdown)',
  `image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '题目图片URL',
  `options` json NULL COMMENT '閫夐」(JSON鏍煎紡: [{key:\"A\",value:\"閫夐」鍐呭?\"}])',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '绛旀?(澶氶?鐢ㄩ?鍙峰垎闅?',
  `analysis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '瑙ｆ瀽',
  `difficulty` tinyint NOT NULL DEFAULT 2 COMMENT '闅惧害: 1-绠?崟 2-涓?瓑 3-鍥伴毦 4-鏋侀毦',
  `score` decimal(5, 2) NOT NULL DEFAULT 5.00 COMMENT '榛樿?鍒嗗?',
  `use_count` int NOT NULL DEFAULT 0 COMMENT '浣跨敤娆℃暟',
  `correct_rate` decimal(5, 2) NULL DEFAULT NULL COMMENT '姝ｇ‘鐜?%)',
  `creator_id` bigint NOT NULL COMMENT '鍒涘缓浜篒D(鏁欏笀ID)',
  `is_public` tinyint NOT NULL DEFAULT 0 COMMENT '鏄?惁鍏?紑: 0-绉佹湁 1-鍏?紑',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-绂佺敤 1-鍚?敤',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `course_id` bigint NULL DEFAULT NULL COMMENT '课程ID',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `idx_category`(`category` ASC) USING BTREE,
  INDEX `idx_difficulty`(`difficulty` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_id` ASC) USING BTREE,
  INDEX `idx_public`(`is_public` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 144 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '棰樺簱琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of question
-- ----------------------------
INSERT INTO `question` VALUES (4, 1, 'Operating System Basics', 'Which of the following is true for Operating System (Q1)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 1);
INSERT INTO `question` VALUES (5, 3, 'Data Structures Advanced Concepts', 'Statement about Data Structures: This is a true statement (Q2).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 2);
INSERT INTO `question` VALUES (6, 1, 'Java Web Design Applications', 'Which of the following is true for Java Web Design (Q3)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 3);
INSERT INTO `question` VALUES (7, 2, 'Database Systems Theory', 'Select all correct options for Database Systems (Q4).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 4);
INSERT INTO `question` VALUES (8, 5, 'Computer Networks Practice', 'Explain a key principle in Computer Networks (Q5).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 5);
INSERT INTO `question` VALUES (9, 4, 'Software Engineering Fundamental', 'The primary component of Software Engineering is related to ______ (Q6).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 6);
INSERT INTO `question` VALUES (10, 1, 'Intro to AI Deep Dive', 'Which of the following is true for Intro to AI (Q7)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 7);
INSERT INTO `question` VALUES (11, 3, 'Machine Learning Case Study', 'Statement about Machine Learning: This is a true statement (Q8).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 8);
INSERT INTO `question` VALUES (12, 1, 'Advanced Math I Algorithms', 'Which of the following is true for Advanced Math I (Q9)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 9);
INSERT INTO `question` VALUES (13, 2, 'Advanced Math II Principles', 'Select all correct options for Advanced Math II (Q10).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 10);
INSERT INTO `question` VALUES (14, 5, 'Linear Algebra Basics', 'Explain a key principle in Linear Algebra (Q11).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 11);
INSERT INTO `question` VALUES (15, 4, 'Probability Stats Advanced Concepts', 'The primary component of Probability Stats is related to ______ (Q12).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 12);
INSERT INTO `question` VALUES (16, 1, 'College English I Applications', 'Which of the following is true for College English I (Q13)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 13);
INSERT INTO `question` VALUES (17, 3, 'College English II Theory', 'Statement about College English II: This is a true statement (Q14).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 14);
INSERT INTO `question` VALUES (18, 1, 'College Physics Practice', 'Which of the following is true for College Physics (Q15)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 15);
INSERT INTO `question` VALUES (19, 2, 'DATA Techology Fundamental', 'Select all correct options for DATA Techology (Q16).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 16);
INSERT INTO `question` VALUES (20, 5, 'Operating System Deep Dive', 'Explain a key principle in Operating System (Q17).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 1);
INSERT INTO `question` VALUES (21, 4, 'Data Structures Case Study', 'The primary component of Data Structures is related to ______ (Q18).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 2);
INSERT INTO `question` VALUES (22, 1, 'Java Web Design Algorithms', 'Which of the following is true for Java Web Design (Q19)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 3);
INSERT INTO `question` VALUES (23, 3, 'Database Systems Principles', 'Statement about Database Systems: This is a true statement (Q20).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 4);
INSERT INTO `question` VALUES (24, 1, 'Computer Networks Basics', 'Which of the following is true for Computer Networks (Q21)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 5);
INSERT INTO `question` VALUES (25, 2, 'Software Engineering Advanced Concepts', 'Select all correct options for Software Engineering (Q22).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 6);
INSERT INTO `question` VALUES (26, 5, 'Intro to AI Applications', 'Explain a key principle in Intro to AI (Q23).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 7);
INSERT INTO `question` VALUES (27, 4, 'Machine Learning Theory', 'The primary component of Machine Learning is related to ______ (Q24).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 8);
INSERT INTO `question` VALUES (28, 1, 'Advanced Math I Practice', 'Which of the following is true for Advanced Math I (Q25)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 9);
INSERT INTO `question` VALUES (29, 3, 'Advanced Math II Fundamental', 'Statement about Advanced Math II: This is a true statement (Q26).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 10);
INSERT INTO `question` VALUES (30, 1, 'Linear Algebra Deep Dive', 'Which of the following is true for Linear Algebra (Q27)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 11);
INSERT INTO `question` VALUES (31, 2, 'Probability Stats Case Study', 'Select all correct options for Probability Stats (Q28).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 12);
INSERT INTO `question` VALUES (32, 5, 'College English I Algorithms', 'Explain a key principle in College English I (Q29).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 13);
INSERT INTO `question` VALUES (33, 4, 'College English II Principles', 'The primary component of College English II is related to ______ (Q30).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 14);
INSERT INTO `question` VALUES (34, 1, 'College Physics Basics', 'Which of the following is true for College Physics (Q31)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 15);
INSERT INTO `question` VALUES (35, 3, 'DATA Techology Advanced Concepts', 'Statement about DATA Techology: This is a true statement (Q32).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 16);
INSERT INTO `question` VALUES (36, 1, 'Operating System Applications', 'Which of the following is true for Operating System (Q33)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 1);
INSERT INTO `question` VALUES (37, 2, 'Data Structures Theory', 'Select all correct options for Data Structures (Q34).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 2);
INSERT INTO `question` VALUES (38, 5, 'Java Web Design Practice', 'Explain a key principle in Java Web Design (Q35).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 3);
INSERT INTO `question` VALUES (39, 4, 'Database Systems Fundamental', 'The primary component of Database Systems is related to ______ (Q36).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 4);
INSERT INTO `question` VALUES (40, 1, 'Computer Networks Deep Dive', 'Which of the following is true for Computer Networks (Q37)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 5);
INSERT INTO `question` VALUES (41, 3, 'Software Engineering Case Study', 'Statement about Software Engineering: This is a true statement (Q38).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 6);
INSERT INTO `question` VALUES (42, 1, 'Intro to AI Algorithms', 'Which of the following is true for Intro to AI (Q39)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 7);
INSERT INTO `question` VALUES (43, 2, 'Machine Learning Principles', 'Select all correct options for Machine Learning (Q40).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 8);
INSERT INTO `question` VALUES (44, 5, 'Advanced Math I Basics', 'Explain a key principle in Advanced Math I (Q41).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 9);
INSERT INTO `question` VALUES (45, 4, 'Advanced Math II Advanced Concepts', 'The primary component of Advanced Math II is related to ______ (Q42).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 10);
INSERT INTO `question` VALUES (46, 1, 'Linear Algebra Applications', 'Which of the following is true for Linear Algebra (Q43)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 11);
INSERT INTO `question` VALUES (47, 3, 'Probability Stats Theory', 'Statement about Probability Stats: This is a true statement (Q44).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 12);
INSERT INTO `question` VALUES (48, 1, 'College English I Practice', 'Which of the following is true for College English I (Q45)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 13);
INSERT INTO `question` VALUES (49, 2, 'College English II Fundamental', 'Select all correct options for College English II (Q46).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 14);
INSERT INTO `question` VALUES (50, 5, 'College Physics Deep Dive', 'Explain a key principle in College Physics (Q47).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 15);
INSERT INTO `question` VALUES (51, 4, 'DATA Techology Case Study', 'The primary component of DATA Techology is related to ______ (Q48).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 16);
INSERT INTO `question` VALUES (52, 1, 'Operating System Algorithms', 'Which of the following is true for Operating System (Q49)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 1);
INSERT INTO `question` VALUES (53, 3, 'Data Structures Principles', 'Statement about Data Structures: This is a true statement (Q50).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 2);
INSERT INTO `question` VALUES (54, 1, 'Java Web Design Basics', 'Which of the following is true for Java Web Design (Q51)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 3);
INSERT INTO `question` VALUES (55, 2, 'Database Systems Advanced Concepts', 'Select all correct options for Database Systems (Q52).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 4);
INSERT INTO `question` VALUES (56, 5, 'Computer Networks Applications', 'Explain a key principle in Computer Networks (Q53).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 5);
INSERT INTO `question` VALUES (57, 4, 'Software Engineering Theory', 'The primary component of Software Engineering is related to ______ (Q54).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 6);
INSERT INTO `question` VALUES (58, 1, 'Intro to AI Practice', 'Which of the following is true for Intro to AI (Q55)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 7);
INSERT INTO `question` VALUES (59, 3, 'Machine Learning Fundamental', 'Statement about Machine Learning: This is a true statement (Q56).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 8);
INSERT INTO `question` VALUES (60, 1, 'Advanced Math I Deep Dive', 'Which of the following is true for Advanced Math I (Q57)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 9);
INSERT INTO `question` VALUES (61, 2, 'Advanced Math II Case Study', 'Select all correct options for Advanced Math II (Q58).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 10);
INSERT INTO `question` VALUES (62, 5, 'Linear Algebra Algorithms', 'Explain a key principle in Linear Algebra (Q59).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 11);
INSERT INTO `question` VALUES (63, 4, 'Probability Stats Principles', 'The primary component of Probability Stats is related to ______ (Q60).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 12);
INSERT INTO `question` VALUES (64, 1, 'College English I Basics', 'Which of the following is true for College English I (Q61)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 13);
INSERT INTO `question` VALUES (65, 3, 'College English II Advanced Concepts', 'Statement about College English II: This is a true statement (Q62).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 14);
INSERT INTO `question` VALUES (66, 1, 'College Physics Applications', 'Which of the following is true for College Physics (Q63)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 15);
INSERT INTO `question` VALUES (67, 2, 'DATA Techology Theory', 'Select all correct options for DATA Techology (Q64).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 16);
INSERT INTO `question` VALUES (68, 5, 'Operating System Practice', 'Explain a key principle in Operating System (Q65).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 1);
INSERT INTO `question` VALUES (69, 4, 'Data Structures Fundamental', 'The primary component of Data Structures is related to ______ (Q66).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 2);
INSERT INTO `question` VALUES (70, 1, 'Java Web Design Deep Dive', 'Which of the following is true for Java Web Design (Q67)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 3);
INSERT INTO `question` VALUES (71, 3, 'Database Systems Case Study', 'Statement about Database Systems: This is a true statement (Q68).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 4);
INSERT INTO `question` VALUES (72, 1, 'Computer Networks Algorithms', 'Which of the following is true for Computer Networks (Q69)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 5);
INSERT INTO `question` VALUES (73, 2, 'Software Engineering Principles', 'Select all correct options for Software Engineering (Q70).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 6);
INSERT INTO `question` VALUES (74, 5, 'Intro to AI Basics', 'Explain a key principle in Intro to AI (Q71).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 7);
INSERT INTO `question` VALUES (75, 4, 'Machine Learning Advanced Concepts', 'The primary component of Machine Learning is related to ______ (Q72).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 8);
INSERT INTO `question` VALUES (76, 1, 'Advanced Math I Applications', 'Which of the following is true for Advanced Math I (Q73)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 9);
INSERT INTO `question` VALUES (77, 3, 'Advanced Math II Theory', 'Statement about Advanced Math II: This is a true statement (Q74).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 10);
INSERT INTO `question` VALUES (78, 1, 'Linear Algebra Practice', 'Which of the following is true for Linear Algebra (Q75)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 11);
INSERT INTO `question` VALUES (79, 2, 'Probability Stats Fundamental', 'Select all correct options for Probability Stats (Q76).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 12);
INSERT INTO `question` VALUES (80, 5, 'College English I Deep Dive', 'Explain a key principle in College English I (Q77).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 13);
INSERT INTO `question` VALUES (81, 4, 'College English II Case Study', 'The primary component of College English II is related to ______ (Q78).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 14);
INSERT INTO `question` VALUES (82, 1, 'College Physics Algorithms', 'Which of the following is true for College Physics (Q79)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 15);
INSERT INTO `question` VALUES (83, 3, 'DATA Techology Principles', 'Statement about DATA Techology: This is a true statement (Q80).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 16);
INSERT INTO `question` VALUES (84, 1, 'Operating System Basics', 'Which of the following is true for Operating System (Q81)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 1);
INSERT INTO `question` VALUES (85, 2, 'Data Structures Advanced Concepts', 'Select all correct options for Data Structures (Q82).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 2);
INSERT INTO `question` VALUES (86, 5, 'Java Web Design Applications', 'Explain a key principle in Java Web Design (Q83).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 3);
INSERT INTO `question` VALUES (88, 1, 'Computer Networks Practice', 'Which of the following is true for Computer Networks (Q85)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 5);
INSERT INTO `question` VALUES (89, 3, 'Software Engineering Fundamental', 'Statement about Software Engineering: This is a true statement (Q86).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 6);
INSERT INTO `question` VALUES (90, 1, 'Intro to AI Deep Dive', 'Which of the following is true for Intro to AI (Q87)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 7);
INSERT INTO `question` VALUES (91, 2, 'Machine Learning Case Study', 'Select all correct options for Machine Learning (Q88).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 8);
INSERT INTO `question` VALUES (92, 5, 'Advanced Math I Algorithms', 'Explain a key principle in Advanced Math I (Q89).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 9);
INSERT INTO `question` VALUES (93, 4, 'Advanced Math II Principles', 'The primary component of Advanced Math II is related to ______ (Q90).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 10);
INSERT INTO `question` VALUES (94, 1, 'Linear Algebra Basics', 'Which of the following is true for Linear Algebra (Q91)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 11);
INSERT INTO `question` VALUES (95, 3, 'Probability Stats Advanced Concepts', 'Statement about Probability Stats: This is a true statement (Q92).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 12);
INSERT INTO `question` VALUES (96, 1, 'College English I Applications', 'Which of the following is true for College English I (Q93)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 13);
INSERT INTO `question` VALUES (97, 2, 'College English II Theory', 'Select all correct options for College English II (Q94).', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A,C', NULL, 2, 8.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 14);
INSERT INTO `question` VALUES (98, 5, 'College Physics Practice', 'Explain a key principle in College Physics (Q95).', NULL, NULL, 'A key principle involves efficient resource management.', NULL, 2, 12.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 15);
INSERT INTO `question` VALUES (99, 4, 'DATA Techology Fundamental', 'The primary component of DATA Techology is related to ______ (Q96).', NULL, NULL, 'concepts', NULL, 2, 20.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 16);
INSERT INTO `question` VALUES (100, 1, 'Operating System Deep Dive', 'Which of the following is true for Operating System (Q97)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 1);
INSERT INTO `question` VALUES (101, 3, 'Data Structures Case Study', 'Statement about Data Structures: This is a true statement (Q98).', NULL, NULL, 'T', NULL, 2, 10.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 2);
INSERT INTO `question` VALUES (102, 1, 'Java Web Design Algorithms', 'Which of the following is true for Java Web Design (Q99)?', NULL, '{\"A\": \"Option A\", \"B\": \"Option B\", \"C\": \"Option C\", \"D\": \"Option D\"}', 'A', NULL, 2, 15.00, 0, NULL, 1, 1, 1, '2025-11-10 21:31:34', '2025-11-10 21:31:34', 3);
INSERT INTO `question` VALUES (104, 1, '你好', '你好', NULL, '{\"A\": \"一\", \"B\": \"二\", \"C\": \"三\", \"D\": \"四\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 0, 1, '2025-11-10 22:25:59', '2025-11-10 22:25:59', 12);
INSERT INTO `question` VALUES (106, 1, 'data', 'asfsf', NULL, '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 20:00:52', '2025-11-12 20:00:52', 2);
INSERT INTO `question` VALUES (107, 1, '你好', 'safsaf', NULL, '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 2, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 20:01:26', '2025-11-12 20:01:25', 2);
INSERT INTO `question` VALUES (109, 1, '	Data Structures Advanced Concepts', 'saf', NULL, '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 20:03:10', '2025-11-12 20:03:10', 2);
INSERT INTO `question` VALUES (110, 5, 'asfsa', 'sasfas', NULL, NULL, 'safsafsa', NULL, 2, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 20:54:21', '2025-11-12 20:54:20', 12);
INSERT INTO `question` VALUES (111, 4, 'safsa', 'dsad', NULL, NULL, 'sadsa', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 20:54:28', '2025-11-12 20:54:28', 12);
INSERT INTO `question` VALUES (112, 1, 'safsa', 'safsa', NULL, '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 20:54:42', '2025-11-12 20:54:41', 12);
INSERT INTO `question` VALUES (113, 4, 'aFDSA', 'safsa', NULL, NULL, 'safsaf', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 20:54:49', '2025-11-12 20:54:49', 12);
INSERT INTO `question` VALUES (114, 4, 'wqrwq', 'wqr', NULL, NULL, 'wqr', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 22:27:36', '2025-11-12 22:27:35', 2);
INSERT INTO `question` VALUES (115, 4, 'sad', 'safsa', NULL, NULL, 'safsaf', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 22:27:48', '2025-11-12 22:27:47', 2);
INSERT INTO `question` VALUES (116, 4, 'safasfsafsafsafsa', 'ssafsa', NULL, NULL, 'safsa', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 22:42:52', '2025-11-12 22:42:52', 2);
INSERT INTO `question` VALUES (117, 4, 'safsafa', 'sdfsdfa', NULL, NULL, 'sadsaf', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-12 22:43:05', '2025-11-12 22:43:04', 2);
INSERT INTO `question` VALUES (118, 1, 'DATA', 'HHHHHHHH', NULL, '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-11-17 22:11:05', '2025-11-17 22:11:05', 16);
INSERT INTO `question` VALUES (119, 1, '数学', '1+1=？', NULL, '{\"A\": \"1\", \"B\": \"2\", \"C\": \"aa\", \"D\": \"不知道\"}', 'B', NULL, 3, 5.00, 0, NULL, 1, 0, 1, '2025-11-17 22:24:18', '2025-11-17 22:24:17', 18);
INSERT INTO `question` VALUES (125, 1, '示例知识点', '示例：以下哪个是正确的？', NULL, '{\"A\": \"选项A内容\", \"B\": \"选项B内容\", \"C\": \"选项C内容\", \"D\": \"选项D内容\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-05 11:28:07', '2025-12-05 11:28:07', 2);
INSERT INTO `question` VALUES (126, 2, '示例知识点', '示例：以下哪些是正确的？', NULL, '{\"A\": \"选项A\", \"B\": \"选项B\", \"C\": \"选项C\", \"D\": \"选项D\"}', 'A,B,C', NULL, 2, 10.00, 0, NULL, 1, 0, 1, '2025-12-05 11:28:08', '2025-12-05 11:28:07', 2);
INSERT INTO `question` VALUES (127, 3, '示例知识点', '示例：这是判断题？', NULL, NULL, 'F', NULL, 1, 3.00, 0, NULL, 1, 0, 1, '2025-12-05 11:28:08', '2025-12-05 11:28:07', 2);
INSERT INTO `question` VALUES (128, 4, '示例知识点', '示例：请填写____', NULL, NULL, '正确答案', NULL, 2, 5.00, 0, NULL, 1, 0, 1, '2025-12-05 11:28:08', '2025-12-05 11:28:07', 2);
INSERT INTO `question` VALUES (129, 5, '示例知识点', '示例：请简述观点', NULL, NULL, '参考答案', NULL, 3, 20.00, 0, NULL, 1, 0, 1, '2025-12-05 11:28:08', '2025-12-05 11:28:08', 2);
INSERT INTO `question` VALUES (130, 1, '示例知识点', '示例：以下哪个是正确的？', NULL, '{\"A\": \"选项A内容\", \"B\": \"选项B内容\", \"C\": \"选项C内容\", \"D\": \"选项D内容\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-06 00:43:34', '2025-12-06 00:43:34', 16);
INSERT INTO `question` VALUES (131, 2, '示例知识点', '示例：以下哪些是正确的？', NULL, '{\"A\": \"选项A\", \"B\": \"选项B\", \"C\": \"选项C\", \"D\": \"选项D\"}', 'A,B,C', NULL, 2, 10.00, 0, NULL, 1, 0, 1, '2025-12-06 00:43:34', '2025-12-06 00:43:34', 16);
INSERT INTO `question` VALUES (132, 3, '示例知识点', '示例：这是判断题？', NULL, NULL, 'F', NULL, 1, 3.00, 0, NULL, 1, 0, 1, '2025-12-06 00:43:34', '2025-12-06 00:43:34', 16);
INSERT INTO `question` VALUES (133, 4, '示例知识点', '示例：请填写____', NULL, NULL, '正确答案', NULL, 2, 5.00, 0, NULL, 1, 0, 1, '2025-12-06 00:43:35', '2025-12-06 00:43:34', 16);
INSERT INTO `question` VALUES (134, 5, '示例知识点', '示例：请简述观点', NULL, NULL, '参考答案', NULL, 3, 20.00, 0, NULL, 1, 0, 1, '2025-12-06 00:43:35', '2025-12-06 00:43:35', 16);
INSERT INTO `question` VALUES (135, 1, 'DATA', 'safsafsa', '/uploads/questions/2025/12/07/30e70220973d4672b61d043aef6be29b.jpg', '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-07 20:47:42', '2025-12-07 20:47:41', 17);
INSERT INTO `question` VALUES (136, 1, '示例知识点', '示例：以下哪个是正确的？', NULL, '{\"A\": \"选项A内容\", \"B\": \"选项B内容\", \"C\": \"选项C内容\", \"D\": \"选项D内容\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-07 20:48:53', '2025-12-07 20:48:53', 17);
INSERT INTO `question` VALUES (137, 2, '示例知识点', '示例：以下哪些是正确的？', NULL, '{\"A\": \"选项A\", \"B\": \"选项B\", \"C\": \"选项C\", \"D\": \"选项D\"}', 'A,B,C', NULL, 2, 10.00, 0, NULL, 1, 0, 1, '2025-12-07 20:48:54', '2025-12-07 20:48:53', 17);
INSERT INTO `question` VALUES (139, 4, '示例知识点', '示例：请填写____', NULL, NULL, '正确答案', NULL, 2, 5.00, 0, NULL, 1, 0, 1, '2025-12-07 20:48:54', '2025-12-07 20:48:53', 17);
INSERT INTO `question` VALUES (140, 5, '示例知识点', '示例：请简述观点', NULL, NULL, '参考答案', NULL, 3, 20.00, 0, NULL, 1, 0, 1, '2025-12-07 20:48:54', '2025-12-07 20:48:53', 17);
INSERT INTO `question` VALUES (141, 1, 'DATA technolog', 'safsa', '/uploads/questions/2025/12/09/c77a8f7325c741b9919068c121b94991.jpg', '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-09 16:25:09', '2025-12-09 16:25:08', 12);
INSERT INTO `question` VALUES (142, 2, 'saf', 'DATAsafsafasfasfa', '/uploads/questions/2025/12/09/27ead2d8bccf422f96af68045770480d.png', '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A,B', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-09 16:54:21', '2025-12-09 16:54:20', 18);
INSERT INTO `question` VALUES (143, 1, '111', 'safsafasf', '/uploads/questions/2025/12/09/f9617eb9cbea480d89f3f443d11cc822.jpg', '{\"A\": \"A\", \"B\": \"B\", \"C\": \"C\", \"D\": \"D\"}', 'A', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-09 23:44:03', '2025-12-09 23:44:03', 13);
INSERT INTO `question` VALUES (144, 5, 'asfsa', 'safsafas', '/uploads/questions/2025/12/18/422320927ef54c02902e77de6c51a342.jpg', NULL, 'saffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff$x^{2}$$\\sum_{i=1}^{n}$$\\lim_{x \\to \\infty}$$x^{2}$', NULL, 1, 5.00, 0, NULL, 1, 0, 1, '2025-12-18 18:25:30', '2025-12-18 18:25:29', 5);

-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '瀛︾敓ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀵嗙爜(BCrypt鍔犲瘑)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐪熷疄濮撳悕',
  `student_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '瀛﹀彿',
  `gender` tinyint NULL DEFAULT NULL COMMENT '鎬у埆: 0-濂?1-鐢',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶村儚URL',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '閭??',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鎵嬫満鍙',
  `major` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '涓撲笟',
  `grade` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '骞寸骇',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-绂佺敤 1-鍚?敤',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `current_token` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '褰撳墠鐧诲綍Token锛堢敤浜庡崟璁惧?闄愬埗锛',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_student_no`(`student_no` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀛︾敓琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of student
-- ----------------------------
INSERT INTO `student` VALUES (1, 'student1', '$2a$10$ItD5NsBJq9dK93hA3iY7COR/vPNnkPeOkkMa2wIvtEIXTSkOziIbC', 'Zhang San', '2024001', 1, '/uploads/avatars/2025/12/17/bc1b11c6fd60491e9b77a93de4ba65ee.jpg', '1813876172@qq.com', '16691760624', 'Computer Science', '2024', 1, '2025-11-08 15:36:20', '2025-12-20 20:52:49', 'eyJhbGciOiJIUzUxMiJ9.eyJyb2xlIjowLCJleHAiOjE3NjY4Mzk5NjksInVzZXJJZCI6MSwiaWF0IjoxNzY2MjM1MTY5LCJ1c2VybmFtZSI6InN0dWRlbnQxIn0.gCKwdhNG8FZEsSJV_4UzCoTicxYFa-nfFWL6r5A1odKrtkrar0fc5ycXo_HVHPk1ijo5HLAZlAXv1Gv8uCkgEA');
INSERT INTO `student` VALUES (2, 'student2', '$2a$10$Xj0iIHy9RO8ntJqzRGtFzefy3kUYspBxNHAYu7/PAQKca4I6PVIau', 'Li Si', '2024002', 0, '/uploads/avatars/2025/12/16/d92bd50c1096424b96504523dc141f55.jpg', 'aaa', 'eee', 'Software Engineering', '2024', 1, '2025-11-08 15:36:20', '2025-12-16 11:33:31', 'eyJhbGciOiJIUzUxMiJ9.eyJyb2xlIjowLCJleHAiOjE3NjY0NjA3ODgsInVzZXJJZCI6MiwiaWF0IjoxNzY1ODU1OTg4LCJ1c2VybmFtZSI6InN0dWRlbnQyIn0.om0EhQkcyBZXJQBiZtQqLnaud8BNG4uPMG-HxdfOs1rkw9YzWmN_LCD_9Q5c2VWczsbzc_jJa0zK7tf2wNS9wA');
INSERT INTO `student` VALUES (3, 'student3', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'Wang Wu', '2024003', 1, NULL, 'wangwu@exam.com', '13800001003', 'Information Security', '2024', 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20', NULL);

-- ----------------------------
-- Table structure for student_class
-- ----------------------------
DROP TABLE IF EXISTS `student_class`;
CREATE TABLE `student_class`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `student_id` bigint NOT NULL COMMENT '瀛︾敓ID',
  `class_id` bigint NOT NULL COMMENT '鐝?骇ID',
  `join_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍔犲叆鏃堕棿',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-宸查?鍑?1-姝ｅ父',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_student_class`(`student_id` ASC, `class_id` ASC) USING BTREE,
  INDEX `idx_student`(`student_id` ASC) USING BTREE,
  INDEX `idx_class`(`class_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '瀛︾敓-鐝?骇鍏宠仈琛' ROW_FORMAT = Dynamic;

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
-- Table structure for system_config
-- ----------------------------
DROP TABLE IF EXISTS `system_config`;
CREATE TABLE `system_config`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '閰嶇疆ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '閰嶇疆閿',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '閰嶇疆鍊',
  `config_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'string' COMMENT '閰嶇疆绫诲瀷: string/number/boolean/json',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鎻忚堪',
  `is_system` tinyint NOT NULL DEFAULT 0 COMMENT '鏄?惁绯荤粺閰嶇疆: 0-鍚?1-鏄',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '绯荤粺閰嶇疆琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of system_config
-- ----------------------------
INSERT INTO `system_config` VALUES (1, 'system.name', 'Online Exam System', 'string', 'System Name', 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `system_config` VALUES (2, 'system.version', '3.0.0', 'string', 'System Version', 1, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `system_config` VALUES (3, 'exam.max_duration', '180', 'number', 'Max exam duration (minutes)', 0, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `system_config` VALUES (4, 'file.max_size', '104857600', 'number', 'Max file upload size (bytes)', 0, '2025-11-08 15:36:20', '2025-11-08 15:36:20');
INSERT INTO `system_config` VALUES (5, 'ai.enabled', 'true', 'boolean', 'AI feature global switch', 0, '2025-11-08 15:36:20', '2025-11-08 15:36:20');

-- ----------------------------
-- Table structure for teacher
-- ----------------------------
DROP TABLE IF EXISTS `teacher`;
CREATE TABLE `teacher`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '鏁欏笀ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '鐢ㄦ埛鍚',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '瀵嗙爜(BCrypt鍔犲瘑)',
  `real_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鐪熷疄濮撳悕',
  `teacher_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '宸ュ彿',
  `gender` tinyint NULL DEFAULT NULL COMMENT '鎬у埆: 0-濂?1-鐢',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '澶村儚URL',
  `department` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '闄㈢郴/閮ㄩ棬',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鑱岀О',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '閭??',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '鎵嬫満鍙',
  `introduction` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '涓?汉绠?粙',
  `status` tinyint NOT NULL DEFAULT 1 COMMENT '鐘舵?: 0-绂佺敤 1-鍚?敤',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `current_token` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '当前登录Token（用于单设备限制）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_teacher_no`(`teacher_no` ASC) USING BTREE,
  INDEX `idx_department`(`department` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '鏁欏笀琛' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of teacher
-- ----------------------------
INSERT INTO `teacher` VALUES (1, 'teacher1', '$2a$10$PqyZKkF3ag6/tGQungV3N.7vgr036IVd.RUNZn76ZRUFkwqYtXX96', 'Liu Yang', 'T001', 1, '/uploads/avatars/2025/12/09/d77d3fcd7ce94ba682b5f64c8732de47.jpg', 'Computer Science', 'Professor', '1813876172@qq.com', '166917606241', NULL, 1, '2025-11-08 15:36:20', '2025-12-20 20:52:01', 'eyJhbGciOiJIUzUxMiJ9.eyJyb2xlIjoxLCJleHAiOjE3NjY4Mzk5MjAsInVzZXJJZCI6MSwiaWF0IjoxNzY2MjM1MTIwLCJ1c2VybmFtZSI6InRlYWNoZXIxIn0.QDjwd8I_PJk40c0vGE1V0uEPjBF6vi38QhNwaxpQ6n_RJrPDYKi74fk8baNMlIlKEoBxiC8arF2fmcNq9cX9ZQ');
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
