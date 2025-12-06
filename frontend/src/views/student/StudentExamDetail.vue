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
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, Loading, Edit } from '@element-plus/icons-vue'
import request from '@/utils/request'

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
  const scoreText = (answer && answer.score != null) ? `${answer.score} 分` : '-'
  const userAnswerText = answer && answer.userAnswer
    ? formatAnswerText(q, answer.userAnswer)
    : '未作答'
  const comment = answer && answer.comment ? answer.comment : ''
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

onMounted(loadData)
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
  color: #d1d5db;
  margin: 0 4px;
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
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  padding: 40px 24px;
  display: flex;
  gap: 24px;
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
  gap: 16px;
}

/* ============ 题目卡片 ============ */
.question-card {
  padding: 24px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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
  gap: 16px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.08);
}

.q-number-badge {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border-radius: 12px;
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
  font-size: 16px;
  font-weight: 600;
  color: #111827;
  line-height: 1.6;
  word-break: break-word;
  margin-bottom: 10px;
}

.q-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.q-type-tag,
.q-score-tag {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  white-space: nowrap;
}

.q-type-tag {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  color: #667eea;
  border: 1px solid rgba(102, 126, 234, 0.2);
}

.q-score-tag {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.1) 0%, rgba(234, 88, 12, 0.1) 100%);
  color: #f97316;
  border: 1px solid rgba(249, 115, 22, 0.2);
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
  gap: 16px;
}

.detail-item {
  padding: 14px 16px;
  border-radius: 12px;
  background: rgba(249, 250, 251, 0.8);
  border: 1px solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
}

.detail-item:hover {
  background: rgba(249, 250, 251, 1);
  border-color: rgba(102, 126, 234, 0.15);
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
  padding: 16px 18px;
}

.comment-item:hover {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.08) 0%, rgba(168, 85, 247, 0.08) 100%);
  border-color: rgba(139, 92, 246, 0.25);
}

.comment-item .detail-label {
  color: #8b5cf6;
  display: flex;
  align-items: center;
  font-size: 13px;
  font-weight: 700;
}

.teacher-comment {
  color: #6b21a8;
  font-weight: 500;
  line-height: 1.6;
  padding: 10px 12px;
  background: rgba(255, 255, 255, 0.6);
  border-radius: 8px;
  border-left: 3px solid #8b5cf6;
  margin-top: 8px;
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
</style>
