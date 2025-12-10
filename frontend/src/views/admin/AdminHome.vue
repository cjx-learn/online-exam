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
        
        <el-menu-item index="class">
          <el-icon><School /></el-icon>
          <span>班级管理</span>
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
              <el-avatar 
                :size="42" 
                :icon="userInfo.realName ? (userInfo.avatar ? undefined : UserFilled) : UserFilled" 
                :src="getAvatarUrl(userInfo.avatar)"
                class="avatar-img" 
              />
              <span class="user-name">{{ userInfo.realName || '管理员' }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>
                  个人信息
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
            <el-upload class="upload-btn" :action="uploadUrl + '/admin/import/course'" :show-file-list="false" :on-success="handleImportSuccess" :on-error="handleImportError" accept=".xlsx,.xls">
              <el-button type="success"><el-icon><Upload /></el-icon>批量导入</el-button>
            </el-upload>
            <el-button type="info" text @click="downloadTemplate('course')">下载模板</el-button>
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
        
        <!-- 班级管理 -->
        <div v-if="activeMenu === 'class'" class="class-management">
          <el-table :data="classList" border stripe>
            <el-table-column prop="id" label="班级ID" width="80" />
            <el-table-column prop="name" label="班级名称" min-width="150" />
            <el-table-column prop="code" label="课程代码" width="120" />
            <el-table-column prop="inviteCode" label="邀请码" width="120" />
            <el-table-column prop="semester" label="学期" width="150" />
            <el-table-column prop="teacherName" label="授课教师" width="120" />
            <el-table-column prop="studentCount" label="学生数" width="90" />
            <el-table-column label="启用状态" width="100">
              <template #default="{ row }">
                <el-switch v-model="row.status" :active-value="1" :inactive-value="0" @change="updateClassStatus(row)" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button link type="danger" size="small" @click="deleteClass(row)">删除</el-button>
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
            <el-upload class="upload-btn" :action="uploadUrl + '/admin/import/teacher'" :show-file-list="false" :on-success="handleImportSuccess" :on-error="handleImportError" accept=".xlsx,.xls">
              <el-button type="success"><el-icon><Upload /></el-icon>批量导入</el-button>
            </el-upload>
            <el-button type="info" text @click="downloadTemplate('teacher')">下载模板</el-button>
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
            <el-upload class="upload-btn" :action="uploadUrl + '/admin/import/student'" :show-file-list="false" :on-success="handleImportSuccess" :on-error="handleImportError" accept=".xlsx,.xls">
              <el-button type="success"><el-icon><Upload /></el-icon>批量导入</el-button>
            </el-upload>
            <el-button type="info" text @click="downloadTemplate('student')">下载模板</el-button>
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
    
    <!-- 个人信息对话框 -->
    <el-dialog v-model="profileDialogVisible" title="个人信息" width="500px" :close-on-click-modal="false">
      <el-form :model="userForm" label-width="80px">
        <el-form-item label="头像">
          <AvatarUpload v-model="userForm.avatar" />
        </el-form-item>
        <el-form-item label="用户名"><el-input v-model="userForm.username" disabled /></el-form-item>
        <el-form-item label="真实姓名"><el-input v-model="userForm.realName" disabled /></el-form-item>
        <el-divider content-position="left"><span style="color: #909399; font-size: 13px;">可修改信息</span></el-divider>
        <el-form-item label="邮箱"><el-input v-model="userForm.email" placeholder="请输入邮箱" clearable /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="userForm.phone" placeholder="请输入手机号" maxlength="11" clearable /></el-form-item>
      </el-form>
      <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ebeef5;">
        <el-button @click="openPasswordDialog" type="primary" plain>修改密码</el-button>
      </div>
      <template #footer>
        <el-button @click="profileDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveProfile">保存修改</el-button>
      </template>
    </el-dialog>
    
    <!-- 修改密码对话框 -->
    <el-dialog v-model="passwordDialogVisible" title="修改密码" width="450px" :close-on-click-modal="false">
      <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="100px">
        <el-form-item label="旧密码" prop="oldPassword">
          <el-input v-model="passwordForm.oldPassword" type="password" placeholder="请输入旧密码" show-password clearable />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码（6-20位）" show-password clearable />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请再次输入新密码" show-password clearable />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="closePasswordDialog">取消</el-button>
        <el-button type="primary" @click="changePassword">确认修改</el-button>
      </template>
    </el-dialog>
    
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
    
    <!-- 教师对话框 -->
    <el-dialog v-model="teacherDialogVisible" :title="teacherDialogTitle" width="500px">
      <el-form :model="teacherForm" :rules="teacherRules" ref="teacherFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="teacherForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="teacherForm.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="工号">
          <el-input v-model="teacherForm.teacherNo" placeholder="请输入工号" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="teacherForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="teacherForm.phone" placeholder="请输入手机号" maxlength="11" />
        </el-form-item>
        <el-form-item label="院系">
          <el-input v-model="teacherForm.department" placeholder="请输入院系" />
        </el-form-item>
        <el-form-item label="职称">
          <el-input v-model="teacherForm.title" placeholder="请输入职称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="teacherDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveTeacher">保存</el-button>
      </template>
    </el-dialog>
    
    <!-- 学生对话框 -->
    <el-dialog v-model="studentDialogVisible" :title="studentDialogTitle" width="500px">
      <el-form :model="studentForm" :rules="studentRules" ref="studentFormRef" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="studentForm.username" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="真实姓名" prop="realName">
          <el-input v-model="studentForm.realName" placeholder="请输入真实姓名" />
        </el-form-item>
        <el-form-item label="学号">
          <el-input v-model="studentForm.studentNo" placeholder="请输入学号" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="studentForm.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="studentForm.phone" placeholder="请输入手机号" maxlength="11" />
        </el-form-item>
        <el-form-item label="专业">
          <el-input v-model="studentForm.major" placeholder="请输入专业" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="studentDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveStudent">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { API_URL } from '@/config/api'
import { getAvatarUrl } from '@/utils/file'
import {
  Document,
  User,
  UserFilled,
  SwitchButton,
  Plus,
  Edit,
  Delete,
  Search,
  Refresh,
  Download,
  Upload
} from '@element-plus/icons-vue'
import request from '@/utils/request'
import AvatarUpload from '@/components/AvatarUpload.vue'

const router = useRouter()

// 用户信息
const userInfo = reactive({
  id: '',
  username: '',
  realName: '管理员',
  email: '',
  phone: '',
  avatar: ''
})

// 从 localStorage 读取用户信息
try {
  const storedUserInfo = localStorage.getItem('userInfo')
  if (storedUserInfo) {
    const parsed = JSON.parse(storedUserInfo)
    Object.assign(userInfo, {
      id: parsed.userId || '',
      username: parsed.username || '',
      realName: parsed.realName || '管理员',
      email: parsed.email || '',
      phone: parsed.phone || '',
      avatar: parsed.avatar || ''
    })
  }
} catch (e) {
  console.error('Failed to parse userInfo from localStorage in AdminHome:', e)
}

// 当前激活的菜单
const activeMenu = ref('dashboard')

// 菜单标题映射
const menuTitles = {
  dashboard: '系统概览',
  course: '课程管理',
  class: '班级管理',
  teacher: '教师账号管理',
  student: '学生账号管理'
}

// 上传URL
const uploadUrl = API_URL

// 统计数据
const stats = reactive({
  courseCount: 0,
  teacherCount: 0,
  studentCount: 0,
  classCount: 0
})

// 数据列表
const courseList = ref([])
const classList = ref([])
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

// 教师对话框
const teacherDialogVisible = ref(false)
const teacherFormRef = ref(null)
const teacherForm = reactive({
  id: null,
  username: '',
  realName: '',
  teacherNo: '',
  email: '',
  phone: '',
  department: '',
  title: ''
})
const teacherRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }]
}

// 学生对话框
const studentDialogVisible = ref(false)
const studentFormRef = ref(null)
const studentForm = reactive({
  id: null,
  username: '',
  realName: '',
  studentNo: '',
  email: '',
  phone: '',
  major: ''
})
const studentRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }]
}

// 菜单选择
const handleMenuSelect = (index) => {
  activeMenu.value = index
  if (index === 'course') {
    loadCourseList()
  } else if (index === 'class') {
    loadClassList()
  } else if (index === 'teacher') {
    loadTeacherList()
  } else if (index === 'student') {
    loadStudentList()
  }
}

// 个人信息对话框
const profileDialogVisible = ref(false)
const userForm = reactive({
  id: '',
  username: '',
  realName: '',
  email: '',
  phone: '',
  avatar: ''
})

// 修改密码对话框
const passwordDialogVisible = ref(false)
const passwordFormRef = ref(null)
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const passwordRules = {
  oldPassword: [{ required: true, message: '请输入旧密码', trigger: 'blur' }],
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

// 用户菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      const storedUserInfo = localStorage.getItem('userInfo')
      if (storedUserInfo) {
        const parsed = JSON.parse(storedUserInfo)
        Object.assign(userForm, {
          id: parsed.userId,
          username: parsed.username,
          realName: parsed.realName,
          email: parsed.email || '',
          phone: parsed.phone || '',
          avatar: parsed.avatar || ''
        })
      }
      profileDialogVisible.value = true
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

// 保存个人信息
const saveProfile = async () => {
  try {
    const response = await request.post('/user/update', {
      id: userForm.id,
      realName: userForm.realName,
      email: userForm.email,
      phone: userForm.phone,
      avatar: userForm.avatar,
      role: 2
    })
    if (response.code === 200) {
      ElMessage.success('个人信息已保存')
      profileDialogVisible.value = false
      // 更新本地 userInfo
      Object.assign(userInfo, {
        realName: userForm.realName,
        email: userForm.email,
        phone: userForm.phone,
        avatar: userForm.avatar
      })
      // 更新 localStorage
      const storedUserInfo = localStorage.getItem('userInfo')
      if (storedUserInfo) {
        const parsed = JSON.parse(storedUserInfo)
        parsed.realName = userForm.realName
        parsed.email = userForm.email
        parsed.phone = userForm.phone
        parsed.avatar = userForm.avatar
        localStorage.setItem('userInfo', JSON.stringify(parsed))
      }
    } else {
      ElMessage.error(response.message || '保存失败')
    }
  } catch (error) {
    ElMessage.error('网络错误，无法保存')
  }
}

const openPasswordDialog = () => { passwordDialogVisible.value = true }
const closePasswordDialog = () => {
  passwordDialogVisible.value = false
  passwordForm.oldPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
}

const changePassword = async () => {
  if (!passwordFormRef.value) return
  await passwordFormRef.value.validate(async (valid) => {
    if (!valid) return
    try {
      const response = await request.post('/user/changePassword', {
        id: userForm.id,
        oldPassword: passwordForm.oldPassword,
        newPassword: passwordForm.newPassword,
        role: 2
      })
      if (response.code === 200) {
        ElMessage.success('密码修改成功，请重新登录')
        closePasswordDialog()
        profileDialogVisible.value = false
        setTimeout(() => {
          localStorage.clear()
          router.push('/login')
        }, 1500)
      } else {
        ElMessage.error(response.message || '密码修改失败')
      }
    } catch (error) {
      ElMessage.error('网络错误，无法修改密码')
    }
  })
}

// 导入成功处理
const handleImportSuccess = (response) => {
  if (response.code === 200) {
    const data = response.data
    ElMessage.success(`导入完成！成功: ${data.successCount} 条，失败: ${data.errorCount} 条`)
    if (data.errors && data.errors.length > 0) {
      ElMessageBox.alert(data.errors.slice(0, 10).join('<br>'), '导入错误详情', { dangerouslyUseHTMLString: true, type: 'warning' })
    }
    if (activeMenu.value === 'course') loadCourseList()
    else if (activeMenu.value === 'teacher') loadTeacherList()
    else if (activeMenu.value === 'student') loadStudentList()
  } else {
    ElMessage.error(response.message || '导入失败')
  }
}

const handleImportError = () => { ElMessage.error('文件上传失败，请检查文件格式') }

// 下载模板
const downloadTemplate = (type) => {
  const templates = {
    course: ['课程代码(必填)', '课程名称(必填)', '分类', '学分', '学时', '院系', '描述'],
    teacher: ['用户名(必填)', '真实姓名', '工号', '邮箱', '手机号', '院系', '职称'],
    student: ['用户名(必填)', '真实姓名', '学号', '邮箱', '手机号']
  }
  const headers = templates[type]
  import('xlsx').then((XLSX) => {
    const ws = XLSX.utils.aoa_to_sheet([headers])
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')
    XLSX.writeFile(wb, `${type}_template.xlsx`)
    ElMessage.success('模板已下载')
  })
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

// 加载班级列表
const loadClassList = async () => {
  try {
    const response = await request.get('/class/all')
    if (response.code === 200) {
      classList.value = response.data || []
    }
  } catch (error) {
    console.error('加载班级列表失败:', error)
    ElMessage.error('加载班级列表失败')
  }
}

// 删除班级
const deleteClass = (row) => {
  ElMessageBox.confirm(`确定要删除班级"${row.name}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.delete(`/class/${row.id}`)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadClassList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 更新班级状态
const updateClassStatus = async (row) => {
  try {
    const response = await request.post('/admin/class/status', { id: row.id, status: row.status })
    if (response.code === 200) {
      ElMessage.success('状态更新成功')
    } else {
      ElMessage.error(response.message || '更新失败')
      row.status = row.status === 1 ? 0 : 1
    }
  } catch (error) {
    row.status = row.status === 1 ? 0 : 1
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

// 教师对话框标题
const teacherDialogTitle = ref('添加教师')

const showAddTeacherDialog = () => {
  teacherDialogTitle.value = '添加教师'
  Object.assign(teacherForm, { id: null, username: '', realName: '', teacherNo: '', email: '', phone: '', department: '', title: '' })
  teacherDialogVisible.value = true
}

const saveTeacher = async () => {
  try {
    await teacherFormRef.value.validate()
    const url = teacherForm.id ? '/admin/teacher/update' : '/admin/teacher/add'
    const method = teacherForm.id ? 'put' : 'post'
    const response = await request[method](url, teacherForm)
    if (response.code === 200) {
      ElMessage.success(response.message || (teacherForm.id ? '修改成功' : '添加成功'))
      teacherDialogVisible.value = false
      loadTeacherList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (!error.errors) ElMessage.error('操作失败')
  }
}

const editTeacher = (row) => {
  teacherDialogTitle.value = '编辑教师'
  Object.assign(teacherForm, {
    id: row.id,
    username: row.username,
    realName: row.realName,
    teacherNo: row.teacherNo,
    email: row.email,
    phone: row.phone,
    department: row.department,
    title: row.title
  })
  teacherDialogVisible.value = true
}

const deleteTeacher = (row) => {
  ElMessageBox.confirm(`确定要删除教师"${row.realName}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.delete(`/admin/teacher/${row.id}`)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadTeacherList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 学生对话框标题
const studentDialogTitle = ref('添加学生')

const showAddStudentDialog = () => {
  studentDialogTitle.value = '添加学生'
  Object.assign(studentForm, { id: null, username: '', realName: '', studentNo: '', email: '', phone: '', major: '' })
  studentDialogVisible.value = true
}

const saveStudent = async () => {
  try {
    await studentFormRef.value.validate()
    const url = studentForm.id ? '/admin/student/update' : '/admin/student/add'
    const method = studentForm.id ? 'put' : 'post'
    const response = await request[method](url, studentForm)
    if (response.code === 200) {
      ElMessage.success(response.message || (studentForm.id ? '修改成功' : '添加成功'))
      studentDialogVisible.value = false
      loadStudentList()
    } else {
      ElMessage.error(response.message || '操作失败')
    }
  } catch (error) {
    if (!error.errors) ElMessage.error('操作失败')
  }
}

const editStudent = (row) => {
  studentDialogTitle.value = '编辑学生'
  Object.assign(studentForm, {
    id: row.id,
    username: row.username,
    realName: row.realName,
    studentNo: row.studentNo,
    email: row.email,
    phone: row.phone,
    major: row.major
  })
  studentDialogVisible.value = true
}

const deleteStudent = (row) => {
  ElMessageBox.confirm(`确定要删除学生"${row.realName}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.delete(`/admin/student/${row.id}`)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadStudentList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
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
  display: flex;
  gap: 12px;
  align-items: center;
}

.upload-btn {
  display: inline-block;
}

/* 内容面板样式 - 添加班级管理 */
.class-management {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.08);
  min-height: calc(100vh - 140px);
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

