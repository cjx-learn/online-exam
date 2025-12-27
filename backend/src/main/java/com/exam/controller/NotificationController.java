package com.exam.controller;

import com.exam.common.Result;
import com.exam.entity.Notification;
import com.exam.service.NotificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/notification")
public class NotificationController {

    private static final Logger logger = LoggerFactory.getLogger(NotificationController.class);

    @Autowired
    private NotificationService notificationService;

    /**
     * 获取通知列表
     */
    @GetMapping("/list")
    public Result getNotifications(HttpServletRequest request,
                                   @RequestParam(required = false) Integer limit) {
        Long userId = (Long) request.getAttribute("userId");
        Integer role = (Integer) request.getAttribute("role");
        logger.info("获取通知列表: userId={}, role={}, limit={}", userId, role, limit);
        List<Notification> notifications = notificationService.getUserNotifications(userId, role, limit);
        logger.info("查询到通知数量: {}", notifications != null ? notifications.size() : 0);
        return Result.success(notifications);
    }

    /**
     * 获取未读数量
     */
    @GetMapping("/unread-count")
    public Result getUnreadCount(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Integer role = (Integer) request.getAttribute("role");
        logger.info("获取未读数量: userId={}, role={}", userId, role);
        int count = notificationService.getUnreadCount(userId, role);
        logger.info("未读数量: {}", count);
        Map<String, Object> data = new HashMap<>();
        data.put("count", count);
        return Result.success(data);
    }

    /**
     * 获取通知列表和未读数量
     */
    @GetMapping("/summary")
    public Result getSummary(HttpServletRequest request,
                             @RequestParam(defaultValue = "10") Integer limit) {
        Long userId = (Long) request.getAttribute("userId");
        Integer role = (Integer) request.getAttribute("role");
        logger.info("获取通知摘要: userId={}, role={}, limit={}", userId, role, limit);
        
        List<Notification> notifications = notificationService.getUserNotifications(userId, role, limit);
        int unreadCount = notificationService.getUnreadCount(userId, role);
        
        logger.info("通知数量: {}, 未读数量: {}", notifications != null ? notifications.size() : 0, unreadCount);
        
        Map<String, Object> data = new HashMap<>();
        data.put("notifications", notifications);
        data.put("unreadCount", unreadCount);
        return Result.success(data);
    }

    /**
     * 标记单条为已读
     */
    @PostMapping("/read/{id}")
    public Result markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return Result.success("已标记为已读");
    }

    /**
     * 标记全部为已读
     */
    @PostMapping("/read-all")
    public Result markAllAsRead(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Integer role = (Integer) request.getAttribute("role");
        notificationService.markAllAsRead(userId, role);
        return Result.success("已全部标记为已读");
    }

    /**
     * 删除通知
     */
    @DeleteMapping("/{id}")
    public Result deleteNotification(@PathVariable Long id) {
        notificationService.deleteNotification(id);
        return Result.success("删除成功");
    }

    /**
     * 删除所有已读通知
     */
    @DeleteMapping("/read")
    public Result deleteReadNotifications(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Integer role = (Integer) request.getAttribute("role");
        notificationService.deleteReadNotifications(userId, role);
        return Result.success("已删除所有已读通知");
    }
}
