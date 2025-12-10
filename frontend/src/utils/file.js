/**
 * 文件 URL 工具函数
 */
import { API_URL } from '@/config/api'

/**
 * 获取完整的文件 URL
 * @param {string} path - 文件路径（如 /uploads/avatar/xxx.jpg）
 * @returns {string} 完整的文件 URL
 */
export function getFileUrl(path) {
  if (!path) return ''
  
  // 如果已经是完整 URL，直接返回
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return path
  }
  
  // 拼接 API_URL
  return `${API_URL}${path}`
}

/**
 * 获取头像 URL
 * @param {string} avatarPath - 头像路径
 * @returns {string} 完整的头像 URL
 */
export function getAvatarUrl(avatarPath) {
  return getFileUrl(avatarPath)
}

/**
 * 获取图片 URL
 * @param {string} imagePath - 图片路径
 * @returns {string} 完整的图片 URL
 */
export function getImageUrl(imagePath) {
  return getFileUrl(imagePath)
}
