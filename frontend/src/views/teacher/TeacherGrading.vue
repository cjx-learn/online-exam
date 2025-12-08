<template>
  <div class="teacher-grading-container">
    <!-- 顶部导航栏 -->
    <div class="grading-header">
      <div class="header-left">
        <button class="back-btn" @click="goBack" title="返回">
          <el-icon><ArrowLeft /></el-icon>
        </button>
        <div class="header-info">
          <h1 class="grading-title">主观题试卷批改</h1>
          <p class="grading-subtitle">{{ examInfo.title }}</p>
        </div>
      </div>
      <div class="header-stats">
        <div class="stat-item pending-stat">
          <span class="stat-label">待批改</span>
          <span class="stat-value">{{ pendingCount }}</span>
        </div>
        <div class="stat-divider"></div>
        <div class="stat-item graded-stat">
          <span class="stat-label">已批改</span>
          <span class="stat-value">{{ gradedCount }}</span>
        </div>
      </div>
    </div>

    <!-- 主要内容 -->
    <div class="grading-body">
      <!-- 左侧题目列表 -->
      <aside class="question-list-panel">
        <div class="panel-header">
          <span class="panel-title">题目列表</span>
          <span class="panel-count">{{ allQuestions.length }}</span>
        </div>
        <div class="question-list">
          <div
            v-for="(question, index) in allQuestions"
            :key="question.questionId"
            class="question-item"
            :class="{ 'is-current': currentQuestionId === question.questionId }"
            @click="selectQuestion(question)"
          >
            <div class="question-num"> 第 {{ index + 1 }} 题</div>
            <div class="question-status">
              <span class="status-badge" :class="getQuestionStatusClass(question)">
                {{ getQuestionStatusText(question) }}
              </span>
            </div>
          </div>
        </div>
      </aside>

      <!-- 右侧批改区域 -->
      <div class="grading-panel">
        <div v-if="!currentQuestion" class="empty-state">
          <div class="empty-icon">📋</div>
          <p>请选择题目进行批改</p>
        </div>

        <div v-else class="grading-content">
          <!-- 题目信息 -->
          <div class="question-info-card">
            <div class="question-header">
              <div class="q-number"> {{ currentQuestionIndex + 1 }} </div>
              <div class="q-info">
                <div class="q-content">{{ currentQuestion.content }}</div>
                <div class="q-meta">
                  <span class="q-score">满分 <strong>{{ currentQuestion.score }}</strong> 分</span>
                  <span class="q-count">{{ currentQuestionAnswers.length }} 个学生</span>
                  <span class="q-progress" :class="getQuestionStatusClass(currentQuestion)">
                    {{ getQuestionProgressText(currentQuestion) }}
                  </span>
                </div>
              </div>
            </div>

            <!-- 标准答案 -->
            <div class="answer-section">
              <div class="section-title">标准答案</div>
              <div class="answer-box standard-answer">
                {{ currentQuestion.standardAnswer }}
              </div>
            </div>
          </div>

          <!-- 学生答案列表 -->
          <div class="student-answers-list">
            <div
              v-for="(answer, index) in currentQuestionAnswers"
              :key="answer.examRecordId"
              class="student-answer-card"
              :class="{ 
                'is-current': currentAnswerIndex === index,
                'is-graded': isAnswerSaved(answer)
              }"
              @click="selectAnswer(index)"
            >
              <div class="answer-header">
                <div class="student-info">
                  <div class="student-name">学生 {{ index + 1 }}</div>
                </div>
                <div class="answer-status">
                  <span v-if="isAnswerSaved(answer)" class="status-badge graded">
                    {{ answer.currentScore }}分
                  </span>
                  <span v-else class="status-badge pending">待批改</span>
                </div>
              </div>
            </div>
          </div>

          <!-- 批改区域 -->
          <div v-if="currentAnswer" class="grading-section-large">
            <div class="grading-title-section">
              批改 - 学生 {{ currentAnswerIndex + 1 }}
            </div>
            
            <div class="answer-section">
              <div class="section-title">学生答案</div>
              <div class="answer-box student-answer">
                {{ currentAnswer.userAnswer || '未作答' }}
              </div>
            </div>

            <div class="grading-section">
              <div class="grading-row">
                <label class="grading-label">得分</label>
                <div class="grading-input-group">
                  <el-input-number
                    v-if="currentAnswerData"
                    v-model="currentAnswerData.currentScore"
                    :min="0"
                    :max="currentQuestion.score"
                    :step="1"
                    :precision="0"
                    controls-position="right"
                    class="score-input"
                    @change="hasUnsavedChanges = true"
                  />
                  <span class="score-max">/ {{ currentQuestion.score }}</span>
                </div>
              </div>

              <div class="grading-row">
                <label class="grading-label">批改意见</label>
                <el-input
                  v-if="currentAnswerData"
                  v-model="currentAnswerData.comment"
                  type="textarea"
                  :rows="3"
                  placeholder="请输入批改意见..."
                  class="comment-input"
                  @input="hasUnsavedChanges = true"
                />
              </div>
            </div>

            <!-- 操作按钮 -->
            <div class="action-buttons">
              <el-button 
                @click="goToPreviousAnswer" 
                :disabled="!hasPreviousAnswer"
                class="nav-btn"
                title="快捷键: ← 左箭头"
              >
                <el-icon><ArrowLeft /></el-icon>
                上一个
              </el-button>
              <el-button 
                type="primary" 
                @click="saveCurrentAnswer"
                class="save-btn"
                title="快捷键: Ctrl/Cmd + S"
              >
                <el-icon><Check /></el-icon>
                保存批改
              </el-button>
              <el-button 
                @click="goToNextAnswer" 
                :disabled="!hasNextAnswer"
                class="nav-btn"
                title="快捷键: → 右箭头"
              >
                下一个
                <el-icon><ArrowRight /></el-icon>
              </el-button>
            </div>
            
            <!-- 快捷键提示 -->
            <div class="keyboard-shortcuts">
              <div class="shortcuts-title">💡 快捷键</div>
              <div class="shortcuts-list">
                <span class="shortcut-item"><kbd>←</kbd> 上一个</span>
                <span class="shortcut-item"><kbd>→</kbd> 下一个</span>
                <span class="shortcut-item"><kbd>Ctrl</kbd> + <kbd>S</kbd> 保存</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, ArrowRight, Check } from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()

const examId = ref(Number(route.params.examId))
const classId = ref(Number(route.params.classId))

const examInfo = reactive({
  title: '',
  startTime: '',
  endTime: ''
})

const studentAnswers = ref([])
const currentQuestionId = ref(null)
const currentAnswerIndex = ref(0)
const currentAnswerData = ref(null) // 直接存储当前答案的引用
const loading = ref(true)
const hasUnsavedChanges = ref(false) // 是否有未保存的修改
const savedAnswers = ref(new Set()) // 已保存的答案ID集合

// 从所有学生答案中提取所有主观题
const allQuestions = computed(() => {
  const questionsMap = new Map()
  
  for (const student of studentAnswers.value) {
    for (const question of student.subjectiveQuestions) {
      if (!questionsMap.has(question.questionId)) {
        questionsMap.set(question.questionId, {
          questionId: question.questionId,
          content: question.content,
          score: question.score,
          standardAnswer: question.standardAnswer
        })
      }
    }
  }
  
  return Array.from(questionsMap.values())
})

// 当前选中的题目
const currentQuestion = computed(() => {
  return allQuestions.value.find(q => q.questionId === currentQuestionId.value) || null
})

const currentQuestionIndex = computed(() => {
  return allQuestions.value.findIndex(q => q.questionId === currentQuestionId.value)
})

// 当前题目的所有学生答案
const currentQuestionAnswers = computed(() => {
  if (!currentQuestion.value) return []
  
  const answers = []
  for (const student of studentAnswers.value) {
    const answer = student.subjectiveQuestions.find(q => q.questionId === currentQuestion.value.questionId)
    if (answer) {
      // 直接使用原始 answer 对象，添加额外属性
      answer.examRecordId = student.examRecordId
      answer.studentName = student.studentName
      answer.studentNo = student.studentNo
      answers.push(answer)
    }
  }
  return answers
})

// 当前选中的答案（用于显示，不用于 v-model）
const currentAnswer = computed(() => {
  return currentAnswerData.value
})

// 更新当前答案的引用
const updateCurrentAnswer = () => {
  if (!currentQuestion.value) {
    currentAnswerData.value = null
    hasUnsavedChanges.value = false
    return
  }
  
  const answers = currentQuestionAnswers.value
  if (currentAnswerIndex.value >= 0 && currentAnswerIndex.value < answers.length) {
    currentAnswerData.value = answers[currentAnswerIndex.value]
  } else {
    currentAnswerData.value = null
  }
  
  // 切换答案时重置未保存标记
  hasUnsavedChanges.value = false
}

const hasPreviousAnswer = computed(() => {
  return currentAnswerIndex.value > 0
})

const hasNextAnswer = computed(() => {
  return currentAnswerIndex.value < currentQuestionAnswers.value.length - 1
})

const pendingCount = computed(() => {
  let count = 0
  for (const student of studentAnswers.value) {
    for (const question of student.subjectiveQuestions) {
      if (question.currentScore === null) {
        count++
      }
    }
  }
  return count
})

const gradedCount = computed(() => {
  let count = 0
  for (const student of studentAnswers.value) {
    for (const question of student.subjectiveQuestions) {
      if (question.currentScore !== null) {
        count++
      }
    }
  }
  return count
})

const getQuestionStatusClass = (question) => {
  const answers = studentAnswers.value.flatMap(s => 
    s.subjectiveQuestions.filter(q => q.questionId === question.questionId)
  )
  
  const allGraded = answers.every(a => a.currentScore !== null)
  const someGraded = answers.some(a => a.currentScore !== null)
  
  if (allGraded) return 'graded'
  if (someGraded) return 'partial'
  return 'pending'
}

const getQuestionStatusText = (question) => {
  const status = getQuestionStatusClass(question)
  if (status === 'graded') return '已批改'
  if (status === 'partial') return '部分批改'
  return '待批改'
}

const getQuestionProgressText = (question) => {
  const answers = studentAnswers.value.flatMap(s => 
    s.subjectiveQuestions.filter(q => q.questionId === question.questionId)
  )
  
  const gradedCount = answers.filter(a => a.currentScore !== null).length
  const totalCount = answers.length
  
  return `${gradedCount}/${totalCount}`
}

// 判断答案是否已保存
const isAnswerSaved = (answer) => {
  if (!answer || !currentQuestion.value) return false
  const answerId = `${answer.examRecordId}-${currentQuestion.value.questionId}`
  return savedAnswers.value.has(answerId)
}

const loadExamInfo = async () => {
  try {
    const response = await request.get(`/exam/${examId.value}`)
    if (response.code === 200) {
      Object.assign(examInfo, response.data)
    }
  } catch (error) {
    console.error('加载考试信息失败:', error)
    ElMessage.error('加载考试信息失败')
  }
}

const loadStudentAnswers = async () => {
  loading.value = true
  try {
    const response = await request.get(`/grading/exam/${examId.value}/class/${classId.value}`)
    if (response.code === 200) {
      studentAnswers.value = response.data || []
      
      // 初始化已保存的答案集合
      savedAnswers.value = new Set()
      for (const student of studentAnswers.value) {
        for (const question of student.subjectiveQuestions) {
          if (question.currentScore !== null && question.currentScore !== undefined) {
            const answerId = `${student.examRecordId}-${question.questionId}`
            savedAnswers.value.add(answerId)
          }
        }
      }
      
      if (allQuestions.value.length > 0) {
        currentQuestionId.value = allQuestions.value[0].questionId
        updateCurrentAnswer()
      }
    } else {
      // 显示后端返回的错误消息
      ElMessage.error(response.message || '加载学生答案失败')
      // 如果是考试未结束的错误，返回批改列表
      if (response.message && response.message.includes('尚未结束')) {
        setTimeout(() => {
          router.back()
        }, 1500)
      }
    }
  } catch (error) {
    console.error('加载学生答案失败:', error)
    const errorMsg = error.response?.data?.message || error.message || '加载学生答案失败'
    ElMessage.error(errorMsg)
    // 如果是考试未结束的错误，返回批改列表
    if (errorMsg.includes('尚未结束')) {
      setTimeout(() => {
        router.back()
      }, 1500)
    }
  } finally {
    loading.value = false
  }
}

const selectQuestion = async (question) => {
  // 检查是否有未保存的修改
  if (hasUnsavedChanges.value) {
    try {
      await ElMessageBox.confirm(
        '当前有未保存的批改内容，是否放弃修改？',
        '提示',
        {
          confirmButtonText: '放弃',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      hasUnsavedChanges.value = false
    } catch {
      return // 用户取消，不切换
    }
  }
  
  currentQuestionId.value = question.questionId
  currentAnswerIndex.value = 0
  updateCurrentAnswer()
}

const selectAnswer = async (index) => {
  // 检查是否有未保存的修改
  if (hasUnsavedChanges.value) {
    try {
      await ElMessageBox.confirm(
        '当前有未保存的批改内容，是否放弃修改？',
        '提示',
        {
          confirmButtonText: '放弃',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      hasUnsavedChanges.value = false
    } catch {
      return // 用户取消，不切换
    }
  }
  
  currentAnswerIndex.value = index
  updateCurrentAnswer()
}

const goToPreviousAnswer = async () => {
  if (!hasPreviousAnswer.value) return
  
  // 检查是否有未保存的修改
  if (hasUnsavedChanges.value) {
    try {
      await ElMessageBox.confirm(
        '当前有未保存的批改内容，是否放弃修改？',
        '提示',
        {
          confirmButtonText: '放弃',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      hasUnsavedChanges.value = false
    } catch {
      return // 用户取消
    }
  }
  
  currentAnswerIndex.value--
  updateCurrentAnswer()
}

const goToNextAnswer = async () => {
  if (!hasNextAnswer.value) return
  
  // 检查是否有未保存的修改
  if (hasUnsavedChanges.value) {
    try {
      await ElMessageBox.confirm(
        '当前有未保存的批改内容，是否放弃修改？',
        '提示',
        {
          confirmButtonText: '放弃',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      hasUnsavedChanges.value = false
    } catch {
      return // 用户取消
    }
  }
  
  currentAnswerIndex.value++
  updateCurrentAnswer()
}

const saveCurrentAnswer = async () => {
  if (!currentAnswer.value || !currentQuestion.value) return

  // 验证得分
  if (currentAnswer.value.currentScore === null || currentAnswer.value.currentScore === undefined) {
    ElMessage.warning('请输入得分')
    return
  }

  try {
    const gradingData = {
      examRecordId: currentAnswer.value.examRecordId,
      answers: [{
        questionId: currentQuestion.value.questionId,
        score: currentAnswer.value.currentScore,
        comment: currentAnswer.value.comment
      }]
    }

    const response = await request.post('/grading/save', gradingData)
    if (response.code === 200) {
      ElMessage.success('批改保存成功')
      
      // 清除未保存标记
      hasUnsavedChanges.value = false
      
      // 添加到已保存集合
      const answerId = `${currentAnswer.value.examRecordId}-${currentQuestion.value.questionId}`
      savedAnswers.value.add(answerId)
      
      // 因为我们直接修改的是原始数据，所以不需要额外更新
      // 数据已经自动更新了
      
      // 查找下一个未保存的答案
      const currentAnswers = currentQuestionAnswers.value
      let nextUngradedIndex = -1
      
      // 从当前位置之后查找
      for (let i = currentAnswerIndex.value + 1; i < currentAnswers.length; i++) {
        if (!isAnswerSaved(currentAnswers[i])) {
          nextUngradedIndex = i
          break
        }
      }
      
      // 如果后面没有，从头开始查找
      if (nextUngradedIndex === -1) {
        for (let i = 0; i < currentAnswerIndex.value; i++) {
          if (!isAnswerSaved(currentAnswers[i])) {
            nextUngradedIndex = i
            break
          }
        }
      }
      
      // 跳转到下一个未保存的答案，或者提示全部完成
      if (nextUngradedIndex !== -1) {
        currentAnswerIndex.value = nextUngradedIndex
        updateCurrentAnswer()
      } else {
        // 真正检查当前题目是否全部批改完成（所有答案都已保存）
        const allGraded = currentAnswers.every(a => isAnswerSaved(a))
        if (allGraded) {
          ElMessage.success('当前题目已全部批改完成')
        }
      }
    } else {
      ElMessage.error(response.message || '保存失败')
    }
  } catch (error) {
    console.error('保存批改失败:', error)
    ElMessage.error('保存批改失败')
  }
}

const goBack = () => {
  // 标记需要刷新批改列表（教师班级界面）
  sessionStorage.setItem('refreshGradingList', 'true')
  // 标记需要刷新考试列表（学生班级界面）
  sessionStorage.setItem('refreshExamListFromGrading', 'true')
  router.back()
}

// 键盘快捷键
const handleKeyPress = (event) => {
  // 如果正在输入，不触发快捷键
  if (event.target.tagName === 'INPUT' || event.target.tagName === 'TEXTAREA') {
    return
  }
  
  // Ctrl/Cmd + S: 保存当前批改
  if ((event.ctrlKey || event.metaKey) && event.key === 's') {
    event.preventDefault()
    saveCurrentAnswer()
    return
  }
  
  // 左箭头: 上一个答案
  if (event.key === 'ArrowLeft' && hasPreviousAnswer.value) {
    event.preventDefault()
    goToPreviousAnswer()
    return
  }
  
  // 右箭头: 下一个答案
  if (event.key === 'ArrowRight' && hasNextAnswer.value) {
    event.preventDefault()
    goToNextAnswer()
    return
  }
}

onMounted(async () => {
  await loadExamInfo()
  await loadStudentAnswers()
  
  // 添加键盘事件监听
  window.addEventListener('keydown', handleKeyPress)
})

// 组件卸载时移除监听器
onUnmounted(() => {
  window.removeEventListener('keydown', handleKeyPress)
})
</script>

<style scoped>
/* ============ 全局容器 ============ */
.teacher-grading-container {
  min-height: 100vh;
  padding: 0;
  background: linear-gradient(135deg, #f0f4ff 0%, #f5f0ff 50%, #fff5f7 100%);
  display: flex;
  flex-direction: column;
  animation: fadeIn 0.6s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

/* ============ 顶部导航栏 ============ */
.grading-header {
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
  justify-content: space-between;
  padding: 0 24px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
  flex: 1;
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

.grading-title {
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

.grading-subtitle {
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

.header-stats {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-shrink: 0;
}

.stat-divider {
  width: 1px;
  height: 32px;
  background: linear-gradient(180deg, transparent 0%, rgba(102, 126, 234, 0.2) 50%, transparent 100%);
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border-radius: 12px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.stat-item.pending-stat {
  background: rgba(249, 115, 22, 0.05);
}

.stat-item.graded-stat {
  background: rgba(34, 197, 94, 0.05);
}

.stat-label {
  font-size: 11px;
  color: #6b7280;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-value {
  font-size: 22px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* ============ 主要内容区域 ============ */
.grading-body {
  flex: 1;
  max-width: 1400px;
  width: 100%;
  margin: 0 auto;
  padding: 24px;
  display: flex;
  gap: 24px;
  align-items: flex-start;
}

/* ============ 题目列表面板 ============ */
.question-list-panel {
  flex-shrink: 0;
  width: 260px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.12);
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  max-height: fit-content;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.panel-header {
  padding: 16px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  flex-shrink: 0;
}

.panel-title {
  font-size: 14px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.panel-count {
  font-size: 16px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.question-list {
  flex: 0 1 auto;
  overflow-y: auto;
  padding: 8px;
  max-height: calc(100vh - 300px);
}

.question-item {
  padding: 12px;
  margin-bottom: 8px;
  border-radius: 12px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  border: 2px solid rgba(102, 126, 234, 0.12);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  gap: 8px;
  box-shadow: 0 2px 6px rgba(102, 126, 234, 0.04);
}

.question-item:hover {
  background: linear-gradient(135deg, rgba(255, 255, 255, 1) 0%, rgba(250, 251, 255, 1) 100%);
  border-color: rgba(102, 126, 234, 0.25);
  box-shadow: 0 6px 14px rgba(102, 126, 234, 0.12);
  transform: translateY(-1px);
}

.question-num {
  font-size: 13px;
  font-weight: 700;
  color: #111827;
  word-break: break-word;
  line-height: 1.4;
}

.question-item.is-current .question-num {
  color: white;
}

.question-status {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.status-badge {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: 1px solid;
}

.status-badge.pending {
  background: rgba(249, 115, 22, 0.1);
  color: #c2410c;
  border-color: rgba(249, 115, 22, 0.2);
}

.status-badge.partial {
  background: rgba(59, 130, 246, 0.1);
  color: #1e40af;
  border-color: rgba(59, 130, 246, 0.2);
}

.status-badge.graded {
  background: rgba(34, 197, 94, 0.1);
  color: #166534;
  border-color: rgba(34, 197, 94, 0.2);
}

.question-item.is-current {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: transparent;
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.25);
}

.question-item.is-current .status-badge {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border-color: rgba(255, 255, 255, 0.3);
}

/* ============ 批改面板 ============ */
.grading-panel {
  flex: 1;
  min-width: 0;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  max-height: calc(100vh - 140px);
}

.empty-state {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 60px 24px;
}

.empty-icon {
  font-size: 48px;
}

.empty-state p {
  margin: 0;
  font-size: 16px;
  color: #9ca3af;
}

.grading-content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 0;
}


/* ============ 题目信息卡片 ============ */
.question-info-card {
  padding: 16px;
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.1);
  animation: slideInUp 0.6s ease-out;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  flex: 0 0 auto;
}

.question-info-card:hover {
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.25);
}

/* ============ 学生答案列表 ============ */
.student-answers-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 10px;
  flex: 0 0 auto;
  max-height: 100px;
  overflow-y: auto;
  padding: 10px;
  background: linear-gradient(135deg, rgba(249, 250, 251, 0.8) 0%, rgba(240, 244, 255, 0.8) 100%);
  border-radius: 12px;
  border: 2px solid rgba(102, 126, 234, 0.1);
}

.student-answers-list::-webkit-scrollbar {
  width: 6px;
}

.student-answers-list::-webkit-scrollbar-track {
  background: transparent;
}

.student-answers-list::-webkit-scrollbar-thumb {
  background: rgba(102, 126, 234, 0.2);
  border-radius: 3px;
}

.student-answers-list::-webkit-scrollbar-thumb:hover {
  background: rgba(102, 126, 234, 0.4);
}

.student-answer-card {
  padding: 10px 12px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  border: 2px solid rgba(102, 126, 234, 0.12);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  gap: 4px;
  box-shadow: 0 2px 6px rgba(102, 126, 234, 0.04);
  min-height: 0;
}

.student-answer-card:hover {
  background: linear-gradient(135deg, rgba(255, 255, 255, 1) 0%, rgba(250, 251, 255, 1) 100%);
  border-color: rgba(102, 126, 234, 0.25);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
  transform: translateY(-1px);
}

.student-answer-card.is-current {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: transparent;
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.25);
  transform: scale(1.01);
}

.answer-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.answer-number {
  font-size: 13px;
  font-weight: 700;
  color: #111827;
  display: flex;
  align-items: center;
  gap: 4px;
}

.answer-number::before {
  content: '';
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.student-answer-card.is-current .answer-number {
  color: white;
}

.student-answer-card.is-current .answer-number::before {
  background: rgba(255, 255, 255, 0.8);
}

.student-answer-card.is-graded {
  background: linear-gradient(135deg, rgba(209, 250, 229, 0.5) 0%, rgba(167, 243, 208, 0.5) 100%);
  border-color: rgba(34, 197, 94, 0.2);
}

.student-answer-card.is-graded:hover {
  background: linear-gradient(135deg, rgba(209, 250, 229, 0.7) 0%, rgba(167, 243, 208, 0.7) 100%);
  border-color: rgba(34, 197, 94, 0.3);
}

.student-answer-card.is-current.is-graded {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
}

.student-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.student-name {
  font-size: 13px;
  font-weight: 700;
  color: #111827;
}

.student-no {
  font-size: 11px;
  color: #6b7280;
  font-weight: 500;
}

.student-answer-card.is-current .student-name,
.student-answer-card.is-current .student-no {
  color: white;
}

.answer-status {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.answer-preview {
  display: none;
}

/* ============ 大批改区域 ============ */
.grading-section-large {
  padding: 20px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  flex: 1;
  min-height: 0;
  overflow-y: auto;
}

.grading-section-large:hover {
  border-color: rgba(102, 126, 234, 0.25);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.1);
}

.grading-title-section {
  font-size: 15px;
  font-weight: 700;
  color: #111827;
  padding-bottom: 14px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.15);
  display: flex;
  align-items: center;
  gap: 8px;
}

.grading-title-section::before {
  content: '';
  width: 4px;
  height: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 2px;
}

/* ============ 主观题批改区域 ============ */
.questions-grading {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.question-grading-card {
  padding: 24px;
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border: 2px solid rgba(102, 126, 234, 0.12);
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: slideInUp 0.5s ease-out;
}

.question-grading-card:hover {
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.25);
  transform: translateY(-2px);
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.question-header {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.08);
}

.q-number {
  flex-shrink: 0;
  width: 44px;
  height: 44px;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 800;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.question-grading-card:hover .q-number {
  transform: scale(1.08);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.35);
}

.q-info {
  flex: 1;
  min-width: 0;
}

.q-content {
  font-size: 16px;
  font-weight: 600;
  color: #111827;
  line-height: 1.6;
  word-break: break-word;
  margin-bottom: 8px;
}

.q-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.q-score {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.q-score strong {
  color: #f97316;
  font-weight: 700;
}

.q-count {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
}

.q-progress {
  font-size: 12px;
  font-weight: 600;
  padding: 4px 10px;
  border-radius: 12px;
  transition: all 0.3s ease;
}

.q-progress.pending {
  background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
  color: #dc2626;
}

.q-progress.partial {
  background: linear-gradient(135deg, #fed7aa 0%, #fdba74 100%);
  color: #ea580c;
}

.q-progress.graded {
  background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
  color: #059669;
}

.q-current {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
  padding: 4px 8px;
  background: rgba(34, 197, 94, 0.1);
  border-radius: 6px;
}

.q-current strong {
  color: #22c55e;
  font-weight: 700;
}

/* ============ 答案区域 ============ */
.answer-section {
  margin-bottom: 20px;
}

.section-title {
  font-size: 12px;
  font-weight: 700;
  color: #6b7280;
  margin-bottom: 10px;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  display: flex;
  align-items: center;
  gap: 6px;
}

.answer-box {
  padding: 16px;
  border-radius: 12px;
  border: 2px solid rgba(102, 126, 234, 0.12);
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  font-size: 14px;
  line-height: 1.8;
  color: #4b5563;
  word-break: break-word;
  white-space: pre-wrap;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  max-height: 220px;
  overflow-y: auto;
  box-shadow: inset 0 2px 4px rgba(102, 126, 234, 0.04);
}

.answer-box::-webkit-scrollbar {
  width: 6px;
}

.answer-box::-webkit-scrollbar-track {
  background: transparent;
}

.answer-box::-webkit-scrollbar-thumb {
  background: rgba(102, 126, 234, 0.2);
  border-radius: 3px;
}

.answer-box::-webkit-scrollbar-thumb:hover {
  background: rgba(102, 126, 234, 0.4);
}

.standard-answer {
  background: linear-gradient(135deg, #dcfce7 0%, #d1fae5 100%);
  border-color: rgba(34, 197, 94, 0.3);
  color: #166534;
  box-shadow: inset 0 2px 4px rgba(34, 197, 94, 0.08), 0 2px 8px rgba(34, 197, 94, 0.08);
}

.standard-answer:hover {
  border-color: rgba(34, 197, 94, 0.5);
  box-shadow: inset 0 2px 4px rgba(34, 197, 94, 0.08), 0 4px 12px rgba(34, 197, 94, 0.15);
}

.student-answer {
  background: linear-gradient(135deg, #ffedd5 0%, #fed7aa 100%);
  border-color: rgba(249, 115, 22, 0.3);
  color: #c2410c;
  box-shadow: inset 0 2px 4px rgba(249, 115, 22, 0.08), 0 2px 8px rgba(249, 115, 22, 0.08);
}

.student-answer:hover {
  border-color: rgba(249, 115, 22, 0.5);
  box-shadow: inset 0 2px 4px rgba(249, 115, 22, 0.08), 0 4px 12px rgba(249, 115, 22, 0.15);
}

/* ============ 批改信息区域 ============ */
.grading-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
  padding: 18px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
  border: 2px solid rgba(102, 126, 234, 0.12);
  border-radius: 12px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.grading-section:hover {
  border-color: rgba(102, 126, 234, 0.2);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.08);
}

.grading-row {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.grading-label {
  font-size: 12px;
  font-weight: 700;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.grading-input-group {
  display: flex;
  align-items: center;
  gap: 12px;
}

.score-input {
  width: 140px;
}

.score-input :deep(.el-input__wrapper) {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  border-color: rgba(102, 126, 234, 0.2);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 4px rgba(102, 126, 234, 0.04);
}

.score-input :deep(.el-input__wrapper:hover) {
  border-color: rgba(102, 126, 234, 0.35);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
}

.score-input :deep(.el-input__wrapper:focus-within) {
  border-color: rgba(102, 126, 234, 0.5);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.score-max {
  font-size: 13px;
  color: #6b7280;
  font-weight: 600;
  padding: 0 8px;
}

.comment-input {
  width: 100%;
}

.comment-input :deep(.el-textarea__wrapper) {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  border-color: rgba(102, 126, 234, 0.2);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 4px rgba(102, 126, 234, 0.04);
}

.comment-input :deep(.el-textarea__wrapper:hover) {
  border-color: rgba(102, 126, 234, 0.35);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
}

.comment-input :deep(.el-textarea__wrapper:focus-within) {
  border-color: rgba(102, 126, 234, 0.5);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.comment-input :deep(.el-textarea__inner) {
  font-size: 14px;
  line-height: 1.7;
  background: transparent;
}

/* ============ 操作按钮 ============ */
.action-buttons {
  display: flex;
  gap: 16px;
  justify-content: center;
  align-items: center;
  padding: 24px;
  border-top: 2px solid rgba(102, 126, 234, 0.1);
  background: linear-gradient(135deg, rgba(249, 250, 251, 0.95) 0%, rgba(240, 244, 255, 0.95) 100%);
  animation: slideInUp 0.6s ease-out 0.3s both;
  box-shadow: inset 0 2px 4px rgba(102, 126, 234, 0.04);
}

.action-buttons :deep(.el-button) {
  min-width: 140px;
  height: 42px;
  font-weight: 600;
  font-size: 14px;
  border-radius: 10px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

.action-buttons :deep(.el-button--primary) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.3);
  color: white;
}

.action-buttons :deep(.el-button--primary:hover) {
  transform: translateY(-3px);
  box-shadow: 0 10px 24px rgba(102, 126, 234, 0.4);
}

.action-buttons :deep(.el-button--primary:active) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
}

.nav-btn {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(250, 251, 255, 0.95) 100%);
  border: 2px solid rgba(102, 126, 234, 0.25);
  color: #667eea;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.08);
}

.action-buttons :deep(.nav-btn) {
  color: #667eea;
}

.action-buttons :deep(.nav-btn:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.08) 100%);
  border-color: rgba(102, 126, 234, 0.4);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.15);
}

.action-buttons :deep(.nav-btn:active) {
  transform: translateY(0);
}

.action-buttons :deep(.nav-btn:disabled) {
  background: rgba(249, 250, 251, 0.6);
  border-color: rgba(102, 126, 234, 0.1);
  color: #d1d5db;
  cursor: not-allowed;
  box-shadow: none;
}

.action-buttons :deep(.el-icon) {
  font-size: 16px;
}

/* ============ 快捷键提示 ============ */
.keyboard-shortcuts {
  margin-top: 16px;
  padding: 12px 16px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  border: 1px dashed rgba(102, 126, 234, 0.2);
  border-radius: 10px;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.shortcuts-title {
  font-size: 12px;
  font-weight: 600;
  color: #6b7280;
}

.shortcuts-list {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.shortcut-item {
  font-size: 12px;
  color: #6b7280;
  display: flex;
  align-items: center;
  gap: 4px;
}

.shortcut-item kbd {
  display: inline-block;
  padding: 2px 6px;
  font-size: 11px;
  font-weight: 600;
  line-height: 1;
  color: #667eea;
  background: white;
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(102, 126, 234, 0.1);
  font-family: 'Monaco', 'Consolas', monospace;
}

/* ============ 响应式设计 ============ */
@media (max-width: 1200px) {
  .grading-body {
    flex-direction: column;
  }

  .student-list-panel {
    width: 100%;
    max-height: 200px;
  }

  .student-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 8px;
  }

  .student-info-card {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .grading-header {
    height: 60px;
    padding: 0 16px;
  }

  .grading-title {
    font-size: 18px;
  }

  .header-stats {
    gap: 12px;
  }

  .stat-value {
    font-size: 16px;
  }

  .grading-body {
    padding: 16px;
    gap: 16px;
  }

  .student-info-card {
    grid-template-columns: 1fr;
  }

  .question-grading-card {
    padding: 16px;
  }

  .grading-section {
    padding: 12px;
  }

  .action-buttons {
    flex-wrap: wrap;
  }
}
</style>
