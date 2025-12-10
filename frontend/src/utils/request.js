import axios from 'axios'
import { ElMessage } from 'element-plus'
import { API_URL } from '@/config/api'

// 创建axios实例
const service = axios.create({
  baseURL: import.meta.env.MODE === 'development' ? '/api' : API_URL,
  timeout: 10000
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['Authorization'] = token
    }
    return config
  },
  error => {
    console.error('请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  response => {
    const res = response.data
    
    // 如果返回的状态码不是200，说明接口有问题
    if (res.code !== 200) {
      ElMessage.error(res.message || '请求失败')
      
      // 401: 未登录或被踢下线
      if (res.code === 401) {
        localStorage.removeItem('token')
        localStorage.removeItem('userInfo')
        
        // 显示具体的错误消息
        if (res.message && res.message.includes('其他设备登录')) {
          ElMessage.warning({
            message: res.message,
            duration: 3000
          })
        }
        
        // 延迟跳转，让用户看到消息
        setTimeout(() => {
          window.location.href = '/login'
        }, 1500)
      }
      
      return Promise.reject(new Error(res.message || '请求失败'))
    } else {
      return res
    }
  },
  error => {
    console.error('响应错误:', error)
    
    // 处理HTTP 401状态码
    if (error.response && error.response.status === 401) {
      const message = error.response.data?.message || '登录已过期，请重新登录'
      
      ElMessage.error({
        message: message,
        duration: 3000
      })
      
      localStorage.removeItem('token')
      localStorage.removeItem('userInfo')
      
      setTimeout(() => {
        window.location.href = '/login'
      }, 1500)
    } else {
      ElMessage.error(error.message || '网络错误')
    }
    
    return Promise.reject(error)
  }
)

export default service

