<template>
  <div class="take-exam">
    <el-card>
      <template #header>
        <div class="exam-header">
          <h3>考试名称</h3>
          <div class="timer">
            <el-icon><Clock /></el-icon>
            剩余时间: {{ formatTime(remainingTime) }}
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
import { useRoute } from 'vue-router'

const route = useRoute()
const examId = route.params.id
const remainingTime = ref(3600) // 秒
let timer = null

const formatTime = (seconds) => {
  const h = Math.floor(seconds / 3600)
  const m = Math.floor((seconds % 3600) / 60)
  const s = seconds % 60
  return `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
}

onMounted(() => {
  timer = setInterval(() => {
    if (remainingTime.value > 0) {
      remainingTime.value--
    }
  }, 1000)
})

onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
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
</style>

