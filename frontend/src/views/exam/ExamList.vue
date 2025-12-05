<template>
  <div class="exam-list">
    <h2>考试列表</h2>
    
    <el-card>
      <el-table :data="examList" style="width: 100%">
        <el-table-column prop="title" label="考试名称" />
        <el-table-column prop="subject" label="科目" />
        <el-table-column prop="duration" label="时长(分钟)" />
        <el-table-column prop="startTime" label="开始时间" />
        <el-table-column prop="endTime" label="结束时间" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button 
              type="primary" 
              size="small"
              :disabled="row.status !== 1"
              @click="startExam(row.id)"
            >
              开始考试
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <el-empty v-if="examList.length === 0" description="暂无考试" />
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const examList = ref([])

const getStatusType = (status) => {
  const types = { 0: 'info', 1: 'success', 2: 'warning', 3: 'danger' }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = { 0: '未开始', 1: '进行中', 2: '已结束', 3: '已完成' }
  return texts[status] || '未知'
}

const startExam = (id) => {
  router.push(`/exam/take/${id}`)
}
</script>

<style scoped>
.exam-list {
  padding: 20px;
}

h2 {
  margin-bottom: 20px;
  color: #303133;
}
</style>

