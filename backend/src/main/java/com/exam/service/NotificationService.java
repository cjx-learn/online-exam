package com.exam.service;

import com.exam.entity.Notification;
import com.exam.entity.StudentClass;
import com.exam.mapper.NotificationMapper;
import com.exam.mapper.StudentClassMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private StudentClassMapper studentClassMapper;

    /**
     * 发送通知给单个用户
     */
    public void sendToUser(Long userId, Integer userRole, String type, String title, String content, Long relatedId, String relatedType) {
        logger.info("发送通知给用户: userId={}, userRole={}, type={}, title={}", userId, userRole, type, title);
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setUserRole(userRole);
        notification.setType(type);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setRelatedId(relatedId);
        notification.setRelatedType(relatedType);
        int result = notificationMapper.insert(notification);
        logger.info("通知插入结果: {}, notificationId={}", result, notification.getId());
    }

    /**
     * 发送通知给班级所有学生
     */
    public void sendToClassStudents(Long classId, String type, String title, String content, Long relatedId, String relatedType) {
        logger.info("发送通知给班级学生: classId={}, type={}", classId, type);
        List<StudentClass> studentClasses = studentClassMapper.selectByClassId(classId);
        logger.info("班级学生数量: {}", studentClasses != null ? studentClasses.size() : 0);
        
        if (studentClasses == null || studentClasses.isEmpty()) {
            logger.warn("班级 {} 没有学生", classId);
            return;
        }
        
        for (StudentClass sc : studentClasses) {
            logger.info("学生关联: studentId={}, status={}", sc.getStudentId(), sc.getStatus());
            if (sc.getStatus() != null && sc.getStatus() == 1) { // 只通知正常状态的学生
                sendToUser(sc.getStudentId(), 0, type, title, content, relatedId, relatedType);
            }
        }
    }

    /**
     * 获取用户通知列表
     */
    public List<Notification> getUserNotifications(Long userId, Integer userRole, Integer limit) {
        if (limit != null && limit > 0) {
            return notificationMapper.findByUser(userId, userRole, limit);
        }
        return notificationMapper.findAllByUser(userId, userRole);
    }

    /**
     * 获取未读通知数量
     */
    public int getUnreadCount(Long userId, Integer userRole) {
        return notificationMapper.countUnread(userId, userRole);
    }

    /**
     * 标记单条通知为已读
     */
    public void markAsRead(Long notificationId) {
        notificationMapper.markAsRead(notificationId);
    }

    /**
     * 标记所有通知为已读
     */
    public void markAllAsRead(Long userId, Integer userRole) {
        notificationMapper.markAllAsRead(userId, userRole);
    }

    /**
     * 删除通知
     */
    public void deleteNotification(Long notificationId) {
        notificationMapper.deleteById(notificationId);
    }

    /**
     * 删除所有已读通知
     */
    public void deleteReadNotifications(Long userId, Integer userRole) {
        notificationMapper.deleteReadByUser(userId, userRole);
    }

    // ========== 便捷方法：特定场景通知 ==========

    /**
     * 考试发布通知（带班级名称）
     */
    public void notifyExamPublished(Long classId, Long examId, String examTitle, String className) {
        logger.info("考试发布通知: classId={}, examId={}, examTitle={}, className={}", classId, examId, examTitle, className);
        String title = "新考试发布";
        String content = "班级「" + className + "」的考试「" + examTitle + "」已发布，请及时参加。";
        // relatedId 存储班级ID，方便跳转到班级页面
        sendToClassStudents(classId, "exam_publish", title, content, classId, "class");
    }

    /**
     * 考试发布通知（不带班级名称，兼容旧调用）
     */
    public void notifyExamPublished(Long classId, Long examId, String examTitle) {
        logger.info("考试发布通知: classId={}, examId={}, examTitle={}", classId, examId, examTitle);
        String title = "新考试发布";
        String content = "考试「" + examTitle + "」已发布，请及时参加。";
        // relatedId 存储班级ID，方便跳转到班级页面
        sendToClassStudents(classId, "exam_publish", title, content, classId, "class");
    }

    /**
     * 成绩发布通知
     */
    public void notifyGradeReleased(Long studentId, Long examId, String examTitle) {
        String title = "成绩已发布";
        String content = "考试「" + examTitle + "」的成绩已发布，请查看。";
        sendToUser(studentId, 0, "grade_release", title, content, examId, "exam");
    }

    /**
     * 批改完成通知
     * @param studentId 学生ID
     * @param examRecordId 考试记录ID（用于跳转到考试详情）
     * @param examTitle 考试标题
     */
    public void notifyGradingComplete(Long studentId, Long examRecordId, String examTitle) {
        String title = "试卷批改完成";
        String content = "您的「" + examTitle + "」试卷已批改完成，请查看成绩。";
        // relatedId 存储 examRecordId，方便跳转到考试详情页面
        sendToUser(studentId, 0, "grading_complete", title, content, examRecordId, "exam_record");
    }

    /**
     * 系统通知
     */
    public void sendSystemNotification(Long userId, Integer userRole, String title, String content) {
        sendToUser(userId, userRole, "system", title, content, null, null);
    }
}
