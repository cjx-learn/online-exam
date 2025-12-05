<template>
  <div class="teacher-class-detail">
    <h1>教师班级详情页</h1>
    <p>班级ID: {{ classId }}</p>
    <el-button @click="goBack">返回</el-button>
  </div>
</template>

<script setup>
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const classId = route.params.id

const goBack = () => {
  router.push('/teacher/home')
}
</script>

<style scoped>
.teacher-class-detail {
  padding: 40px;
  text-align: center;
}

h1 {
  font-size: 32px;
  color: #303133;
  margin-bottom: 20px;
}

p {
  font-size: 18px;
  color: #606266;
  margin-bottom: 30px;
}
</style>

