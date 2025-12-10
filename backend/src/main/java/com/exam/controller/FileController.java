package com.exam.controller;

import com.exam.common.Result;
import com.exam.util.FileUtil;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

/**
 * 文件上传控制器
 */
@RestController
@RequestMapping("/file")
public class FileController {
    
    /**
     * 上传头像
     */
    @PostMapping("/upload/avatar")
    public Result<?> uploadAvatar(@RequestParam("file") MultipartFile file) {
        try {
            String url = FileUtil.uploadAvatar(file);
            
            Map<String, String> result = new HashMap<>();
            result.put("url", url);
            result.put("filename", file.getOriginalFilename());
            
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("上传失败: " + e.getMessage());
        }
    }
    
    /**
     * 上传题目图片（最大5MB）
     */
    @PostMapping("/upload/question-image")
    public Result<?> uploadQuestionImage(@RequestParam("file") MultipartFile file) {
        try {
            // 5MB = 5 * 1024 * 1024 字节
            long maxSize = 5 * 1024 * 1024;
            String url = FileUtil.uploadFile(file, "questions", maxSize);
            
            Map<String, String> result = new HashMap<>();
            result.put("url", url);
            result.put("filename", file.getOriginalFilename());
            
            return Result.success(result);
        } catch (Exception e) {
            return Result.error("上传失败: " + e.getMessage());
        }
    }
    
    /**
     * 删除文件
     */
    @DeleteMapping("/delete")
    public Result<?> deleteFile(@RequestParam("url") String url) {
        try {
            boolean success = FileUtil.deleteFile(url);
            if (success) {
                return Result.success("删除成功");
            } else {
                return Result.error("文件不存在或删除失败");
            }
        } catch (Exception e) {
            return Result.error("删除失败: " + e.getMessage());
        }
    }
}
