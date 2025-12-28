<template>
  <el-popover
    placement="bottom-end"
    :width="360"
    trigger="click"
    @show="loadNotifications"
  >
    <template #reference>
      <el-badge :value="unreadCount" :hidden="unreadCount === 0" :max="99">
        <el-button :icon="Bell" circle />
      </el-badge>
    </template>

    <div class="notification-panel">
      <div class="notification-header">
        <span class="title">消息通知</span>
        <el-button v-if="unreadCount > 0" type="primary" link size="small" @click="markAllRead">
          全部已读
        </el-button>
      </div>

      <div class="notification-list" v-loading="loading">
        <div v-if="notifications.length === 0" class="empty-tip">
          暂无消息
        </div>
        <div
          v-for="item in notifications"
          :key="item.id"
          class="notification-item"
          :class="{ unread: item.isRead === 0 }"
          @click="handleClick(item)"
        >
          <div class="item-icon">
            <el-icon :size="20" :color="getIconColor(item.type)">
              <component :is="getIcon(item.type)" />
            </el-icon>
          </div>
          <div class="item-content">
            <div class="item-title">{{ item.title }}</div>
            <div class="item-desc">{{ item.content }}</div>
            <div class="item-time">{{ formatTime(item.createTime) }}</div>
          </div>
          <div v-if="item.isRead === 0" class="unread-dot"></div>
        </div>
      </div>

      <div class="notification-footer">
        <el-button type="primary" link @click="goToAll">查看全部</el-button>
      </div>
    </div>
  </el-popover>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Bell, Document, Trophy, InfoFilled, Warning } from '@element-plus/icons-vue'
import request from '@/utils/request'

const router = useRouter()
const loading = ref(false)
const unreadCount = ref(0)
const notifications = ref([])

// 定义角色路由前缀
const props = defineProps({
  rolePrefix: {
    type: String,
    default: 'student'
  }
})

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
  const now = new Date()
  const diff = now - date
  
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return Math.floor(diff / 60000) + '分钟前'
  if (diff < 86400000) return Math.floor(diff / 3600000) + '小时前'
  if (diff < 604800000) return Math.floor(diff / 86400000) + '天前'
  
  return date.toLocaleDateString()
}

const loadNotifications = async () => {
  loading.value = true
  try {
    const res = await request.get('/notification/summary', { params: { limit: 10 } })
    if (res.code === 200) {
      notifications.value = res.data.notifications
      unreadCount.value = res.data.unreadCount
    }
  } catch (e) {
    console.error('加载通知失败', e)
  } finally {
    loading.value = false
  }
}

const loadUnreadCount = async () => {
  try {
    const res = await request.get('/notification/unread-count')
    if (res.code === 200) {
      unreadCount.value = res.data.count
    }
  } catch (e) {
    console.error('获取未读数量失败', e)
  }
}

const markAllRead = async () => {
  try {
    await request.post('/notification/read-all')
    notifications.value.forEach(n => n.isRead = 1)
    unreadCount.value = 0
  } catch (e) {
    console.error('标记已读失败', e)
  }
}

const handleClick = async (item) => {
  // 标记为已读
  if (item.isRead === 0) {
    await request.post(`/notification/read/${item.id}`)
    item.isRead = 1
    unreadCount.value = Math.max(0, unreadCount.value - 1)
  }
  
  // 跳转到相关页面
  if (item.relatedType === 'class' && item.relatedId) {
    // 跳转到班级详情页面
    router.push(`/${props.rolePrefix}/class/${item.relatedId}`)
  } else if (item.relatedType === 'exam_record' && item.relatedId) {
    // 批改完成通知：跳转到考试详情页面
    router.push(`/${props.rolePrefix}/exam-detail/${item.relatedId}`)
  } else if (item.relatedType === 'exam' && item.relatedId) {
    // 兼容旧的考试类型通知
    router.push(`/${props.rolePrefix}/exam`)
  }
}

const goToAll = () => {
  router.push(`/${props.rolePrefix}/notifications`)
}

onMounted(() => {
  loadUnreadCount()
  // 每60秒刷新一次未读数量
  setInterval(loadUnreadCount, 60000)
})

defineExpose({ loadUnreadCount })
</script>

<style scoped>
.notification-panel {
  margin: -12px;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  border-bottom: 1px solid #ebeef5;
}

.notification-header .title {
  font-weight: 600;
  font-size: 14px;
}

.notification-list {
  max-height: 400px;
  overflow-y: auto;
}

.empty-tip {
  padding: 40px;
  text-align: center;
  color: #909399;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 12px 16px;
  cursor: pointer;
  transition: background-color 0.2s;
  position: relative;
}

.notification-item:hover {
  background-color: #f5f7fa;
}

.notification-item.unread {
  background-color: #ecf5ff;
}

.item-icon {
  margin-right: 12px;
  margin-top: 2px;
}

.item-content {
  flex: 1;
  min-width: 0;
}

.item-title {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.item-desc {
  font-size: 12px;
  color: #606266;
  margin-bottom: 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-time {
  font-size: 12px;
  color: #909399;
}

.unread-dot {
  width: 8px;
  height: 8px;
  background-color: #f56c6c;
  border-radius: 50%;
  margin-left: 8px;
  margin-top: 6px;
}

.notification-footer {
  padding: 8px 16px;
  text-align: center;
  border-top: 1px solid #ebeef5;
}
</style>
