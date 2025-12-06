<template>
  <div class="take-exam" @contextmenu.prevent @copy.prevent @paste.prevent @cut.prevent>
    <!-- 考试须知弹窗 -->
    <el-dialog
      v-model="noticeVisible"
      title="考试须知"
      width="500px"
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
          <p>3. 考试过程中请勿切换页面或离开考试界面。</p>
          <p>4. 答题完成后请及时提交试卷。</p>
          <p>5. 如遇网络问题，系统会自动保存答案。</p>
          <p>6. 违反考试纪律者，成绩将作废处理。</p>
        </div>
        <div class="countdown-tip">
          <el-icon><Clock /></el-icon>
          <span>{{ countdown }} 秒后自动进入考试...</span>
        </div>
      </div>
      <template #footer>
        <el-button type="primary" @click="startExamNow" :disabled="countdown > 0">
          {{ countdown > 0 ? `请等待 ${countdown} 秒` : '立即开始考试' }}
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

    <el-card v-if="!noticeVisible">
      <template #header>
        <div class="exam-header">
          <h3>考试名称</h3>
          <div class="header-right">
            <div class="switch-warning" v-if="switchCount > 0">
              <el-tag type="danger" effect="dark">切屏次数: {{ switchCount }}/3</el-tag>
            </div>
            <div class="timer">
              <el-icon><Clock /></el-icon>
              剩余时间: {{ formatTime(remainingTime) }}
            </div>
          </div>
        </div>
      </template>
      
      <div class="exam-content">
        <el-empty description="考试题目加载中..." />
      </div>
      
      <div class="exam-footer">
        <el-button type="primary" size="large">提交试卷</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Clock, WarningFilled } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()
const examId = route.params.id
const remainingTime = ref(3600) // 秒
let timer = null

// 考试须知相关
const noticeVisible = ref(true)
const countdown = ref(5)
let countdownTimer = null

// 防作弊相关
const switchCount = ref(0)
const switchWarningVisible = ref(false)

const formatTime = (seconds) => {
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

// 开始倒计时
const startCountdown = () => {
  countdownTimer = setInterval(() => {
    if (countdown.value > 0) {
      countdown.value--
    } else {
      clearInterval(countdownTimer)
      startExamNow()
    }
  }, 1000)
}

// 立即开始考试
const startExamNow = () => {
  if (countdownTimer) {
    clearInterval(countdownTimer)
  }
  noticeVisible.value = false
  startExamTimer()
}

// 开始考试计时
const startExamTimer = () => {
  timer = setInterval(() => {
    if (remainingTime.value > 0) {
      remainingTime.value--
    }
  }, 1000)
}

// 防作弊：监听切屏
const handleVisibilityChange = () => {
  if (document.hidden && !noticeVisible.value) {
    switchCount.value++
    if (switchCount.value >= 3) {
      // 超过3次自动交卷
      ElMessageBox.alert('您已切屏超过3次，系统将自动提交试卷！', '警告', {
        confirmButtonText: '确定',
        type: 'error',
        callback: () => {
          autoSubmitExam()
        }
      })
    } else {
      switchWarningVisible.value = true
      ElMessage.warning(`警告：检测到切屏行为！已切屏 ${switchCount.value} 次，超过3次将自动交卷`)
    }
  }
}

// 自动交卷
const autoSubmitExam = () => {
  ElMessage.error('由于多次切屏，试卷已自动提交')
  // TODO: 调用提交试卷接口
  router.push('/student')
}

// 防作弊：禁用快捷键
const handleKeydown = (e) => {
  // 禁用 Ctrl+C, Ctrl+V, Ctrl+X, Ctrl+A, F12
  if ((e.ctrlKey && ['c', 'v', 'x', 'a'].includes(e.key.toLowerCase())) || e.key === 'F12') {
    e.preventDefault()
    ElMessage.warning('考试期间禁止使用此快捷键')
  }
}

onMounted(() => {
  startCountdown()
  // 添加防作弊监听
  document.addEventListener('visibilitychange', handleVisibilityChange)
  document.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
  if (countdownTimer) {
    clearInterval(countdownTimer)
  }
  // 移除防作弊监听
  document.removeEventListener('visibilitychange', handleVisibilityChange)
  document.removeEventListener('keydown', handleKeydown)
})
</script>

<style scoped>
.take-exam {
  padding: 20px;
}

.exam-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.timer {
  font-size: 18px;
  color: #E6A23C;
  display: flex;
  align-items: center;
  gap: 5px;
}

.exam-content {
  min-height: 400px;
}

.exam-footer {
  text-align: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #eee;
}

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

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

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
</style>

