package com.exam.util;

import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

/**
 * 文件上传工具类
 */
public class FileUtil {
    
    // 文件上传根目录（使用绝对路径）
    private static final String UPLOAD_DIR = System.getProperty("user.dir") + File.separator + "uploads" + File.separator;
    
    // 头像上传子目录
    private static final String AVATAR_DIR = "avatars" + File.separator;
    
    // 允许的图片格式
    private static final String[] ALLOWED_EXTENSIONS = {
        ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp"
    };
    
    // 最大文件大小（2MB）
    private static final long MAX_FILE_SIZE = 2 * 1024 * 1024;
    
    /**
     * 上传头像
     */
    public static String uploadAvatar(MultipartFile file) throws IOException {
        // 验证文件
        validateFile(file);
        
        // 生成文件名
        String originalFilename = file.getOriginalFilename();
        String extension = getFileExtension(originalFilename);
        String newFilename = generateFilename(extension);
        
        // 按日期分目录存储
        String dateDir = new SimpleDateFormat("yyyy" + File.separator + "MM" + File.separator + "dd").format(new Date());
        String relativePath = AVATAR_DIR + dateDir + File.separator;
        String absolutePath = UPLOAD_DIR + relativePath;
        
        // 创建目录
        File uploadDir = new File(absolutePath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        // 保存文件
        String filePath = absolutePath + newFilename;
        File dest = new File(filePath);
        file.transferTo(dest);
        
        // 返回访问路径（使用URL路径分隔符）
        String urlPath = relativePath.replace(File.separator, "/");
        return "/uploads/" + urlPath + newFilename;
    }
    
    /**
     * 验证文件
     */
    private static void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new RuntimeException("文件不能为空");
        }
        
        // 检查文件大小
        if (file.getSize() > MAX_FILE_SIZE) {
            throw new RuntimeException("文件大小不能超过2MB");
        }
        
        // 检查文件类型
        String filename = file.getOriginalFilename();
        String extension = getFileExtension(filename);
        boolean isAllowed = false;
        for (String allowed : ALLOWED_EXTENSIONS) {
            if (allowed.equalsIgnoreCase(extension)) {
                isAllowed = true;
                break;
            }
        }
        if (!isAllowed) {
            throw new RuntimeException("不支持的文件格式，仅支持图片文件");
        }
        
        // 检查文件真实类型（防止恶意文件伪装）
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new RuntimeException("文件类型不正确，仅支持图片文件");
        }
    }
    
    /**
     * 获取文件扩展名
     */
    private static String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf("."));
    }
    
    /**
     * 生成唯一文件名
     */
    private static String generateFilename(String extension) {
        return UUID.randomUUID().toString().replace("-", "") + extension;
    }
    
    /**
     * 删除文件
     */
    public static boolean deleteFile(String filePath) {
        if (filePath == null || filePath.isEmpty()) {
            return false;
        }
        
        // 移除 /uploads/ 前缀
        if (filePath.startsWith("/uploads/")) {
            filePath = filePath.substring("/uploads/".length());
        }
        
        // 将URL路径分隔符转换为系统路径分隔符
        filePath = filePath.replace("/", File.separator);
        
        File file = new File(UPLOAD_DIR + filePath);
        if (file.exists() && file.isFile()) {
            return file.delete();
        }
        return false;
    }
}
