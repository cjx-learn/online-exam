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
            <div class="title-row">
              <h1 class="grades-title">{{ exam.title || '考试成绩' }}</h1>
              <span v-if="exam" class="grades-time">
                <el-icon class="time-icon"><Calendar /></el-icon>
                {{ formatTime(exam.startTime) }} - {{ formatTime(exam.endTime) }}
              </span>
            </div>
          </div>
        </div>
        <div class="header-right">
          <div class="exam-status-tag" :class="{ ended: isExamEnded }">
            <span class="status-dot" :class="{ 'breathing': !isExamEnded }"></span>
            {{ isExamEnded ? '已结束' : '进行中' }}
          </div>
          
          <div class="header-divider"></div>

          <!-- 用户头像下拉菜单 -->
          <el-dropdown @command="handleUserCommand" trigger="click">
            <div class="user-avatar">
              <el-avatar 
                :size="42" 
                :icon="userInfo.avatar ? undefined : UserFilled" 
                :src="getAvatarUrl(userInfo.avatar)"
                class="avatar-img" 
              />
              <span class="user-name">{{ userInfo.realName }}</span>
              <el-icon class="dropdown-icon"><ArrowDown /></el-icon>
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
        <div class="stat-card total-score-card">
          <div class="stat-icon">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-label">考试总分</div>
            <div class="stat-value">{{ exam.totalScore || 0 }}</div>
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

      <!-- 成绩分布图表 - 紧凑型 -->
      <div class="chart-section">
        <div class="chart-card-compact">
          <div class="chart-header-compact">
            <h3>成绩分布</h3>
          </div>
          <div class="score-distribution-horizontal">
            <div v-for="range in scoreRanges" :key="range.label" class="distribution-item-horizontal">
              <div class="range-badge" :style="{ backgroundColor: range.color }">
                <div class="range-label-compact">{{ range.label }}</div>
                <div class="range-count-compact">{{ range.count }}人</div>
              </div>
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
            <el-button type="success" @click="exportToExcel" class="export-btn">
              <el-icon><Download /></el-icon>
              导出Excel
            </el-button>
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

      <!-- 整体考试分析 -->
      <div class="analysis-section">
        <div class="analysis-header">
          <h3>
            <el-icon class="header-icon"><DataAnalysis /></el-icon>
            整体考试分析
          </h3>
          <el-button 
            type="primary" 
            @click="toggleAnalysis"
            size="small"
          >
            <el-icon v-if="analysisExpanded"><ArrowUp /></el-icon>
            <el-icon v-else><ArrowDown /></el-icon>
            {{ analysisExpanded ? '收起' : '展开' }}分析
          </el-button>
        </div>

        <el-collapse-transition>
          <div v-show="analysisExpanded" class="analysis-content">
            <!-- 三列图表布局 -->
            <div class="analysis-grid-compact">
              <!-- 题目正确率分析 -->
              <div class="analysis-card-compact">
                <div class="analysis-card-header">
                  <h4>📊 题目正确率</h4>
                </div>
                <div ref="correctRateChart" class="chart-container-compact"></div>
              </div>

              <!-- 题目得分率趋势 -->
              <div class="analysis-card-compact">
                <div class="analysis-card-header">
                  <h4>📈 题目得分率趋势</h4>
                </div>
                <div ref="errorDistChart" class="chart-container-compact"></div>
              </div>

              <!-- 题型数量分布 -->
              <div class="analysis-card-compact">
                <div class="analysis-card-header">
                  <h4>📝 题型分布</h4>
                </div>
                <div ref="typeRateChart" class="chart-container-compact"></div>
              </div>
            </div>

            <!-- 高频错误题目列表（紧凑版） -->
            <div class="analysis-card-compact" v-if="highErrorQuestions.length > 0">
              <div class="analysis-card-header">
                <h4>⚠️ 高频错误题目（正确率<50%）</h4>
              </div>
              <div class="error-questions-compact">
                <div class="error-question-compact" v-for="(item, index) in highErrorQuestions.slice(0, 5)" :key="item.questionId">
                  <div class="error-left">
                    <span class="error-number">#{{ index + 1 }}</span>
                    <span class="error-title">题{{ item.questionIndex + 1 }}: {{ item.question.content.substring(0, 40) }}...</span>
                  </div>
                  <div class="error-right">
                    <el-tag size="small" :type="getQuestionTypeColor(item.question.type)">
                      {{ getQuestionTypeName(item.question.type) }}
                    </el-tag>
                    <span class="error-stat correct-count">
                      正确: <strong>{{ item.correctAnswers }}</strong> 人
                    </span>
                    <span class="error-stat total-count">
                      总数: {{ item.totalAnswers }} 人
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-collapse-transition>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getAvatarUrl } from '@/utils/file'
import { ArrowLeft, Loading, Search, Document, TrendCharts, DataLine, Trophy, Bottom, CircleCheck, Calendar, UserFilled, User, SwitchButton, Download, DataAnalysis, ArrowUp, ArrowDown } from '@element-plus/icons-vue'
import request from '@/utils/request'
import * as echarts from 'echarts'

const route = useRoute()
const router = useRouter()

const examId = ref(Number(route.params.id))
const exam = reactive({})
const examRecords = ref([])
const loading = ref(true)
const searchKeyword = ref('')
const sortBy = ref('score-desc')

// 分析相关
const analysisExpanded = ref(false)
const questions = ref([])
const allAnswers = ref([])
const correctRateChart = ref(null)
const errorDistChart = ref(null)
const typeRateChart = ref(null)

// 用户信息
const userInfo = reactive({
  realName: '教师',
  avatar: ''
})

// 加载用户信息
try {
  const storedUserInfo = localStorage.getItem('userInfo')
  if (storedUserInfo) {
    const parsed = JSON.parse(storedUserInfo)
    if (parsed.realName) userInfo.realName = parsed.realName
    if (parsed.avatar) userInfo.avatar = parsed.avatar
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

    // 获取考试题目
    const questionsRes = await request.get(`/exam/${examId.value}/questions`)
    if (questionsRes && questionsRes.data) {
      questions.value = questionsRes.data
    }

    // 获取所有学生的答题记录
    const answersPromises = examRecords.value.map(record => 
      request.get(`/examRecord/${record.id}/answers`).then(res => res.data || [])
    )
    const answersResults = await Promise.all(answersPromises)
    allAnswers.value = answersResults.flat()

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

// 成绩分布（基于考试总分的百分比）
const scoreRanges = computed(() => {
  const totalScore = exam.totalScore || 100 // 考试总分，默认100
  
  // 根据考试总分计算分数段
  const score90 = totalScore * 0.9
  const score80 = totalScore * 0.8
  const score70 = totalScore * 0.7
  const score60 = totalScore * 0.6
  
  const ranges = [
    { label: `${score90.toFixed(0)}-${totalScore}`, min: score90, max: totalScore, color: '#22c55e', desc: '优秀(≥90%)' },
    { label: `${score80.toFixed(0)}-${(score90 - 0.01).toFixed(0)}`, min: score80, max: score90 - 0.01, color: '#3b82f6', desc: '良好(80-89%)' },
    { label: `${score70.toFixed(0)}-${(score80 - 0.01).toFixed(0)}`, min: score70, max: score80 - 0.01, color: '#f59e0b', desc: '中等(70-79%)' },
    { label: `${score60.toFixed(0)}-${(score70 - 0.01).toFixed(0)}`, min: score60, max: score70 - 0.01, color: '#f97316', desc: '及格(60-69%)' },
    { label: `0-${(score60 - 0.01).toFixed(0)}`, min: 0, max: score60 - 0.01, color: '#ef4444', desc: '不及格(<60%)' }
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
  // 如果有班级ID，返回到班级页面的考试管理标签；否则返回到教师主页
  if (exam.classId) {
    router.push(`/teacher/class/${exam.classId}?tab=exams`)
  } else {
    router.push('/teacher/home')
  }
}

// 查看学生详情
const handleViewDetail = (record) => {
  router.push(`/teacher/student-grade-detail/${record.id}`)
}

// 导出Excel
const exportToExcel = () => {
  try {
    const exportData = filteredAndSortedRecords.value.map((record, index) => ({
      '排名': index + 1,
      '学号': record.studentNo || '-',
      '姓名': record.studentName || '-',
      '总分': record.totalScore != null ? record.totalScore : '-',
      '满分': exam.totalScore || '-',
      '客观题得分': record.objectiveScore != null ? record.objectiveScore : '-',
      '主观题得分': record.subjectiveScore != null ? record.subjectiveScore : '-',
      '状态': record.status === 1 ? '待批改' : record.status === 2 ? '已批改' : '未提交',
      '提交时间': record.submitTime ? formatTime(record.submitTime) : '-'
    }))

    const statsData = [
      {},
      { '排名': '统计信息' },
      { '排名': '参加人数', '学号': examRecords.value.length },
      { '排名': '平均分', '学号': averageScore.value.toFixed(2) },
      { '排名': '最高分', '学号': maxScore.value },
      { '排名': '最低分', '学号': minScore.value }
    ]

    const allData = [...exportData, ...statsData]

    import('xlsx').then(XLSX => {
      const ws = XLSX.utils.json_to_sheet(allData)
      ws['!cols'] = [
        { wch: 8 }, { wch: 15 }, { wch: 12 }, { wch: 10 }, { wch: 10 }, 
        { wch: 12 }, { wch: 12 }, { wch: 10 }, { wch: 20 }
      ]
      const wb = XLSX.utils.book_new()
      XLSX.utils.book_append_sheet(wb, ws, '成绩单')
      const fileName = `${exam.title || '考试成绩'}_${new Date().toLocaleDateString('zh-CN').replace(/\//g, '-')}.xlsx`
      XLSX.writeFile(wb, fileName)
      ElMessage.success('导出成功！')
    }).catch(() => {
      ElMessage.error('导出失败，请安装xlsx库: npm install xlsx')
    })
  } catch (error) {
    ElMessage.error('导出失败：' + error.message)
  }
}

// 计算高频错误题目（正确率<50%）
const highErrorQuestions = computed(() => {
  if (questions.value.length === 0 || examRecords.value.length === 0) return []
  
  const questionStats = questions.value.map((question, index) => {
    const questionAnswers = allAnswers.value.filter(a => a.questionId === question.id)
    // 使用参加考试的总人数
    const totalAnswers = examRecords.value.length
    
    let correctRate = 0
    let correctAnswers = 0
    
    // 与题目正确率图表保持一致的计算逻辑
    // 对于客观题（单选、多选、判断）：按答对人数计算正确率
    if ([1, 2, 3].includes(question.type)) {
      correctAnswers = questionAnswers.filter(a => {
        const score = a.score ?? 0
        return score > 0
      }).length
      correctRate = totalAnswers > 0 ? Math.round((correctAnswers / totalAnswers) * 100) : 0
    } 
    // 对于主观题（填空题、简答题）：按得分占总分的比例计算
    else {
      const totalScore = questionAnswers.reduce((sum, a) => sum + (a.score ?? 0), 0)
      const maxScore = question.score * totalAnswers
      correctRate = maxScore > 0 ? Math.round((totalScore / maxScore) * 100) : 0
      // 主观题的"正确人数"按得分率估算（为了显示）
      correctAnswers = Math.round(totalAnswers * correctRate / 100)
    }
    
    return {
      questionId: question.id,
      questionIndex: index,
      question,
      correctRate,
      totalAnswers,
      correctAnswers
    }
  })
  
  return questionStats
    .filter(s => s.correctRate < 50 && s.totalAnswers > 0)
    .sort((a, b) => a.correctRate - b.correctRate)
})

// 题型数量统计
const questionTypeStats = computed(() => {
  if (questions.value.length === 0) return []
  
  const typeMap = {
    1: '单选题',
    2: '多选题',
    3: '判断题',
    4: '填空题',
    5: '简答题'
  }
  
  const stats = {}
  
  // 统计各类型题目数量
  questions.value.forEach(question => {
    const typeName = typeMap[question.type] || '其他'
    if (!stats[typeName]) {
      stats[typeName] = 0
    }
    stats[typeName]++
  })
  
  return Object.entries(stats).map(([type, count]) => ({
    type,
    count
  }))
})

// 绘制图表
const drawCharts = () => {
  nextTick(() => {
    drawCorrectRateChart()
    drawErrorDistChart()
    drawTypeRateChart()
  })
}

// 绘制题目正确率图表（高级版）
const drawCorrectRateChart = () => {
  if (!correctRateChart.value) return
  
  const chart = echarts.init(correctRateChart.value)
  
  const data = questions.value.map((q, index) => {
    const questionAnswers = allAnswers.value.filter(a => a.questionId === q.id)
    const total = examRecords.value.length
    
    let rate = 0
    
    // 对于客观题（单选、多选、判断）：按答对人数计算正确率
    if ([1, 2, 3].includes(q.type)) {
      const correct = questionAnswers.filter(a => {
        const score = a.score ?? 0  // null/undefined视为0
        return score > 0
      }).length
      rate = total > 0 ? Math.round((correct / total) * 100) : 0
    } 
    // 对于主观题（填空题、简答题）：按得分占总分的比例计算
    else {
      const totalScore = questionAnswers.reduce((sum, a) => sum + (a.score ?? 0), 0)
      const maxScore = q.score * total
      rate = maxScore > 0 ? Math.round((totalScore / maxScore) * 100) : 0
    }
    
    return {
      name: `题${index + 1}`,
      value: rate
    }
  })
  
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: { 
        type: 'shadow',
        shadowStyle: {
          color: 'rgba(102, 126, 234, 0.1)'
        }
      },
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderColor: '#667eea',
      borderWidth: 1,
      textStyle: {
        color: '#333',
        fontSize: 12
      },
      formatter: '<b>{b}</b><br/>正确率: <span style="color: #667eea; font-weight: bold;">{c}%</span>'
    },
    grid: {
      left: '5%',
      right: '5%',
      bottom: '10%',
      top: '10%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: data.map(d => d.name),
      axisLabel: { 
        interval: 0, 
        rotate: 30,
        fontSize: 11,
        color: '#666'
      },
      axisLine: {
        lineStyle: {
          color: '#e0e0e0'
        }
      }
    },
    yAxis: {
      type: 'value',
      max: 100,
      axisLabel: { 
        formatter: '{value}%',
        fontSize: 11,
        color: '#666'
      },
      splitLine: {
        lineStyle: {
          color: '#f0f0f0',
          type: 'dashed'
        }
      }
    },
    series: [{
      data: data.map(d => ({
        value: d.value,
        itemStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: d.value >= 80 ? '#34d399' : d.value >= 60 ? '#60a5fa' : d.value >= 40 ? '#fbbf24' : '#f87171' },
            { offset: 1, color: d.value >= 80 ? '#22c55e' : d.value >= 60 ? '#3b82f6' : d.value >= 40 ? '#f59e0b' : '#ef4444' }
          ]),
          borderRadius: [6, 6, 0, 0],
          shadowColor: 'rgba(0, 0, 0, 0.1)',
          shadowBlur: 4,
          shadowOffsetY: 2
        }
      })),
      type: 'bar',
      barWidth: '50%',
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetY: 4,
          shadowColor: 'rgba(0, 0, 0, 0.2)'
        }
      }
    }]
  }
  
  chart.setOption(option)
}

// 绘制题目得分率趋势图表（折线图）
const drawErrorDistChart = () => {
  if (!errorDistChart.value) return
  
  const chart = echarts.init(errorDistChart.value)
  
  // 计算每道题的得分率
  const scoreRates = questions.value.map((q, qIndex) => {
    const questionAnswers = allAnswers.value.filter(a => a.questionId === q.id)
    
    // 使用参加考试的总人数
    const totalStudents = examRecords.value.length
    
    if (totalStudents === 0) {
      return {
        name: `第${qIndex + 1}题`,
        rate: 0
      }
    }
    
    const totalScore = questionAnswers.reduce((sum, a) => sum + (a.score || 0), 0)
    const maxScore = q.score * totalStudents
    const rate = maxScore > 0 ? ((totalScore / maxScore) * 100).toFixed(1) : 0
    
    return {
      name: `第${qIndex + 1}题`,
      rate: parseFloat(rate)
    }
  })
  
  const option = {
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderColor: '#3b82f6',
      borderWidth: 1,
      textStyle: {
        color: '#333',
        fontSize: 12
      },
      formatter: (params) => {
        const data = params[0]
        return `${data.name}<br/>得分率: <span style="color: #3b82f6; font-weight: bold;">${data.value}%</span>`
      }
    },
    grid: {
      left: '10%',
      right: '5%',
      top: '15%',
      bottom: '10%'
    },
    xAxis: {
      type: 'category',
      data: scoreRates.map(s => s.name),
      axisLabel: {
        color: '#666',
        fontSize: 10,
        interval: 0,
        rotate: scoreRates.length > 15 ? 45 : 0
      },
      axisLine: {
        lineStyle: {
          color: '#ddd'
        }
      }
    },
    yAxis: {
      type: 'value',
      name: '得分率(%)',
      min: 0,
      max: 100,
      nameTextStyle: {
        color: '#666',
        fontSize: 12
      },
      axisLabel: {
        color: '#666',
        fontSize: 11,
        formatter: '{value}%'
      },
      axisLine: {
        show: false
      },
      splitLine: {
        lineStyle: {
          color: '#f0f0f0',
          type: 'dashed'
        }
      }
    },
    series: [{
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: {
        width: 2,
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
          { offset: 0, color: '#3b82f6' },
          { offset: 1, color: '#8b5cf6' }
        ])
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(59, 130, 246, 0.3)' },
          { offset: 1, color: 'rgba(59, 130, 246, 0.05)' }
        ])
      },
      itemStyle: {
        color: '#3b82f6',
        borderColor: '#fff',
        borderWidth: 2
      },
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowColor: 'rgba(59, 130, 246, 0.5)',
          scale: 1.2
        }
      },
      markLine: {
        silent: true,
        symbol: 'none',
        lineStyle: {
          type: 'dashed',
          color: '#f59e0b',
          width: 1
        },
        label: {
          show: true,
          position: 'end',
          formatter: '平均线',
          color: '#f59e0b',
          fontSize: 10
        },
        data: [{
          yAxis: scoreRates.length > 0 ? 
            (scoreRates.reduce((sum, s) => sum + s.rate, 0) / scoreRates.length).toFixed(1) : 0
        }]
      },
      data: scoreRates.map(s => s.rate)
    }]
  }
  
  chart.setOption(option)
}

// 绘制题型数量分布图表（雷达图）
const drawTypeRateChart = () => {
  if (!typeRateChart.value) return
  
  const chart = echarts.init(typeRateChart.value)
  const data = questionTypeStats.value
  
  // 计算最大值，用于设置雷达图的max
  const maxCount = data.length > 0 ? Math.max(...data.map(d => d.count)) : 10
  const radarMax = Math.ceil(maxCount * 1.2) // 最大值增加20%留白
  
  const option = {
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(255, 255, 255, 0.95)',
      borderColor: '#667eea',
      borderWidth: 1,
      textStyle: {
        color: '#333',
        fontSize: 12
      },
      formatter: (params) => {
        let result = '<b>题型分布</b><br/>'
        params.value.forEach((val, idx) => {
          result += `${data[idx].type}: <span style="color: #667eea; font-weight: bold;">${val}题</span><br/>`
        })
        return result
      }
    },
    radar: {
      indicator: data.map(d => ({
        name: d.type,
        max: radarMax
      })),
      shape: 'polygon',
      radius: '65%',
      name: {
        textStyle: {
          color: '#666',
          fontSize: 12,
          fontWeight: 'bold'
        }
      },
      splitArea: {
        areaStyle: {
          color: ['rgba(102, 126, 234, 0.05)', 'rgba(102, 126, 234, 0.1)', 
                  'rgba(102, 126, 234, 0.15)', 'rgba(102, 126, 234, 0.2)']
        }
      },
      axisLine: {
        lineStyle: {
          color: 'rgba(102, 126, 234, 0.3)'
        }
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(102, 126, 234, 0.3)'
        }
      }
    },
    series: [{
      type: 'radar',
      data: [{
        value: data.map(d => d.count),
        name: '题目数量',
        symbol: 'circle',
        symbolSize: 8,
        lineStyle: {
          width: 3,
          color: '#667eea'
        },
        itemStyle: {
          color: '#667eea',
          borderColor: '#fff',
          borderWidth: 2,
          shadowBlur: 6,
          shadowColor: 'rgba(102, 126, 234, 0.4)'
        },
        areaStyle: {
          color: new echarts.graphic.RadialGradient(0.5, 0.5, 1, [
            { offset: 0, color: 'rgba(102, 126, 234, 0.5)' },
            { offset: 1, color: 'rgba(102, 126, 234, 0.1)' }
          ])
        },
        label: {
          show: true,
          fontSize: 11,
          color: '#667eea',
          fontWeight: 'bold',
          formatter: (params) => params.value + '题'
        }
      }],
      emphasis: {
        lineStyle: {
          width: 4
        },
        itemStyle: {
          shadowBlur: 10
        }
      }
    }]
  }
  
  chart.setOption(option)
}

// 切换分析板块展开状态
const toggleAnalysis = () => {
  analysisExpanded.value = !analysisExpanded.value
  if (analysisExpanded.value) {
    setTimeout(drawCharts, 100)
  }
}

// 辅助函数
const getQuestionTypeName = (type) => {
  const typeMap = { 1: '单选题', 2: '多选题', 3: '判断题', 4: '填空题', 5: '简答题' }
  return typeMap[type] || '未知'
}

const getQuestionTypeColor = (type) => {
  const colorMap = { 1: 'primary', 2: 'success', 3: 'warning', 4: 'info', 5: 'danger' }
  return colorMap[type] || ''
}

const getProgressColor = (rate) => {
  if (rate >= 80) return '#22c55e'
  if (rate >= 60) return '#3b82f6'
  if (rate >= 40) return '#f59e0b'
  return '#ef4444'
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
/* 毛玻璃导航栏 */
.grades-header {
  position: sticky;
  top: 0;
  z-index: 100;
  height: 70px;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px) saturate(180%);
  -webkit-backdrop-filter: blur(10px) saturate(180%);
  border-bottom: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08), 0 1px 3px rgba(102, 126, 234, 0.06);
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

/* 状态标签优化 */
.exam-status-tag {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  background: rgba(103, 194, 58, 0.1);
  color: #67c23a;
  border: 1px solid rgba(103, 194, 58, 0.2);
}

.exam-status-tag.ended {
  background: rgba(144, 147, 153, 0.1);
  color: #909399;
  border: 1px solid rgba(144, 147, 153, 0.2);
}

/* 状态圆点 */
.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #67c23a;
}

.exam-status-tag.ended .status-dot {
  background: #909399;
}

/* 呼吸灯动画 */
.status-dot.breathing {
  animation: breathing 2s ease-in-out infinite;
  box-shadow: 0 0 8px rgba(103, 194, 58, 0.6);
}

@keyframes breathing {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.6;
    transform: scale(0.8);
  }
}

.header-divider {
  width: 1px;
  height: 24px;
  background: rgba(0, 0, 0, 0.08);
  margin: 0 20px;
}

/* 用户头像区域 - 精致设计 */
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
  position: relative;
}

/* 头像外描边 */
.user-avatar:hover .avatar-img {
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.15), 0 2px 8px rgba(102, 126, 234, 0.25);
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
}

/* 下拉箭头 */
.dropdown-icon {
  font-size: 12px;
  color: #909399;
  transition: all 0.3s ease;
}

.user-avatar:hover .dropdown-icon {
  color: var(--primary);
  transform: translateY(2px);
}

/* 用户下拉菜单美化 */
:deep(.user-dropdown) {
  margin-top: 8px;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.15);
  border: 1px solid rgba(102, 126, 234, 0.1);
  overflow: hidden;
}

:deep(.user-dropdown .el-dropdown-menu__item) {
  padding: 12px 20px;
  font-size: 14px;
  transition: all 0.3s ease;
}

:deep(.user-dropdown .el-dropdown-menu__item:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  color: var(--primary);
}

:deep(.user-dropdown .el-dropdown-menu__item .el-icon) {
  margin-right: 8px;
  font-size: 16px;
}

/* 弱化返回按钮 */
.back-btn {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 50%;
  background: transparent;
  color: #909399;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  position: relative;
}

.back-btn:hover {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
  transform: translateX(-2px);
}

.back-btn:active {
  transform: translateX(-1px) scale(0.95);
}

.back-btn :deep(.el-icon) {
  font-size: 20px;
  transition: all 0.3s ease;
}

.header-info {
  flex: 1;
  min-width: 0;
}

/* 标题和时间同行显示 */
.title-row {
  display: flex;
  align-items: center;
  gap: 16px;
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

.grades-time {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #909399;
  padding: 4px 12px;
  background: rgba(144, 147, 153, 0.08);
  border-radius: 12px;
  white-space: nowrap;
  flex-shrink: 0;
}

.grades-time .time-icon {
  font-size: 14px;
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
  grid-template-columns: repeat(5, 1fr);
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

.total-score-card .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
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

/* ============ 成绩分布图表 - 紧凑型 ============ */
.chart-section {
  animation: fadeInUp 0.6s ease-out 0.1s both;
}

.chart-card-compact {
  padding: 24px 28px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.chart-card-compact:hover {
  transform: translateY(-4px);
  box-shadow: 0 16px 40px rgba(102, 126, 234, 0.1);
  border-color: rgba(102, 126, 234, 0.2);
}

.chart-header-compact {
  margin-bottom: 20px;
  padding-bottom: 14px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.chart-header-compact h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #303133;
}

.score-distribution-horizontal {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.distribution-item-horizontal {
  flex: 1;
}

.range-badge {
  padding: 16px 20px;
  border-radius: 16px;
  text-align: center;
  transition: all 0.3s ease;
  cursor: default;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.range-badge:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

.range-label-compact {
  font-size: 15px;
  font-weight: 700;
  color: white;
  margin-bottom: 8px;
  font-family: 'Monaco', monospace;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
}

.range-count-compact {
  font-size: 22px;
  font-weight: 800;
  color: white;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

/* ============ 整体考试分析 ============ */
.analysis-section {
  animation: fadeInUp 0.6s ease-out 0.15s both;
}

.analysis-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px 28px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  margin-bottom: 24px;
  transition: all 0.3s ease;
}

.analysis-header:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.1);
  border-color: rgba(102, 126, 234, 0.2);
}

.analysis-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
  color: #303133;
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-icon {
  font-size: 24px;
  color: #667eea;
}

.analysis-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.analysis-card {
  padding: 28px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
}

.analysis-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.1);
  border-color: rgba(102, 126, 234, 0.2);
}

.analysis-card-header {
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.analysis-card-header h4 {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
  color: #303133;
}

.analysis-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
}

.analysis-grid-compact {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.analysis-card-compact {
  padding: 20px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(16px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
}

.analysis-card-compact:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.12);
  border-color: rgba(102, 126, 234, 0.2);
}

.chart-container {
  width: 100%;
  height: 400px;
}

.chart-container-small {
  width: 100%;
  height: 300px;
}

.chart-container-compact {
  width: 100%;
  height: 260px;
}

.error-questions-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.error-question-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px;
  background: rgba(249, 250, 251, 0.8);
  border-radius: 12px;
  border: 1px solid rgba(102, 126, 234, 0.1);
  transition: all 0.3s ease;
}

.error-question-item:hover {
  background: rgba(255, 255, 255, 1);
  border-color: rgba(102, 126, 234, 0.3);
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
}

.error-rank {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  font-size: 18px;
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.error-question-info {
  flex: 1;
  min-width: 0;
}

.error-question-title {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 10px;
  line-height: 1.5;
}

.error-question-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.error-rate {
  font-size: 14px;
  color: #606266;
}

.error-rate strong {
  color: #ef4444;
  font-weight: 700;
}

.answer-count {
  font-size: 14px;
  color: #909399;
}

.error-action {
  flex-shrink: 0;
  width: 200px;
}

/* 紧凑版错误题目列表 */
.error-questions-compact {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.error-question-compact {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  background: linear-gradient(135deg, rgba(249, 250, 251, 0.9) 0%, rgba(255, 255, 255, 0.9) 100%);
  border-radius: 10px;
  border: 1px solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
}

.error-question-compact:hover {
  background: rgba(255, 255, 255, 1);
  border-color: rgba(102, 126, 234, 0.25);
  transform: translateX(3px);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.08);
}

.error-left {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
}

.error-number {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  font-size: 13px;
  box-shadow: 0 2px 6px rgba(239, 68, 68, 0.3);
}

.error-title {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.error-right {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}

.error-stat {
  font-size: 13px;
  font-weight: 500;
  color: #666;
  min-width: 80px;
  text-align: left;
  margin-left: 12px;
}

.error-stat.correct-count {
  color: #22c55e;
}

.error-stat.correct-count strong {
  font-size: 16px;
  font-weight: 700;
}

.error-stat.total-count {
  color: #666;
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

.export-btn {
  white-space: nowrap;
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
@media (max-width: 1400px) {
  .stats-section {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 1200px) {
  .stats-section {
    grid-template-columns: repeat(2, 1fr);
  }

  .analysis-grid-compact {
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
  .sort-select,
  .export-btn {
    width: 100%;
  }

  .score-distribution-horizontal {
    flex-direction: column;
    gap: 12px;
  }

  .stats-section {
    grid-template-columns: 1fr;
  }

  .analysis-grid {
    grid-template-columns: 1fr;
  }

  .analysis-grid-compact {
    grid-template-columns: 1fr;
  }

  .chart-container {
    height: 300px;
  }

  .chart-container-small {
    height: 250px;
  }

  .chart-container-compact {
    height: 220px;
  }

  .error-action {
    width: 100%;
  }

  .error-question-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .error-question-compact {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .error-right {
    width: 100%;
    justify-content: space-between;
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
    flex-wrap: wrap;
    gap: 12px;
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
