/**
 * API 配置文件
 * 统一管理 API 基础 URL
 */

// 获取环境变量中的 API 基础 URL
// 如果未设置，则根据当前环境自动判断
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || (
  import.meta.env.MODE === 'development' 
    ? 'http://localhost:8080'
    : window.location.origin.replace(':5173', ':8080')
)

// 完整的 API URL（带 /api 前缀）
export const API_URL = `${API_BASE_URL}/api`

console.log('API Base URL:', API_BASE_URL)
console.log('API URL:', API_URL)
