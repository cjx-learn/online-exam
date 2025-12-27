<template>
  <div class="notifications-page">
    <div class="page-header">
      <el-button :icon="ArrowLeft" @click="$router.back()">返回</el-button>
      <h2>消息通知</h2>
      <div class="header-actions">
        <el-button v-if="unreadCount > 0" type="primary" link @click="markAllRead">
          全部标为已读
        </el-button>
        <el-button type="danger" link @click="deleteRead" :disabled="!hasReadNotifications">
          清除已读
        </el-button>
      </div>
    </div>

    <div class="notifications-container" v-loading="loading">
      <div v-if="notifications.length === 0" class="empty-state">
        <el-empty description="暂无消息通知" />
      </div>

      <div v-else class="notification-list">
        <div
          v-for="item in notifications"
          :key="item.id"
          class="notification-item"
          :class="{ unread: item.isRead === 0 }"
          @click="handleClick(item)"
        >
          <div class="item-icon">
            <el-icon :size="24" :color="getIconColor(item.type)">
              <component :is="getIcon(item.type)" />
            </el-icon>
          </div>
          <div class="item-content">
            <div class="item-header">
              <span class="item-title">{{ item.title }}</span>
              <span class="item-time">{{ formatTime(item.createTime) }}</span>
            </div>
            <div class="item-desc">{{ item.content }}</div>
          </div>
          <div class="item-actions">
            <el-button
              v-if="item.isRead === 0"
              type="primary"
              link
              size="small"
              @click.stop="markAsRead(item)"
            >
              标为已读
            </el-button>
            <el-button
              type="danger"
              link
              size="small"
              @click.stop="deleteNotification(item)"
            >
              删除
            </el-button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { ArrowLeft, Bell, Document, Trophy, InfoFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const loading = ref(false)
const notifications = ref([])

const unreadCount = computed(() => notifications.value.filter(n => n.isRead === 0).length)
const hasReadNotifications = computed(() => notifications.value.some(n => n.isRead === 1))

const getIcon = (type) => {
  const icons = {
    exam_publish: Document,
    grade_release: Trophy,
    grading_complete: Trophy,
    system: InfoFilled
  }
  return icons[type] || Bell
}

const getIconColor = (type) => {
  const colors = {
    exam_publish: '#409EFF',
    grade_release: '#67C23A',
    grading_complete: '#67C23A',
    system: '#909399'
  }
  return colors[type] || '#409EFF'
}

const formatTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const loadNotifications = async () => {
  loading.value = true
  try {
    const res = await request.get('/notification/list')
    if (res.code === 200) {
      notifications.value = res.data || []
    }
  } catch (e) {
    ElMessage.error('加载通知失败')
  } finally {
    loading.value = false
  }
}

const markAsRead = async (item) => {
  try {
    await request.post(`/notification/read/${item.id}`)
    item.isRead = 1
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

const markAllRead = async () => {
  try {
    await request.post('/notification/read-all')
    notifications.value.forEach(n => n.isRead = 1)
    ElMessage.success('已全部标为已读')
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

const deleteNotification = async (item) => {
  try {
    await ElMessageBox.confirm('确定删除这条通知吗？', '提示', {
      type: 'warning'
    })
    await request.delete(`/notification/${item.id}`)
    notifications.value = notifications.value.filter(n => n.id !== item.id)
    ElMessage.success('删除成功')
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const deleteRead = async () => {
  try {
    await ElMessageBox.confirm('确定清除所有已读通知吗？', '提示', {
      type: 'warning'
    })
    await request.delete('/notification/read')
    notifications.value = notifications.value.filter(n => n.isRead === 0)
    ElMessage.success('清除成功')
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('清除失败')
    }
  }
}

const handleClick = async (item) => {
  if (item.isRead === 0) {
    await markAsRead(item)
  }
  
  // 跳转到相关页面
  if (item.relatedType === 'class' && item.relatedId) {
    // 跳转到班级详情页面
    router.push(`/student/class/${item.relatedId}`)
  } else if (item.relatedType === 'exam' && item.relatedId) {
    // 兼容旧的考试类型通知
    router.push('/student/exam')
  }
}

onMounted(() => {
  loadNotifications()
})
</script>

<style scoped>
.notifications-page {
  min-height: 100vh;
  background: #f5f7fa;
  padding: 20px;
}

.page-header {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 20px;
  background: white;
  padding: 16px 24px;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.page-header h2 {
  flex: 1;
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.notifications-container {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  min-height: 400px;
}

.empty-state {
  padding: 80px 0;
}

.notification-list {
  padding: 12px;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 16px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  margin-bottom: 8px;
}

.notification-item:hover {
  background: #f5f7fa;
}

.notification-item.unread {
  background: #ecf5ff;
}

.notification-item.unread:hover {
  background: #d9ecff;
}

.item-icon {
  margin-right: 16px;
  margin-top: 4px;
}

.item-content {
  flex: 1;
  min-width: 0;
}

.item-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.item-title {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.item-time {
  font-size: 12px;
  color: #909399;
}

.item-desc {
  font-size: 14px;
  color: #606266;
  line-height: 1.5;
}

.item-actions {
  display: flex;
  gap: 8px;
  margin-left: 16px;
}
</style>
