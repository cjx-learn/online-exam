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

    <div v-show="!noticeVisible" class="exam-header">
      <div class="header-left">
        <div class="exam-info">
          <h1 class="exam-title">{{ exam.title || '考试' }}</h1>
          <div class="exam-meta">
            <span class="meta-item">
              <el-icon><Timer /></el-icon>
              {{ exam.duration ? exam.duration + ' 分钟' : '-' }}
            </span>
            <span class="meta-item">
              <el-icon><Trophy /></el-icon>
              总分 {{ totalScore }}
            </span>
          </div>
        </div>
      </div>
      
      <div class="header-center">
        <div class="countdown-box" :class="{ 'urgent': timeLeftMs < 300000 }">
          <span class="countdown-label">剩余时间</span>
          <span class="countdown-value">{{ timeLeftText }}</span>
        </div>
      </div>

      <div class="header-right">
        <div class="status-area">
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
        </div>

        <div class="switch-count-tag" v-if="switchCount > 0">
          <el-tag type="danger" effect="dark">切屏: {{ switchCount }}/3</el-tag>
        </div>

        <div class="action-buttons">
          <el-button class="nav-btn-mobile" plain @click="navVisible = true">
            <el-icon><Grid /></el-icon>
            题目
          </el-button>
          <el-button type="danger" @click="confirmSubmit" class="submit-btn">
            <el-icon><Checked /></el-icon>
            交卷
          </el-button>
        </div>
      </div>
    </div>

    <el-progress
      v-if="questions.length && !noticeVisible"
      class="progress-bar"
      :percentage="progressPercent"
      :stroke-width="6"
      :format="p => `进度 ${answeredCount}/${questions.length}`"
      status="success"
    />

    <el-card v-if="loading && !noticeVisible" class="loading-card" shadow="never">
      <el-icon class="is-loading"><Loading /></el-icon>
      正在加载试题...
    </el-card>

    <div v-show="!loading && !noticeVisible" class="exam-body">
      <aside class="q-nav">
        <div class="nav-header">
          <span>题目导航</span>
          <span class="nav-progress">{{ answeredCount }}/{{ questions.length }}</span>
        </div>
        <div class="nav-grid">
          <button
            v-for="(item, i) in navList"
            :key="item.id"
            class="nav-item"
            :class="{ done: isAnswered(answers[item.id], item.type) }"
            @click="scrollToQuestion(item.id)"
          >{{ i + 1 }}</button>
        </div>
      </aside>

      <el-card class="paper-card" shadow="never">
        <template v-for="section in groupedQuestions" :key="section.type">
          <div class="section">
            <div class="section-header">
              <h3>{{ section.title }}（共 {{ section.items.length }} 题，{{ section.totalScore }} 分）</h3>
            </div>
            <div class="question" :id="'q-' + q.id" v-for="(q, idx) in section.items" :key="q.id">
              <div class="q-header">
                <span class="q-no">{{ indexMap[q.id] }}.</span>
                <span class="q-content" v-text="q.content" />
                <el-tag class="q-score" type="info">{{ q.score ?? '-' }} 分</el-tag>
              </div>
              <div class="q-body">
                <template v-if="[1,2,3].includes(q.type)">
                  <el-radio-group v-if="q.type===1 || q.type===3" v-model="answers[q.id]" class="q-options">
                    <el-radio border class="option-item" v-for="(opt, key) in parseOptions(q.options, q.type)" :key="key" :label="key">
                      {{ key }}. {{ opt }}
                    </el-radio>
                  </el-radio-group>
                  <el-checkbox-group v-else v-model="answers[q.id]" class="q-options">
                    <el-checkbox border class="option-item" v-for="(opt, key) in parseOptions(q.options, q.type)" :key="key" :label="key">
                      {{ key }}. {{ opt }}
                    </el-checkbox>
                  </el-checkbox-group>
                </template>

                <template v-else>
                  <el-input
                    v-model="answers[q.id]"
                    type="textarea"
                    :rows="4"
                    placeholder="在此作答..."
                    class="answer-textarea"
                  />
                </template>
              </div>
              <el-divider />
            </div>
          </div>
        </template>
        <div v-if="!questions.length" class="empty">暂无试题</div>
      </el-card>
    </div>

    <el-drawer v-model="navVisible" direction="ltr" size="260px" class="nav-drawer">
      <div class="nav-header">
        <span>题目导航</span>
        <span class="nav-progress">{{ answeredCount }}/{{ questions.length }}</span>
      </div>
      <div class="nav-grid">
        <button
          v-for="(item, i) in navList"
          :key="item.id"
          class="nav-item"
          :class="{ done: isAnswered(answers[item.id], item.type) }"
          @click="scrollToQuestion(item.id)"
        >{{ i + 1 }}</button>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onBeforeUnmount, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Loading, Timer, Trophy, Select, Grid, Checked, WarningFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()
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

const isAnswered = (val, type) => {
  if (type === 2) return Array.isArray(val) && val.length > 0
  return val != null && String(val).trim() !== ''
}

const answeredCount = computed(() => {
  return questions.value.reduce((c, q) => c + (isAnswered(answers[q.id], q.type) ? 1 : 0), 0)
})

const progressPercent = computed(() => {
  const total = questions.value.length
  return total ? Math.round((answeredCount.value * 100) / total) : 0
})

// 题目导航
const navVisible = ref(false)
const navList = computed(() => questions.value.map(q => ({ id: q.id, type: q.type })))
const indexMap = computed(() => {
  const map = {}
  questions.value.forEach((q, i) => { map[q.id] = i + 1 })
  return map
})
const scrollToQuestion = (id) => {
  navVisible.value = false
  // 延迟以确保抽屉关闭不影响滚动
  setTimeout(() => {
    const el = document.getElementById('q-' + id)
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }, 10)
}
const examRecord = ref(null)
const questions = ref([])
const answers = reactive({})
const lastSavedAt = ref(0)
const saving = ref(false)
const loading = ref(true)
const autosaveEnabled = ref(true)
const lastPayloadKey = ref('')
const errorNotified = ref(false)

const countdownTimer = ref(null)
const timeLeftMs = ref(0)

let currentUserInfo = null
try {
  const stored = localStorage.getItem('userInfo')
  if (stored) currentUserInfo = JSON.parse(stored)
} catch (_) {}

const parseOptions = (options, type) => {
  try {
    if (type === 3 && !options) return { A: '正确', B: '错误' }
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
    // 先保存当前答案（强制保存）
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
    // 1) 加载考试
    const examRes = await request.get(`/exam/${examId.value}`)
    if (!examRes || !examRes.data) {
      ElMessage.error('考试不存在或已被删除')
      router.back(); return
    }
    Object.assign(exam, examRes.data)

    // 2) 开始考试（或恢复未完成记录）
    if (currentUserInfo && currentUserInfo.userId) {
      try {
        const startRes = await request.post('/examRecord/start', null, { params: { studentId: currentUserInfo.userId, examId: examId.value } })
        if (startRes && startRes.data) examRecord.value = startRes.data
      } catch (_) {}
    }

    // 3) 加载题目
    try {
      const qRes = await request.get(`/exam/${examId.value}/questions`)
      if (qRes && qRes.data) {
        questions.value = qRes.data || []
        for (const q of questions.value) {
          answers[q.id] = q.type === 2 ? [] : ''
        }
      }
    } catch (_) { questions.value = [] }

    // 4) 若存在记录，加载已保存答案
    if (examRecord.value && examRecord.value.id) {
      try {
        const saved = await request.get(`/examRecord/${examRecord.value.id}/answers`)
        if (saved && saved.data && Array.isArray(saved.data)) {
          for (const item of saved.data) {
            if (!item) continue
            // 多选存的是 JSON 字符串
            try {
              const raw = (item.userAnswer ?? item.answerValue)
              const parsed = JSON.parse(raw)
              answers[item.questionId] = parsed
            } catch (_) {
              answers[item.questionId] = (item.userAnswer ?? item.answerValue ?? '')
            }
          }
          // 记录初始payload签名，避免首次就触发冗余保存
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

// API: 批量保存答案
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

  // 若无变化，且非强制保存，则跳过
  if (!force && key === lastPayloadKey.value) return

  saving.value = true
  try {
    await request.post(`/examRecord/${examRecord.value.id}/answers`, payload)
    lastSavedAt.value = Date.now()
    lastPayloadKey.value = key
  } catch (_) { /* ignore */ }
  finally { saving.value = false }
}

// 保存失败的容错（例如后端未部署新接口时）
watch(saving, async (v, ov) => {
  // 无法在此获知错误类型，改为在 request 拦截器之外做一次试探
})

// 包裹一层：发生 404 时停用自动保存，避免刷屏
const _origPost = request.post
request.post = async (url, data, config) => {
  try {
    return await _origPost(url, data, config)
  } catch (e) {
    const status = e?.response?.status
    if (status === 404 && String(url || '').includes('/examRecord/') && String(url || '').includes('/answers')) {
      autosaveEnabled.value = false
      if (!errorNotified.value) {
        errorNotified.value = true
        ElMessage.error('自动保存接口不可用（404）。请确认后端已重启并提供 /examRecord/{id}/answers 接口。')
      }
      if (autosaveTimer) { clearInterval(autosaveTimer); autosaveTimer = null }
    }
    throw e
  }
}

// 定时保存 + 防抖保存
let autosaveTimer
const debouncedSave = (() => {
  let t
  return () => { clearTimeout(t); t = setTimeout(saveAnswers, 800) }
})()

// 监听答案变化，触发防抖保存
watch(answers, () => { debouncedSave() }, { deep: true })

onMounted(() => {
  autosaveTimer = setInterval(() => { saveAnswers() }, 30000) // 每30秒自动保存
})
onBeforeUnmount(() => { if (autosaveTimer) clearInterval(autosaveTimer) })

// 考试须知倒计时
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

// 立即开始考试
const startExamNow = () => {
  if (noticeTimer) {
    clearInterval(noticeTimer)
  }
  noticeVisible.value = false
}

// 防作弊：监听切屏
const handleVisibilityChange = () => {
  if (document.hidden && !noticeVisible.value) {
    switchCount.value++
    if (switchCount.value >= 3) {
      ElMessageBox.alert('您已切屏超过3次，系统将自动提交试卷！', '警告', {
        confirmButtonText: '确定',
        type: 'error',
        callback: () => {
          submit()
        }
      })
    } else {
      switchWarningVisible.value = true
      ElMessage.warning(`警告：检测到切屏行为！已切屏 ${switchCount.value} 次，超过3次将自动交卷`)
    }
  }
}

// 防作弊：禁用快捷键
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
  margin: 0 auto; 
  padding: 24px 0; 
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%);
  min-height: 100vh;
}

.exam-header { 
  display: grid; 
  grid-template-columns: 1fr auto 1fr; 
  align-items: center; 
  gap: 16px; 
  margin: 0 auto 20px;
  max-width: 1360px;
  padding: 20px 24px 20px calc(24px + 260px);
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  backdrop-filter: blur(16px) saturate(180%);
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.2);
  position: relative;
  overflow: hidden;
}

.exam-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 50%, transparent 100%);
  pointer-events: none;
}

.exam-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, rgba(255,255,255,0.6) 0%, rgba(255,255,255,0.8) 50%, rgba(255,255,255,0.6) 100%);
  opacity: 0.7;
  transition: opacity 0.3s ease;
}

.exam-title { 
  margin: 0; 
  text-align: center; 
  font-size: 26px; 
  font-weight: 800; 
  color: #ffffff;
  letter-spacing: 0.5px;
  text-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.meta-left { 
  display: flex; 
  gap: 20px; 
  font-size: 14px;
  color: rgba(255,255,255,0.95);
  font-weight: 500;
}

.meta-left span {
  display: flex;
  align-items: center;
  gap: 6px;
}

.meta-left span::before {
  content: '';
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: rgba(255,255,255,0.8);
}

.meta-right { 
  display: flex; 
  justify-content: flex-end; 
  align-items: center; 
  gap: 12px; 
}

.countdown-tag { 
  font-weight: 700;
  font-size: 15px;
  padding: 8px 16px;
  background: rgba(255,255,255,0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,0.3);
  color: #fff;
}

.submit-btn { 
  min-width: 100px;
  height: 38px;
  font-weight: 600;
  background: #fff;
  color: #dc2626;
  border: 2px solid rgba(255,255,255,0.3);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.submit-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(220, 38, 38, 0.3);
  background: #fee;
}

.save-tag { 
  height: 28px; 
  display: inline-flex; 
  align-items: center;
  padding: 0 12px;
  background: rgba(255,255,255,0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,0.3);
  color: #fff;
  font-weight: 500;
}

.progress-bar { 
  margin: 0 auto 20px;
  max-width: 1360px;
  padding-left: 260px;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}

.progress-bar :deep(.el-progress-bar__outer) {
  background: rgba(102, 126, 234, 0.1);
  border-radius: 10px;
  overflow: hidden;
}

.progress-bar :deep(.el-progress-bar__inner) {
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  position: relative;
}

.progress-bar :deep(.el-progress-bar__inner)::after {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { left: -100%; }
  50% { left: 100%; }
  100% { left: 100%; }
}

.exam-body { 
  display: flex;
  justify-content: flex-start;
  gap: 20px;
  align-items: flex-start;
  max-width: 1360px;
  margin: 0 auto;
}

.q-nav { 
  position: sticky; 
  top: 20px; 
  width: 240px;
  flex-shrink: 0;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  border: 1px solid rgba(102, 126, 234, 0.15);
  border-radius: 16px; 
  padding: 16px; 
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.1);
  transition: all 0.3s ease;
}

.q-nav:hover {
  box-shadow: 0 8px 30px rgba(102, 126, 234, 0.15);
}

.nav-header { 
  display: flex; 
  justify-content: space-between; 
  align-items: center; 
  font-weight: 700;
  font-size: 15px;
  margin-bottom: 14px;
  padding-bottom: 12px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.1);
  color: #374151;
}

.nav-progress { 
  color: #667eea;
  font-weight: 600;
  font-size: 14px;
}

.nav-grid { 
  display: grid; 
  grid-template-columns: repeat(5, 1fr); 
  gap: 10px; 
}

.nav-item { 
  height: 40px; 
  border-radius: 10px; 
  border: 2px solid rgba(102, 126, 234, 0.1);
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  cursor: pointer; 
  font-weight: 700;
  font-size: 14px;
  color: #6b7280;
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.06);
}

.nav-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  opacity: 0;
  transition: opacity 0.25s ease;
}

.nav-item:hover::before {
  opacity: 1;
}

.nav-item:hover { 
  transform: translateY(-2px); 
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
  border-color: #667eea;
  color: #667eea;
}

.nav-item.done { 
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  border-color: #22c55e;
  color: #ffffff;
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.35);
  position: relative;
}

.nav-item.done::before {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.2) 0%, rgba(255, 255, 255, 0.1) 100%);
  opacity: 1;
}

.nav-item.done::after {
  content: '✓';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 10px;
  font-weight: 900;
  color: rgba(255, 255, 255, 0.8);
  opacity: 0;
  transition: opacity 0.2s ease;
}

.nav-item.done:hover::after {
  opacity: 1;
}

.nav-item.done:hover {
  transform: translateY(-2px) scale(1.05);
  box-shadow: 0 4px 16px rgba(16, 185, 129, 0.4);
}

.nav-btn-mobile { 
  display: none; 
  background: rgba(255,255,255,0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,0.3);
  color: #fff;
  font-weight: 600;
}

.loading-card { 
  display: flex; 
  align-items: center; 
  gap: 12px; 
  color: #667eea;
  font-size: 16px;
  padding: 40px;
  background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.1);
  max-width: 1360px;
  margin: 0 auto;
}

.paper-card { 
  padding: 0;
  border-radius: 16px;
  background: transparent;
  border: none;
  box-shadow: none;
  max-width: 1100px;
  width: 100%;
}

.section { 
  margin-bottom: 24px;
  animation: fadeInUp 0.5s ease-out;
}

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

.section-header { 
  position: sticky; 
  top: 0; 
  z-index: 5; 
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 14px 20px;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.25);
  margin-bottom: 16px;
  backdrop-filter: blur(10px);
}

.section-header h3 { 
  margin: 0; 
  font-size: 17px; 
  font-weight: 700;
  color: #ffffff;
  letter-spacing: 0.3px;
}

.question { 
  margin: 0 0 16px;
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
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.2);
  transform: translateY(-3px);
}

.question:hover::before {
  opacity: 1;
}

.q-header { 
  display: flex; 
  align-items: flex-start;
  gap: 12px; 
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.08);
}

.q-no { 
  font-weight: 800;
  color: #667eea;
  font-size: 16px;
  min-width: 28px;
}

.q-content { 
  flex: 1; 
  color: #1f2937;
  font-size: 15px;
  line-height: 1.7;
  font-weight: 500;
}

.q-score { 
  margin-left: auto;
  font-weight: 700;
  background: linear-gradient(135deg, #fed7aa 0%, #fdba74 100%);
  color: #ea580c;
  border: 2px solid rgba(251, 146, 60, 0.2);
  border-radius: 8px;
  padding: 6px 12px;
  font-size: 13px;
  box-shadow: 0 2px 8px rgba(251, 146, 60, 0.15);
  transition: all 0.3s ease;
}

.q-score:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(251, 146, 60, 0.25);
}

.q-body {
  padding: 8px 0;
}

.q-options { 
  display: grid; 
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.option-item { 
  width: 100%; 
  box-sizing: border-box; 
  border-radius: 12px;
  padding: 12px 16px;
  min-height: 48px;
  border: 2px solid rgba(102, 126, 234, 0.1);
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  font-weight: 500;
  position: relative;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.04);
}

.option-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  opacity: 0;
  transition: opacity 0.25s ease;
}

.option-item:hover::before {
  opacity: 1;
}

.option-item.is-checked { 
  border-color: #667eea;
  background: linear-gradient(135deg, #e0e7ff 0%, #ddd6fe 100%);
  color: #4338ca;
  font-weight: 600;
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25);
  transform: translateY(-1px) scale(1.02);
}

.option-item.is-checked::before {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  opacity: 1;
}

.option-item:hover { 
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.15);
  border-color: #a5b4fc;
  transform: translateY(-1px);
}

.option-item :deep(.el-radio__label),
.option-item :deep(.el-checkbox__label) {
  font-weight: inherit;
  line-height: 1.6;
}

.answer-textarea :deep(.el-textarea__inner) {
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 12px;
  padding: 16px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  font-size: 15px;
  line-height: 1.6;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.04);
  resize: vertical;
}

.answer-textarea :deep(.el-textarea__inner:focus) {
  border-color: #667eea;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.15);
  background: linear-gradient(135deg, #fafbff 0%, #ffffff 100%);
}

.answer-textarea :deep(.el-textarea__inner::placeholder) {
  color: #a1a1aa;
  font-style: italic;
}

.q-header .q-no {
  position: relative;
}

.q-header .q-no::after {
  content: '';
  position: absolute;
  top: 50%;
  right: -6px;
  width: 3px;
  height: 16px;
  background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
  border-radius: 2px;
  transform: translateY(-50%);
}

.section-header {
  position: relative;
}

.section-header::before {
  content: '';
  position: absolute;
  left: 20px;
  top: 50%;
  width: 6px;
  height: 24px;
  background: linear-gradient(180deg, #ffffff 0%, rgba(255, 255, 255, 0.6) 100%);
  border-radius: 3px;
  transform: translateY(-50%);
}

.section-header h3 {
  padding-left: 20px;
}

.empty { 
  text-align: center; 
  color: #9ca3af;
  padding: 48px 0;
  font-size: 16px;
  font-weight: 500;
  background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
  border-radius: 16px;
  border: 2px dashed rgba(102, 126, 234, 0.2);
}

@media (max-width: 1400px) {
  .exam-header {
    padding-left: calc(20px + 260px);
  }

  .progress-bar {
    padding-left: calc(20px + 260px);
    padding-right: 20px;
  }

  .exam-body {
    padding: 0 20px;
    max-width: none;
  }
  
  .paper-card {
    max-width: none;
  }
}

@media (max-width: 960px) {
  .student-exam-container {
    padding: 24px 20px;
  }

  .exam-header { 
    grid-template-columns: 1fr; 
    gap: 12px;
    padding: 16px 20px;
  }

  .progress-bar {
    padding-left: 0;
    padding-right: 0;
  }
  
  .exam-title {
    font-size: 22px;
  }
  
  .meta-left, .meta-right { 
    justify-content: center; 
  }
  
  .exam-body { 
    flex-direction: column;
    padding: 0;
  }
  
  .q-nav { 
    display: none; 
  }
  
  .nav-btn-mobile { 
    display: inline-flex; 
  }
  
  .q-options { 
    grid-template-columns: 1fr; 
  }
  
  .question {
    padding: 16px 18px;
  }
}

/* 考试须知弹窗样式 */
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

/* 切屏警告弹窗样式 */
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

.switch-count-tag {
  margin-right: 12px;
}
</style>
