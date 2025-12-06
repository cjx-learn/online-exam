<template>
  <div class="student-exam-detail-container">
    <!-- 顶部导航栏 -->
    <div class="detail-header">
      <div class="header-content">
        <button class="back-btn" @click="goBack">
          <el-icon><ArrowLeft /></el-icon>
        </button>
        <div class="header-info">
          <h1 class="detail-title">{{ exam.title || '考试详情' }}</h1>
          <p v-if="examRecord" class="detail-subtitle">
            <span class="time-icon">📅</span>
            {{ formatTime(examRecord.examStartTime || exam.startTime) }}
            <span class="separator">•</span>
            {{ formatTime(examRecord.examEndTime || exam.endTime) }}
          </p>
        </div>
        <!-- 视图切换按钮 -->
        <div class="view-switch-buttons">
          <button 
            :class="['switch-btn', { active: currentView === 'report' }]"
            @click="currentView = 'report'"
          >
            📊 学情报告
          </button>
          <button 
            :class="['switch-btn', { active: currentView === 'detail' }]"
            @click="currentView = 'detail'"
          >
            📝 试卷详情
          </button>
        </div>
      </div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-card">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>正在加载考试详情...</span>
      </div>
    </div>

    <!-- 主要内容 -->
    <div v-else class="detail-body">
      <!-- 学情报告视图 -->
      <div v-if="currentView === 'report'" class="report-view">
        <!-- 统计卡片区域 -->
        <div class="stats-section">
        <div class="stat-card total-card">
          <div class="stat-icon">
            <span class="icon-bg">📊</span>
          </div>
          <div class="stat-content">
            <div class="stat-label">总分</div>
            <div class="stat-value">{{ totalScoreText }}</div>
          </div>
        </div>
        <div class="stat-card objective-card">
          <div class="stat-icon">
            <span class="icon-bg">✓</span>
          </div>
          <div class="stat-content">
            <div class="stat-label">客观题得分</div>
            <div class="stat-value">{{ objectiveScoreText }}</div>
          </div>
        </div>
        <div class="stat-card subjective-card">
          <div class="stat-icon">
            <span class="icon-bg">✎</span>
          </div>
          <div class="stat-content">
            <div class="stat-label">主观题得分</div>
            <div class="stat-value">{{ subjectiveScoreText }}</div>
          </div>
        </div>
      </div>

      <!-- 个人学情报告区域 -->
      <div v-if="analysisData" class="analysis-section">
        <div class="analysis-header">
          <h2 class="analysis-title">
            <span class="title-icon">📊</span>
            个人学情报告
          </h2>
          <div class="header-actions">
            <el-button type="success" @click="currentView = 'detail'" class="view-detail-btn">
              <el-icon><Edit /></el-icon>
              查看试卷详情
            </el-button>
            <el-button type="primary" @click="downloadPDF" class="download-btn">
              <el-icon><Download /></el-icon>
              下载成绩证明
            </el-button>
          </div>
        </div>

        <!-- PDF证明内容（隐藏，仅用于导出） -->
        <div id="certificateContent" style="display: none;">
          <div style="padding: 40px; font-family: '微软雅黑', sans-serif;">
            <h1 style="text-align: center; margin-bottom: 30px; color: #333;">成绩证明</h1>
            <div style="margin: 20px 0; line-height: 2;">
              <p><strong>考试名称：</strong>{{ analysisData.examTitle }}</p>
              <p><strong>总分：</strong>{{ analysisData.studentScore }} 分</p>
              <p><strong>客观题得分：</strong>{{ analysisData.objectiveScore || 0 }} 分</p>
              <p><strong>主观题得分：</strong>{{ analysisData.subjectiveScore || 0 }} 分</p>
              <p><strong>及格分：</strong>{{ analysisData.passScore }} 分</p>
              <p><strong>班级排名：</strong>第 {{ analysisData.rank }} 名 / 共 {{ analysisData.totalStudents }} 人</p>
              <p><strong>班级平均分：</strong>{{ analysisData.classAverage }} 分</p>
              <p style="margin-top: 40px; text-align: right;">生成日期：{{ new Date().toLocaleDateString('zh-CN') }}</p>
            </div>
          </div>
        </div>

        <div class="analysis-content">
          <!-- 排名和成绩对比卡片 -->
          <div class="rank-cards">
            <div class="rank-card rank-card-1">
              <div class="rank-icon">🏆</div>
              <div class="rank-info">
                <div class="rank-label">班级排名</div>
                <div class="rank-value">
                  第 <span class="rank-number">{{ analysisData.rank }}</span> 名
                </div>
                <div class="rank-sub">共 {{ analysisData.totalStudents }} 人参加</div>
              </div>
            </div>

            <div class="rank-card rank-card-2">
              <div class="rank-icon">📈</div>
              <div class="rank-info">
                <div class="rank-label">与班级平均分对比</div>
                <div class="rank-value">
                  <span :class="['compare-value', analysisData.studentScore >= analysisData.classAverage ? 'positive' : 'negative']">
                    {{ analysisData.studentScore >= analysisData.classAverage ? '+' : '' }}{{ (analysisData.studentScore - analysisData.classAverage).toFixed(1) }}
                  </span> 分
                </div>
                <div class="rank-sub">班级平均: {{ analysisData.classAverage }} 分</div>
              </div>
            </div>

            <div class="rank-card rank-card-3">
              <div class="rank-icon">⭐</div>
              <div class="rank-info">
                <div class="rank-label">成绩水平</div>
                <div class="rank-value">
                  <span :class="['level-badge', getScoreLevel(analysisData.studentScore, analysisData.passScore)]">
                    {{ getScoreLevelText(analysisData.studentScore, analysisData.passScore) }}
                  </span>
                </div>
                <div class="rank-sub">及格线: {{ analysisData.passScore }} 分</div>
              </div>
            </div>
          </div>

          <!-- 知识点雷达图 -->
          <div v-if="analysisData.knowledgePoints && analysisData.knowledgePoints.length > 0" class="radar-container">
            <div id="radarChart" class="radar-chart"></div>
          </div>

          <!-- 知识点详细列表 -->
          <div v-if="analysisData.knowledgePoints && analysisData.knowledgePoints.length > 0" class="knowledge-list">
            <h3 class="knowledge-title">📚 知识点详细分析</h3>
            <div class="knowledge-items">
              <div 
                v-for="(point, index) in analysisData.knowledgePoints" 
                :key="index"
                class="knowledge-item"
              >
                <div class="knowledge-item-header">
                  <span class="knowledge-name">{{ point.name }}</span>
                  <span class="knowledge-percentage" :style="{ color: getPercentageColor(point.percentage) }">
                    {{ point.percentage }}%
                  </span>
                </div>
                <div class="knowledge-progress">
                  <div 
                    class="knowledge-progress-bar" 
                    :style="{ width: point.percentage + '%', backgroundColor: getPercentageColor(point.percentage) }"
                  ></div>
                </div>
                <div class="knowledge-score">
                  得分: {{ point.score }} / {{ point.total }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      </div>

      <!-- 试卷详情视图 -->
      <div v-else-if="currentView === 'detail'" class="detail-view">
      <!-- 题目导航侧边栏 -->
      <aside class="questions-nav">
        <div class="nav-header">
          <span class="nav-title">题目导航</span>
          <span class="nav-progress">{{ questions.length }}</span>
        </div>
        <div class="nav-grid">
          <button
            v-for="(q, index) in questions"
            :key="q.id"
            class="nav-item"
            :class="{ 'is-current': currentQuestionId === q.id }"
            @click="scrollToQuestion(q.id)"
            :title="`题目 ${index + 1}`"
          >
            {{ index + 1 }}
          </button>
        </div>
      </aside>

      <!-- 主内容区域 -->
      <div class="detail-content">
        <!-- 统计卡片区域 -->
        <div class="stats-section">
        <div class="stat-card total-card">
          <div class="stat-icon">
            <span class="icon-bg">📊</span>
          </div>
          <div class="stat-content">
            <div class="stat-label">总分</div>
            <div class="stat-value">{{ totalScoreText }}</div>
          </div>
        </div>
        <div class="stat-card objective-card">
          <div class="stat-icon">
            <span class="icon-bg">✓</span>
          </div>
          <div class="stat-content">
            <div class="stat-label">客观题得分</div>
            <div class="stat-value">{{ objectiveScoreText }}</div>
          </div>
        </div>
        <div class="stat-card subjective-card">
          <div class="stat-icon">
            <span class="icon-bg">✎</span>
          </div>
          <div class="stat-content">
            <div class="stat-label">主观题得分</div>
            <div class="stat-value">{{ subjectiveScoreText }}</div>
          </div>
        </div>
      </div>

      <!-- 试题详情区域 -->
      <div class="questions-section">
        <div v-if="questions.length === 0" class="empty-state">
          <div class="empty-icon">📝</div>
          <p>暂无试题数据</p>
        </div>
        <div v-else class="question-list">
          <div
            v-for="(q, index) in questions"
            :key="q.id"
            :id="'q-' + q.id"
            class="question-card"
          >
            <!-- 题目头部 -->
            <div class="question-header">
              <div class="q-number-badge">{{ index + 1 }}</div>
              <div class="q-main-info">
                <div class="q-content">{{ q.content }}</div>
                <div class="q-tags">
                  <span class="q-type-tag">{{ typeLabel(q.type) }}</span>
                  <span class="q-score-tag">{{ q.score ?? '-' }} 分</span>
                </div>
              </div>
            </div>

            <!-- 题目选项 -->
            <div v-if="[1, 2, 3].includes(q.type) && Object.keys(parseOptions(q.options, q.type)).length > 0" class="question-options">
              <div class="options-label">选项</div>
              <div class="options-grid">
                <div
                  v-for="(optionText, optionKey) in parseOptions(q.options, q.type)"
                  :key="optionKey"
                  class="option-card"
                  :class="{
                    'is-correct': answerIncludesOption(formatAnswerText(q, q.answer), optionKey, q),
                    'is-selected': answerIncludesOption(perQuestionScore(q).userAnswerText, optionKey, q)
                  }"
                >
                  <div class="option-key">{{ optionKey }}</div>
                  <div class="option-text">{{ optionText }}</div>
                </div>
              </div>
            </div>

            <!-- 答题信息 -->
            <div class="question-details">
              <div class="detail-item score-item">
                <span class="detail-label">本题得分</span>
                <span class="detail-value score-value">{{ perQuestionScore(q).scoreText }}</span>
              </div>
              <div class="detail-item answer-item">
                <span class="detail-label">正确答案</span>
                <span class="detail-value correct-answer">{{ formatAnswerText(q, q.answer) }}</span>
              </div>
              <div class="detail-item user-answer-item">
                <span class="detail-label">你的答案</span>
                <span class="detail-value user-answer">{{ perQuestionScore(q).userAnswerText }}</span>
              </div>
              <!-- 教师批改意见 -->
              <div v-if="perQuestionScore(q).comment" class="detail-item comment-item">
                <span class="detail-label">
                  <el-icon style="margin-right: 4px;"><Edit /></el-icon>
                  教师批改意见
                </span>
                <div class="detail-value teacher-comment">{{ perQuestionScore(q).comment }}</div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <!-- 关闭试题详情区域 questions-section -->
      </div>
      <!-- 关闭主内容区域 detail-content -->
      </div>
      <!-- 关闭试卷详情视图 detail-view -->
    </div>
    <!-- 关闭主要内容 detail-body -->
  </div>
  <!-- 关闭最外层容器 -->
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Loading, Edit, Download } from '@element-plus/icons-vue'
import request from '@/utils/request'
import * as echarts from 'echarts'
import html2pdf from 'html2pdf.js'

const route = useRoute()
const router = useRouter()

const recordId = ref(Number(route.params.recordId))
const loading = ref(true)
const examRecord = ref(null)
const exam = reactive({})
const questions = ref([])
const answers = ref([])
const answerMap = reactive({})
const currentQuestionId = ref(null)

// 学情分析数据
const analysisData = ref(null)
const analysisLoading = ref(false)
const radarChart = ref(null)

// 视图切换：'report' - 学情报告, 'detail' - 试卷详情
const currentView = ref('report')

const totalScoreText = computed(() => {
  if (!examRecord.value || examRecord.value.totalScore == null) return '-'
  return `${examRecord.value.totalScore} 分`
})

const objectiveScoreText = computed(() => {
  if (!examRecord.value || examRecord.value.objectiveScore == null) return '-'
  return `${examRecord.value.objectiveScore} 分`
})

const subjectiveScoreText = computed(() => {
  if (!examRecord.value || examRecord.value.subjectiveScore == null) return '-'
  return `${examRecord.value.subjectiveScore} 分`
})

const loadData = async () => {
  loading.value = true
  try {
    const recordRes = await request.get(`/examRecord/${recordId.value}`)
    if (!recordRes || !recordRes.data) {
      ElMessage.error('考试记录不存在或已被删除')
      router.back()
      return
    }
    examRecord.value = recordRes.data

    const examRes = await request.get(`/exam/${examRecord.value.examId}`)
    if (examRes && examRes.data) {
      Object.assign(exam, examRes.data)
    }

    const qRes = await request.get(`/exam/${examRecord.value.examId}/questions`)
    questions.value = (qRes && qRes.data) ? qRes.data : []

    const aRes = await request.get(`/examRecord/${recordId.value}/answers`)
    answers.value = (aRes && aRes.data) ? aRes.data : []
    for (const item of answers.value) {
      if (item && item.questionId != null) {
        answerMap[item.questionId] = item
      }
    }
  } catch (e) {
    ElMessage.error('加载考试详情失败')
  } finally {
    loading.value = false
  }
}

// 加载学情分析数据
const loadAnalysisData = async () => {
  analysisLoading.value = true
  try {
    const res = await request.get(`/examRecord/${recordId.value}/analysis`)
    if (res && res.data) {
      analysisData.value = res.data
      // 渲染雷达图
      await nextTick()
      renderRadarChart()
    }
  } catch (e) {
    console.error('加载学情分析失败:', e)
  } finally {
    analysisLoading.value = false
  }
}

// 渲染雷达图
const renderRadarChart = () => {
  if (!analysisData.value || !analysisData.value.knowledgePoints) return
  
  const chartDom = document.getElementById('radarChart')
  if (!chartDom) return
  
  // 销毁旧图表
  if (radarChart.value) {
    radarChart.value.dispose()
  }
  
  radarChart.value = echarts.init(chartDom)
  
  const knowledgePoints = analysisData.value.knowledgePoints
  const indicator = knowledgePoints.map(item => ({
    name: item.name,
    max: 100
  }))
  
  const values = knowledgePoints.map(item => item.percentage)
  
  const option = {
    title: {
      text: '知识点掌握度分析',
      left: 'center',
      textStyle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#333'
      }
    },
    tooltip: {
      trigger: 'item',
      formatter: (params) => {
        let result = '<div style="padding: 5px;">'
        params.value.forEach((val, idx) => {
          const point = knowledgePoints[idx]
          result += `<div style="margin: 3px 0;">
            <strong>${point.name}</strong>: ${val}% <br/>
            <span style="color: #666; font-size: 12px;">
              得分: ${point.score}/${point.total}
            </span>
          </div>`
        })
        result += '</div>'
        return result
      }
    },
    radar: {
      indicator: indicator,
      radius: '65%',
      splitNumber: 4,
      name: {
        textStyle: {
          color: '#666',
          fontSize: 12
        }
      },
      splitLine: {
        lineStyle: {
          color: ['#e0e6f1', '#e5e8ef', '#ebeef5', '#f2f3f5']
        }
      },
      splitArea: {
        areaStyle: {
          color: ['rgba(114, 172, 209, 0.05)', 'rgba(114, 172, 209, 0.1)'],
          shadowColor: 'rgba(0, 0, 0, 0.2)',
          shadowBlur: 5
        }
      },
      axisLine: {
        lineStyle: {
          color: '#d0d0d0'
        }
      }
    },
    series: [{
      name: '知识点掌握度',
      type: 'radar',
      data: [{
        value: values,
        name: '我的掌握度',
        symbol: 'circle',
        symbolSize: 6,
        lineStyle: {
          width: 2,
          color: '#4facfe'
        },
        areaStyle: {
          color: new echarts.graphic.RadialGradient(0.5, 0.5, 1, [
            {
              color: 'rgba(79, 172, 254, 0.3)',
              offset: 0
            },
            {
              color: 'rgba(79, 172, 254, 0.1)',
              offset: 1
            }
          ])
        },
        itemStyle: {
          color: '#4facfe',
          borderColor: '#fff',
          borderWidth: 2
        }
      }]
    }]
  }
  
  radarChart.value.setOption(option)
  
  // 响应式调整
  window.addEventListener('resize', () => {
    radarChart.value && radarChart.value.resize()
  })
}

// 下载PDF成绩证明
const downloadPDF = () => {
  const element = document.getElementById('certificateContent')
  if (!element) {
    ElMessage.error('内容加载失败')
    return
  }
  
  ElMessage.info('正在生成PDF，请稍候...')
  
  const opt = {
    margin: [10, 10],
    filename: `成绩证明_${exam.title || '考试'}_${new Date().getTime()}.pdf`,
    image: { type: 'jpeg', quality: 0.98 },
    html2canvas: { scale: 2, useCORS: true },
    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
  }
  
  html2pdf().set(opt).from(element).save().then(() => {
    ElMessage.success('PDF下载成功')
  }).catch(() => {
    ElMessage.error('PDF生成失败')
  })
}

const goBack = () => {
  if (exam.classId) {
    router.push(`/student/class/${exam.classId}`)
  } else {
    router.back()
  }
}

const scrollToQuestion = (questionId) => {
  currentQuestionId.value = questionId
  setTimeout(() => {
    const el = document.getElementById('q-' + questionId)
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
  }, 10)
}

const typeLabel = (type) => {
  if (type === 1) return '单选题'
  if (type === 2) return '多选题'
  if (type === 3) return '判断题'
  if (type === 4) return '填空题'
  if (type === 5) return '简答题'
  return '题目'
}

const parseOptions = (options, type) => {
  try {
    if (type === 3 && !options) return { A: '正确', B: '错误' }
    if (!options) return {}
    if (typeof options === 'string') return JSON.parse(options)
    return options
  } catch (e) { return {} }
}

const perQuestionScore = (q) => {
  const answer = answerMap[q.id]
  
  // 得分显示逻辑
  let scoreText = '-'
  if (answer && answer.score != null) {
    // 如果有评分记录，显示分数
    scoreText = `${answer.score} 分`
  } else if (q.type === 1 || q.type === 2 || q.type === 3) {
    // 客观题（单选、多选、判断）未作答时显示 0 分
    scoreText = '0 分'
  }
  
  const userAnswerText = answer && answer.userAnswer
    ? formatAnswerText(q, answer.userAnswer)
    : '未作答'
  const comment = answer && answer.teacherComment ? answer.teacherComment : ''
  return { scoreText, userAnswerText, comment }
}

const formatAnswerText = (q, raw) => {
  if (raw == null || raw === '') return '-'
  let text = String(raw).trim()
  if (!text) return '-'

  // 判断题型
  const isJudgment = q && q.type === 3
  const isObjective = q && [1, 2, 3].includes(q.type) // 单选、多选、判断
  
  // 对于主观题（填空题、简答题），直接返回原文
  if (!isObjective) {
    return text
  }

  // 对于客观题，进行格式化处理
  if (text.startsWith('[') && text.endsWith(']')) {
    try {
      const arr = JSON.parse(text)
      if (Array.isArray(arr)) {
        return arr.map(v => normalizeAnswerUnit(String(v), isJudgment)).join('、')
      }
    } catch (e) {}
  }

  if (text.includes(',')) {
    const parts = text.split(',').map(s => s.trim()).filter(Boolean)
    if (parts.length > 1) {
      return parts.map(s => normalizeAnswerUnit(s, isJudgment)).join('、')
    }
  }

  return normalizeAnswerUnit(text, isJudgment)
}

const normalizeAnswerUnit = (v, isJudgment = false) => {
  if (!v) return v
  
  const upper = v.toUpperCase()
  
  // 只对判断题进行转换
  if (isJudgment) {
    // 判断题答案规范化：T/A/TRUE/正确 → 正确，F/B/FALSE/错误 → 错误
    if (upper === 'T' || upper === 'A' || upper === 'TRUE' || v === '正确') return '正确'
    if (upper === 'F' || upper === 'B' || upper === 'FALSE' || v === '错误') return '错误'
    return v // 判断题其他情况保持原样
  }
  
  // 对于选择题（单选、多选），转换为大写
  // 对于主观题，这个函数不应该被调用，但如果被调用了，保持原样
  // 简单判断：如果是单个字母，转为大写；否则保持原样
  if (v.length === 1 && /^[a-zA-Z]$/.test(v)) {
    return upper
  }
  
  return v // 保持原样
}

// 判断答案是否包含某个选项（用于高亮选项卡片）
const answerIncludesOption = (answerText, optionKey, question) => {
  if (!answerText || !optionKey) return false
  const isJudgment = question && question.type === 3
  const normalized = normalizeAnswerUnit(optionKey, isJudgment)
  return answerText.includes(optionKey) || answerText.includes(normalized)
}

const formatTime = (timeString) => {
  if (!timeString) return '-'
  const date = new Date(timeString)
  if (Number.isNaN(date.getTime())) return '-'
  return date.toLocaleString('zh-CN', { hour12: false })
}

// 获取成绩等级样式类
const getScoreLevel = (score, passScore) => {
  const percentage = (score / (passScore * 1.5)) * 100  // 假设满分是及格分的1.5倍
  if (percentage >= 90) return 'excellent'
  if (percentage >= 80) return 'good'
  if (percentage >= 60) return 'pass'
  return 'fail'
}

// 获取成绩等级文本
const getScoreLevelText = (score, passScore) => {
  const percentage = (score / (passScore * 1.5)) * 100
  if (percentage >= 90) return '优秀'
  if (percentage >= 80) return '良好'
  if (percentage >= 60) return '及格'
  return '不及格'
}

// 获取百分比对应的颜色
const getPercentageColor = (percentage) => {
  if (percentage >= 90) return '#10b981'  // 绿色
  if (percentage >= 75) return '#3b82f6'  // 蓝色
  if (percentage >= 60) return '#f59e0b'  // 橙色
  return '#ef4444'  // 红色
}

onMounted(() => {
  loadData()
  loadAnalysisData()
})
</script>

<style scoped>
/* ============ 全局容器 ============ */
.student-exam-detail-container {
  min-height: 100vh;
  padding: 0;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%);
  display: flex;
  flex-direction: column;
}

/* ============ 顶部导航栏 ============ */
.detail-header {
  position: sticky;
  top: 0;
  z-index: 100;
  height: 68px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  backdrop-filter: blur(16px);
  border-bottom: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  display: flex;
  align-items: center;
  padding: 0 24px;
}

.detail-header::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 50%, #667eea 100%);
  opacity: 0.3;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 16px;
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
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
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.back-btn:hover {
  transform: scale(1.05) translateY(-2px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
}

.back-btn :deep(.el-icon) {
  font-size: 20px;
}

.header-info {
  flex: 1;
  min-width: 0;
}

.detail-title {
  margin: 0;
  font-size: 24px;
  font-weight: 800;
  letter-spacing: 0.02em;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.detail-subtitle {
  margin: 4px 0 0;
  font-size: 12px;
  color: #6b7280;
  display: flex;
  align-items: center;
  gap: 6px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.time-icon {
  font-size: 14px;
}

.separator {
  margin: 0 8px;
  color: #d1d5db;
}

/* ============ 视图切换按钮 ============ */
.view-switch-buttons {
  display: flex;
  gap: 12px;
  margin-left: 20px;
}

.switch-btn {
  padding: 10px 20px;
  border: 2px solid rgba(102, 126, 234, 0.2);
  background: rgba(255, 255, 255, 0.9);
  border-radius: 12px;
  font-size: 14px;
  font-weight: 600;
  color: #667eea;
  cursor: pointer;
  transition: all 0.3s ease;
  white-space: nowrap;
}

.switch-btn:hover {
  border-color: rgba(102, 126, 234, 0.5);
  background: rgba(102, 126, 234, 0.1);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.switch-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: transparent;
  color: white;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
}

.switch-btn.active:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
}

/* ============ 视图容器 ============ */
.report-view {
  width: 100%;
  animation: fadeIn 0.4s ease-out;
}

.detail-view {
  width: 100%;
  display: flex;
  gap: 28px;
  animation: fadeIn 0.4s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
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
  padding: 24px 32px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  border-radius: 16px;
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.12);
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
.detail-body {
  flex: 1;
  max-width: 1280px;
  width: 100%;
  margin: 0 auto;
  padding: 32px 24px;
  display: flex;
  gap: 28px;
}

/* ============ 题目导航侧边栏 ============ */
.questions-nav {
  flex-shrink: 0;
  width: 120px;
  position: sticky;
  top: 88px;
  height: fit-content;
  padding: 16px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
}

.nav-header {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.nav-title {
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.nav-progress {
  font-size: 18px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.nav-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
}

.nav-item {
  width: 100%;
  aspect-ratio: 1;
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 10px;
  background: rgba(249, 250, 251, 0.8);
  color: #667eea;
  font-weight: 700;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
}

.nav-item:hover {
  background: rgba(249, 250, 251, 1);
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
  transform: scale(1.05);
}

.nav-item.is-current {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.25);
  transform: scale(1.08);
}

.nav-item.is-current:hover {
  transform: scale(1.12);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.3);
}

/* ============ 详情内容区域 ============ */
.detail-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 32px;
}

/* ============ 统计卡片区域 ============ */
.stats-section {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  animation: fadeInUp 0.6s ease-out;
}

.stat-card {
  padding: 24px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.stat-card::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0.06) 45%, transparent 100%);
  pointer-events: none;
}

.stat-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.2);
}

.stat-icon {
  flex-shrink: 0;
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  position: relative;
  z-index: 1;
}

.total-card .stat-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
}

.objective-card .stat-icon {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 8px 20px rgba(34, 197, 94, 0.3);
}

.subjective-card .stat-icon {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 8px 20px rgba(249, 115, 22, 0.3);
}

.stat-content {
  flex: 1;
  position: relative;
  z-index: 1;
}

.stat-label {
  font-size: 13px;
  color: #6b7280;
  font-weight: 500;
  margin-bottom: 6px;
}

.stat-value {
  font-size: 28px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* ============ 试题详情区域 ============ */
.questions-section {
  animation: fadeInUp 0.6s ease-out 0.1s both;
}

.empty-state {
  padding: 60px 24px;
  text-align: center;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  border-radius: 16px;
  border: 2px dashed rgba(102, 126, 234, 0.1);
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.empty-state p {
  margin: 0;
  font-size: 16px;
  color: #9ca3af;
}

.question-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* ============ 题目卡片 ============ */
.question-card {
  padding: 28px 32px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(16px);
  border: 2px solid rgba(102, 126, 234, 0.12);
  box-shadow: 0 6px 24px rgba(102, 126, 234, 0.1);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  animation: fadeInUp 0.6s ease-out;
}

.question-card::before {
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

.question-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.2);
}

.question-card:hover::before {
  opacity: 1;
}

.question-card > * {
  position: relative;
  z-index: 1;
}

/* ============ 题目头部 ============ */
.question-header {
  display: flex;
  align-items: flex-start;
  gap: 18px;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.1);
}

.q-number-badge {
  flex-shrink: 0;
  width: 48px;
  height: 48px;
  border-radius: 14px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 800;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.q-main-info {
  flex: 1;
  min-width: 0;
}

.q-content {
  font-size: 17px;
  font-weight: 500;
  line-height: 1.9;
  color: #1e293b;
  margin-bottom: 14px;
  word-wrap: break-word;
  white-space: pre-wrap;
  letter-spacing: 0.01em;
}

.q-tags {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.q-type-tag,
.q-score-tag {
  padding: 6px 14px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.q-type-tag {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.12) 0%, rgba(118, 75, 162, 0.12) 100%);
  color: #667eea;
  border: 1.5px solid rgba(102, 126, 234, 0.25);
}

.q-score-tag {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.12) 0%, rgba(234, 88, 12, 0.12) 100%);
  color: #f97316;
  border: 1.5px solid rgba(249, 115, 22, 0.25);
}

/* ============ 题目选项 ============ */
.question-options {
  margin: 20px 0;
  padding: 16px 0;
  border-top: 1px solid rgba(102, 126, 234, 0.08);
  border-bottom: 1px solid rgba(102, 126, 234, 0.08);
}

.options-label {
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  margin-bottom: 12px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.options-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.option-card {
  padding: 12px 14px;
  border-radius: 12px;
  background: rgba(249, 250, 251, 0.8);
  border: 2px solid rgba(102, 126, 234, 0.1);
  display: flex;
  align-items: flex-start;
  gap: 10px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: default;
}

.option-card:hover {
  background: rgba(249, 250, 251, 1);
  border-color: rgba(102, 126, 234, 0.15);
}

.option-card.is-correct {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.08) 0%, rgba(22, 163, 74, 0.08) 100%);
  border-color: rgba(34, 197, 94, 0.3);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.1);
}

.option-card.is-selected:not(.is-correct) {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.08) 0%, rgba(234, 88, 12, 0.08) 100%);
  border-color: rgba(249, 115, 22, 0.3);
  box-shadow: 0 4px 12px rgba(249, 115, 22, 0.1);
}

.option-card.is-correct.is-selected {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.12) 0%, rgba(22, 163, 74, 0.12) 100%);
  border-color: rgba(34, 197, 94, 0.4);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.15);
}

.option-key {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 700;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
}

.option-card.is-correct .option-key {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 2px 8px rgba(34, 197, 94, 0.2);
}

.option-card.is-selected:not(.is-correct) .option-key {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 2px 8px rgba(249, 115, 22, 0.2);
}

.option-text {
  flex: 1;
  font-size: 14px;
  color: #4b5563;
  line-height: 1.5;
  word-break: break-word;
}

.option-card.is-correct .option-text {
  color: #166534;
  font-weight: 500;
}

.option-card.is-selected:not(.is-correct) .option-text {
  color: #c2410c;
  font-weight: 500;
}

/* ============ 答题信息 ============ */
.question-details {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 18px;
  margin-top: 20px;
}

.detail-item {
  padding: 16px 18px;
  border-radius: 14px;
  background: rgba(249, 250, 251, 0.9);
  border: 1.5px solid rgba(102, 126, 234, 0.1);
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.detail-item:hover {
  background: rgba(255, 255, 255, 1);
  border-color: rgba(102, 126, 234, 0.2);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.08);
  transform: translateY(-2px);
}

.detail-label {
  display: block;
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.detail-value {
  display: block;
  font-size: 14px;
  font-weight: 600;
  word-break: break-word;
  line-height: 1.5;
}

.score-item .detail-value {
  color: #3b82f6;
}

.answer-item .detail-value {
  color: #22c55e;
}

.user-answer-item .detail-value {
  color: #f97316;
}

/* 教师批改意见 */
.comment-item {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.05) 0%, rgba(168, 85, 247, 0.05) 100%);
  border: 1px solid rgba(139, 92, 246, 0.15);
  padding: 12px 14px;
}

.comment-item:hover {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.08) 0%, rgba(168, 85, 247, 0.08) 100%);
  border-color: rgba(139, 92, 246, 0.25);
}

.comment-item .detail-label {
  color: #8b5cf6;
  display: flex;
  align-items: center;
  font-size: 12px;
  font-weight: 700;
  margin-bottom: 6px;
}

.teacher-comment {
  color: #6b21a8;
  font-weight: 500;
  line-height: 1.5;
  padding: 8px 10px;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 6px;
  border-left: 3px solid #8b5cf6;
  margin-top: 0;
  font-size: 13px;
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
@media (max-width: 960px) {
  .detail-header {
    height: 60px;
    padding: 0 16px;
  }

  .detail-title {
    font-size: 18px;
  }

  .detail-subtitle {
    font-size: 11px;
  }

  .detail-body {
    flex-direction: column;
    padding: 24px 16px;
    gap: 24px;
  }

  .questions-nav {
    width: 100%;
    position: relative;
    top: auto;
  }

  .nav-grid {
    grid-template-columns: repeat(6, 1fr);
  }

  .stats-section {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .stat-card {
    padding: 20px;
  }

  .stat-icon {
    width: 48px;
    height: 48px;
    font-size: 24px;
  }

  .stat-value {
    font-size: 24px;
  }

  .question-card {
    padding: 16px;
  }

  .question-header {
    gap: 12px;
    margin-bottom: 16px;
    padding-bottom: 12px;
  }

  .q-number-badge {
    width: 36px;
    height: 36px;
    font-size: 14px;
  }

  .q-content {
    font-size: 15px;
  }

  .options-grid {
    grid-template-columns: 1fr;
  }

  .question-details {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .detail-item {
    padding: 12px 14px;
  }

  .detail-label {
    font-size: 11px;
  }

  .detail-value {
    font-size: 13px;
  }
}

@media (max-width: 640px) {
  .detail-header {
    height: 56px;
    padding: 0 12px;
  }

  .back-btn {
    width: 36px;
    height: 36px;
  }

  .detail-title {
    font-size: 16px;
  }

  .detail-subtitle {
    display: none;
  }

  .detail-body {
    flex-direction: column;
    padding: 16px 12px;
    gap: 16px;
  }

  .questions-nav {
    width: 100%;
    padding: 12px;
  }

  .nav-grid {
    grid-template-columns: repeat(8, 1fr);
    gap: 4px;
  }

  .nav-item {
    font-size: 11px;
  }

  .stat-card {
    padding: 16px;
    gap: 12px;
  }

  .stat-icon {
    width: 44px;
    height: 44px;
    font-size: 22px;
  }

  .stat-value {
    font-size: 20px;
  }

  .question-card {
    padding: 14px;
  }

  .question-header {
    gap: 10px;
    margin-bottom: 14px;
    padding-bottom: 10px;
  }

  .q-number-badge {
    width: 32px;
    height: 32px;
    font-size: 12px;
  }

  .q-content {
    font-size: 14px;
  }

  .q-tags {
    gap: 6px;
  }

  .q-type-tag,
  .q-score-tag {
    padding: 3px 10px;
    font-size: 11px;
  }

  .options-grid {
    grid-template-columns: 1fr;
  }

  .option-card {
    padding: 10px 12px;
  }

  .option-key {
    width: 26px;
    height: 26px;
    font-size: 12px;
  }

  .option-text {
    font-size: 13px;
  }
}

/* ============ 学情报告区域 ============ */
.analysis-section {
  margin: 30px 0;
  animation: fadeInUp 0.6s ease-out;
}

.analysis-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding-bottom: 16px;
  border-bottom: 3px solid rgba(79, 172, 254, 0.3);
}

.analysis-title {
  font-size: 24px;
  font-weight: 700;
  color: #1e3a8a;
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 0;
}

.title-icon {
  font-size: 28px;
  animation: iconPulse 2s ease-in-out infinite;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.view-detail-btn {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border: none;
  box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
  transition: all 0.3s ease;
}

.view-detail-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
}

.download-btn {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  border: none;
  box-shadow: 0 4px 15px rgba(79, 172, 254, 0.3);
  transition: all 0.3s ease;
}

.download-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(79, 172, 254, 0.4);
}

.analysis-content {
  background: rgba(255, 255, 255, 0.9);
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.08);
}

/* 排名卡片 */
.rank-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.rank-card {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 16px;
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.rank-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
}

.rank-card-1 {
  border-color: rgba(245, 158, 11, 0.3);
}

.rank-card-1:hover {
  border-color: rgba(245, 158, 11, 0.6);
  background: linear-gradient(135deg, #fff7ed 0%, #ffffff 100%);
}

.rank-card-2 {
  border-color: rgba(59, 130, 246, 0.3);
}

.rank-card-2:hover {
  border-color: rgba(59, 130, 246, 0.6);
  background: linear-gradient(135deg, #eff6ff 0%, #ffffff 100%);
}

.rank-card-3 {
  border-color: rgba(168, 85, 247, 0.3);
}

.rank-card-3:hover {
  border-color: rgba(168, 85, 247, 0.6);
  background: linear-gradient(135deg, #faf5ff 0%, #ffffff 100%);
}

.rank-icon {
  font-size: 40px;
  line-height: 1;
}

.rank-info {
  flex: 1;
}

.rank-label {
  font-size: 13px;
  color: #6b7280;
  margin-bottom: 8px;
  font-weight: 600;
}

.rank-value {
  font-size: 26px;
  font-weight: 700;
  color: #1e293b;
  margin-bottom: 4px;
}

.rank-number {
  color: #f59e0b;
  font-size: 32px;
}

.rank-sub {
  font-size: 12px;
  color: #9ca3af;
}

.compare-value {
  font-size: 28px;
  font-weight: 700;
}

.compare-value.positive {
  color: #10b981;
}

.compare-value.negative {
  color: #ef4444;
}

.level-badge {
  display: inline-block;
  padding: 6px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
}

.level-badge.excellent {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
}

.level-badge.good {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
}

.level-badge.pass {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: white;
}

.level-badge.fail {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
}

/* 雷达图 */
.radar-container {
  background: white;
  border-radius: 16px;
  padding: 20px;
  margin-bottom: 30px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.radar-chart {
  width: 100%;
  height: 400px;
}

/* 知识点列表 */
.knowledge-list {
  background: white;
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.knowledge-title {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
  margin: 0 0 20px 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.knowledge-items {
  display: grid;
  gap: 16px;
}

.knowledge-item {
  padding: 16px;
  background: rgba(249, 250, 251, 0.6);
  border-radius: 12px;
  border: 1px solid rgba(226, 232, 240, 0.8);
  transition: all 0.3s ease;
}

.knowledge-item:hover {
  background: rgba(249, 250, 251, 1);
  border-color: rgba(79, 172, 254, 0.3);
  box-shadow: 0 4px 12px rgba(79, 172, 254, 0.1);
}

.knowledge-item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.knowledge-name {
  font-size: 15px;
  font-weight: 600;
  color: #1e293b;
}

.knowledge-percentage {
  font-size: 18px;
  font-weight: 700;
}

.knowledge-progress {
  height: 8px;
  background: #e5e7eb;
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 8px;
}

.knowledge-progress-bar {
  height: 100%;
  border-radius: 10px;
  transition: width 1s ease-out;
  background: linear-gradient(90deg, #4facfe 0%, #00f2fe 100%);
}

.knowledge-score {
  font-size: 13px;
  color: #6b7280;
  text-align: right;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .rank-cards {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .radar-chart {
    height: 300px;
  }

  .analysis-content {
    padding: 20px;
  }
}
</style>
