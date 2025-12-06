<template>
  <div class="teacher-home">
    <!-- 背景装饰 -->
    <div class="bg-decorations">
      <div class="deco-circle deco-circle-1"></div>
      <div class="deco-circle deco-circle-2"></div>
      <div class="deco-circle deco-circle-3"></div>
      <div class="deco-square deco-square-1"></div>
      <div class="deco-square deco-square-2"></div>
    </div>
    
    <!-- 顶部导航栏 -->
    <div class="top-nav">
      <div class="nav-left">
        <h1 class="title">
          <span class="title-text">在线考试系统</span>
        </h1>
      </div>
      
      <div class="nav-right">
        <!-- 创建班级按钮 -->
        <el-button type="primary" @click="showCreateDialog" class="create-btn">
          <el-icon><Plus /></el-icon>
          创建班级
        </el-button>
        
        <!-- 用户头像下拉菜单 -->
        <el-dropdown @command="handleCommand">
          <div class="user-avatar">
            <el-avatar :size="42" :icon="UserFilled" class="avatar-img" />
            <span class="user-name">{{ userInfo.realName || '教师' }}</span>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon><User /></el-icon>
                修改信息
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
      <!-- 欢迎区域 -->
      <div class="welcome-section">
        <h2 class="welcome-title">欢迎回来，<span class="name-highlight">{{ currentUserInfo.realName }}</span>！</h2>
        <p class="teacher-info">工号: {{ currentUserInfo.teacherNo || 'T001' }}</p>
      </div>
      
      <!-- 班级列表 -->
      <div class="class-list-section">
        <div class="section-header">
          <h3>我创建的班级</h3>
          <span class="class-count">全部班级</span>
        </div>
        
        <!-- 加载中 -->
        <div v-if="loading" class="loading-container">
          <el-icon class="is-loading"><Loading /></el-icon>
          <span>加载中...</span>
        </div>
        
        <!-- 班级网格 -->
        <div v-else class="class-grid">
          <!-- 班级卡片 -->
          <div 
            v-for="(item, index) in currentPageClasses" 
            :key="item.id" 
            class="class-card"
            :class="`class-card-${(index % 3) + 1}`"
            @click="enterClass(item)"
            :style="{ animationDelay: `${index * 0.1}s` }"
          >
            <div class="card-header">
              <div class="card-icon">
                <el-icon><Monitor /></el-icon>
              </div>
              <div class="card-badge">智慧课程</div>
            </div>
            <div class="card-cover" :class="`cover-gradient-${(index % 3) + 1}`"></div>
            <div class="card-content">
              <div class="class-title-section">
                <h3 class="class-name">{{ item.name }}</h3>
                <p class="course-code">
                  <el-icon><Document /></el-icon>
                  {{ item.code || '课程代码' }}
                </p>
              </div>
              <div class="class-info-section">
                <div class="info-item teacher-info">
                  <div class="info-icon">
                    <el-icon><User /></el-icon>
                  </div>
                  <div class="info-text">
                    <span class="info-label">授课教师</span>
                    <span class="info-value">{{ item.teacherName || userInfo.realName }}</span>
                  </div>
                </div>
                <div class="info-item student-info">
                  <div class="info-icon">
                    <el-icon><UserFilled /></el-icon>
                  </div>
                  <div class="info-text">
                    <span class="info-label">学生人数</span>
                    <span class="info-value">{{ item.studentCount || 0 }} 人</span>
                  </div>
                </div>
              </div>
              <div class="card-footer">
                <span class="invite-label">邀请码</span>
                <span class="invite-code">{{ item.inviteCode }}</span>
              </div>
            </div>
          </div>
          
          <!-- 空状态 -->
          <el-empty 
            v-if="classList.length === 0" 
            description="还没有创建任何班级"
            class="empty-state"
          >
            <el-button type="primary" @click="showCreateDialog">创建班级</el-button>
          </el-empty>
        </div>
        
        <!-- 分页 -->
        <div v-if="classList.length > pageSize" class="pagination">
          <el-pagination
            v-model:current-page="currentPage"
            :page-size="pageSize"
            :total="classList.length"
            layout="prev, pager, next"
            @current-change="handlePageChange"
          />
        </div>
      </div>
    </div>
    
    <!-- 创建班级对话框 -->
    <el-dialog 
      v-model="createDialogVisible" 
      title="创建班级" 
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="createForm" :rules="createRules" ref="createFormRef" label-width="80px">
        <el-form-item label="选择课程" prop="courseId">
          <el-select 
            v-model="createForm.courseId" 
            placeholder="请选择课程"
            filterable
            @change="handleCourseChange"
            style="width: 100%"
          >
            <el-option
              v-for="course in courseList"
              :key="course.id"
              :label="`${course.code} - ${course.name}`"
              :value="course.id"
            >
              <span style="float: left">{{ course.code }}</span>
              <span style="float: right; color: #8492a6; font-size: 13px">{{ course.name }}</span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="班级名称" prop="name">
          <el-input 
            v-model="createForm.name" 
            placeholder="如：操作系统（2025春季班）"
            clearable
          />
        </el-form-item>
        <el-form-item label="学期" prop="semester">
          <el-input 
            v-model="createForm.semester" 
            placeholder="如：2025 Fall-Winter"
            clearable
          />
        </el-form-item>
        <el-form-item label="课程描述">
          <el-input 
            v-model="createForm.description" 
            type="textarea"
            :rows="3"
            placeholder="可选，默认使用课程描述"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmCreateClass" :loading="creating">创建</el-button>
      </template>
    </el-dialog>
    
    <!-- 个人信息对话框 -->
    <el-dialog 
      v-model="profileDialogVisible" 
      title="个人信息" 
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="userForm" label-width="80px">
        <el-form-item label="真实姓名">
          <el-input v-model="userForm.realName" disabled />
        </el-form-item>
        <el-form-item label="工号">
          <el-input v-model="userForm.teacherNo" disabled />
        </el-form-item>
        <el-form-item label="密码">
          <el-input v-model="userForm.password" type="password" placeholder="留空则不修改" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="userForm.email" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="userForm.phone" />
        </el-form-item>
        <el-form-item label="单位">
          <el-input v-model="userForm.department" />
        </el-form-item>
        <el-form-item label="职称">
          <el-input v-model="userForm.title" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="profileDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveProfile">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { 
  Plus, UserFilled, User, SwitchButton, Monitor, Loading, Document
} from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()

// 用户信息
const userInfo = reactive({
  id: '',
  username: '',
  realName: '',
  teacherNo: '',
  email: '',
  phone: '',
  department: '',
  title: ''
})

// 个人信息表单
const userForm = reactive({ ...userInfo })

let currentUserInfo = null;
try {
  const storedUserInfo = localStorage.getItem('userInfo');
  if (storedUserInfo) {
    currentUserInfo = JSON.parse(storedUserInfo);
    // Populate userInfo reactive object
    if (currentUserInfo && currentUserInfo.userId) {
      Object.assign(userInfo, {
        id: currentUserInfo.userId,
        username: currentUserInfo.username,
        realName: currentUserInfo.realName,
        teacherNo: currentUserInfo.teacherNo || '',
        email: currentUserInfo.email || '',
        phone: currentUserInfo.phone || '',
        department: currentUserInfo.department || '',
        title: currentUserInfo.title || '',
      });
    }
  }
} catch (e) {
  console.error("Failed to parse userInfo from localStorage in TeacherHome:", e);
}

// 班级列表
const classList = ref([])
const loading = ref(false)

// 课程列表
const courseList = ref([])

// 分页
const currentPage = ref(1)
const pageSize = ref(9) // 每页9个

// 当前页的班级
const currentPageClasses = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return classList.value.slice(start, end)
})

// 对话框状态
const createDialogVisible = ref(false)
const profileDialogVisible = ref(false)
const creating = ref(false)

// 创建班级表单
const createFormRef = ref(null)
const createForm = reactive({
  courseId: null,
  name: '',
  description: '',
  semester: '2025 Fall-Winter'
})

// 表单验证规则
const createRules = {
  courseId: [
    { required: true, message: '请选择课程', trigger: 'change' }
  ],
  name: [
    { required: true, message: '请输入班级名称', trigger: 'blur' }
  ],
  semester: [
    { required: true, message: '请输入学期', trigger: 'blur' }
  ]
}

// 加载班级列表
const loadClassList = async () => {
  loading.value = true
  try {
    // 检查教师ID是否可用
    if (!currentUserInfo || !currentUserInfo.userId) {
      console.error("Teacher ID not found in userInfo. Cannot load class list.");
      ElMessage.error('用户信息未找到，请重新登录！');
      router.push('/login'); // 如果ID丢失，则重定向到登录
      return;
    }

    // 打印用于请求的ID
    console.log('Fetching class list for teacher ID:', currentUserInfo.userId, 'Type:', typeof currentUserInfo.userId);

    const response = await request.get(`/class/teacher/${currentUserInfo.userId}`)
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

// 加载课程列表
const loadCourseList = async () => {
  try {
    const response = await request.get('/course/list')
    if (response.code === 200) {
      courseList.value = response.data || []
    } else {
      ElMessage.error(response.message || '加载课程列表失败')
    }
  } catch (error) {
    console.error('加载课程列表失败:', error)
    ElMessage.error('加载课程列表失败')
  }
}

// 课程选择改变
const handleCourseChange = (courseId) => {
  const course = courseList.value.find(c => c.id === courseId)
  if (course) {
    // 可以自动填充一些默认值
    if (!createForm.name) {
      createForm.name = `${course.name}`
    }
  }
}

// 显示创建对话框
const showCreateDialog = () => {
  // 加载课程列表
  if (courseList.value.length === 0) {
    loadCourseList()
  }
  // 重置表单
  createForm.courseId = null
  createForm.name = ''
  createForm.description = ''
  createForm.semester = '2025 Fall-Winter'
  createDialogVisible.value = true
}

// 确认创建班级
const confirmCreateClass = async () => {
  try {
    await createFormRef.value.validate()
    
    // 检查班级名称是否重复
    const existingClass = classList.value.find(c => c.name === createForm.name)
    if (existingClass) {
      ElMessage.warning('班级名称已存在，请使用其他名称')
      return
    }
    
    creating.value = true
    
    const response = await request.post('/class', {
      courseId: createForm.courseId,
      name: createForm.name,
      description: createForm.description,
      semester: createForm.semester,
      schoolYear: '2024-2025',
      teacherId: currentUserInfo.userId,
      status: 1
    })
    
    if (response.code === 200) {
      ElMessage.success('创建班级成功！')
      createDialogVisible.value = false
      // 重新加载班级列表
      loadClassList()
    } else {
      ElMessage.error(response.message || '创建班级失败')
    }
  } catch (error) {
    if (error.errors) {
      // 表单验证错误
      return
    }
    console.error('创建班级失败:', error)
    ElMessage.error('创建班级失败')
  } finally {
    creating.value = false
  }
}

// 处理用户菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      Object.assign(userForm, currentUserInfo)
      profileDialogVisible.value = true
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
    // 假设后端有一个 /user/update 接口来更新用户信息
    const updateData = {
      id: currentUserInfo.userId,
      role: 1, // 教师角色
      realName: userForm.realName,
      teacherNo: userForm.teacherNo,
      email: userForm.email,
      phone: userForm.phone,
      department: userForm.department,
      title: userForm.title,
      // password: userForm.password // 密码字段需要额外处理，这里暂时不包含
    };
    // 如果密码字段有值，则添加到更新数据中
    if (userForm.password) {
      updateData.password = userForm.password;
    }
    const response = await request.post('/user/update', updateData);

    if (response.code === 200) {
      ElMessage.success('个人信息已保存');
      profileDialogVisible.value = false;

      const updatedUserInfo = { ...currentUserInfo, ...updateData };
      localStorage.setItem('userInfo', JSON.stringify(updatedUserInfo));
      Object.assign(userInfo, updatedUserInfo);
      currentUserInfo = updatedUserInfo;
    } else {
      ElMessage.error(response.message || '保存个人信息失败');
    }
  } catch (error) {
    console.error('保存个人信息失败:', error);
    ElMessage.error('网络错误，无法保存个人信息');
  }
  profileDialogVisible.value = false
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

// 进入班级详情
const enterClass = (classItem) => {
  router.push(`/teacher/class/${classItem.id}`)
}

// 分页切换
const handlePageChange = (page) => {
  currentPage.value = page
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

.teacher-home {
  min-height: 100vh;
  background: linear-gradient(135deg, #fce4ec 0%, #e3f2fd 50%, #f3e5f5 100%);
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

/* 圆形装饰 */
.deco-circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.3);
  animation: float 15s ease-in-out infinite;
}

.deco-circle-1 {
  width: 150px;
  height: 150px;
  top: 10%;
  left: 8%;
  animation-delay: 0s;
}

.deco-circle-2 {
  width: 100px;
  height: 100px;
  top: 60%;
  right: 10%;
  animation-delay: 3s;
}

.deco-circle-3 {
  width: 80px;
  height: 80px;
  bottom: 15%;
  left: 15%;
  animation-delay: 6s;
}

/* 方形装饰 */
.deco-square {
  position: absolute;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.2);
  transform: rotate(45deg);
  animation: rotate 20s linear infinite;
}

.deco-square-1 {
  width: 120px;
  height: 120px;
  top: 30%;
  right: 20%;
}

.deco-square-2 {
  width: 90px;
  height: 90px;
  bottom: 25%;
  right: 8%;
  animation-delay: 5s;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0) scale(1);
  }
  50% {
    transform: translateY(-30px) scale(1.05);
  }
}

@keyframes rotate {
  0% {
    transform: rotate(45deg);
  }
  100% {
    transform: rotate(405deg);
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

.nav-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

/* 创建按钮 */
.create-btn {
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

.create-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s;
}

.create-btn:hover::before {
  left: 100%;
}

.create-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.45);
}

.create-btn:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 用户区域 */
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
  color: #606060;
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

/* 欢迎区域 */
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

.teacher-info {
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

/* 加载中 */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 0;
  color: #909399;
}

.loading-container .el-icon {
  font-size: 40px;
  margin-bottom: 15px;
}

.class-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 28px;
  margin-bottom: 30px;
}

/* 班级卡片 */
.class-card {
  background: white;
  border-radius: 18px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  border: 1px solid rgba(102, 126, 234, 0.1);
  position: relative;
  animation: cardFadeIn 0.6s ease-out both;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
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
  transform: translateY(-10px) scale(1.02);
  box-shadow: 0 16px 40px rgba(102, 126, 234, 0.25);
  border-color: rgba(102, 126, 234, 0.3);
}

.class-card:active {
  transform: translateY(-6px) scale(0.99);
}

/* 卡片头部 */
.card-header {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 3;
}

/* 卡片图标 */
.card-icon {
  width: 52px;
  height: 52px;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(12px);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.card-icon :deep(.el-icon) {
  font-size: 28px;
  color: #667eea;
}

.class-card:hover .card-icon {
  transform: scale(1.15) rotate(-8deg);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.35);
}

.class-card:hover .card-icon :deep(.el-icon) {
  color: #764ba2;
}

/* 智慧课程徽章 */
.card-badge {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.98) 0%, rgba(255, 255, 255, 0.95) 100%);
  backdrop-filter: blur(12px);
  padding: 7px 15px;
  border-radius: 20px;
  font-size: 12px;
  color: #667eea;
  font-weight: 600;
  box-shadow: 0 2px 12px rgba(102, 126, 234, 0.18);
  border: 1px solid rgba(102, 126, 234, 0.15);
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.class-card:hover .card-badge {
  transform: scale(1.08);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

/* 卡片封面 - 不同卡片不同渐变 */
.card-cover {
  height: 120px;
  position: relative;
  transition: all 0.4s;
  overflow: hidden;
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
  filter: brightness(1.1);
}

/* 卡片内容 */
.card-content {
  padding: 28px 24px 24px;
}

/* 班级标题区域 */
.class-title-section {
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.08);
}

.class-name {
  font-size: 20px;
  font-weight: 700;
  color: #1D2129;
  margin: 0 0 10px 0;
  letter-spacing: 0.3px;
  line-height: 1.4;
  transition: all 0.3s;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.class-card:hover .class-name {
  color: #667eea;
}

.course-code {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #86909C;
  margin: 0;
  font-weight: 500;
}

.course-code :deep(.el-icon) {
  font-size: 14px;
  color: #667eea;
}

/* 班级信息区域 */
.class-info-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 20px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.04) 0%, rgba(118, 75, 162, 0.02) 100%);
  border-radius: 12px;
  transition: all 0.3s;
}

.info-item:hover {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.04) 100%);
  transform: translateY(-2px);
}

.info-icon {
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.info-icon :deep(.el-icon) {
  font-size: 18px;
  color: white;
}

.info-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
  flex: 1;
}

.info-label {
  font-size: 11px;
  color: #86909C;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-value {
  font-size: 14px;
  color: #1D2129;
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.03) 0%, rgba(118, 75, 162, 0.02) 100%);
  border-radius: 12px;
  margin-top: 4px;
}

.invite-label {
  font-size: 12px;
  color: #86909C;
  font-weight: 500;
}

.invite-code {
  font-size: 14px;
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 6px 14px;
  border-radius: 10px;
  font-weight: 700;
  letter-spacing: 1px;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.25);
  transition: all 0.3s;
}

.class-card:hover .invite-code {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.35);
}

/* 分页 */
.pagination {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}

.empty-state {
  grid-column: 1 / -1;
  padding: 70px 0;
}

/* 响应式 */
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
  
  .welcome-title {
    font-size: 28px;
  }
  
  .class-grid {
    grid-template-columns: 1fr;
  }
}
</style>

