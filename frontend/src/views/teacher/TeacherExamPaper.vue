<template>
  <div class="exam-paper-container">
    <div class="top-header">
      <div class="header-left">
        <h1 class="system-title">在线考试系统</h1>
      </div>
      <div class="header-right">
        <el-button type="danger" @click="goExamManage" class="back-btn">
          <el-icon><Back /></el-icon>
          返回考试管理界面
        </el-button>
        <el-dropdown @command="handleUserCommand">
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
    <div class="paper-body">
      <div class="top-bar">
      <el-button type="primary" @click="goBack" class="back-button">
        <el-icon><Back /></el-icon>
        返回
      </el-button>
      <h2 class="title">试卷预览：{{ exam.title || '-' }}</h2>
      <div class="actions">
        <el-button @click="printPaper" class="print-button">
          <el-icon><Printer /></el-icon>
          打印
        </el-button>
      </div>
    </div>

    <el-card class="exam-info" shadow="never">
      <div class="info-grid">
        <div class="info-item">
          <div class="info-icon">
            <el-icon><User /></el-icon>
          </div>
          <div class="info-content">
            <div class="info-label">班级</div>
            <div class="info-value">{{ exam.className || exam.classId || '-' }}</div>
          </div>
        </div>
        <div class="info-item">
          <div class="info-icon score-icon">
            <el-icon><TrendCharts /></el-icon>
          </div>
          <div class="info-content">
            <div class="info-label">总分</div>
            <div class="info-value score-value">{{ exam.totalScore ?? '-' }}</div>
          </div>
        </div>
        <div class="info-item">
          <div class="info-icon time-icon">
            <el-icon><Timer /></el-icon>
          </div>
          <div class="info-content">
            <div class="info-label">时长</div>
            <div class="info-value">{{ exam.duration ? exam.duration + ' 分钟' : '-' }}</div>
          </div>
        </div>
        <div class="info-item">
          <div class="info-icon start-icon">
            <el-icon><Clock /></el-icon>
          </div>
          <div class="info-content">
            <div class="info-label">开始时间</div>
            <div class="info-value">{{ formatTime(exam.startTime) }}</div>
          </div>
        </div>
        <div class="info-item">
          <div class="info-icon end-icon">
            <el-icon><Clock /></el-icon>
          </div>
          <div class="info-content">
            <div class="info-label">结束时间</div>
            <div class="info-value">{{ formatTime(exam.endTime) }}</div>
          </div>
        </div>
        <div class="info-item">
          <div class="info-icon status-icon">
            <el-icon><CircleCheck /></el-icon>
          </div>
          <div class="info-content">
            <div class="info-label">状态</div>
            <div class="info-value">
              <el-tag :type="examStatusTag" class="status-tag">{{ examStatusText }}</el-tag>
            </div>
          </div>
        </div>
      </div>
      <div class="meta-stats">
        <div class="stat-card questions-stat">
          <div class="stat-icon">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ totalQuestions }}</div>
            <div class="stat-label">题目</div>
          </div>
        </div>
        <div class="stat-card score-stat">
          <div class="stat-icon">
            <el-icon><TrendCharts /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ totalScore }}</div>
            <div class="stat-label">总分</div>
          </div>
        </div>
      </div>
      <div v-if="exam.description" class="desc">{{ exam.description }}</div>
    </el-card>

    <el-card class="paper-card" shadow="never">
      <div v-if="loading" class="loading-wrap">
        <el-icon class="is-loading"><Loading /></el-icon>
        加载中...
      </div>
      <template v-else>
        <template v-for="section in groupedQuestions" :key="section.type">
          <div class="section">
            <div class="section-header">
              <h3>{{ section.title }}（共 {{ section.items.length }} 题，{{ section.totalScore }} 分）</h3>
            </div>
            <div class="question" v-for="(q, idx) in section.items" :key="q.id">
              <div class="q-header">
                <span class="q-no">{{ idx + 1 }}.</span>
                <span class="q-content" v-text="q.content" />
                <el-tag class="q-score" type="warning">{{ q.score ?? '-' }} 分</el-tag>
              </div>
              <div class="q-body">
                <!-- 选择题选项 -->
                <div v-if="[1,2,3].includes(q.type) && q.options" class="q-options">
                  <div v-for="(opt, key) in parseOptions(q.options)" :key="key" class="opt">
                    <span class="opt-key">{{ key }}.</span>
                    <span class="opt-text">{{ opt }}</span>
                  </div>
                </div>

                <!-- 答案显示（教师可见） -->
                <div class="q-answer">
                  <b>答案：</b>
                  <span>{{ q.answer }}</span>
                </div>
              </div>
              <el-divider class="q-divider" />
            </div>
          </div>
        </template>
        <div v-if="!questions.length" class="empty">暂无题目</div>
      </template>
    </el-card>

    <!-- 个人信息对话框 -->
    <el-dialog 
      v-model="profileDialogVisible" 
      title="个人信息" 
      width="500px"
      :close-on-click-modal="false">
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Back, Loading, Printer, User, UserFilled, SwitchButton, TrendCharts, Timer, Clock, CircleCheck, Document } from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()
const examId = ref(route.params.id)

const exam = reactive({})
const questions = ref([])
const loading = ref(true)

const goBack = () => router.back()
const goExamManage = () => {
  if (exam.classId) {
    router.push(`/teacher/class/${exam.classId}?tab=exams`)
  } else {
    router.back()
  }
}
const printPaper = () => window.print()

// 个人设置
const profileDialogVisible = ref(false)
const userInfo = reactive({
  id: '', username: '', realName: '教师', teacherNo: '', email: '', phone: '', department: '', title: ''
})
const userForm = reactive({ ...userInfo })
let currentUserInfo = null
try {
  const storedUserInfo = localStorage.getItem('userInfo')
  if (storedUserInfo) {
    currentUserInfo = JSON.parse(storedUserInfo)
    if (currentUserInfo && currentUserInfo.userId) {
      Object.assign(userInfo, {
        id: currentUserInfo.userId,
        username: currentUserInfo.username,
        realName: currentUserInfo.realName,
        teacherNo: currentUserInfo.teacherNo || '',
        email: currentUserInfo.email || '',
        phone: currentUserInfo.phone || '',
        department: currentUserInfo.department || '',
        title: currentUserInfo.title || ''
      })
    }
  }
} catch (e) {
  console.error('Failed to parse userInfo from localStorage in TeacherExamPaper:', e)
}

const handleUserCommand = (command) => {
  switch (command) {
    case 'profile':
      Object.assign(userForm, userInfo)
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

const saveProfile = async () => {
  if (!currentUserInfo || !currentUserInfo.userId) {
    ElMessage.warning('用户信息未找到，请重新登录')
    router.push('/login')
    return
  }
  try {
    const updateData = {
      id: currentUserInfo.userId,
      realName: userForm.realName,
      teacherNo: userForm.teacherNo,
      email: userForm.email,
      phone: userForm.phone,
      department: userForm.department,
      title: userForm.title
    }
    if (userForm.password) updateData.password = userForm.password
    const response = await request.post('/user/update', updateData)
    if (response.code === 200) {
      ElMessage.success('个人信息已保存')
      profileDialogVisible.value = false
      const updatedUserInfo = { ...currentUserInfo, ...updateData }
      localStorage.setItem('userInfo', JSON.stringify(updatedUserInfo))
      Object.assign(userInfo, updatedUserInfo)
      currentUserInfo = updatedUserInfo
    } else {
      ElMessage.error(response.message || '保存个人信息失败')
    }
  } catch (error) {
    console.error('保存个人信息失败:', error)
    ElMessage.error('网络错误，无法保存个人信息')
  }
}

const formatTime = (time) => {
  if (!time) return '-'
  const d = new Date(time)
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mm = String(d.getMinutes()).padStart(2, '0')
  return `${y}-${m}-${day} ${hh}:${mm}`
}

const examStatusTag = computed(() => {
  if (!exam.startTime || !exam.endTime) return 'info'
  const now = new Date()
  const s = new Date(exam.startTime)
  const e = new Date(exam.endTime)
  if (now < s) return 'info'
  if (now > e) return ''
  return 'success'
})

const examStatusText = computed(() => {
  if (!exam.startTime || !exam.endTime) return '未设置'
  const now = new Date()
  const s = new Date(exam.startTime)
  const e = new Date(exam.endTime)
  if (now < s) return '未开始'
  if (now > e) return '已结束'
  return '进行中'
})

const parseOptions = (options) => {
  try {
    if (!options) return {}
    if (typeof options === 'string') return JSON.parse(options)
    return options
  } catch (e) {
    console.warn('Invalid options JSON:', options)
    return {}
  }
}

const groupedQuestions = computed(() => {
  const order = [1, 2, 3, 4, 5]
  const titles = {
    1: '单选题',
    2: '多选题',
    3: '判断题',
    4: '填空题',
    5: '简答题'
  }
  const groups = order.map(t => ({ type: t, title: titles[t], items: [], totalScore: 0 }))
  for (const q of questions.value) {
    const g = groups.find(x => x.type === q.type)
    if (g) g.items.push(q)
  }
  for (const g of groups) {
    g.totalScore = g.items.reduce((s, q) => s + Number(q.score || 0), 0)
  }
  return groups.filter(g => g.items.length)
})

const totalQuestions = computed(() => questions.value.length)
const totalScore = computed(() => questions.value.reduce((s, q) => s + Number(q.score || 0), 0))

const loadData = async () => {
  loading.value = true
  try {
    const [examRes, qRes] = await Promise.all([
      request.get(`/exam/${examId.value}`),
      request.get(`/exam/${examId.value}/questions`),
    ])
    if (examRes.code === 200) Object.assign(exam, examRes.data || {})
    if (qRes.code === 200) questions.value = qRes.data || []
  } catch (e) {
    console.error('加载试卷失败:', e)
    ElMessage.error('加载试卷失败')
  } finally {
    loading.value = false
  }
}

onMounted(loadData)
</script>

<style scoped>
/* 页面背景与布局（与主界面一致风格） */
.exam-paper-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%);
  position: relative;
  overflow-x: hidden;
  font-family: 'Inter', 'PingFang SC', 'Helvetica Neue', Helvetica, 'microsoft yahei', Arial, sans-serif;
}
.exam-paper-container::before {
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
.exam-paper-container::after {
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

/* 顶部导航（与主界面一致风格） */
.top-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 400;
  height: 68px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(248, 249, 255, 0.95) 100%);
  backdrop-filter: blur(16px) saturate(180%);
  -webkit-backdrop-filter: blur(16px) saturate(180%);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.12);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-bottom: 2px solid rgba(102, 126, 234, 0.08);
}
.top-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 50%, #667eea 100%);
  opacity: 0.7;
  transition: opacity 0.3s ease;
}

.top-header:hover::after {
  opacity: 1;
}
.header-left { display: flex; align-items: center; gap: 16px; }
.system-title {
  font-size: 28px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
  letter-spacing: 0.8px;
  filter: drop-shadow(0 2px 8px rgba(102, 126, 234, 0.15));
  transition: all 0.3s ease;
}

.system-title:hover {
  letter-spacing: 1px;
  filter: drop-shadow(0 4px 12px rgba(102, 126, 234, 0.25));
}
.header-right { display: flex; align-items: center; gap: 16px; }
.back-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  border: none !important;
  color: #fff !important;
  font-weight: 600;
  border-radius: 12px;
  padding: 12px 24px;
  box-shadow: 0 4px 18px rgba(102, 126, 234, 0.35);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  font-size: 14px;
}

.back-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s ease;
}

.back-btn:hover::before {
  left: 100%;
}

.back-btn:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 8px 28px rgba(102, 126, 234, 0.45);
}

.back-btn:active {
  transform: translateY(-1px) scale(1.0);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
}

/* 内容容器 */
.paper-body {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 20px;
  padding-top: 90px;
  position: relative;
  z-index: 1;
}
.top-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 24px;
  padding: 20px 28px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  backdrop-filter: blur(12px);
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  border: 2px solid rgba(102, 126, 234, 0.1);
  transition: all 0.3s ease;
  animation: slideDown 0.5s ease-out;
}

.top-bar:hover {
  box-shadow: 0 6px 25px rgba(102, 126, 234, 0.12);
  border-color: rgba(102, 126, 234, 0.2);
  transform: translateY(-2px);
}

.back-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  border: none !important;
  color: #fff !important;
  border-radius: 12px;
  padding: 10px 20px;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.back-button:hover {
  transform: translateY(-2px) scale(1.02);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.35);
}

.print-button {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.actions :deep(.el-button) {
  min-width: 100px;
  border-radius: 12px;
  padding: 10px 20px;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border: 2px solid rgba(102, 126, 234, 0.15);
  color: #667eea;
}

.actions :deep(.el-button:hover) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.2);
  border-color: rgba(102, 126, 234, 0.3);
  background: linear-gradient(135deg, #fafbff 0%, #ffffff 100%);
}
.title {
  margin: 0;
  font-weight: 700;
  font-size: 22px;
  letter-spacing: 0.5px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  transition: all 0.3s ease;
}
.exam-info {
  margin-bottom: 20px;
  border-radius: 16px;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  padding: 24px 28px;
  transition: all 0.3s ease;
  animation: fadeInUp 0.6s ease-out 0.1s backwards;
}

.exam-info:hover {
  box-shadow: 0 6px 28px rgba(102, 126, 234, 0.12);
  border-color: rgba(102, 126, 234, 0.2);
  transform: translateY(-2px);
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 18px 20px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.8) 0%, rgba(248, 249, 255, 0.8) 100%);
  border-radius: 14px;
  border: 2px solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.info-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.05), transparent);
  transition: left 0.6s ease;
}

.info-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.12);
  border-color: rgba(102, 126, 234, 0.15);
}

.info-item:hover::before {
  left: 100%;
}

.info-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
  transition: all 0.3s ease;
}

.score-icon {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 4px 12px rgba(249, 115, 22, 0.25);
}

.time-icon {
  background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%);
  box-shadow: 0 4px 12px rgba(6, 182, 212, 0.25);
}

.start-icon, .end-icon {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.25);
}

.status-icon {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.25);
}

.info-item:hover .info-icon {
  transform: scale(1.1) rotate(5deg);
}

.info-content {
  flex: 1;
}

.info-label {
  font-size: 13px;
  color: #8b92a8;
  font-weight: 500;
  margin-bottom: 4px;
}

.info-value {
  font-size: 16px;
  color: #2c3e50;
  font-weight: 600;
}

.score-value {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  font-size: 18px;
  font-weight: 700;
}

.status-tag {
  padding: 6px 12px !important;
  border-radius: 8px !important;
  font-weight: 600 !important;
  font-size: 13px !important;
}

.meta-stats {
  display: flex;
  gap: 20px;
  justify-content: center;
  margin-top: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 24px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.9) 0%, rgba(250, 251, 255, 0.9) 100%);
  border-radius: 16px;
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  min-width: 160px;
}

.stat-card:hover {
  transform: translateY(-4px) scale(1.02);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.2);
}

.questions-stat .stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  box-shadow: 0 4px 16px rgba(34, 197, 94, 0.3);
}

.score-stat .stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  box-shadow: 0 4px 16px rgba(245, 158, 11, 0.3);
}

.stat-content {
  text-align: left;
}

.stat-number {
  font-size: 28px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  line-height: 1;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #8b92a8;
  font-weight: 500;
}

.desc {
  margin-top: 16px;
  padding: 16px;
  background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
  border-radius: 12px;
  color: #444;
  line-height: 1.8;
  border-left: 4px solid #667eea;
  font-size: 15px;
}
.paper-card {
  padding: 24px 28px;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
  animation: fadeInUp 0.6s ease-out 0.2s backwards;
}

.paper-card:hover {
  box-shadow: 0 6px 28px rgba(102, 126, 234, 0.12);
}
.user-avatar { display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 8px 16px; border-radius: 25px; background: rgba(255,255,255,0.8); border: 1px solid rgba(102,126,234,0.15); transition: all .3s ease; }
.user-avatar:hover { background: #fff; border-color: rgba(102,126,234,0.3); box-shadow: 0 4px 12px rgba(102,126,234,0.15); transform: translateY(-1px); }
.avatar-img { transition: transform .3s; box-shadow: 0 2px 8px rgba(102,126,234,.25); border: 2px solid #fff; }
.user-avatar:hover .avatar-img { transform: scale(1.05); }
.user-name { font-size: 15px; font-weight: 500; color: #333; letter-spacing: .3px; transition: all .3s; }
.user-avatar:hover .user-name { color: var(--primary); transform: translateY(-1px); }
.section {
  margin-bottom: 32px;
  animation: fadeInUp 0.6s ease-out backwards;
}

.section:nth-child(1) { animation-delay: 0.3s; }
.section:nth-child(2) { animation-delay: 0.35s; }
.section:nth-child(3) { animation-delay: 0.4s; }
.section:nth-child(4) { animation-delay: 0.45s; }
.section:nth-child(5) { animation-delay: 0.5s; }

.section-header {
  position: sticky;
  top: 90px;
  z-index: 5;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 16px 20px;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.25);
  margin-bottom: 16px;
  transition: all 0.3s ease;
}

.section-header:hover {
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.35);
  transform: translateY(-1px);
}

.section-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #ffffff;
  letter-spacing: 0.5px;
  display: flex;
  align-items: center;
  gap: 10px;
}

.section-header h3::before {
  content: '';
  display: inline-block;
  width: 6px;
  height: 24px;
  background: linear-gradient(180deg, #ffffff 0%, rgba(255, 255, 255, 0.6) 100%);
  border-radius: 3px;
}
.question {
  margin: 16px 0;
  padding: 20px 24px;
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border: 2px solid rgba(102, 126, 234, 0.08);
  border-radius: 14px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.question::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 50%, #667eea 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.question:hover {
  border-color: rgba(102, 126, 234, 0.15);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.12);
  transform: translateX(4px);
}

.question:hover::before {
  opacity: 1;
}
.q-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 14px;
}

.q-no {
  font-weight: 700;
  font-size: 16px;
  color: #667eea;
  min-width: 32px;
}

.q-content {
  flex: 1;
  color: #2c3e50;
  font-size: 16px;
  line-height: 1.6;
  font-weight: 500;
}

.q-score {
  margin-left: auto;
  padding: 6px 14px;
  border-radius: 10px;
  font-weight: 600;
  font-size: 13px;
}
.q-options {
  padding-left: 8px;
  margin: 12px 0;
  display: grid;
  grid-template-columns: repeat(2, minmax(220px, 1fr));
  gap: 10px 24px;
}

.opt {
  display: flex;
  gap: 10px;
  padding: 12px 16px;
  background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
  border-radius: 10px;
  border: 2px solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.opt::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(102, 126, 234, 0.04), transparent);
  transition: left 0.5s ease;
}

.opt:hover {
  border-color: rgba(102, 126, 234, 0.2);
  box-shadow: 0 6px 18px rgba(102, 126, 234, 0.1);
  transform: translateX(4px);
}

.opt:hover::before {
  left: 100%;
}

.opt-key {
  color: #667eea;
  font-weight: 700;
  font-size: 15px;
  min-width: 24px;
}

.opt-text {
  color: #4a5568;
  font-size: 15px;
  line-height: 1.5;
}
.q-answer {
  margin-top: 12px;
  padding: 14px 18px;
  background: linear-gradient(135deg, #dcfce7 0%, #d1fae5 100%);
  border-left: 4px solid #22c55e;
  border-radius: 12px;
  color: #166534;
  font-size: 15px;
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(34, 197, 94, 0.1);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.q-answer::before {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 0;
  height: 100%;
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.1) 0%, rgba(34, 197, 94, 0.05) 100%);
  transition: width 0.3s ease;
}

.q-answer:hover {
  box-shadow: 0 6px 20px rgba(34, 197, 94, 0.18);
  transform: translateX(2px);
}

.q-answer:hover::before {
  width: 100%;
}

.q-answer b {
  color: #16a34a;
  font-weight: 700;
  margin-right: 6px;
}
.loading-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  color: #667eea;
  font-size: 16px;
  font-weight: 500;
  padding: 40px 0;
}

.loading-wrap :deep(.el-icon) {
  font-size: 24px;
}

.empty {
  text-align: center;
  color: #999;
  padding: 48px 0;
  font-size: 16px;
  background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
  border-radius: 12px;
  border: 2px dashed rgba(102, 126, 234, 0.2);
}

.q-divider {
  margin: 16px 0 0 0;
  border-color: rgba(102, 126, 234, 0.1);
}

/* 动画定义 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 响应式优化 */
@media (max-width: 960px) {
  .paper-body {
    padding: 20px 16px;
    padding-top: 84px;
  }

  .top-header {
    padding: 0 20px;
    height: 60px;
  }

  .system-title {
    font-size: 22px;
  }

  .top-bar {
    flex-direction: column;
    align-items: stretch;
    padding: 16px 20px;
  }

  .title {
    font-size: 18px;
    text-align: center;
  }

  .actions {
    display: flex;
    justify-content: center;
  }

  .exam-info,
  .paper-card {
    padding: 20px;
  }

  .info-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .info-item {
    padding: 16px;
  }

  .info-icon {
    width: 40px;
    height: 40px;
    font-size: 18px;
  }

  .meta-stats {
    flex-direction: column;
    gap: 16px;
  }

  .stat-card {
    padding: 16px 20px;
    min-width: auto;
  }

  .q-options {
    grid-template-columns: 1fr;
  }

  .section-header {
    top: 60px;
    padding: 12px 16px;
  }

  .section-header h3 {
    font-size: 16px;
  }

  .question {
    padding: 16px;
  }
}

/* 打印样式 */
@media print {
  .top-header { display: none; }
  .top-bar { display: none; }
  .exam-paper-container { 
    padding: 0; 
    max-width: 100%; 
    background: white;
  }
  .paper-body {
    padding: 20px;
    max-width: 100%;
  }
  .paper-card, .exam-info { 
    box-shadow: none; 
    border: 1px solid #ddd;
    background: white;
  }
  .section-header { 
    position: static; 
    box-shadow: none;
    background: #667eea;
    page-break-after: avoid;
  }
  .question {
    page-break-inside: avoid;
    border: 1px solid #e0e0e0;
    background: white;
  }
  .opt {
    background: white;
    border: 1px solid #e0e0e0;
  }
  .q-answer {
    background: #f0fdf4;
  }
}
</style>
