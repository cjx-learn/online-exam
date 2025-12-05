<template>
  <div class="class-detail">
    <div class="detail-header">
      <el-button :icon="ArrowLeft" @click="goBack">返回</el-button>
      <h2>{{ classInfo.name }}</h2>
    </div>
    
    <div class="detail-content">
      <el-tabs v-model="activeTab">
        <el-tab-pane label="考试列表" name="exams">
          <el-empty description="暂无考试" />
        </el-tab-pane>
        <el-tab-pane label="成绩" name="scores">
          <el-empty description="暂无成绩" />
        </el-tab-pane>
        <el-tab-pane label="班级信息" name="info">
          <el-descriptions :column="2" border>
            <el-descriptions-item label="班级名称">{{ classInfo.name }}</el-descriptions-item>
            <el-descriptions-item label="教师">{{ classInfo.teacherName }}</el-descriptions-item>
            <el-descriptions-item label="学期">{{ classInfo.semester }}</el-descriptions-item>
            <el-descriptions-item label="学生人数">{{ classInfo.students }}</el-descriptions-item>
          </el-descriptions>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ArrowLeft } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const activeTab = ref('exams')
const classInfo = reactive({
  id: route.params.id,
  name: '操作系统',
  teacherName: '刘扬、于静泽',
  semester: '2025年秋冬学期',
  students: 45
})

const goBack = () => {
  router.back()
}
</script>

<style scoped>
.class-detail {
  min-height: 100vh;
  background: #f5f7fa;
  padding: 20px;
}

.detail-header {
  background: white;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
}

.detail-header h2 {
  margin: 0;
  font-size: 24px;
}

.detail-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
}
</style>

