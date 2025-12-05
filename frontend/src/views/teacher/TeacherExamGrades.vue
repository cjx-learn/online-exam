<template>
  <div class="teacher-exam-grades-container">
    <!-- 背景装饰 -->
    <div class="bg-decorations">
      <div class="deco-circle deco-circle-1"></div>
      <div class="deco-circle deco-circle-2"></div>
      <div class="deco-circle deco-circle-3"></div>
      <div class="deco-square deco-square-1"></div>
      <div class="deco-square deco-square-2"></div>
    </div>

    <!-- 顶部导航栏 -->
    <div class="grades-header">
      <div class="header-content">
        <div class="header-left">
          <button class="back-btn" @click="goBack">
            <el-icon><ArrowLeft /></el-icon>
          </button>
          <div class="header-info">
            <h1 class="grades-title">{{ exam.title || '考试成绩' }}</h1>
            <p v-if="exam" class="grades-subtitle">
              <el-icon class="time-icon"><Calendar /></el-icon>
              {{ formatTime(exam.startTime) }} - {{ formatTime(exam.endTime) }}
            </p>
          </div>
        </div>
        <div class="header-right">
          <div class="exam-meta-tag">
            <span class="meta-label">总分</span>
            <span class="meta-value">{{ exam.totalScore }}</span>
          </div>
          <div class="exam-status-tag" :class="{ ended: isExamEnded }">
            {{ isExamEnded ? '已结束' : '进行中' }}
          </div>
          
          <div class="header-divider"></div>

          <!-- 用户头像下拉菜单 -->
          <el-dropdown @command="handleUserCommand" trigger="click">
            <div class="user-avatar">
              <el-avatar :size="34" :icon="UserFilled" class="avatar-img" />
              <span class="user-name">{{ userInfo.realName }}</span>
            </div>
            <template #dropdown>
              <el-dropdown-menu class="user-dropdown">
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>
                  个人中心
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
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-card">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>正在加载成绩数据...</span>
      </div>
    </div>

    <!-- 主要内容 -->
    <div v-else class="grades-body">
      <!-- 统计卡片区域 -->
      <div class="stats-section">
        <div class="stat-card total-card">
          <div class="stat-icon">
            <el-icon><TrendCharts /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">参加人数</div>
            <div class="stat-value">{{ examRecords.length }}</div>
          </div>
        </div>
        <div class="stat-card avg-card">
          <div class="stat-icon">
            <el-icon><DataLine /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">平均分</div>
            <div class="stat-value">{{ averageScore.toFixed(2) }}</div>
          </div>
        </div>
        <div class="stat-card max-card">
          <div class="stat-icon">
            <el-icon><Trophy /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">最高分</div>
            <div class="stat-value">{{ maxScore }}</div>
          </div>
        </div>
        <div class="stat-card min-card">
          <div class="stat-icon">
            <el-icon><Bottom /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">最低分</div>
            <div class="stat-value">{{ minScore }}</div>
          </div>
        </div>
      </div>

      <!-- 成绩分布图表 -->
      <div class="chart-section">
        <div class="chart-card">
          <div class="chart-header">
            <h3>成绩分布</h3>
          </div>
          <div class="score-distribution">
            <div v-for="range in scoreRanges" :key="range.label" class="distribution-item">
              <div class="range-label">{{ range.label }}</div>
              <div class="range-bar">
                <div 
                  class="range-fill" 
                  :style="{ width: range.percentage + '%', backgroundColor: range.color }"
                >
                  <span v-if="range.count > 0" class="range-count">{{ range.count }}</span>
                </div>
              </div>
              <div class="range-info">{{ range.count }} 人</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 学生成绩列表 -->
      <div class="grades-list-section">
        <div class="list-header">
          <h3>学生成绩详情</h3>
          <div class="list-controls">
            <el-input 
              v-model="searchKeyword" 
              placeholder="搜索学生..." 
              clearable
              class="search-input"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-select 
              v-model="sortBy" 
              placeholder="排序方式" 
              class="sort-select"
            >
              <el-option label="按成绩降序" value="score-desc"></el-option>
              <el-option label="按成绩升序" value="score-asc"></el-option>
              <el-option label="按学号" value="studentNo"></el-option>
            </el-select>
          </div>
        </div>

        <el-table :data="filteredAndSortedRecords" stripe style="width: 100%" class="grades-table">
          <el-table-column type="index" label="排名" width="60" align="center" />
          <el-table-column prop="studentNo" label="学号" min-width="120" show-overflow-tooltip />
          <el-table-column prop="studentName" label="姓名" min-width="140" show-overflow-tooltip />
          <el-table-column label="总分" min-width="120" align="center">
            <template #default="scope">
              <div class="score-cell">
                <span class="score-value">{{ scope.row.totalScore ?? '-' }}</span>
                <span class="score-max">/ {{ exam.totalScore }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="客观题得分" min-width="120" align="center">
            <template #default="scope">
              {{ scope.row.objectiveScore ?? '-' }}
            </template>
          </el-table-column>
          <el-table-column label="主观题得分" min-width="140" align="center">
            <template #default="scope">
              <!-- 情况1: 已提交待批改 (status=1) -->
              <div v-if="scope.row.status === 1" class="subjective-score-cell">
                <span class="score-num">{{ scope.row.subjectiveScore ?? '-' }}</span>
                <el-tag 
                  type="warning" 
                  effect="light"
                  round
                  size="small"
                  class="status-tag"
                >
                  待批
                </el-tag>
              </div>
              
              <!-- 情况2: 已批改 (status=2) 且有主观题分数 -->
              <div v-else-if="scope.row.status === 2 && scope.row.subjectiveScore != null" class="subjective-score-cell">
                <span class="score-num">{{ scope.row.subjectiveScore }}</span>
                <el-tooltip content="已完成批改" placement="top">
                  <el-icon class="graded-icon"><CircleCheck /></el-icon>
                </el-tooltip>
              </div>
              
              <!-- 情况3: 其他 (如全是客观题，或者无主观题分数) -->
              <span v-else class="empty-text">-</span>
            </template>
          </el-table-column>
          <el-table-column label="提交时间" min-width="180">
            <template #default="scope">
              {{ formatTime(scope.row.submitTime) || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" fixed="right" align="center">
            <template #default="scope">
              <el-button 
                type="primary" 
                size="small" 
                @click="handleViewDetail(scope.row)"
              >
                <el-icon><Document /></el-icon>
                详情
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Loading, Search, Document, TrendCharts, DataLine, Trophy, Bottom, CircleCheck, Calendar, UserFilled, User, SwitchButton } from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()

const examId = ref(Number(route.params.id))
const exam = reactive({})
const examRecords = ref([])
const loading = ref(true)
const searchKeyword = ref('')
const sortBy = ref('score-desc')

// 用户信息
const userInfo = reactive({
  realName: '教师'
})

// 加载用户信息
try {
  const storedUserInfo = localStorage.getItem('userInfo')
  if (storedUserInfo) {
    const parsed = JSON.parse(storedUserInfo)
    if (parsed.realName) userInfo.realName = parsed.realName
  }
} catch (e) {}

// 处理用户菜单命令
const handleUserCommand = (command) => {
  if (command === 'profile') {
    // 跳转到个人信息页或者打开对话框（这里简化处理，提示暂不支持或跳转主页）
    // 更好的做法是：复用 TeacherClass 的 profileDialog，但这需要重构。
    // 暂时跳转到 TeacherHome 并带参数？或者简单提示。
    // 考虑到这是一个子页面，用户可能想在这里修改。
    // 但为了保持简单，我们可以只支持退出登录，或者提示去主页修改。
    // 既然 TeacherHome 有弹窗，TeacherClass 也有弹窗。
    // 我们可以从 TeacherClass 复制弹窗逻辑吗？这会增加很多代码。
    // 让我们先只支持退出登录，修改信息跳转回主页。
    router.push('/teacher/home')
    ElMessage.info('请在主页修改个人信息')
  } else if (command === 'logout') {
    localStorage.clear()
    router.push('/login')
    ElMessage.success('已退出登录')
  }
}

const isExamEnded = computed(() => {
  if (!exam.endTime) return false
  return new Date(exam.endTime).getTime() < Date.now()
})

// 获取考试信息和成绩数据
const loadData = async () => {
  loading.value = true
  try {
    // 获取考试信息
    const examRes = await request.get(`/exam/${examId.value}`)
    if (examRes && examRes.data) {
      Object.assign(exam, examRes.data)
    }

    // 获取考试记录（学生成绩）
    const recordsRes = await request.get(`/examRecord/exam/${examId.value}`)
    if (recordsRes && recordsRes.data) {
      examRecords.value = recordsRes.data.map(record => {
        // 严格判断：只有状态为2才算完全已批改
        record.isGraded = record.status === 2
        return record
      })
    }
  } catch (e) {
    ElMessage.error('加载成绩数据失败')
    console.error(e)
  } finally {
    loading.value = false
  }
}

// 统计数据计算
const averageScore = computed(() => {
  if (examRecords.value.length === 0) return 0
  const sum = examRecords.value.reduce((acc, record) => {
    return acc + (record.totalScore || 0)
  }, 0)
  return sum / examRecords.value.length
})

const maxScore = computed(() => {
  if (examRecords.value.length === 0) return 0
  return Math.max(...examRecords.value.map(r => r.totalScore || 0))
})

const minScore = computed(() => {
  if (examRecords.value.length === 0) return 0
  return Math.min(...examRecords.value.map(r => r.totalScore || 0))
})

// 成绩分布
const scoreRanges = computed(() => {
  const ranges = [
    { label: '90-100', min: 90, max: 100, color: '#22c55e' },
    { label: '80-89', min: 80, max: 89, color: '#3b82f6' },
    { label: '70-79', min: 70, max: 79, color: '#f59e0b' },
    { label: '60-69', min: 60, max: 69, color: '#f97316' },
    { label: '0-59', min: 0, max: 59, color: '#ef4444' }
  ]

  const totalCount = examRecords.value.length

  return ranges.map(range => {
    const count = examRecords.value.filter(r => {
      const score = r.totalScore || 0
      return score >= range.min && score <= range.max
    }).length
    return {
      ...range,
      count,
      percentage: totalCount > 0 ? Math.round((count / totalCount) * 100) : 0
    }
  })
})

// 搜索和排序
const filteredAndSortedRecords = computed(() => {
  let filtered = examRecords.value.filter(record => {
    const keyword = searchKeyword.value.toLowerCase()
    return (
      (record.studentNo && record.studentNo.toLowerCase().includes(keyword)) ||
      (record.studentName && record.studentName.toLowerCase().includes(keyword))
    )
  })

  // 排序
  if (sortBy.value === 'score-desc') {
    filtered.sort((a, b) => (b.totalScore || 0) - (a.totalScore || 0))
  } else if (sortBy.value === 'score-asc') {
    filtered.sort((a, b) => (a.totalScore || 0) - (b.totalScore || 0))
  } else if (sortBy.value === 'studentNo') {
    filtered.sort((a, b) => (a.studentNo || '').localeCompare(b.studentNo || ''))
  }

  return filtered
})

// 格式化时间
const formatTime = (timeString) => {
  if (!timeString) return '-'
  const date = new Date(timeString)
  if (Number.isNaN(date.getTime())) return '-'
  return date.toLocaleString('zh-CN', { hour12: false })
}

// 返回上一页
const goBack = () => {
  router.back()
}

// 查看学生详情
const handleViewDetail = (record) => {
  router.push(`/student/exam-detail/${record.id}`)
}

onMounted(loadData)
</script>

<style scoped>
/* ============ 全局容器 ============ */
.teacher-exam-grades-container {
  min-height: 100vh;
  padding: 0;
  background: linear-gradient(135deg, #fce4ec 0%, #e3f2fd 50%, #f3e5f5 100%);
  display: flex;
  flex-direction: column;
  position: relative;
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

/* ============ 顶部导航栏 ============ */
.grades-header {
  position: sticky;
  top: 0;
  z-index: 100;
  height: 70px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border-bottom: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 24px rgba(0, 0, 0, 0.04);
  display: flex;
  align-items: center;
  padding: 0 32px;
}

.grades-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 50%, #667eea 100%);
  opacity: 0.4;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 20px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.exam-meta-tag {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 16px;
  background: #f3f4f6;
  border-radius: 20px;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.meta-label {
  font-size: 12px;
  color: #606266;
  font-weight: 600;
}

.meta-value {
  font-size: 16px;
  font-weight: 800;
  color: #667eea;
}

.exam-status-tag {
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  background: #f3f4f6;
  color: #606266;
  border: 1px solid rgba(0, 0, 0, 0.05);
}

.exam-status-tag.ended {
  background: #f3f4f6;
  color: #909399;
}

.header-divider {
  width: 1px;
  height: 24px;
  background: rgba(0, 0, 0, 0.08);
  margin: 0 20px;
}

.user-avatar {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 4px 8px 4px 4px;
  border-radius: 24px;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.user-avatar:hover {
  background: rgba(255, 255, 255, 0.5);
  border-color: rgba(102, 126, 234, 0.1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.avatar-img {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: 2px solid #fff;
  box-shadow: 0 2px 6px rgba(102, 126, 234, 0.2);
  transition: transform 0.3s ease;
}

.user-avatar:hover .avatar-img {
  transform: scale(1.05);
}

.user-name {
  font-size: 14px;
  font-weight: 600;
  color: #606266;
  margin-right: 4px;
}

.back-btn {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  position: relative;
  overflow: hidden;
}

.back-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s;
}

.back-btn:hover::before {
  left: 100%;
}

.back-btn:hover {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
}

.back-btn:active {
  transform: translateY(-1px);
}

.back-btn :deep(.el-icon) {
  font-size: 20px;
}

.header-info {
  flex: 1;
  min-width: 0;
}

.grades-title {
  margin: 0;
  font-size: 22px;
  font-weight: 800;
  letter-spacing: 0.5px;
  background: linear-gradient(135deg, #303133 0%, #606266 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.grades-subtitle {
  margin: 6px 0 0;
  font-size: 13px;
  color: #909399;
  display: flex;
  align-items: center;
  gap: 8px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.time-icon {
  font-size: 14px;
}

/* ============ 加载状态 ============ */
.loading-container {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 24px;
}

.loading-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 32px 48px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.1);
  color: #667eea;
  font-size: 16px;
  font-weight: 500;
}

.loading-card :deep(.el-icon) {
  font-size: 24px;
}

.loading-card :deep(.is-loading) {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* ============ 主要内容区域 ============ */
.grades-body {
  flex: 1;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  padding: 40px 32px;
  display: flex;
  flex-direction: column;
  gap: 32px;
  position: relative;
  z-index: 1;
}

/* ============ 统计卡片区域 ============ */
.stats-section {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
  animation: fadeInUp 0.6s ease-out;
}

.stat-card {
  padding: 28px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  display: flex;
  align-items: center;
  gap: 20px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.stat-card::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(120deg, transparent 30%, rgba(255,255,255,0.4) 50%, transparent 70%);
  transform: translateX(-100%);
  transition: transform 0.6s;
}

.stat-card:hover::after {
  transform: translateX(100%);
}

.stat-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 16px 40px rgba(102, 126, 234, 0.12);
  background: rgba(255, 255, 255, 0.95);
  border-color: rgba(102, 126, 234, 0.3);
}

.stat-icon {
  flex-shrink: 0;
  width: 64px;
  height: 64px;
  border-radius: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  position: relative;
  z-index: 1;
  color: white;
  transition: all 0.3s ease;
}

.stat-card:hover .stat-icon {
  transform: scale(1.1) rotate(5deg);
}

.total-card .stat-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
}

.avg-card .stat-icon {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
  box-shadow: 0 8px 20px rgba(139, 92, 246, 0.3);
}

.max-card .stat-icon {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 8px 20px rgba(34, 197, 94, 0.3);
}

.min-card .stat-icon {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 8px 20px rgba(249, 115, 22, 0.3);
}

.stat-content {
  flex: 1;
  position: relative;
  z-index: 1;
}

.stat-label {
  font-size: 14px;
  color: #909399;
  font-weight: 600;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stat-value {
  font-size: 32px;
  font-weight: 800;
  background: linear-gradient(135deg, #303133 0%, #606266 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  letter-spacing: -0.5px;
}

/* ============ 成绩分布图表 ============ */
.chart-section {
  animation: fadeInUp 0.6s ease-out 0.1s both;
}

.chart-card {
  padding: 32px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.chart-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 40px rgba(102, 126, 234, 0.1);
  border-color: rgba(102, 126, 234, 0.2);
}

.chart-header {
  margin-bottom: 28px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #303133;
}

.score-distribution {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.distribution-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.range-label {
  width: 70px;
  font-size: 14px;
  font-weight: 600;
  color: #606266;
  text-align: right;
  font-family: 'Monaco', monospace;
}

.range-bar {
  flex: 1;
  height: 24px;
  background: #f0f2f5;
  border-radius: 12px;
  overflow: hidden;
  position: relative;
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.05);
}

.range-fill {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 10px;
  transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  border-radius: 12px;
  min-width: 24px;
}

.range-count {
  font-size: 12px;
  font-weight: 700;
  color: white;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

.range-info {
  width: 60px;
  text-align: right;
  font-size: 14px;
  color: #909399;
  font-weight: 500;
}

/* ============ 学生成绩列表 ============ */
.grades-list-section {
  animation: fadeInUp 0.6s ease-out 0.2s both;
  width: 100%; /* 确保占满宽度 */
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 0 8px;
}

.list-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: #303133;
}

.list-controls {
  display: flex;
  gap: 16px;
}

.search-input {
  width: 240px;
}

.sort-select {
  width: 160px;
}

/* 输入框和选择器样式优化 */
.list-controls :deep(.el-input__wrapper) {
  box-shadow: 0 4px 12px rgba(0,0,0,0.03) !important;
  border: 1px solid rgba(255,255,255,0.8);
  background: rgba(255,255,255,0.8);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.list-controls :deep(.el-input__wrapper:hover),
.list-controls :deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 4px 16px rgba(102,126,234,0.15) !important;
  background: #fff;
}

.grades-table {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  border-radius: 16px;
  /* overflow: hidden;  移除此行，避免可能的裁剪问题 */
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  border: 1px solid rgba(255, 255, 255, 0.6);
  width: 100%; /* 显式设置宽度 */
}

.grades-table :deep(.el-table__header) {
  width: 100% !important; /* 强制表头占满 */
}

.grades-table :deep(.el-table__body) {
  width: 100% !important; /* 强制表体占满 */
}

.grades-table :deep(.el-table__header th) {
  background-color: #f8f9fa !important;
  border-bottom: 1px solid #ebeef5;
  color: #606266;
  font-weight: 600;
  height: 54px; /* 稍微增加表头高度 */
  padding: 8px 0;
}

.grades-table :deep(.el-table__row td) {
  padding: 12px 0; /* 增加行高 */
}

.score-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.score-value {
  font-weight: 800;
  color: #667eea;
  font-size: 16px;
}

.score-max {
  font-size: 12px;
  color: #9ca3af;
  margin-top: 2px;
}

.subjective-score-cell {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.score-num {
  font-weight: 600;
  color: #606266;
}

.status-tag {
  font-size: 12px;
  height: 22px;
  line-height: 20px;
  padding: 0 8px;
}

.graded-icon {
  font-size: 18px;
  color: #67c23a;
}

.empty-text {
  color: #9ca3af;
}

/* 按钮优化 */
:deep(.el-button--primary) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  transition: all 0.3s ease;
}

:deep(.el-button--primary:hover) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 标签优化 */
:deep(.el-tag) {
  border: none;
  padding: 0 12px;
  height: 28px;
  line-height: 28px;
  border-radius: 8px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

:deep(.el-tag--success) {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.1) 0%, rgba(34, 197, 94, 0.2) 100%);
  color: #15803d;
}

:deep(.el-tag--warning) {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.1) 0%, rgba(249, 115, 22, 0.2) 100%);
  color: #c2410c;
}

/* ============ 动画 ============ */
@keyframes fadeInUp {
  0% {
    opacity: 0;
    transform: translateY(20px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

/* ============ 响应式设计 ============ */
@media (max-width: 1200px) {
  .stats-section {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 960px) {
  .grades-header {
    height: 60px;
    padding: 0 16px;
  }

  .grades-title {
    font-size: 18px;
  }

  .grades-body {
    padding: 24px 16px;
    gap: 24px;
  }

  .stat-card {
    padding: 20px;
  }

  .stat-icon {
    width: 52px;
    height: 52px;
    font-size: 26px;
  }

  .stat-value {
    font-size: 26px;
  }

  .list-controls {
    flex-direction: column;
    width: 100%;
  }

  .search-input,
  .sort-select {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .grades-header {
    height: auto;
    padding: 12px 16px;
  }

  .header-content {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .header-left {
    width: 100%;
  }

  .header-right {
    width: 100%;
    justify-content: space-between;
    border-top: 1px solid rgba(0,0,0,0.05);
    padding-top: 12px;
  }

  .header-divider {
    display: none;
  }

  .back-btn {
    width: 36px;
    height: 36px;
  }

  .grades-subtitle {
    font-size: 12px;
  }
}
</style>
