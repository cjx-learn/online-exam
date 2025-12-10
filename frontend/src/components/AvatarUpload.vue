<template>
  <div class="avatar-upload">
    <el-upload
      class="avatar-uploader"
      :action="uploadUrl"
      :headers="uploadHeaders"
      :show-file-list="false"
      :on-success="handleSuccess"
      :on-error="handleError"
      :before-upload="beforeUpload"
      :accept="'image/*'"
    >
      <img v-if="imageUrl" :src="imageUrl" class="avatar" alt="头像">
      <div v-else class="avatar-placeholder">
        <el-icon class="avatar-uploader-icon"><Plus /></el-icon>
        <div class="avatar-tip">点击上传头像</div>
      </div>
    </el-upload>
    <div class="avatar-hint">
      支持 jpg、png、gif 格式，大小不超过 2MB
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { API_URL } from '@/config/api'
import { getAvatarUrl } from '@/utils/file'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue'])

const imageUrl = ref('')

// 上传地址
const uploadUrl = computed(() => {
  return `${API_URL}/file/upload/avatar`
})

// 请求头
const uploadHeaders = computed(() => {
  const token = localStorage.getItem('token')
  return {
    'Authorization': `Bearer ${token}`
  }
})

// 上传前验证
const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}

// 上传成功
const handleSuccess = (response) => {
  if (response.code === 200 && response.data.url) {
    imageUrl.value = getAvatarUrl(response.data.url)
    emit('update:modelValue', response.data.url)
    ElMessage.success('头像上传成功')
  } else {
    ElMessage.error('上传失败: ' + (response.message || '未知错误'))
  }
}

// 上传失败
const handleError = (error) => {
  console.error('上传失败:', error)
  ElMessage.error('上传失败，请重试')
}

// 监听外部传入的值
watch(() => props.modelValue, (newValue) => {
  if (newValue) {
    // 如果是完整URL，直接使用；否则使用工具函数拼接
    if (newValue.startsWith('http')) {
      imageUrl.value = newValue
    } else {
      imageUrl.value = getAvatarUrl(newValue)
    }
  } else {
    imageUrl.value = ''
  }
}, { immediate: true })
</script>

<style scoped>
.avatar-upload {
  text-align: center;
}

.avatar-uploader {
  display: inline-block;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.3s;
}

.avatar-uploader:hover {
  border-color: #409eff;
}

.avatar {
  width: 150px;
  height: 150px;
  display: block;
  object-fit: cover;
}

.avatar-placeholder {
  width: 150px;
  height: 150px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #8c939d;
  background-color: #fbfdff;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  margin-bottom: 8px;
}

.avatar-tip {
  font-size: 12px;
}

.avatar-hint {
  margin-top: 10px;
  font-size: 12px;
  color: #909399;
}
</style>
