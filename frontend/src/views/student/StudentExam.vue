<template>
  <div class="student-exam-container" @contextmenu.prevent @copy.prevent @paste.prevent @cut.prevent>
    <!-- 考试须知弹窗 -->
    <el-dialog
      v-model="noticeVisible"
      title="考试须知"
      width="520px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      :show-close="false"
      center
    >
      <div class="notice-content">
        <el-alert type="warning" :closable="false" show-icon>
          <template #title>
            <span style="font-size: 16px; font-weight: bold;">请认真阅读以下考试纪律</span>
          </template>
        </el-alert>
        <div class="notice-list">
          <p>1. 考试期间请保持诚信，严禁作弊行为。</p>
          <p>2. 禁止使用任何通讯工具或查阅资料。</p>
          <p>3. 考试过程中请勿切换页面或离开考试界面，切屏超过3次将自动交卷。</p>
          <p>4. 禁止复制、粘贴、右键菜单等操作。</p>
          <p>5. 答题完成后请及时提交试卷。</p>
          <p>6. 如遇网络问题，系统会自动保存答案。</p>
          <p>7. 违反考试纪律者，成绩将作废处理。</p>
        </div>
        <div class="countdown-tip">
          <el-icon><Timer /></el-icon>
          <span>{{ noticeCountdown }} 秒后自动进入考试...</span>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" @click="startExamNow" :disabled="noticeCountdown > 0">
          {{ noticeCountdown > 0 ? `请等待 ${noticeCountdown} 秒` : '立即开始考试' }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 切屏警告弹窗 -->
    <el-dialog
      v-model="switchWarningVisible"
      title="警告"
      width="400px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      :show-close="false"
      center
    >
      <div class="warning-content">
        <el-icon class="warning-icon" color="#F56C6C" :size="60"><WarningFilled /></el-icon>
        <p class="warning-text">检测到您离开了考试页面！</p>
        <p class="warning-count">您已切屏 <span class="count-num">{{ switchCount }}</span> 次，超过 3 次将自动交卷</p>
      </div>
      <template #footer>
        <el-button type="primary" @click="switchWarningVisible = false">我知道了</el-button>
      </template>
    </el-dialog>

    <!-- 顶部导航栏 -->
    <div v-show="!noticeVisible" class="exam-header">
      <div class="header-left">
        <h1 class="title">
          <span class="title-text">{{ exam.title || '考试' }}</span>
        </h1>
        <el-tag type="success" effect="dark" class="status-tag">考试中</el-tag>
        <span class="user-name-left">{{ currentUserInfo?.realName || '学生' }}</span>
      </div>
      
      <div class="header-right">
        <div class="countdown-box" :class="{ 'urgent': timeLeftMs < 300000 }">
          <el-icon><Timer /></el-icon>
          <span class="countdown-label">剩余时间</span>
          <span class="countdown-value">{{ timeLeftText }}</span>
        </div>
        
        <transition name="fade" mode="out-in">
          <div v-if="saving" class="save-status saving">
            <el-icon class="is-loading"><Loading /></el-icon>
            <span>保存中</span>
          </div>
          <div v-else-if="lastSavedAt" class="save-status saved">
            <el-icon><Select /></el-icon>
            <span>已保存</span>
          </div>
        </transition>

        <el-tag v-if="switchCount > 0" type="danger" effect="dark" class="switch-tag">
          切屏: {{ switchCount }}/3
        </el-tag>

        <el-button plain @click="refreshPage" class="refresh-btn">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
        
        <el-button type="danger" @click="confirmSubmit" class="submit-btn">
          交卷
        </el-button>

        <!-- 用户头像下拉菜单 -->
        <el-dropdown @command="handleCommand">
          <div class="user-avatar">
            <el-avatar 
              :size="42" 
              :icon="currentUserInfo?.avatar ? undefined : UserFilled" 
              :src="getAvatarUrl(currentUserInfo?.avatar)"
              class="avatar-img" 
            />
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon><User /></el-icon>
                个人信息
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <el-card v-if="loading && !noticeVisible" class="loading-card" shadow="never">
      <el-icon class="is-loading"><Loading /></el-icon>
      正在加载试题...
    </el-card>

    <!-- 主体区域 -->
    <div v-show="!loading && !noticeVisible" class="exam-body">
      <!-- 左侧信息面板 -->
      <aside class="left-panel">
        <!-- 学生信息 -->
        <div class="student-info-card">
          <div class="info-row">
            <span class="info-label">姓名</span>
            <span class="info-value">{{ currentUserInfo?.realName || '学生' }}</span>
          </div>
          <div class="info-row">
            <span class="info-label">学号</span>
            <span class="info-value">{{ currentUserInfo?.studentNo || '-' }}</span>
          </div>
        </div>

        <!-- 答题进度 -->
        <div class="progress-card">
          <div class="progress-header">
            <span class="progress-label">答题进度</span>
            <span class="progress-value" :class="{ 'complete': answeredCount === questions.length }">
              {{ answeredCount }}/{{ questions.length }}
            </span>
          </div>
          <div class="progress-info">
            共 <strong>{{ questions.length }}</strong> 题；满分 <strong class="score-highlight">{{ totalScore }}</strong> 分
          </div>
        </div>

        <!-- 题目导航 -->
        <div class="nav-sections">
          <template v-for="section in groupedQuestions" :key="section.type">
            <div class="nav-section" v-if="section.items.length">
              <div class="nav-section-header">
                <el-icon><Minus /></el-icon>
                <span>{{ section.title }}</span>
              </div>
              <div class="nav-grid">
                <button
                  v-for="(q, idx) in section.items"
                  :key="q.id"
                  class="nav-item"
                  :class="{ 
                    'answered': isAnswered(answers[q.id], q.type),
                    'current': currentQuestion?.id === q.id,
                    'marked': markedQuestions.has(q.id)
                  }"
                  @click="goToQuestion(q.id)"
                >
                  {{ getGlobalIndex(q.id) }}
                </button>
              </div>
            </div>
          </template>
        </div>

        <!-- 图例 -->
        <div class="legend">
          <div class="legend-item">
            <span class="legend-dot answered"></span>
            <span>已答</span>
          </div>
          <div class="legend-item">
            <span class="legend-dot unanswered"></span>
            <span>未答</span>
          </div>
          <div class="legend-item">
            <span class="legend-dot marked"></span>
            <span>标记</span>
          </div>
        </div>
      </aside>

      <!-- 右侧答题区域 - 单题显示 -->
      <div class="right-panel">
        <!-- 当前题目的题型标题 -->
        <div class="section-header" v-if="currentQuestion">
          <span class="section-title">{{ currentSectionNumber }}、{{ currentSectionTitle }}</span>
          <span class="section-info">（共{{ currentSectionCount }}题；共{{ currentSectionScore }}分）</span>
        </div>
        
        <!-- 当前题目 -->
        <div class="question-card" v-if="currentQuestion">
          <div class="question-header">
            <span class="question-score">{{ currentQuestion.score }}分</span>
            <span class="question-number">{{ getGlobalIndex(currentQuestion.id) }}.</span>
            <span class="question-content">{{ currentQuestion.content }}</span>
          </div>
          
          <!-- 题目图片 -->
          <div v-if="currentQuestion.image" class="question-image">
            <el-image 
              :src="getImageUrl(currentQuestion.image)" 
              :preview-src-list="[getImageUrl(currentQuestion.image)]"
              fit="contain"
              class="q-image"
              :preview-teleported="true"
            />
          </div>

          <!-- 选项区域 -->
          <div class="question-options">
            <!-- 单选题 -->
            <template v-if="currentQuestion.type === 1">
              <div 
                v-for="(opt, key) in parseOptions(currentQuestion.options, currentQuestion.type)" 
                :key="key"
                class="option-item"
                :class="{ 'selected': answers[currentQuestion.id] === key }"
                @click="answers[currentQuestion.id] = key"
              >
                <span class="option-radio">
                  <span class="radio-inner" v-if="answers[currentQuestion.id] === key"></span>
                </span>
                <span class="option-label">{{ key }}.</span>
                <span class="option-text">{{ opt }}</span>
              </div>
            </template>

            <!-- 多选题 -->
            <template v-else-if="currentQuestion.type === 2">
              <div 
                v-for="(opt, key) in parseOptions(currentQuestion.options, currentQuestion.type)" 
                :key="key"
                class="option-item"
                :class="{ 'selected': answers[currentQuestion.id]?.includes(key) }"
                @click="toggleMultiAnswer(currentQuestion.id, key)"
              >
                <span class="option-checkbox">
                  <el-icon v-if="answers[currentQuestion.id]?.includes(key)"><Check /></el-icon>
                </span>
                <span class="option-label">{{ key }}.</span>
                <span class="option-text">{{ opt }}</span>
              </div>
            </template>

            <!-- 判断题 -->
            <template v-else-if="currentQuestion.type === 3">
              <div 
                v-for="(opt, key) in parseOptions(currentQuestion.options, currentQuestion.type)" 
                :key="key"
                class="option-item"
                :class="{ 'selected': answers[currentQuestion.id] === key }"
                @click="answers[currentQuestion.id] = key"
              >
                <span class="option-radio">
                  <span class="radio-inner" v-if="answers[currentQuestion.id] === key"></span>
                </span>
                <span class="option-label">{{ key }}.</span>
                <span class="option-text">{{ opt }}</span>
              </div>
            </template>

            <!-- 填空题 -->
            <template v-else-if="currentQuestion.type === 4">
              <div class="fill-blank-input">
                <el-input
                  v-model="answers[currentQuestion.id]"
                  type="textarea"
                  :rows="3"
                  placeholder="请输入填空答案..."
                  class="answer-textarea fill-blank"
                  maxlength="500"
                  show-word-limit
                />
              </div>
            </template>

            <!-- 简答题 -->
            <template v-else-if="currentQuestion.type === 5">
              <div class="essay-input">
                <div class="essay-mode-switch">
                  <el-radio-group v-model="essayMode" size="small">
                    <el-radio-button value="simple">简单模式</el-radio-button>
                    <el-radio-button value="formula">公式模式</el-radio-button>
                  </el-radio-group>
                  <span class="mode-tip">{{ essayMode === 'formula' ? '支持 LaTeX 公式编辑' : '普通文本输入' }}</span>
                </div>
                <!-- 简单模式 -->
                <template v-if="essayMode === 'simple'">
                  <div class="essay-toolbar">
                    <span class="toolbar-tip">💡 请认真作答，注意条理清晰</span>
                  </div>
                  <el-input
                    v-model="answers[currentQuestion.id]"
                    type="textarea"
                    :rows="10"
                    placeholder="请输入您的答案...&#10;&#10;建议：&#10;1. 先理清思路，分点作答&#10;2. 注意逻辑性和条理性&#10;3. 字迹工整，表达清晰"
                    class="answer-textarea essay"
                    maxlength="5000"
                    show-word-limit
                    resize="vertical"
                  />
                  <div class="essay-footer">
                    <span class="char-count">已输入 {{ (answers[currentQuestion.id] || '').length }} 字</span>
                  </div>
                </template>
                <!-- 公式模式 -->
                <FormulaEditor 
                  v-else
                  v-model="answers[currentQuestion.id]"
                  :rows="10"
                  placeholder="请输入您的答案...&#10;&#10;公式示例：&#10;行内公式：$x^2 + y^2 = z^2$&#10;独立公式：$$\frac{a}{b}$$"
                />
              </div>
            </template>
          </div>

          <!-- 标记按钮 -->
          <div class="question-footer">
            <button 
              class="mark-btn" 
              :class="{ 'marked': markedQuestions.has(currentQuestion.id) }"
              @click="toggleMark(currentQuestion.id)"
            >
              <el-icon><Star /></el-icon>
              {{ markedQuestions.has(currentQuestion.id) ? '取消标记' : '标记该题' }}
            </button>
          </div>
        </div>

        <!-- 底部导航 -->
        <div class="bottom-nav">
          <el-button 
            :disabled="currentIndex <= 0" 
            @click="goToPrev"
            class="nav-btn"
          >
            &lt; 上一题
          </el-button>
          <el-button 
            type="primary" 
            :disabled="currentIndex >= questions.length - 1" 
            @click="goToNext"
            class="nav-btn next-btn"
          >
            下一题 &gt;
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>


<script setup>
import { ref, reactive, onMounted, computed, onBeforeUnmount, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getImageUrl, getAvatarUrl } from '@/utils/file'
import { Loading, Timer, Select, WarningFilled, Minus, Star, Check, Refresh, UserFilled, User } from '@element-plus/icons-vue'
import request from '@/utils/request'
import FormulaEditor from '@/components/FormulaEditor.vue'

const route = useRoute()

// 简答题模式
const essayMode = ref('simple')
const router = useRouter()

const examId = ref(Number(route.params.id))
const exam = reactive({})

// 考试须知相关
const noticeVisible = ref(true)
const noticeCountdown = ref(5)
let noticeTimer = null

// 防作弊相关
const switchCount = ref(0)
const switchWarningVisible = ref(false)

// 标记的题目
const markedQuestions = ref(new Set())

// 当前题目索引
const currentIndex = ref(0)

const examRecord = ref(null)
const questions = ref([])
const answers = reactive({})
const lastSavedAt = ref(0)
const saving = ref(false)
const loading = ref(true)
const autosaveEnabled = ref(true)
const lastPayloadKey = ref('')

const countdownTimer = ref(null)
const timeLeftMs = ref(0)

let currentUserInfo = null
try {
  const stored = localStorage.getItem('userInfo')
  if (stored) currentUserInfo = JSON.parse(stored)
} catch (_) {}

// 当前题目
const currentQuestion = computed(() => {
  return questions.value[currentIndex.value] || null
})

// 获取题目全局序号
const getGlobalIndex = (qId) => {
  return questions.value.findIndex(q => q.id === qId) + 1
}

// 当前题型信息
const currentSectionTitle = computed(() => {
  const titles = { 1: '单选题', 2: '多选题', 3: '判断题', 4: '填空题', 5: '简答题' }
  return currentQuestion.value ? titles[currentQuestion.value.type] || '' : ''
})

const currentSectionNumber = computed(() => {
  if (!currentQuestion.value) return ''
  const numbers = ['一', '二', '三', '四', '五']
  const types = [...new Set(questions.value.map(q => q.type))]
  const idx = types.indexOf(currentQuestion.value.type)
  return numbers[idx] || ''
})

const currentSectionCount = computed(() => {
  if (!currentQuestion.value) return 0
  return questions.value.filter(q => q.type === currentQuestion.value.type).length
})

const currentSectionScore = computed(() => {
  if (!currentQuestion.value) return 0
  return questions.value
    .filter(q => q.type === currentQuestion.value.type)
    .reduce((sum, q) => sum + Number(q.score || 0), 0)
})

const isAnswered = (val, type) => {
  if (type === 2) return Array.isArray(val) && val.length > 0
  return val != null && String(val).trim() !== ''
}

const answeredCount = computed(() => {
  return questions.value.reduce((c, q) => c + (isAnswered(answers[q.id], q.type) ? 1 : 0), 0)
})

const parseOptions = (options, type) => {
  try {
    if (type === 3 && !options) return { T: '正确', F: '错误' }
    if (!options) return {}
    if (typeof options === 'string') return JSON.parse(options)
    return options
  } catch (e) { return {} }
}

const groupedQuestions = computed(() => {
  const order = [1,2,3,4,5]
  const titles = { 1: '单选题', 2: '多选题', 3: '判断题', 4: '填空题', 5: '简答题' }
  const groups = order.map(t => ({ type: t, title: titles[t], items: [], totalScore: 0 }))
  for (const q of questions.value) {
    const g = groups.find(x => x.type === q.type)
    if (g) g.items.push(q)
  }
  for (const g of groups) g.totalScore = g.items.reduce((s, q) => s + Number(q.score || 0), 0)
  return groups.filter(g => g.items.length)
})

const totalScore = computed(() => {
  if (exam.totalScore != null) return exam.totalScore
  return questions.value.reduce((s, q) => s + Number(q.score || 0), 0)
})

const timeLeftText = computed(() => {
  const sec = Math.max(0, Math.floor(timeLeftMs.value / 1000))
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  const s = sec % 60
  const pad = (n) => String(n).padStart(2, '0')
  return h > 0 ? `${pad(h)}:${pad(m)}:${pad(s)}` : `${pad(m)}:${pad(s)}`
})

// 切换多选答案
const toggleMultiAnswer = (qId, key) => {
  if (!Array.isArray(answers[qId])) {
    answers[qId] = []
  }
  const index = answers[qId].indexOf(key)
  if (index > -1) {
    answers[qId].splice(index, 1)
  } else {
    answers[qId].push(key)
    answers[qId].sort()
  }
}

// 标记题目
const toggleMark = (qId) => {
  if (markedQuestions.value.has(qId)) {
    markedQuestions.value.delete(qId)
  } else {
    markedQuestions.value.add(qId)
  }
}

// 跳转到指定题目
const goToQuestion = (qId) => {
  const idx = questions.value.findIndex(q => q.id === qId)
  if (idx >= 0) {
    currentIndex.value = idx
  }
}

// 上一题
const goToPrev = () => {
  if (currentIndex.value > 0) {
    currentIndex.value--
  }
}

// 下一题
const goToNext = () => {
  if (currentIndex.value < questions.value.length - 1) {
    currentIndex.value++
  }
}

// 刷新页面
const refreshPage = () => {
  window.location.reload()
}

const initCountdown = () => {
  let endMs = 0
  if (exam.endTime) endMs = new Date(exam.endTime).getTime()
  if (!endMs && exam.duration && examRecord.value && examRecord.value.startTime) {
    endMs = new Date(examRecord.value.startTime).getTime() + Number(exam.duration) * 60 * 1000
  }
  if (!endMs) return
  const tick = () => {
    timeLeftMs.value = endMs - Date.now()
    if (timeLeftMs.value <= 0) {
      clearInterval(countdownTimer.value)
      autoSubmit()
    }
  }
  tick()
  countdownTimer.value = setInterval(tick, 1000)
}

const autoSubmit = async () => {
  ElMessage.warning('时间到，已自动交卷')
  await submit()
}

const confirmSubmit = () => {
  ElMessageBox.confirm('确定要交卷吗？交卷后将无法修改答案。', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => submit())
}

const submit = async () => {
  if (!examRecord.value) return
  try {
    await saveAnswers(true)
    const res = await request.post('/examRecord/submit', null, { params: { examRecordId: examRecord.value.id } })
    if (res.code === 200) {
      ElMessage.success('交卷成功')
      if (exam.classId) router.push(`/student/class/${exam.classId}`)
      else router.push('/student/home')
    } else {
      ElMessage.error(res.msg || '交卷失败')
    }
  } catch (e) {
    ElMessage.error('网络错误，交卷失败')
  }
}

const loadData = async () => {
  loading.value = true
  try {
    const examRes = await request.get(`/exam/${examId.value}`)
    if (!examRes || !examRes.data) {
      ElMessage.error('考试不存在或已被删除')
      router.back(); return
    }
    Object.assign(exam, examRes.data)

    if (currentUserInfo && currentUserInfo.userId) {
      try {
        const startRes = await request.post('/examRecord/start', null, { params: { studentId: currentUserInfo.userId, examId: examId.value } })
        if (startRes && startRes.data) examRecord.value = startRes.data
      } catch (_) {}
    }

    try {
      const qRes = await request.get(`/exam/${examId.value}/questions`)
      if (qRes && qRes.data) {
        questions.value = qRes.data || []
        for (const q of questions.value) {
          answers[q.id] = q.type === 2 ? [] : ''
        }
      }
    } catch (_) { questions.value = [] }

    if (examRecord.value && examRecord.value.id) {
      try {
        const saved = await request.get(`/examRecord/${examRecord.value.id}/answers`)
        if (saved && saved.data && Array.isArray(saved.data)) {
          for (const item of saved.data) {
            if (!item) continue
            try {
              const raw = (item.userAnswer ?? item.answerValue)
              const parsed = JSON.parse(raw)
              answers[item.questionId] = parsed
            } catch (_) {
              answers[item.questionId] = (item.userAnswer ?? item.answerValue ?? '')
            }
          }
          const key = questions.value.map(q => {
            const raw = answers[q.id]
            const val = Array.isArray(raw) ? JSON.stringify(raw) : (raw != null ? String(raw) : '')
            return `${q.id}:${val}`
          }).join('|')
          lastPayloadKey.value = key
        }
      } catch (_) {}
    }
  } catch (e) {
    ElMessage.error('加载考试数据失败')
  } finally {
    loading.value = false
    initCountdown()
  }
}

const saveAnswers = async (force = false) => {
  if (!autosaveEnabled.value) return
  if (!examRecord.value || !examRecord.value.id) return
  if (saving.value) return
  const payload = { answers: [] }
  const key = questions.value.map(q => {
    const raw = answers[q.id]
    const val = Array.isArray(raw) ? JSON.stringify(raw) : (raw != null ? String(raw) : '')
    payload.answers.push({ questionId: q.id, answerValue: val })
    return `${q.id}:${val}`
  }).join('|')

  if (!force && key === lastPayloadKey.value) return

  saving.value = true
  try {
    await request.post(`/examRecord/${examRecord.value.id}/answers`, payload)
    lastSavedAt.value = Date.now()
    lastPayloadKey.value = key
  } catch (_) { }
  finally { saving.value = false }
}

const debouncedSave = (() => {
  let t
  return () => { clearTimeout(t); t = setTimeout(saveAnswers, 800) }
})()

watch(answers, () => { debouncedSave() }, { deep: true })

let autosaveTimer
onMounted(() => {
  autosaveTimer = setInterval(() => { saveAnswers() }, 30000)
})
onBeforeUnmount(() => { if (autosaveTimer) clearInterval(autosaveTimer) })

const startNoticeCountdown = () => {
  noticeTimer = setInterval(() => {
    if (noticeCountdown.value > 0) {
      noticeCountdown.value--
    } else {
      clearInterval(noticeTimer)
      startExamNow()
    }
  }, 1000)
}

const startExamNow = () => {
  if (noticeTimer) clearInterval(noticeTimer)
  noticeVisible.value = false
}

const handleVisibilityChange = () => {
  if (document.hidden && !noticeVisible.value) {
    switchCount.value++
    if (switchCount.value >= 3) {
      ElMessageBox.alert('您已切屏超过3次，系统将自动提交试卷！', '警告', {
        confirmButtonText: '确定',
        type: 'error',
        callback: () => { submit() }
      })
    } else {
      switchWarningVisible.value = true
      ElMessage.warning(`警告：检测到切屏行为！已切屏 ${switchCount.value} 次，超过3次将自动交卷`)
    }
  }
}

const handleKeydown = (e) => {
  if ((e.ctrlKey && ['c', 'v', 'x', 'a'].includes(e.key.toLowerCase())) || e.key === 'F12') {
    e.preventDefault()
    ElMessage.warning('考试期间禁止使用此快捷键')
  }
}

onMounted(() => {
  startNoticeCountdown()
  document.addEventListener('visibilitychange', handleVisibilityChange)
  document.addEventListener('keydown', handleKeydown)
})

// 处理用户菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      ElMessage.info('考试期间无法查看个人信息')
      break
  }
}

onMounted(loadData)

onBeforeUnmount(() => { 
  if (countdownTimer.value) clearInterval(countdownTimer.value)
  if (noticeTimer) clearInterval(noticeTimer)
  document.removeEventListener('visibilitychange', handleVisibilityChange)
  document.removeEventListener('keydown', handleKeydown)
})
</script>


<style scoped>
.student-exam-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7ff 0%, #faf5ff 50%, #fff8fc 100%);
  position: relative;
}

.student-exam-container::before {
  content: '';
  position: fixed;
  top: -40%;
  right: -5%;
  width: 700px;
  height: 700px;
  background: radial-gradient(circle, rgba(139, 92, 246, 0.05) 0%, transparent 60%);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

.student-exam-container::after {
  content: '';
  position: fixed;
  bottom: -25%;
  left: -8%;
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(168, 85, 247, 0.04) 0%, transparent 60%);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

/* 顶部导航栏 - 与其他界面统一 */
.exam-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  backdrop-filter: blur(16px);
  padding: 0 40px;
  height: 68px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 2px solid rgba(102, 126, 234, 0.08);
}

.exam-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, #8b5cf6 0%, #a855f7 50%, #8b5cf6 100%);
  opacity: 0.6;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.title {
  font-size: 26px;
  font-weight: 700;
  margin: 0;
  letter-spacing: 0.5px;
}

.title-text {
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 2px 8px rgba(139, 92, 246, 0.1);
}

.status-tag {
  font-weight: 600;
  padding: 6px 12px;
  border-radius: 8px;
}

.user-name-left {
  font-size: 16px;
  color: #6a7a8a;
  margin: 0;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.countdown-box {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.08) 0%, rgba(168, 85, 247, 0.08) 100%);
  border: 2px solid rgba(139, 92, 246, 0.2);
  border-radius: 12px;
  color: #7c3aed;
  font-weight: 600;
}

.countdown-label {
  font-size: 13px;
  color: #8b5cf6;
  font-weight: 500;
}

.countdown-value {
  font-size: 18px;
  font-weight: 700;
  color: #7c3aed;
}

.countdown-box.urgent {
  background: linear-gradient(135deg, rgba(244, 67, 54, 0.1) 0%, rgba(244, 67, 54, 0.15) 100%);
  border-color: rgba(244, 67, 54, 0.3);
  color: #f44336;
  animation: pulse 1s infinite;
}

.countdown-box.urgent .countdown-label,
.countdown-box.urgent .countdown-value {
  color: #f44336;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.save-status {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #7c3aed;
}

.switch-tag {
  font-weight: 600;
}

.refresh-btn {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.08) 0%, rgba(168, 85, 247, 0.08) 100%);
  border: 2px solid rgba(139, 92, 246, 0.2);
  color: #7c3aed;
  border-radius: 12px;
  padding: 11px 20px;
  font-weight: 600;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.refresh-btn:hover {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.15) 0%, rgba(168, 85, 247, 0.15) 100%);
  border-color: rgba(139, 92, 246, 0.35);
  transform: translateY(-2px);
}

.submit-btn {
  font-weight: 600;
  padding: 11px 24px;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(245, 108, 108, 0.25);
}

.submit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(245, 108, 108, 0.35);
}

/* 用户头像下拉菜单 */
.user-avatar {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  padding: 6px 14px;
  border-radius: 12px;
  transition: all 0.3s;
}

.user-avatar:hover {
  background: rgba(139, 92, 246, 0.08);
}

.avatar-img {
  transition: transform 0.3s;
}

.user-avatar:hover .avatar-img {
  transform: scale(1.05);
}

/* 下拉菜单美化 */
:deep(.el-dropdown-menu) {
  border-radius: 12px;
  padding: 8px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(139, 92, 246, 0.06);
}

:deep(.el-dropdown-menu__item) {
  border-radius: 8px;
  padding: 10px 16px;
  transition: all 0.3s ease;
  font-size: 14px;
}

:deep(.el-dropdown-menu__item:hover) {
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.08) 0%, rgba(168, 85, 247, 0.05) 100%);
  color: #8b5cf6;
}

/* 主体区域 */
.exam-body {
  display: flex;
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
  padding-top: 88px;
  gap: 20px;
}

/* 左侧面板 */
.left-panel {
  width: 280px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
  position: sticky;
  top: 88px;
  max-height: calc(100vh - 108px);
  overflow-y: auto;
}

.student-info-card {
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 12px;
  padding: 18px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
}

.student-info-card:hover {
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.12);
  transform: translateY(-2px);
}

.info-row {
  display: flex;
  margin-bottom: 12px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-label {
  width: 50px;
  color: #666;
  font-size: 14px;
}

.info-value {
  flex: 1;
  font-weight: 600;
  color: #333;
  font-size: 14px;
}

.progress-card {
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 12px;
  padding: 18px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
}

.progress-card:hover {
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.12);
  transform: translateY(-2px);
}

.progress-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.progress-label {
  font-size: 14px;
  color: #666;
}

.progress-value {
  font-size: 16px;
  font-weight: 700;
  color: #7c3aed;
}

.progress-value.complete {
  color: #4caf50;
}

.progress-info {
  font-size: 13px;
  color: #888;
}

.score-highlight {
  color: #f5222d;
}

/* 题目导航 */
.nav-sections {
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 12px;
  padding: 14px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.08);
}

.nav-section {
  margin-bottom: 12px;
}

.nav-section:last-child {
  margin-bottom: 0;
}

.nav-section-header {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #666;
  margin-bottom: 8px;
  padding-bottom: 6px;
  border-bottom: 1px solid #f0f0f0;
}

.nav-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
}

.nav-item {
  width: 38px;
  height: 38px;
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 10px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  cursor: pointer;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 6px rgba(102, 126, 234, 0.06);
}

.nav-item:hover {
  border-color: #8b5cf6;
  color: #7c3aed;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.15);
}

.nav-item.answered {
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  border-color: transparent;
  color: #fff;
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.35);
}

.nav-item.current {
  border-color: #8b5cf6;
  box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.2), 0 4px 12px rgba(139, 92, 246, 0.15);
  transform: scale(1.05);
}

.nav-item.marked {
  position: relative;
}

.nav-item.marked::after {
  content: '★';
  position: absolute;
  top: -4px;
  right: -4px;
  font-size: 10px;
  color: #ff9800;
}

/* 图例 */
.legend {
  display: flex;
  justify-content: center;
  gap: 8px;
  padding: 12px 14px;
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.08);
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #6b7280;
  font-weight: 500;
  padding: 6px 12px;
  background: rgba(102, 126, 234, 0.04);
  border-radius: 8px;
  transition: all 0.2s ease;
}

.legend-item:hover {
  background: rgba(102, 126, 234, 0.08);
}

.legend-dot {
  width: 20px;
  height: 20px;
  border-radius: 6px;
  border: 2px solid rgba(102, 126, 234, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
}

.legend-dot.answered {
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  border-color: transparent;
  box-shadow: 0 2px 6px rgba(139, 92, 246, 0.35);
}

.legend-dot.unanswered {
  background: #fff;
  border-color: rgba(102, 126, 234, 0.2);
}

.legend-dot.marked {
  background: linear-gradient(135deg, #fff8e1 0%, #ffecb3 100%);
  border-color: rgba(255, 152, 0, 0.3);
  position: relative;
}

.legend-dot.marked::after {
  content: '★';
  font-size: 10px;
  color: #ff9800;
}

/* 右侧答题区域 */
.right-panel {
  flex: 1;
  min-width: 0;
}

.section-header {
  padding: 14px 20px;
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  border-radius: 14px 14px 0 0;
  margin-bottom: 0;
  box-shadow: 0 4px 16px rgba(139, 92, 246, 0.25);
}

.section-title {
  font-size: 16px;
  font-weight: 700;
  color: #fff;
}

.section-info {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.85);
  margin-left: 8px;
}

.question-card {
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  padding: 28px;
  border-radius: 0 0 14px 14px;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.1);
  border: 1px solid rgba(102, 126, 234, 0.08);
  border-top: none;
  min-height: 420px;
  position: relative;
  z-index: 1;
}

.question-header {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.08);
  line-height: 1.7;
}

.question-score {
  flex-shrink: 0;
  padding: 4px 12px;
  background: linear-gradient(135deg, #fff3e0 0%, #ffe0b2 100%);
  color: #e65100;
  font-size: 13px;
  font-weight: 700;
  border-radius: 8px;
  border: 1px solid rgba(230, 81, 0, 0.15);
  box-shadow: 0 2px 8px rgba(230, 81, 0, 0.1);
}

.question-number {
  flex-shrink: 0;
  font-weight: 700;
  font-size: 16px;
  color: #7c3aed;
}

.question-content {
  flex: 1;
  color: #1f2937;
  font-size: 16px;
  font-weight: 500;
}

.question-image {
  margin: 24px 0;
  padding: 20px;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 12px;
  border: 2px solid rgba(102, 126, 234, 0.1);
  text-align: center;
  transition: all 0.3s ease;
}

.question-image:hover {
  border-color: rgba(102, 126, 234, 0.2);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.1);
}

.q-image {
  max-width: 100%;
  max-height: 350px;
  border-radius: 8px;
  cursor: pointer;
  transition: transform 0.3s ease;
}

.q-image:hover {
  transform: scale(1.02);
}

/* 选项样式 */
.question-options {
  margin-top: 20px;
}

.option-item {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 16px 20px;
  margin-bottom: 14px;
  border: 2px solid rgba(102, 126, 234, 0.12);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.04);
}

.option-item:hover {
  border-color: rgba(139, 92, 246, 0.35);
  background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 100%);
  transform: translateX(4px);
  box-shadow: 0 4px 16px rgba(139, 92, 246, 0.12);
}

.option-item.selected {
  border-color: #8b5cf6;
  background: linear-gradient(135deg, #f3e8ff 0%, #ede9fe 100%);
  box-shadow: 0 4px 16px rgba(139, 92, 246, 0.2);
}

.option-radio {
  width: 22px;
  height: 22px;
  border: 2px solid #bdbdbd;
  border-radius: 50%;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 1px;
  transition: all 0.25s ease;
}

.option-item:hover .option-radio {
  border-color: #8b5cf6;
}

.option-item.selected .option-radio {
  border-color: #8b5cf6;
  background: rgba(139, 92, 246, 0.1);
}

.radio-inner {
  width: 12px;
  height: 12px;
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  border-radius: 50%;
  box-shadow: 0 2px 6px rgba(139, 92, 246, 0.4);
}

.option-checkbox {
  width: 22px;
  height: 22px;
  border: 2px solid #bdbdbd;
  border-radius: 6px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 1px;
  font-size: 14px;
  color: #fff;
  transition: all 0.25s ease;
}

.option-item:hover .option-checkbox {
  border-color: #8b5cf6;
}

.option-item.selected .option-checkbox {
  border-color: #8b5cf6;
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  box-shadow: 0 2px 6px rgba(139, 92, 246, 0.4);
}

.option-label {
  font-weight: 600;
  color: #7c3aed;
  flex-shrink: 0;
  font-size: 15px;
}

.option-text {
  flex: 1;
  color: #374151;
  line-height: 1.6;
  font-size: 15px;
}

.answer-textarea :deep(.el-textarea__inner) {
  border-radius: 12px;
  padding: 16px;
  font-size: 15px;
  line-height: 1.7;
  border: 2px solid rgba(102, 126, 234, 0.12);
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  transition: all 0.3s ease;
}

.answer-textarea :deep(.el-textarea__inner:hover) {
  border-color: rgba(139, 92, 246, 0.3);
}

.answer-textarea :deep(.el-textarea__inner:focus) {
  border-color: #8b5cf6;
  box-shadow: 0 4px 16px rgba(139, 92, 246, 0.15);
}

/* 填空题输入框 */
.fill-blank-input {
  margin-top: 8px;
}

.answer-textarea.fill-blank :deep(.el-textarea__inner) {
  min-height: 80px;
}

/* 简答题输入框 */
.essay-input {
  margin-top: 8px;
}

.essay-mode-switch {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  padding: 12px 16px;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.05) 0%, rgba(102, 126, 234, 0.05) 100%);
  border-radius: 10px;
  border: 1px solid rgba(139, 92, 246, 0.1);
}

.mode-tip {
  font-size: 12px;
  color: #666;
}

.essay-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
  padding: 10px 14px;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.08) 0%, rgba(102, 126, 234, 0.08) 100%);
  border-radius: 10px;
}

.toolbar-tip {
  font-size: 13px;
  color: #8b5cf6;
}

.answer-textarea.essay :deep(.el-textarea__inner) {
  min-height: 200px;
  font-size: 15px;
  line-height: 1.8;
}

.essay-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 8px;
}

.char-count {
  font-size: 12px;
  color: #999;
}

/* 标记按钮 */
.question-footer {
  margin-top: 28px;
  padding-top: 20px;
  border-top: 2px solid rgba(102, 126, 234, 0.08);
}

.mark-btn {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: 2px solid rgba(255, 152, 0, 0.2);
  border-radius: 10px;
  background: linear-gradient(135deg, #fff8e1 0%, #ffecb3 100%);
  color: #f57c00;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.mark-btn:hover {
  border-color: #ff9800;
  color: #ff9800;
}

.mark-btn.marked {
  border-color: #ff9800;
  background: #fff3e0;
  color: #e65100;
}

/* 底部导航 */
.bottom-nav {
  display: flex;
  justify-content: center;
  gap: 20px;
  padding: 24px;
  margin-top: 24px;
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 14px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.08);
}

.nav-btn {
  min-width: 140px;
  height: 44px;
  font-size: 15px;
  font-weight: 600;
  border-radius: 10px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.nav-btn:not(:disabled):hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.2);
}

.next-btn {
  background: linear-gradient(135deg, #8b5cf6 0%, #a855f7 100%);
  border-color: transparent;
  box-shadow: 0 4px 12px rgba(139, 92, 246, 0.35);
}

.next-btn:hover:not(:disabled) {
  background: linear-gradient(135deg, #7c3aed 0%, #9333ea 100%);
  box-shadow: 0 6px 20px rgba(139, 92, 246, 0.45);
}

/* 加载状态 */
.loading-card {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
  padding: 80px;
  margin: 24px auto;
  margin-top: 100px;
  max-width: 600px;
  color: #7c3aed;
  font-size: 17px;
  font-weight: 500;
  background: linear-gradient(135deg, #ffffff 0%, #faf5ff 100%);
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(139, 92, 246, 0.1);
  border: 1px solid rgba(139, 92, 246, 0.08);
}

/* 考试须知弹窗 */
.notice-content {
  padding: 10px 0;
}

.notice-list {
  margin: 20px 0;
  padding: 15px 20px;
  background: #fdf6ec;
  border-radius: 8px;
}

.notice-list p {
  margin: 10px 0;
  color: #606266;
  font-size: 14px;
  line-height: 1.8;
}

.countdown-tip {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 20px;
  color: #E6A23C;
  font-size: 16px;
  font-weight: bold;
}

/* 切屏警告弹窗 */
.warning-content {
  text-align: center;
  padding: 20px 0;
}

.warning-icon {
  margin-bottom: 15px;
}

.warning-text {
  font-size: 18px;
  color: #303133;
  margin-bottom: 10px;
}

.warning-count {
  color: #606266;
  font-size: 14px;
}

.count-num {
  color: #F56C6C;
  font-size: 24px;
  font-weight: bold;
  margin: 0 5px;
}

/* 响应式 */
@media (max-width: 960px) {
  .exam-body {
    flex-direction: column;
    padding: 16px;
  }

  .left-panel {
    width: 100%;
    position: static;
    max-height: none;
  }

  .nav-sections {
    max-height: 200px;
    overflow-y: auto;
  }

  .exam-header {
    flex-wrap: wrap;
    gap: 12px;
  }

  .header-left {
    width: 100%;
    justify-content: center;
  }

  .header-right {
    width: 100%;
    justify-content: center;
    flex-wrap: wrap;
  }

  .question-card {
    min-height: auto;
  }
}
</style>
