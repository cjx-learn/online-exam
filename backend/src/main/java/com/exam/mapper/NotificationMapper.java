package com.exam.mapper;

import com.exam.entity.Notification;
import org.apache.ibatis.annotations.*;
import java.util.List;

@Mapper
public interface NotificationMapper {

    @Insert("INSERT INTO notification (user_id, user_role, type, title, content, related_id, related_type, is_read, create_time) " +
            "VALUES (#{userId}, #{userRole}, #{type}, #{title}, #{content}, #{relatedId}, #{relatedType}, 0, NOW())")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(Notification notification);

    @Select("SELECT id, user_id, user_role, type, title, content, related_id, related_type, is_read, create_time, read_time FROM notification WHERE user_id = #{userId} AND user_role = #{userRole} ORDER BY create_time DESC LIMIT #{limit}")
    @Results({
        @Result(property = "id", column = "id"),
        @Result(property = "userId", column = "user_id"),
        @Result(property = "userRole", column = "user_role"),
        @Result(property = "type", column = "type"),
        @Result(property = "title", column = "title"),
        @Result(property = "content", column = "content"),
        @Result(property = "relatedId", column = "related_id"),
        @Result(property = "relatedType", column = "related_type"),
        @Result(property = "isRead", column = "is_read"),
        @Result(property = "createTime", column = "create_time"),
        @Result(property = "readTime", column = "read_time")
    })
    List<Notification> findByUser(@Param("userId") Long userId, @Param("userRole") Integer userRole, @Param("limit") Integer limit);

    @Select("SELECT id, user_id, user_role, type, title, content, related_id, related_type, is_read, create_time, read_time FROM notification WHERE user_id = #{userId} AND user_role = #{userRole} ORDER BY create_time DESC")
    @Results({
        @Result(property = "id", column = "id"),
        @Result(property = "userId", column = "user_id"),
        @Result(property = "userRole", column = "user_role"),
        @Result(property = "type", column = "type"),
        @Result(property = "title", column = "title"),
        @Result(property = "content", column = "content"),
        @Result(property = "relatedId", column = "related_id"),
        @Result(property = "relatedType", column = "related_type"),
        @Result(property = "isRead", column = "is_read"),
        @Result(property = "createTime", column = "create_time"),
        @Result(property = "readTime", column = "read_time")
    })
    List<Notification> findAllByUser(@Param("userId") Long userId, @Param("userRole") Integer userRole);

    @Select("SELECT COUNT(*) FROM notification WHERE user_id = #{userId} AND user_role = #{userRole} AND is_read = 0")
    int countUnread(@Param("userId") Long userId, @Param("userRole") Integer userRole);

    @Update("UPDATE notification SET is_read = 1, read_time = NOW() WHERE id = #{id}")
    int markAsRead(@Param("id") Long id);

    @Update("UPDATE notification SET is_read = 1, read_time = NOW() WHERE user_id = #{userId} AND user_role = #{userRole} AND is_read = 0")
    int markAllAsRead(@Param("userId") Long userId, @Param("userRole") Integer userRole);

    @Delete("DELETE FROM notification WHERE id = #{id}")
    int deleteById(@Param("id") Long id);

    @Delete("DELETE FROM notification WHERE user_id = #{userId} AND user_role = #{userRole} AND is_read = 1")
    int deleteReadByUser(@Param("userId") Long userId, @Param("userRole") Integer userRole);
}
