<template>
  <div class="login-container">
    <div class="login-content">
      <!-- 顶部品牌区域 -->
      <div class="brand-section">
        <div class="brand-icon fade-in-scale">
          <el-icon :size="60" color="#ffffff"><EditPen /></el-icon>
        </div>
        <h1 class="brand-title fade-in">
          <span class="title-text">在线考试系统</span>
        </h1>
        <p class="brand-slogan fade-in-delay">让考试更简单</p>
      </div>
      
      <!-- 背景装饰图案 -->
      <div class="bg-decorations">
        <div class="deco-book"></div>
        <div class="deco-pencil"></div>
        <div class="deco-paper"></div>
        <!-- 新增教育元素轮廓 -->
        <div class="deco-outline deco-outline-1"></div>
        <div class="deco-outline deco-outline-2"></div>
        <div class="deco-outline deco-outline-3"></div>
      </div>
      
      <!-- 登录表单区域 -->
      <div class="login-box">
        <h2 class="login-title">登录</h2>
        
        <el-form :model="loginForm" :rules="rules" ref="loginFormRef" class="login-form">
          <el-form-item prop="username">
            <el-input 
              v-model="loginForm.username" 
              placeholder="请输入用户名"
              size="large"
              clearable
            >
              <template #prefix>
                <el-icon><User /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="password">
            <el-input 
              v-model="loginForm.password" 
              type="password"
              placeholder="请输入密码"
              size="large"
              show-password
              @keyup.enter="handleLogin"
            >
              <template #prefix>
                <el-icon><Lock /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <el-form-item prop="role" class="role-item">
            <template #label>
              <span class="role-label">选择身份</span>
            </template>
            <el-radio-group v-model="loginForm.role" size="large">
              <el-radio :value="0" border>
                <el-icon><User /></el-icon>
                <span>学生</span>
              </el-radio>
              <el-radio :value="1" border>
                <el-icon><Reading /></el-icon>
                <span>教师</span>
              </el-radio>
              <el-radio :value="2" border>
                <el-icon><Avatar /></el-icon>
                <span>管理员</span>
              </el-radio>
            </el-radio-group>
          </el-form-item>
          
          <el-form-item>
            <el-button 
              type="primary" 
              class="login-btn" 
              @click="handleLogin"
              :loading="loading"
              size="large"
            >
              登录
            </el-button>
          </el-form-item>
          
          <div class="login-footer">
            <a href="#" class="forgot-link">忘记密码</a>
          </div>
        </el-form>
      </div>
      
      <div class="copyright">
        © 在线考试系统 版权所有
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const router = useRouter()
const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: '',
  role: 0  // 默认学生身份
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  role: [
    { required: true, message: '请选择登录身份', trigger: 'change' }
  ]
}

const handleLogin = async () => {
  try {
    await loginFormRef.value.validate()
    loading.value = true
    
    const response = await request.post('/user/login', loginForm)
    
    if (response.code === 200) {
      ElMessage.success('登录成功')
      // 保存token和用户信息
      if (response.data) {
        localStorage.setItem('userInfo', JSON.stringify(response.data))
      }
      
      // 根据角色跳转到不同页面
      const role = response.data.role
      if (role === 0) {
        // 学生跳转到学生主页
        router.push('/student/home')
      } else if (role === 1) {
        // 教师跳转到教师主页
        router.push('/teacher/home')
      } else if (role === 2) {
        // 管理员跳转到管理后台
        router.push('/admin/home')
      }
    } else {
      ElMessage.error(response.message || '登录失败')
    }
  } catch (error) {
    console.error('登录错误:', error)
    // 不显示额外错误，因为request.js已经处理了
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  // 页面加载时清空localStorage，防止之前登录遗留的数据影响
  // localStorage.clear(); // 移除此行
});
</script>

<style scoped>
.login-container {
  width: 100%;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%);
  padding: 40px 20px;
  position: relative;
  overflow: hidden;
}

/* 背景装饰圆圈 */
.login-container::before,
.login-container::after {
  content: '';
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.3);
  animation: float 8s ease-in-out infinite;
}

.login-container::before {
  width: 300px;
  height: 300px;
  top: -150px;
  right: -150px;
}

.login-container::after {
  width: 200px;
  height: 200px;
  bottom: -100px;
  left: -100px;
  animation-delay: 4s;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) scale(1);
  }
  50% {
    transform: translateY(-20px) scale(1.05);
  }
}

/* 背景教育元素装饰 */
.bg-decorations {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  pointer-events: none;
  overflow: hidden;
}

/* 书本装饰 */
.deco-book {
  position: absolute;
  width: 80px;
  height: 60px;
  top: 15%;
  left: 10%;
  background: rgba(102, 126, 234, 0.08);
  border-radius: 4px;
  animation: floatSlow 10s ease-in-out infinite;
}

.deco-book::before {
  content: '';
  position: absolute;
  width: 2px;
  height: 60%;
  background: rgba(102, 126, 234, 0.15);
  left: 50%;
  top: 20%;
}

/* 铅笔装饰 */
.deco-pencil {
  position: absolute;
  width: 6px;
  height: 80px;
  top: 60%;
  right: 8%;
  background: linear-gradient(to bottom, rgba(102, 126, 234, 0.12) 0%, rgba(102, 126, 234, 0.06) 70%, rgba(252, 196, 150, 0.15) 100%);
  border-radius: 3px;
  transform: rotate(-25deg);
  animation: floatSlow 12s ease-in-out infinite reverse;
}

.deco-pencil::before {
  content: '';
  position: absolute;
  width: 0;
  height: 0;
  border-left: 3px solid transparent;
  border-right: 3px solid transparent;
  border-top: 12px solid rgba(80, 80, 80, 0.1);
  bottom: -12px;
  left: 0;
}

/* 试卷装饰 */
.deco-paper {
  position: absolute;
  width: 70px;
  height: 90px;
  bottom: 20%;
  right: 15%;
  background: rgba(255, 255, 255, 0.15);
  border-radius: 4px;
  border: 1px solid rgba(102, 126, 234, 0.08);
  animation: floatSlow 14s ease-in-out infinite;
}

.deco-paper::before,
.deco-paper::after {
  content: '';
  position: absolute;
  height: 2px;
  background: rgba(102, 126, 234, 0.08);
  left: 10px;
  right: 10px;
}

.deco-paper::before {
  top: 20px;
}

.deco-paper::after {
  top: 35px;
}

@keyframes floatSlow {
  0%, 100% {
    transform: translateY(0) rotate(0deg);
  }
  50% {
    transform: translateY(-15px) rotate(3deg);
  }
}

/* 新增教育元素轮廓装饰 */
.deco-outline {
  position: absolute;
  border: 2px solid rgba(102, 126, 234, 0.08);
  border-radius: 8px;
  animation: outlineFloat 20s ease-in-out infinite;
}

.deco-outline-1 {
  width: 120px;
  height: 160px;
  top: 10%;
  right: 5%;
  border-style: dashed;
  animation-delay: 0s;
}

.deco-outline-1::before,
.deco-outline-1::after {
  content: '';
  position: absolute;
  background: rgba(102, 126, 234, 0.06);
  border-radius: 2px;
}

.deco-outline-1::before {
  width: 80%;
  height: 3px;
  top: 30%;
  left: 10%;
}

.deco-outline-1::after {
  width: 60%;
  height: 3px;
  top: 45%;
  left: 10%;
}

.deco-outline-2 {
  width: 100px;
  height: 100px;
  bottom: 15%;
  left: 8%;
  border-radius: 50%;
  border-style: dotted;
  animation-delay: 5s;
}

.deco-outline-3 {
  width: 90px;
  height: 70px;
  top: 50%;
  left: 12%;
  transform: rotate(-15deg);
  animation-delay: 10s;
}

.deco-outline-3::before {
  content: '';
  position: absolute;
  width: 50%;
  height: 2px;
  background: rgba(102, 126, 234, 0.08);
  top: 50%;
  left: 25%;
}

@keyframes outlineFloat {
  0%, 100% {
    transform: translateY(0) translateX(0) rotate(0deg);
    opacity: 0.4;
  }
  33% {
    transform: translateY(-20px) translateX(10px) rotate(5deg);
    opacity: 0.6;
  }
  66% {
    transform: translateY(-10px) translateX(-10px) rotate(-5deg);
    opacity: 0.5;
  }
}

.login-content {
  width: 100%;
  max-width: 520px;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  z-index: 1;
}

/* 品牌区域 */
.brand-section {
  text-align: center;
  margin-bottom: 50px;
}

.brand-icon {
  width: 90px;
  height: 90px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
  animation: iconFloat 3s ease-in-out infinite;
  transition: all 0.3s;
  position: relative;
  overflow: hidden;
}

.brand-icon::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  animation: shine 3s ease-in-out infinite;
}

@keyframes shine {
  0% {
    transform: rotate(0deg) translate(-100%, -100%);
  }
  100% {
    transform: rotate(0deg) translate(100%, 100%);
  }
}

.brand-icon:hover {
  transform: scale(1.05);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.4);
}

@keyframes iconFloat {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-8px);
  }
}

/* 页面加载动画 */
.fade-in-scale {
  animation: fadeInScale 0.8s ease-out;
}

.fade-in {
  animation: fadeIn 1s ease-out 0.3s both;
}

.fade-in-delay {
  animation: fadeIn 1s ease-out 0.5s both;
}

@keyframes fadeInScale {
  0% {
    opacity: 0;
    transform: scale(0.8) rotate(-10deg);
  }
  100% {
    opacity: 1;
    transform: scale(1) rotate(0deg);
  }
}

@keyframes fadeIn {
  0% {
    opacity: 0;
    transform: translateY(20px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

.brand-title {
  font-size: 38px;
  font-weight: bold;
  margin: 0 0 12px 0;
  letter-spacing: 3px;
}

.title-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #667eea 100%);
  background-size: 200% auto;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradientShift 3s ease-in-out infinite;
  filter: drop-shadow(0 2px 10px rgba(102, 126, 234, 0.15));
  -webkit-text-stroke: 0.5px rgba(102, 126, 234, 0.3);
}

@keyframes gradientShift {
  0%, 100% {
    background-position: 0% center;
  }
  50% {
    background-position: 100% center;
  }
}

.brand-slogan {
  font-size: 15px;
  color: #888;
  margin: 0;
  letter-spacing: 1px;
  font-weight: 300;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* 登录框 */
.login-box {
  width: 100%;
  background: rgba(255, 255, 255, 0.95);
  padding: 50px 55px 55px;
  border-radius: 20px;
  box-shadow: 
    0 20px 60px rgba(102, 126, 234, 0.12),
    0 12px 40px rgba(118, 75, 162, 0.08),
    0 8px 32px rgba(0, 0, 0, 0.05);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.9);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

.login-box::before {
  content: '';
  position: absolute;
  top: -2px;
  left: -2px;
  right: -2px;
  bottom: -2px;
  background: radial-gradient(circle at top, rgba(102, 126, 234, 0.15), transparent 70%);
  border-radius: 20px;
  z-index: -1;
  opacity: 0;
  transition: opacity 0.4s;
}

.login-box:hover::before {
  opacity: 1;
}

.login-box:hover {
  box-shadow: 
    0 24px 70px rgba(102, 126, 234, 0.18),
    0 16px 50px rgba(118, 75, 162, 0.12),
    0 12px 40px rgba(0, 0, 0, 0.08);
  transform: translateY(-3px);
}

.login-title {
  text-align: center;
  margin-bottom: 40px;
  color: #303133;
  font-size: 26px;
  font-weight: 600;
  position: relative;
  padding-bottom: 18px;
}

.login-title::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 50px;
  height: 3px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border-radius: 2px;
}

.login-form {
  margin-top: 0;
}

.login-form :deep(.el-form-item) {
  margin-bottom: 30px;
}

.login-form :deep(.el-form-item:last-child) {
  margin-bottom: 0;
}

/* 输入框与身份选择之间额外间距 */
.role-item {
  margin-top: 16px !important;
}

.login-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #606266;
  margin-bottom: 10px;
}


.role-label {
  font-weight: 500;
  color: #606266;
  margin-bottom: 12px;
  display: inline-block;
}

.role-item :deep(.el-radio-group) {
  display: flex;
  justify-content: space-between;
  width: 100%;
  gap: 12px;
}

.role-item :deep(.el-radio.is-bordered) {
  flex: 1;
  margin: 0;
  padding: 18px 10px;
  text-align: center;
  border-radius: 10px;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  background: #fafbff;
  min-width: 0;
  border: 2px solid #e5e8f0;
}

.role-item :deep(.el-radio.is-bordered:hover) {
  transform: translateY(-2px) scale(0.98);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.2);
  border-color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.06) 0%, rgba(118, 75, 162, 0.06) 100%);
}

.role-item :deep(.el-radio.is-bordered:hover .el-radio__label) {
  color: #667eea;
  transform: scale(1.02);
}

.role-item :deep(.el-radio.is-bordered:hover .el-icon) {
  color: #667eea;
  transform: scale(1.1);
}

.role-item :deep(.el-radio.is-bordered:active) {
  transform: translateY(0) scale(0.96);
}


.role-item :deep(.el-radio.is-bordered.is-checked) {
  background: linear-gradient(135deg, #ecf5ff 0%, #f0e7ff 100%);
  border-color: #667eea;
  border-width: 2px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.25);
  position: relative;
  transform: scale(1.02);
}

.role-item :deep(.el-radio.is-bordered.is-checked .el-icon) {
  color: #667eea;
  animation: iconPop 0.3s ease-out;
}

@keyframes iconPop {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.2);
  }
  100% {
    transform: scale(1);
  }
}

.role-item :deep(.el-radio.is-bordered.is-checked)::after {
  content: '✓';
  position: absolute;
  top: -8px;
  right: -8px;
  width: 22px;
  height: 22px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  color: white;
  font-size: 13px;
  font-weight: bold;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: checkMark 0.4s cubic-bezier(0.68, -0.55, 0.265, 1.55);
  box-shadow: 0 3px 12px rgba(102, 126, 234, 0.5);
  border: 2px solid white;
}

@keyframes checkMark {
  0% {
    transform: scale(0) rotate(-180deg);
    opacity: 0;
  }
  50% {
    transform: scale(1.2) rotate(0deg);
  }
  100% {
    transform: scale(1) rotate(0deg);
    opacity: 1;
  }
}

.role-item :deep(.el-radio__label) {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  font-size: 14px;
  transition: all 0.3s;
  font-weight: 500;
}

.role-item :deep(.el-icon) {
  font-size: 17px;
  color: #b0b8d0;
  transition: all 0.3s;
  flex-shrink: 0;
}

.login-btn {
  width: 100%;
  height: 50px;
  font-size: 16px;
  font-weight: 500;
  border-radius: 12px;
  margin-top: 30px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
  position: relative;
  overflow: hidden;
}

.login-btn::after {
  content: '';
  position: absolute;
  top: -50%;
  left: 50%;
  width: 0;
  height: 200%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.25) 0%, transparent 70%);
  transform: translateX(-50%);
  transition: width 0.6s;
  border-radius: 50%;
}

.login-btn:hover::after {
  width: 200%;
}

.login-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.45);
  background: linear-gradient(135deg, #7a8ef0 0%, #8658b0 100%);
  filter: brightness(1.08);
}

.login-btn:active {
  transform: translateY(1px) scale(0.98);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: all 0.1s;
}

.login-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.login-btn:hover::before {
  left: 100%;
}

.login-footer {
  text-align: center;
  margin-top: 28px;
}

.forgot-link {
  color: #667eea;
  text-decoration: none;
  font-size: 14px;
  position: relative;
  transition: color 0.3s;
}

.forgot-link::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  transition: width 0.3s ease-out;
}

.forgot-link:hover {
  color: #764ba2;
}

.forgot-link:hover::after {
  width: 100%;
}

.copyright {
  margin-top: 35px;
  text-align: center;
  color: #aaa;
  font-size: 12px;
  letter-spacing: 0.5px;
  font-weight: 300;
}

/* 输入框优化 */
.login-form :deep(.el-input__wrapper) {
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  border: 2px solid #e5e8f0;
  padding: 4px 15px;
  background: #fafbff;
}

.login-form :deep(.el-input__wrapper:hover) {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transform: translateY(-1px);
  border-color: #d0d5e8;
}

.login-form :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25), 0 0 0 3px rgba(102, 126, 234, 0.1);
  border-color: #667eea;
  transform: scale(1.01);
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.03) 0%, rgba(118, 75, 162, 0.03) 100%);
  animation: borderGradient 0.6s ease-out;
}

@keyframes borderGradient {
  0% {
    border-color: #e5e8f0;
  }
  50% {
    border-color: #a8b3ea;
  }
  100% {
    border-color: #667eea;
  }
}

/* 输入框图标优化 */
.login-form :deep(.el-input__prefix) {
  color: #b0b8d0;
  transition: color 0.3s;
}

.login-form :deep(.el-input__wrapper.is-focus .el-input__prefix) {
  color: #667eea;
}

.login-form :deep(.el-input__prefix .el-icon) {
  font-size: 18px;
}

/* Placeholder上移动画效果 */
.login-form :deep(.el-input__inner::placeholder) {
  transition: all 0.3s;
}

.login-form :deep(.el-input__wrapper.is-focus .el-input__inner::placeholder) {
  transform: translateY(-2px);
  opacity: 0.6;
}

/* 错误提示样式优化 */
.login-form :deep(.el-form-item__error) {
  color: #ff6b6b;
  font-weight: 500;
  font-size: 13px;
  margin-top: 10px;
  padding-left: 4px;
  line-height: 1.5;
  display: flex;
  align-items: center;
  animation: errorShake 0.3s ease-in-out;
}

.login-form :deep(.el-form-item__error)::before {
  content: '⚠';
  display: inline-block;
  margin-right: 6px;
  font-size: 14px;
  animation: errorPulse 1s ease-in-out infinite;
}

@keyframes errorPulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

@keyframes errorShake {
  0%, 100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-4px);
  }
  75% {
    transform: translateX(4px);
  }
}

/* 响应式设计 */
@media (max-width: 768px) {
  .role-item :deep(.el-radio-group) {
    gap: 8px;
  }
  
  .role-item :deep(.el-radio.is-bordered) {
    padding: 16px 8px;
  }
  
  .role-item :deep(.el-radio__label) {
    font-size: 13px;
    gap: 4px;
  }
  
  .role-item :deep(.el-icon) {
    font-size: 16px;
  }
}

@media (max-width: 600px) {
  .login-container {
    padding: 20px 15px;
  }
  
  .login-content {
    max-width: 100%;
  }
  
  .login-box {
    padding: 30px 25px;
  }
  
  .brand-title {
    font-size: 30px;
  }
  
  .brand-slogan {
    font-size: 14px;
  }
  
  .brand-icon {
    width: 75px;
    height: 75px;
  }
  
  /* 小屏幕下身份选择优化 */
  .role-item :deep(.el-radio-group) {
    flex-direction: column;
    gap: 10px;
  }
  
  .role-item :deep(.el-radio.is-bordered) {
    width: 100%;
    padding: 14px 10px;
  }
  
  .role-item :deep(.el-radio__label) {
    font-size: 15px;
  }
}
</style>

