<template>
  <div class="student-home">
    <!-- 背景装饰 -->
    <div class="bg-decorations">
      <div class="deco-book"></div>
      <div class="deco-pencil"></div>
      <div class="deco-paper"></div>
      <div class="deco-outline deco-outline-1"></div>
      <div class="deco-outline deco-outline-2"></div>
      <div class="deco-outline deco-outline-3"></div>
    </div>
    
    <!-- 顶部导航 -->
    <div class="top-nav">
      <div class="nav-left">
        <h1 class="title">
          <span class="title-text">在线考试系统</span>
        </h1>
        <el-button 
          :type="activeTab === 'classes' ? 'primary' : ''" 
          text 
          @click="activeTab = 'classes'"
          class="tab-btn"
        >
          我的班级
        </el-button>
      </div>
      
      <div class="nav-right">
        <!-- 搜索框 -->
        <el-input
          v-model="searchKeyword"
          placeholder="输入邀请码加入班级"
          class="search-input"
          clearable
        >
          <template #prefix>
            <el-icon class="search-icon"><Search /></el-icon>
          </template>
        </el-input>
        
        <el-button type="primary" @click="joinClassByCode" :icon="Plus" class="join-btn">
          加入班级
        </el-button>
        
        <!-- 用户头像下拉菜单 -->
        <el-dropdown @command="handleCommand">
          <div class="user-avatar">
            <el-avatar :size="42" :icon="UserFilled" class="avatar-img" />
            <span class="user-name">{{ userInfo.realName || '学生' }}</span>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon><User /></el-icon>
                个人信息
              </el-dropdown-item>
              <el-dropdown-item command="settings">
                <el-icon><Setting /></el-icon>
                设置
              </el-dropdown-item>
              <el-dropdown-item command="logout" divided>
                <el-icon><SwitchButton /></el-icon>
                退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
    
    <!-- 主体内容区 -->
    <div class="main-content">
      <!-- 欢迎信息 -->
      <div class="welcome-section">
        <h2 class="welcome-title">欢迎回来，<span class="name-highlight">{{ userInfo.realName }}</span>同学！</h2>
        <p class="student-info">学号: {{ userInfo.studentNo || 'S2021001' }} </p>
      </div>
      
      <!-- 班级列表 -->
      <div class="class-list-section">
        <div class="section-header">
          <h3>我的班级</h3>
          <span class="class-count">全部班级</span>
        </div>
        
        <div class="class-grid">
          <!-- 班级卡片 -->
          <div 
            v-for="(item, index) in classList" 
            :key="item.id" 
            class="class-card"
            :class="`class-card-${index + 1}`"
            @click="enterClass(item)"
            :style="{ animationDelay: `${index * 0.1}s` }"
          >
            <div class="card-icon">
              <el-icon v-if="item.id === 1"><Monitor /></el-icon>
              <el-icon v-else-if="item.id === 2"><DataLine /></el-icon>
              <el-icon v-else><DocumentCopy /></el-icon>
            </div>
            <div class="card-badge">智慧课程</div>
            <div class="card-cover" :class="`cover-gradient-${(index % 3) + 1}`">
              <div class="semester-tag">{{ item.semester }}</div>
            </div>
            <div class="card-content">
              <h4 class="class-name">{{ item.name }}</h4>
              <p class="teacher-info">
                <el-icon><User /></el-icon>
                {{ item.teacherName }}
              </p>
              <div class="card-footer">
                <span class="ai-tag" :class="`ai-tag-${(index % 3) + 1}`">AI智课</span>
              </div>
            </div>
          </div>
          
          <!-- 空状态 -->
          <el-empty 
            v-if="classList.length === 0" 
            description="还没有加入任何班级"
            class="empty-state"
          >
            <el-button type="primary" @click="showJoinDialog">加入班级</el-button>
          </el-empty>
        </div>
      </div>
    </div>
    
    <!-- 个人信息对话框 -->
    <el-dialog 
      v-model="profileDialogVisible" 
      title="个人信息" 
      width="560px"
      :close-on-click-modal="false"
      class="profile-dialog"
    >
      <el-form :model="userForm" label-width="100px" class="profile-form">
        <el-form-item label="用户名">
          <el-input v-model="userForm.username" disabled>
            <template #suffix>
              <el-icon color="#909399"><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="真实姓名">
          <el-input v-model="userForm.realName" disabled>
            <template #suffix>
              <el-icon color="#909399"><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="学号">
          <el-input v-model="userForm.studentNo" disabled>
            <template #suffix>
              <el-icon color="#909399"><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-divider content-position="left">
          <span style="color: #909399; font-size: 13px;">可修改信息</span>
        </el-divider>
        <el-form-item label="邮箱">
          <el-input 
            v-model="userForm.email" 
            placeholder="请输入邮箱"
            clearable
            type="email"
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input 
            v-model="userForm.phone" 
            placeholder="请输入手机号" 
            maxlength="11"
            clearable
          />
        </el-form-item>
      </el-form>
      <div class="password-section">
        <el-button 
          @click="openPasswordDialog" 
          :icon="Key" 
          class="change-password-btn"
        >
          修改密码
        </el-button>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="profileDialogVisible = false" size="large">取消</el-button>
          <el-button type="primary" @click="saveProfile" size="large">保存修改</el-button>
        </div>
      </template>
    </el-dialog>
    
    <!-- 修改密码对话框 -->
    <el-dialog 
      v-model="passwordDialogVisible" 
      title="修改密码" 
      width="480px"
      :close-on-click-modal="false"
      class="password-dialog"
    >
      <el-form 
        :model="passwordForm" 
        :rules="passwordRules"
        ref="passwordFormRef"
        label-width="100px" 
        class="password-form"
      >
        <el-form-item label="旧密码" prop="oldPassword">
          <el-input 
            v-model="passwordForm.oldPassword" 
            type="password" 
            placeholder="请输入旧密码"
            show-password
            clearable
          />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input 
            v-model="passwordForm.newPassword" 
            type="password" 
            placeholder="请输入新密码（6-20位）"
            show-password
            clearable
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input 
            v-model="passwordForm.confirmPassword" 
            type="password" 
            placeholder="请再次输入新密码"
            show-password
            clearable
          />
        </el-form-item>
        <div class="password-tips">
          <el-icon color="#409EFF"><InfoFilled /></el-icon>
          <span>密码长度为6-20位，建议包含字母和数字</span>
        </div>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closePasswordDialog" size="large">取消</el-button>
          <el-button type="primary" @click="changePassword" size="large">确认修改</el-button>
        </div>
      </template>
    </el-dialog>
    
    <!-- 加入班级对话框 -->
    <el-dialog 
      v-model="joinDialogVisible" 
      title="加入班级" 
      width="400px"
    >
      <el-form :model="joinForm">
        <el-form-item label="邀请码">
          <el-input 
            v-model="joinForm.inviteCode" 
            placeholder="请输入班级邀请码"
            clearable
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="joinDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmJoinClass">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Search, Plus, UserFilled, User, Setting, SwitchButton,
  Monitor, DataLine, DocumentCopy, Lock, Key, InfoFilled
} from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()

// Centralized userInfo acquisition
let currentUserInfo = null;
try {
  const storedUserInfo = localStorage.getItem('userInfo');
  if (storedUserInfo) {
    currentUserInfo = JSON.parse(storedUserInfo);
  }
} catch (e) {
  console.error("Failed to parse userInfo from localStorage in StudentHome:", e);
}

// 用户信息
const userInfo = reactive({
  id: currentUserInfo ? currentUserInfo.userId : '',
  username: currentUserInfo ? currentUserInfo.username : '',
  realName: currentUserInfo ? currentUserInfo.realName : '',
  studentNo: currentUserInfo ? currentUserInfo.studentNo : '',
  className: currentUserInfo ? currentUserInfo.className : '',
  email: currentUserInfo ? currentUserInfo.email : '',
  phone: currentUserInfo ? currentUserInfo.phone : '',
})

// 个人信息表单
const userForm = reactive({ ...userInfo })

// 班级列表
const classList = ref([])

// 状态变量
const activeTab = ref('classes')
const searchKeyword = ref('')
const profileDialogVisible = ref(false)
const joinDialogVisible = ref(false)
const passwordDialogVisible = ref(false)
const loading = ref(false)
const joinForm = reactive({
  inviteCode: ''
})

// 修改密码表单
const passwordFormRef = ref(null)
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 密码验证规则
const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入旧密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { 
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      }, 
      trigger: 'blur' 
    }
  ]
}

// 加载班级列表
const loadClassList = async () => {
  loading.value = true
  try {
    if (!currentUserInfo || !currentUserInfo.userId) {
      ElMessage.warning('用户信息未找到，请重新登录');
      router.push('/login');
      return; // Exit early if user info is missing
    }
    const response = await request.get(`/class/student/${currentUserInfo.userId}`)
    if (response.code === 200) {
      classList.value = response.data || []
    } else {
      ElMessage.error(response.message || '加载班级列表失败')
    }
  } catch (error) {
    console.error('加载班级列表失败:', error)
    ElMessage.error('加载班级列表失败')
  } finally {
    loading.value = false
  }
}

// 处理用户菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      // Use currentUserInfo for profile data
      if (currentUserInfo) {
        Object.assign(userForm, currentUserInfo);
      }
      profileDialogVisible.value = true
      break
    case 'settings':
      ElMessage.info('设置功能开发中...')
      break
    case 'logout':
      handleLogout()
      break
  }
}

// 保存个人信息
const saveProfile = async () => {
  if (!currentUserInfo || !currentUserInfo.userId) {
    ElMessage.warning('用户信息未找到，请重新登录');
    router.push('/login');
    return;
  }

  try {
    // 构建要发送到后端的用户信息更新对象
    const updateData = {
      id: currentUserInfo.userId, // 确保发送用户ID
      role: 0, // 学生角色
      realName: userForm.realName,
      studentNo: userForm.studentNo,
      major: userForm.major,
      email: userForm.email,
      phone: userForm.phone
    };

    // 假设后端有一个 /user/update 接口来更新用户信息
    const response = await request.post('/user/update', updateData);

    if (response.code === 200) {
      ElMessage.success('个人信息已保存')
      profileDialogVisible.value = false
      
      // 更新 localStorage 中的 userInfo 和 currentUserInfo
      const updatedUserInfo = { ...currentUserInfo, ...updateData };
      localStorage.setItem('userInfo', JSON.stringify(updatedUserInfo));
      // 确保 reactive 的 userInfo 也更新，以便界面刷新
      Object.assign(userInfo, updatedUserInfo);
      currentUserInfo = updatedUserInfo; // 更新全局变量
    } else {
      ElMessage.error(response.message || '保存个人信息失败');
    }
  } catch (error) {
    console.error('保存个人信息失败:', error);
    ElMessage.error('网络错误，无法保存个人信息');
  }
}

// 退出登录
const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    localStorage.clear()
    ElMessage.success('已退出登录')
    router.push('/login')
  }).catch(() => {})
}

// 显示加入班级对话框
const showJoinDialog = () => {
  joinDialogVisible.value = true
}

// 通过邀请码加入班级
const joinClassByCode = () => {
  if (!searchKeyword.value) {
    showJoinDialog()
    return
  }
  joinForm.inviteCode = searchKeyword.value
  confirmJoinClass()
}

// 确认加入班级
const confirmJoinClass = async () => {
  if (!joinForm.inviteCode) {
    ElMessage.warning('请输入邀请码')
    return
  }
  
  if (!currentUserInfo || !currentUserInfo.userId) {
    ElMessage.warning('用户信息未找到，请重新登录');
    router.push('/login');
    return;
  }

  try {
    const response = await request.post('/class/join', {
      studentId: currentUserInfo.userId,
      inviteCode: joinForm.inviteCode
    })
    
    if (response.code === 200) {
      ElMessage.success('加入班级成功！')
      joinDialogVisible.value = false
      joinForm.inviteCode = ''
      searchKeyword.value = ''
      // 重新加载班级列表
      loadClassList()
    } else {
      ElMessage.error(response.message || '加入班级失败')
    }
  } catch (error) {
    console.error('加入班级失败:', error)
    ElMessage.error('加入班级失败')
  } finally {
    loading.value = false
  }
}

// 进入班级详情
const enterClass = (classItem) => {
  router.push(`/student/class/${classItem.id}`)
}

// 打开修改密码对话框
const openPasswordDialog = () => {
  passwordDialogVisible.value = true
}

// 关闭修改密码对话框
const closePasswordDialog = () => {
  passwordDialogVisible.value = false
  // 重置表单
  if (passwordFormRef.value) {
    passwordFormRef.value.resetFields()
  }
  passwordForm.oldPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
}

// 修改密码
const changePassword = async () => {
  if (!passwordFormRef.value) return
  
  // 验证表单
  await passwordFormRef.value.validate(async (valid) => {
    if (!valid) {
      return false
    }
    
    if (!currentUserInfo || !currentUserInfo.userId) {
      ElMessage.warning('用户信息未找到，请重新登录')
      router.push('/login')
      return
    }
    
    try {
      const response = await request.post('/user/changePassword', {
        id: currentUserInfo.userId,
        oldPassword: passwordForm.oldPassword,
        newPassword: passwordForm.newPassword
      })
      
      if (response.code === 200) {
        ElMessage.success('密码修改成功，请重新登录')
        closePasswordDialog()
        profileDialogVisible.value = false
        
        // 延迟跳转到登录页
        setTimeout(() => {
          localStorage.clear()
          router.push('/login')
        }, 1500)
      } else {
        ElMessage.error(response.message || '密码修改失败')
      }
    } catch (error) {
      console.error('修改密码失败:', error)
      ElMessage.error('网络错误，无法修改密码')
    }
  })
}

onMounted(() => {
  // 从后端加载班级列表
  loadClassList()
})
</script>

<style scoped>
/* 统一使用无衬线字体 */
* {
  font-family: 'Inter', 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

.student-home {
  min-height: 100vh;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%);
  position: relative;
  overflow-x: hidden;
}

/* 背景装饰元素 */
.bg-decorations {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: 0;
  overflow: hidden;
}

/* 书本装饰 */
.deco-book {
  position: absolute;
  top: 15%;
  right: 10%;
  width: 80px;
  height: 60px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
  border-radius: 6px;
  animation: float 6s ease-in-out infinite;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
}

.deco-book::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 30px;
  height: 40px;
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 3px;
}

/* 铅笔装饰 */
.deco-pencil {
  position: absolute;
  bottom: 25%;
  left: 8%;
  width: 100px;
  height: 8px;
  background: linear-gradient(90deg, rgba(118, 75, 162, 0.1) 0%, rgba(102, 126, 234, 0.15) 100%);
  border-radius: 4px;
  transform: rotate(-25deg);
  animation: float 8s ease-in-out infinite 1s;
}

.deco-pencil::before {
  content: '';
  position: absolute;
  right: -10px;
  top: -6px;
  width: 0;
  height: 0;
  border-left: 10px solid rgba(118, 75, 162, 0.15);
  border-top: 10px solid transparent;
  border-bottom: 10px solid transparent;
}

/* 试卷装饰 */
.deco-paper {
  position: absolute;
  top: 60%;
  right: 15%;
  width: 70px;
  height: 90px;
  background: rgba(255, 255, 255, 0.4);
  border-radius: 8px;
  animation: float 7s ease-in-out infinite 2s;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
}

.deco-paper::before {
  content: '';
  position: absolute;
  top: 15px;
  left: 12px;
  width: 45px;
  height: 3px;
  background: rgba(102, 126, 234, 0.12);
  box-shadow: 0 8px 0 rgba(102, 126, 234, 0.12),
              0 16px 0 rgba(102, 126, 234, 0.12),
              0 24px 0 rgba(102, 126, 234, 0.12);
}

/* 轮廓装饰 */
.deco-outline {
  position: absolute;
  border: 2px solid rgba(102, 126, 234, 0.08);
  border-radius: 50%;
  animation: rotate 20s linear infinite;
}

.deco-outline-1 {
  top: 10%;
  left: 5%;
  width: 150px;
  height: 150px;
  animation-duration: 25s;
}

.deco-outline-2 {
  bottom: 15%;
  right: 20%;
  width: 120px;
  height: 120px;
  animation-duration: 30s;
  animation-direction: reverse;
}

.deco-outline-3 {
  top: 50%;
  left: 15%;
  width: 100px;
  height: 100px;
  animation-duration: 35s;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) rotate(0deg);
  }
  50% {
    transform: translateY(-20px) rotate(5deg);
  }
}

@keyframes rotate {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

/* 顶部导航 */
.top-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  backdrop-filter: blur(12px);
  padding: 0 40px;
  height: 64px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.top-nav::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 50%, #667eea 100%);
  opacity: 0.6;
}

.nav-left {
  display: flex;
  align-items: center;
  gap: 35px;
}

.title {
  font-size: 26px;
  font-weight: 700;
  margin: 0;
  letter-spacing: 0.5px;
}

.title-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
}

.tab-btn {
  font-size: 16px;
  font-weight: 500;
  color: #9b8fd9 !important;
  transition: all 0.3s;
}

.tab-btn:hover {
  color: #667eea !important;
  transform: translateY(-1px);
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 18px;
}

/* 搜索框优化 */
.search-input {
  width: 320px;
}

.search-input :deep(.el-input__wrapper) {
  border-radius: 12px;
  border: 2px solid #e5e8f0;
  padding: 6px 18px;
  background: #fafbff;
  transition: all 0.3s;
}

.search-input :deep(.el-input__wrapper:hover) {
  border-color: #d0d5e8;
  background: #ffffff;
}

.search-input :deep(.el-input__wrapper.is-focus) {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  background: linear-gradient(to right, #ffffff, #fafbff);
}

.search-icon {
  color: #667eea;
  font-size: 16px;
  transition: all 0.3s;
}

.search-input :deep(.el-input__wrapper.is-focus) .search-icon {
  transform: scale(1.1);
}

/* 加入班级按钮优化 */
.join-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 10px;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 600;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.35);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.join-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s;
}

.join-btn:hover::before {
  left: 100%;
}

.join-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.45);
}

.join-btn:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 用户区域优化 */
.user-avatar {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 25px;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
}

.user-avatar:hover {
  background: rgba(255, 255, 255, 1);
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
  transform: translateY(-1px);
}

.avatar-img {
  transition: transform 0.3s;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.25);
  border: 2px solid #fff;
}

.user-avatar:hover .avatar-img {
  transform: scale(1.05);
}

.user-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
  letter-spacing: 0.3px;
  transition: all 0.3s;
}

.user-avatar:hover .user-name {
  color: #667eea;
}

/* 主体内容 */
.main-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 105px 25px 50px;
  position: relative;
  z-index: 1;
}

/* 欢迎区域优化 */
.welcome-section {
  margin-bottom: 45px;
}

.welcome-title {
  font-size: 38px;
  font-weight: 700;
  color: #303133;
  margin: 0 0 12px 0;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
  letter-spacing: 0.5px;
}

.name-highlight {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.student-info {
  font-size: 15px;
  color: #b0b3c1;
  margin: 0;
  font-weight: 400;
  letter-spacing: 0.3px;
}

/* 班级列表 */
.class-list-section {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  padding: 35px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.8);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 35px;
}

.section-header h3 {
  font-size: 22px;
  font-weight: 700;
  color: #303133;
  margin: 0;
}

.class-count {
  font-size: 14px;
  color: #b0b3c1;
  font-weight: 400;
}

.class-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 28px;
}

/* 班级卡片优化 */
.class-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  border: 1px solid rgba(102, 126, 234, 0.1);
  position: relative;
  animation: cardFadeIn 0.6s ease-out both;
}

@keyframes cardFadeIn {
  0% {
    opacity: 0;
    transform: translateY(30px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

.class-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.2);
  border-color: rgba(102, 126, 234, 0.3);
}

.class-card:active {
  transform: translateY(-4px) scale(0.99);
}

/* 卡片图标 */
.card-icon {
  position: absolute;
  top: 18px;
  left: 18px;
  width: 50px;
  height: 50px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 3;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  transition: all 0.3s;
}

.card-icon :deep(.el-icon) {
  font-size: 26px;
  color: #667eea;
}

.class-card:hover .card-icon {
  transform: scale(1.1) rotate(5deg);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
}

/* 智慧课程徽章优化 */
.card-badge {
  position: absolute;
  top: 18px;
  right: 18px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(255, 255, 255, 0.9) 100%);
  backdrop-filter: blur(10px);
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 12px;
  color: #667eea;
  font-weight: 600;
  z-index: 3;
  box-shadow: 0 2px 12px rgba(102, 126, 234, 0.15);
  border: 1px solid rgba(102, 126, 234, 0.1);
  transition: all 0.3s;
}

.class-card:hover .card-badge {
  transform: scale(1.05);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.25);
}

/* 卡片封面 - 不同课程不同渐变 */
.card-cover {
  height: 170px;
  position: relative;
  display: flex;
  align-items: flex-end;
  padding: 22px;
  transition: all 0.4s;
}

.cover-gradient-1 {
  background: linear-gradient(135deg, #667eea 0%, #5a67d8 50%, #4c51bf 100%);
}

.cover-gradient-2 {
  background: linear-gradient(135deg, #764ba2 0%, #8b5fbf 50%, #a06dd6 100%);
}

.cover-gradient-3 {
  background: linear-gradient(135deg, #48c6ef 0%, #5fa3d0 50%, #6f86d6 100%);
}

.class-card:hover .card-cover {
  filter: brightness(1.08);
}

.semester-tag {
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(12px);
  padding: 7px 18px;
  border-radius: 24px;
  color: white;
  font-size: 13px;
  font-weight: 500;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s;
}

.class-card:hover .semester-tag {
  transform: scale(1.03);
  background: rgba(255, 255, 255, 0.3);
}

/* 卡片内容 */
.card-content {
  padding: 24px;
}

.class-name {
  font-size: 20px;
  font-weight: 700;
  color: #303133;
  margin: 0 0 14px 0;
  letter-spacing: 0.3px;
  transition: color 0.3s;
}

.class-card:hover .class-name {
  color: #667eea;
}

.teacher-info {
  display: flex;
  align-items: center;
  gap: 7px;
  font-size: 14px;
  color: #b0b3c1;
  margin: 0 0 18px 0;
  font-weight: 400;
}

.teacher-info :deep(.el-icon) {
  font-size: 15px;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 18px;
  border-top: 1px solid rgba(102, 126, 234, 0.08);
}

/* AI智课标签 - 不同课程不同颜色 */
.ai-tag {
  font-size: 12px;
  font-weight: 600;
  padding: 6px 14px;
  border-radius: 20px;
  transition: all 0.3s;
  border: 1px solid transparent;
}

.ai-tag-1 {
  color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(92, 103, 216, 0.15) 100%);
  border-color: rgba(102, 126, 234, 0.2);
}

.ai-tag-2 {
  color: #764ba2;
  background: linear-gradient(135deg, rgba(118, 75, 162, 0.1) 0%, rgba(139, 95, 191, 0.15) 100%);
  border-color: rgba(118, 75, 162, 0.2);
}

.ai-tag-3 {
  color: #48c6ef;
  background: linear-gradient(135deg, rgba(72, 198, 239, 0.1) 0%, rgba(111, 134, 214, 0.15) 100%);
  border-color: rgba(72, 198, 239, 0.2);
}

.class-card:hover .ai-tag {
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
}

.empty-state {
  grid-column: 1 / -1;
  padding: 70px 0;
}

/* 个人信息对话框样式 */
.profile-dialog :deep(.el-dialog__header) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  margin: 0;
}

.profile-dialog :deep(.el-dialog__title) {
  color: white;
  font-size: 18px;
  font-weight: 600;
}

.profile-dialog :deep(.el-dialog__headerbtn .el-icon) {
  color: white;
  font-size: 18px;
}

.profile-dialog :deep(.el-dialog__body) {
  padding: 30px;
}

.profile-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #606266;
}

.profile-form :deep(.el-input.is-disabled .el-input__wrapper) {
  background-color: #f5f7fa;
  cursor: not-allowed;
}

.profile-form :deep(.el-input.is-disabled .el-input__inner) {
  color: #909399;
}

.profile-form :deep(.el-input:not(.is-disabled) .el-input__wrapper) {
  background-color: white !important;
  cursor: text;
}

.profile-form :deep(.el-input:not(.is-disabled) .el-input__inner) {
  color: #606266;
  cursor: text;
}

.profile-form :deep(.el-divider__text) {
  background-color: white;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.dialog-footer .el-button {
  min-width: 100px;
  border-radius: 8px;
  font-weight: 500;
}

.dialog-footer .el-button--primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: all 0.3s;
}

.dialog-footer .el-button--primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

/* 修改密码按钮区域 */
.password-section {
  padding: 20px 30px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  border-radius: 8px;
  margin-top: 16px;
  text-align: center;
}

.change-password-btn {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  border: 2px solid rgba(102, 126, 234, 0.2);
  color: #667eea;
  font-weight: 600;
  border-radius: 8px;
  padding: 10px 24px;
  transition: all 0.3s;
}

.change-password-btn:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: transparent;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.3);
}

/* 修改密码对话框样式 */
.password-dialog :deep(.el-dialog__header) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  margin: 0;
}

.password-dialog :deep(.el-dialog__title) {
  color: white;
  font-size: 18px;
  font-weight: 600;
}

.password-dialog :deep(.el-dialog__headerbtn .el-icon) {
  color: white;
  font-size: 18px;
}

.password-dialog :deep(.el-dialog__body) {
  padding: 30px;
}

.password-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #606266;
}

.password-form :deep(.el-input__wrapper) {
  border-radius: 8px;
  transition: all 0.3s;
}

.password-form :deep(.el-input__wrapper:hover) {
  border-color: #667eea;
}

.password-form :deep(.el-input__wrapper.is-focus) {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.password-tips {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #ecf5ff;
  border-radius: 8px;
  margin-top: 10px;
  font-size: 13px;
  color: #606266;
}

.password-tips .el-icon {
  font-size: 16px;
}

/* 响应式优化 */
@media (max-width: 768px) {
  .top-nav {
    padding: 0 20px;
    height: auto;
    min-height: 70px;
    flex-direction: column;
    gap: 15px;
    padding-top: 15px;
    padding-bottom: 15px;
  }
  
  .nav-left, .nav-right {
    width: 100%;
    justify-content: center;
  }
  
  .search-input {
    width: 100%;
    max-width: 300px;
  }
  
  .welcome-title {
    font-size: 28px;
  }
  
  .class-grid {
    grid-template-columns: 1fr;
  }
  
  .profile-dialog {
    width: 95% !important;
  }
  
  .password-dialog {
    width: 95% !important;
  }
  
  .password-section {
    padding: 16px;
  }
}
</style>

