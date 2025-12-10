<template>
  <div class="question-image-upload">
    <div v-if="imageUrl" class="image-preview">
      <img :src="fullImageUrl" alt="题目图片" />
      <div class="image-actions">
        <el-button size="small" type="primary" @click="handleReupload">
          <el-icon><RefreshRight /></el-icon>
          重新上传
        </el-button>
        <el-button size="small" type="danger" @click="handleRemove">
          <el-icon><Delete /></el-icon>
          删除图片
        </el-button>
      </div>
    </div>
    
    <el-upload
      v-else
      class="image-uploader"
      :action="uploadUrl"
      :show-file-list="false"
      :on-success="handleSuccess"
      :on-error="handleError"
      :before-upload="beforeUpload"
      accept="image/*"
      :headers="{ Authorization: token }"
    >
      <div class="upload-placeholder">
        <el-icon class="upload-icon"><Plus /></el-icon>
        <div class="upload-text">点击上传题目图片</div>
        <div class="upload-hint">支持 JPG、PNG、GIF，最大 5MB</div>
      </div>
    </el-upload>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus, RefreshRight, Delete } from '@element-plus/icons-vue'
import { API_URL } from '@/config/api'
import { getImageUrl } from '@/utils/file'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue'])

const uploadUrl = `${API_URL}/file/upload/question-image`
const token = localStorage.getItem('token') || ''

const imageUrl = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})

const fullImageUrl = computed(() => {
  return getImageUrl(imageUrl.value)
})

const beforeUpload = (file) => {
  const isImage = file.type.startsWith('image/')
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isImage) {
    ElMessage.error('只能上传图片文件！')
    return false
  }
  if (!isLt5M) {
    ElMessage.error('图片大小不能超过 5MB！')
    return false
  }
  return true
}

const handleSuccess = (response) => {
  if (response.code === 200) {
    imageUrl.value = response.data.url
    ElMessage.success('图片上传成功')
  } else {
    ElMessage.error(response.message || '上传失败')
  }
}

const handleError = () => {
  ElMessage.error('上传失败，请重试')
}

const handleReupload = () => {
  imageUrl.value = ''
}

const handleRemove = () => {
  imageUrl.value = ''
  ElMessage.success('图片已删除')
}
</script>

<style scoped>
.question-image-upload {
  width: 100%;
}

.image-preview {
  position: relative;
  width: 100%;
  max-width: 600px;
}

.image-preview img {
  width: 100%;
  border-radius: 8px;
  border: 1px solid #dcdfe6;
  display: block;
}

.image-actions {
  margin-top: 10px;
  display: flex;
  gap: 10px;
}

.image-uploader {
  width: 100%;
  max-width: 400px;
}

.upload-placeholder {
  width: 400px;
  height: 200px;
  border: 2px dashed #d9d9d9;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s;
  background-color: #fafafa;
}

.upload-placeholder:hover {
  border-color: #409eff;
  background-color: #f5f7fa;
}

.upload-icon {
  font-size: 48px;
  color: #8c939d;
  margin-bottom: 16px;
}

.upload-text {
  font-size: 16px;
  color: #606266;
  margin-bottom: 8px;
}

.upload-hint {
  font-size: 12px;
  color: #909399;
}
</style>
