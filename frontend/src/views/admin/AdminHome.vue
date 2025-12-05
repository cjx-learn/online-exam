<template>
  <div class="admin-home">
    <!-- 左侧导航栏 -->
    <div class="sidebar">
      <div class="logo">
        <h2>管理系统</h2>
      </div>
      
      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        background-color="transparent"
        text-color="rgba(255, 255, 255, 0.85)"
        active-text-color="#ffffff"
        @select="handleMenuSelect"
      >
        <el-menu-item index="dashboard">
          <el-icon><HomeFilled /></el-icon>
          <span>首页</span>
        </el-menu-item>
        
        <el-menu-item index="course">
          <el-icon><Reading /></el-icon>
          <span>课程管理</span>
        </el-menu-item>
        
        <el-menu-item index="teacher">
          <el-icon><User /></el-icon>
          <span>教师账号管理</span>
        </el-menu-item>
        
        <el-menu-item index="student">
          <el-icon><UserFilled /></el-icon>
          <span>学生账号管理</span>
        </el-menu-item>
      </el-menu>
    </div>
    
    <!-- 右侧内容区 -->
    <div class="main-content">
      <!-- 顶部栏 -->
      <div class="header">
        <div class="header-left">
          <h1 class="header-title">
            <span class="title-text">{{ menuTitles[activeMenu] }}</span>
          </h1>
        </div>
        <div class="header-right">
          <!-- 用户头像下拉菜单 -->
          <el-dropdown @command="handleCommand">
            <div class="user-avatar">
              <el-avatar :size="42" :icon="UserFilled" class="avatar-img" />
              <span class="user-name">{{ userInfo.realName || '管理员' }}</span>
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
      
      <!-- 内容区域 -->
      <div class="content">
        <!-- 首页仪表板 -->
        <div v-if="activeMenu === 'dashboard'" class="dashboard">
          <el-row :gutter="20">
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-icon course">
                  <el-icon><Reading /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ stats.courseCount }}</div>
                  <div class="stat-label">课程总数</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-icon teacher">
                  <el-icon><User /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ stats.teacherCount }}</div>
                  <div class="stat-label">教师数量</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-icon student">
                  <el-icon><UserFilled /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ stats.studentCount }}</div>
                  <div class="stat-label">学生数量</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card class="stat-card">
                <div class="stat-icon class">
                  <el-icon><Document /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-value">{{ stats.classCount }}</div>
                  <div class="stat-label">班级数量</div>
                </div>
              </el-card>
            </el-col>
          </el-row>
        </div>
        
        <!-- 课程管理 -->
        <div v-if="activeMenu === 'course'" class="course-management">
          <div class="toolbar">
            <el-button type="primary" @click="showAddCourseDialog">
              <el-icon><Plus /></el-icon>
              添加课程
            </el-button>
          </div>
          
          <el-table :data="courseList" border stripe>
            <el-table-column type="selection" width="55" />
            <el-table-column prop="id" label="课程编号" width="100" />
            <el-table-column prop="code" label="课程代码" width="120" />
            <el-table-column prop="name" label="课程名称" min-width="150" />
            <el-table-column prop="category" label="分类" width="120" />
            <el-table-column prop="credit" label="学分" width="80" />
            <el-table-column prop="hours" label="学时" width="80" />
            <el-table-column prop="department" label="院系" width="150" />
            <el-table-column label="操作" width="150" fixed="right">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="editCourse(row)">编辑</el-button>
                <el-button link type="danger" size="small" @click="deleteCourse(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
        
        <!-- 教师账号管理 -->
        <div v-if="activeMenu === 'teacher'" class="teacher-management">
          <div class="toolbar">
            <el-button type="primary" @click="showAddTeacherDialog">
              <el-icon><Plus /></el-icon>
              添加教师
            </el-button>
          </div>
          
          <el-table :data="teacherList" border stripe>
            <el-table-column type="selection" width="55" />
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="teacherNo" label="工号" width="120" />
            <el-table-column prop="realName" label="姓名" width="120" />
            <el-table-column prop="username" label="用户名" width="120" />
            <el-table-column prop="email" label="邮箱" min-width="180" />
            <el-table-column prop="phone" label="手机号" width="130" />
            <el-table-column prop="department" label="院系" width="150" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-switch
                  v-model="row.status"
                  :active-value="1"
                  :inactive-value="0"
                  @change="updateTeacherStatus(row)"
                />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180" fixed="right">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="editTeacher(row)">编辑</el-button>
                <el-button link type="warning" size="small" @click="resetPassword(row, 'teacher')">重置密码</el-button>
                <el-button link type="danger" size="small" @click="deleteTeacher(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
        
        <!-- 学生账号管理 -->
        <div v-if="activeMenu === 'student'" class="student-management">
          <div class="toolbar">
            <el-button type="primary" @click="showAddStudentDialog">
              <el-icon><Plus /></el-icon>
              添加学生
            </el-button>
          </div>
          
          <el-table :data="studentList" border stripe>
            <el-table-column type="selection" width="55" />
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="studentNo" label="学号" width="120" />
            <el-table-column prop="realName" label="姓名" width="120" />
            <el-table-column prop="username" label="用户名" width="120" />
            <el-table-column prop="email" label="邮箱" min-width="180" />
            <el-table-column prop="phone" label="手机号" width="130" />
            <el-table-column prop="major" label="专业" width="150" />
            <el-table-column label="状态" width="100">
              <template #default="{ row }">
                <el-switch
                  v-model="row.status"
                  :active-value="1"
                  :inactive-value="0"
                  @change="updateStudentStatus(row)"
                />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="180" fixed="right">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="editStudent(row)">编辑</el-button>
                <el-button link type="warning" size="small" @click="resetPassword(row, 'student')">重置密码</el-button>
                <el-button link type="danger" size="small" @click="deleteStudent(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>
    
    <!-- 课程对话框 -->
    <el-dialog
      v-model="courseDialogVisible"
      :title="courseDialogTitle"
      width="600px"
    >
      <el-form :model="courseForm" :rules="courseRules" ref="courseFormRef" label-width="100px">
        <el-form-item label="课程代码" prop="code">
          <el-input v-model="courseForm.code" placeholder="如：CS301" />
        </el-form-item>
        <el-form-item label="课程名称" prop="name">
          <el-input v-model="courseForm.name" />
        </el-form-item>
        <el-form-item label="课程描述" prop="description">
          <el-input v-model="courseForm.description" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="分类" prop="category">
          <el-input v-model="courseForm.category" placeholder="如：Computer Science" />
        </el-form-item>
        <el-form-item label="学分" prop="credit">
          <el-input-number v-model="courseForm.credit" :min="0" :max="10" :step="0.5" />
        </el-form-item>
        <el-form-item label="学时" prop="hours">
          <el-input-number v-model="courseForm.hours" :min="0" :max="200" :step="8" />
        </el-form-item>
        <el-form-item label="开课院系" prop="department">
          <el-input v-model="courseForm.department" />
        </el-form-item>
        <el-form-item label="课程级别" prop="level">
          <el-select v-model="courseForm.level" placeholder="请选择">
            <el-option label="本科" value="Undergraduate" />
            <el-option label="研究生" value="Graduate" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="courseDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveCourse">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  HomeFilled, Reading, User, UserFilled, Document, Plus, ArrowDown, Setting, SwitchButton
} from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()

// 用户信息
const userInfo = reactive({
  id: localStorage.getItem('userId') || '',
  username: localStorage.getItem('username') || '',
  realName: localStorage.getItem('realName') || '管理员'
})

// 当前激活的菜单
const activeMenu = ref('dashboard')

// 菜单标题映射
const menuTitles = {
  dashboard: '系统概览',
  course: '课程管理',
  teacher: '教师账号管理',
  student: '学生账号管理'
}

// 统计数据
const stats = reactive({
  courseCount: 0,
  teacherCount: 0,
  studentCount: 0,
  classCount: 0
})

// 数据列表
const courseList = ref([])
const teacherList = ref([])
const studentList = ref([])

// 对话框
const courseDialogVisible = ref(false)
const courseDialogTitle = ref('添加课程')
const courseFormRef = ref(null)
const courseForm = reactive({
  id: null,
  code: '',
  name: '',
  description: '',
  category: '',
  credit: 3.0,
  hours: 48,
  department: '',
  level: 'Undergraduate'
})

const courseRules = {
  code: [{ required: true, message: '请输入课程代码', trigger: 'blur' }],
  name: [{ required: true, message: '请输入课程名称', trigger: 'blur' }],
  category: [{ required: true, message: '请输入课程分类', trigger: 'blur' }]
}

// 菜单选择
const handleMenuSelect = (index) => {
  activeMenu.value = index
  if (index === 'course') {
    loadCourseList()
  } else if (index === 'teacher') {
    loadTeacherList()
  } else if (index === 'student') {
    loadStudentList()
  }
}

// 用户菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      ElMessage.info('个人信息功能开发中...')
      break
    case 'settings':
      ElMessage.info('设置功能开发中...')
      break
    case 'logout':
      ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        localStorage.clear()
        ElMessage.success('已退出登录')
        router.push('/login')
      }).catch(() => {})
      break
  }
}

// 加载统计数据
const loadStats = async () => {
  try {
    const response = await request.get('/admin/stats')
    if (response.code === 200) {
      Object.assign(stats, response.data)
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

// 加载课程列表
const loadCourseList = async () => {
  try {
    const response = await request.get('/course/list')
    if (response.code === 200) {
      courseList.value = response.data || []
    }
  } catch (error) {
    console.error('加载课程列表失败:', error)
    ElMessage.error('加载课程列表失败')
  }
}

// 加载教师列表
const loadTeacherList = async () => {
  try {
    const response = await request.get('/admin/teacher/list')
    if (response.code === 200) {
      teacherList.value = response.data || []
    }
  } catch (error) {
    console.error('加载教师列表失败:', error)
    ElMessage.error('加载教师列表失败')
  }
}

// 加载学生列表
const loadStudentList = async () => {
  try {
    const response = await request.get('/admin/student/list')
    if (response.code === 200) {
      studentList.value = response.data || []
    }
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  }
}

// 显示添加课程对话框
const showAddCourseDialog = () => {
  courseDialogTitle.value = '添加课程'
  Object.assign(courseForm, {
    id: null,
    code: '',
    name: '',
    description: '',
    category: '',
    credit: 3.0,
    hours: 48,
    department: '',
    level: 'Undergraduate'
  })
  courseDialogVisible.value = true
}

// 编辑课程
const editCourse = (row) => {
  courseDialogTitle.value = '编辑课程'
  Object.assign(courseForm, row)
  courseDialogVisible.value = true
}

// 保存课程
const saveCourse = async () => {
  try {
    await courseFormRef.value.validate()
    
    const url = courseForm.id ? '/course/update' : '/course/create'
    const response = await request.post(url, courseForm)
    
    if (response.code === 200) {
      ElMessage.success(courseForm.id ? '修改成功' : '添加成功')
      courseDialogVisible.value = false
      loadCourseList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    console.error('保存课程失败:', error)
  }
}

// 删除课程
const deleteCourse = (row) => {
  ElMessageBox.confirm(`确定要删除课程"${row.name}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.delete(`/course/${row.id}`)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadCourseList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      console.error('删除课程失败:', error)
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 更新教师状态
const updateTeacherStatus = async (row) => {
  try {
    const response = await request.post('/admin/teacher/status', {
      id: row.id,
      status: row.status
    })
    if (response.code === 200) {
      ElMessage.success('状态更新成功')
    } else {
      ElMessage.error(response.message || '更新失败')
      row.status = row.status === 1 ? 0 : 1
    }
  } catch (error) {
    console.error('更新教师状态失败:', error)
    row.status = row.status === 1 ? 0 : 1
  }
}

// 更新学生状态
const updateStudentStatus = async (row) => {
  try {
    const response = await request.post('/admin/student/status', {
      id: row.id,
      status: row.status
    })
    if (response.code === 200) {
      ElMessage.success('状态更新成功')
    } else {
      ElMessage.error(response.message || '更新失败')
      row.status = row.status === 1 ? 0 : 1
    }
  } catch (error) {
    console.error('更新学生状态失败:', error)
    row.status = row.status === 1 ? 0 : 1
  }
}

// 重置密码
const resetPassword = async (row, type) => {
  ElMessageBox.confirm(`确定要重置"${row.realName}"的密码为"123456"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.post(`/admin/${type}/resetPassword`, {
        id: row.id
      })
      if (response.code === 200) {
        ElMessage.success('密码已重置为123456')
      } else {
        ElMessage.error(response.message || '重置失败')
      }
    } catch (error) {
      console.error('重置密码失败:', error)
      ElMessage.error('重置失败')
    }
  }).catch(() => {})
}

// 临时方法（待实现完整功能）
const showAddTeacherDialog = () => {
  ElMessage.info('添加教师功能开发中')
}

const editTeacher = (row) => {
  ElMessage.info('编辑教师功能开发中')
}

const deleteTeacher = (row) => {
  ElMessage.info('删除教师功能开发中')
}

const showAddStudentDialog = () => {
  ElMessage.info('添加学生功能开发中')
}

const editStudent = (row) => {
  ElMessage.info('编辑学生功能开发中')
}

const deleteStudent = (row) => {
  ElMessage.info('删除学生功能开发中')
}

onMounted(() => {
  loadStats()
})
</script>

<style scoped>
.admin-home {
  display: flex;
  height: 100vh;
  background: linear-gradient(135deg, var(--bg-grad-1) 0%, var(--bg-grad-2) 50%, var(--bg-grad-3) 100%);
  position: relative;
  overflow: hidden;
}

/* 背景装饰 */
.admin-home::before {
  content: '';
  position: fixed;
  top: -50%;
  right: -10%;
  width: 800px;
  height: 800px;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.06) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

.admin-home::after {
  content: '';
  position: fixed;
  bottom: -30%;
  left: -10%;
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(118, 75, 162, 0.06) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

/* 左侧导航栏 */
.sidebar {
  width: 240px;
  background: linear-gradient(180deg, #4a3f6b 0%, #5d4a7a 50%, #6b5b8e 100%);
  display: flex;
  flex-direction: column;
  box-shadow: 4px 0 20px rgba(102, 126, 234, 0.25);
  position: relative;
  z-index: 2;
}

.logo {
  height: 70px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.25) 0%, rgba(118, 75, 162, 0.2) 100%);
  border-bottom: 1px solid rgba(255, 255, 255, 0.15);
  position: relative;
  overflow: hidden;
}

.logo::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -20%;
  width: 100px;
  height: 100px;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
  border-radius: 50%;
}

.logo h2 {
  color: #fff;
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
  position: relative;
  z-index: 1;
}

.sidebar-menu {
  border-right: none;
  flex: 1;
  padding: 12px 8px;
  background: transparent !important;
}

:deep(.el-menu) {
  background-color: transparent !important;
}

:deep(.el-menu-item) {
  height: 52px;
  line-height: 52px;
  margin: 4px 0;
  border-radius: 10px;
  color: rgba(255, 255, 255, 0.85) !important;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

:deep(.el-menu-item:hover) {
  background: linear-gradient(135deg, rgba(168, 213, 255, 0.2) 0%, rgba(200, 182, 255, 0.15) 100%) !important;
  transform: translateX(4px);
  color: #fff !important;
}

:deep(.el-menu-item.is-active) {
  background: linear-gradient(135deg, rgba(168, 213, 255, 0.3) 0%, rgba(200, 182, 255, 0.25) 100%) !important;
  color: #fff !important;
  box-shadow: 0 4px 12px rgba(168, 213, 255, 0.3);
}

:deep(.el-menu-item .el-icon) {
  transition: all 0.3s ease;
}

:deep(.el-menu-item:hover .el-icon),
:deep(.el-menu-item.is-active .el-icon) {
  transform: scale(1.15) rotate(-5deg);
}

/* 右侧内容区 */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  position: relative;
  z-index: 1;
}

.header {
  height: 70px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  backdrop-filter: blur(12px);
  padding: 0 32px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  position: relative;
}

.header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, var(--primary) 0%, var(--primary-2) 50%, var(--primary) 100%);
  opacity: 0.6;
}

.header-title {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
}

.title-text {
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

/* 用户头像区域 */
.user-avatar {
  display: flex;
  align-items: center;
  gap: 12px;
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
  color: var(--primary);
  transform: translateY(-1px);
}

.content {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
}

/* 仪表板 */
.dashboard {
  margin-top: 0;
}

.stat-card {
  display: flex;
  align-items: center;
  padding: 24px;
  border-radius: 16px;
  border: none;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  background: linear-gradient(180deg, var(--primary) 0%, var(--primary-2) 100%);
  opacity: 0;
  transition: opacity 0.3s;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 12px 48px rgba(102, 126, 234, 0.15);
}

.stat-card:hover::before {
  opacity: 1;
}

.stat-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
  margin-right: 20px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
}

.stat-icon.course {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

.stat-icon.teacher {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: #fff;
}

.stat-icon.student {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: #fff;
}

.stat-icon.class {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
  color: #fff;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 36px;
  font-weight: 700;
  background: linear-gradient(135deg, #333 0%, #666 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #666;
  font-weight: 500;
}

/* 内容面板样式 */
.course-management,
.teacher-management,
.student-management {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.08);
  min-height: calc(100vh - 140px);
}

/* 工具栏 */
.toolbar {
  margin-bottom: 20px;
}

/* 表格 */
:deep(.el-table) {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

:deep(.el-table th) {
  background: #f8f9fb !important;
  color: #444;
  font-weight: 600;
  height: 50px;
}

:deep(.el-table--striped .el-table__body tr.el-table__row--striped td) {
  background: #fafafa;
}

:deep(.el-table--enable-row-hover .el-table__body tr:hover > td) {
  background-color: #f0f7ff;
}
</style>

