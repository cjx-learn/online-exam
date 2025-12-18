<template>
  <div class="student-exam-detail-container">
    <!-- 顶部导航栏 -->
    <div class="top-nav">
      <div class="nav-left">
        <h1 class="title">
          <span class="title-text">{{ exam.title || '学生答题详情' }}</span>
        </h1>
        <span v-if="examRecord" class="user-name-left">
          {{ examRecord.studentName }} ({{ examRecord.studentNo }})
        </span>
      </div>

      <div class="nav-right">
        <el-button class="back-button" @click="goBack">
          <el-icon><Back /></el-icon>
          返回成绩列表
        </el-button>
        
        <!-- 用户头像下拉菜单 -->
        <el-dropdown @command="handleCommand">
          <div class="user-avatar">
            <el-avatar 
              :size="42" 
              :icon="currentUserInfo?.avatar ? undefined : UserFilled" 
              :src="getAvatarUrl(currentUserInfo?.avatar)"
              class="avatar-img" 
            />
            <span class="user-name">{{ currentUserInfo?.realName || '教师' }}</span>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon><User /></el-icon>
                个人信息
              </el-dropdown-item>
              <el-dropdown-item command="logout" divided>
                <el-icon><SwitchButton /></el-icon>
                退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 加载状态 -->
    <div v-if="loading" class="loading-container">
      <div class="loading-card">
        <el-icon class="is-loading"><Loading /></el-icon>
        <span>正在加载答题详情...</span>
      </div>
    </div>

    <!-- 主要内容 -->
    <div v-else class="detail-body">
      <!-- 题目导航侧边栏 -->
      <aside class="questions-nav">
        <div class="nav-header">
          <span class="nav-title">题目导航</span>
          <span class="nav-progress">共 {{ questions.length }} 题</span>
        </div>
        <!-- 答题统计 -->
        <div class="nav-stats">
          <div class="nav-stat-item correct">
            <span class="stat-dot"></span>
            <span>正确 {{ correctCount }}</span>
          </div>
          <div class="nav-stat-item wrong">
            <span class="stat-dot"></span>
            <span>错误 {{ wrongCount }}</span>
          </div>
        </div>
        <div class="nav-grid">
          <button
            v-for="(q, index) in questions"
            :key="q.id"
            class="nav-item"
            :class="{ 
              'is-current': currentQuestionId === q.id,
              'is-correct': isQuestionCorrect(q),
              'is-wrong': isQuestionWrong(q)
            }"
            @click="scrollToQuestion(q.id)"
            :title="`题目 ${index + 1}`"
          >
            {{ index + 1 }}
          </button>
        </div>
        <!-- 图例 -->
        <div class="nav-legend">
          <div class="legend-item">
            <span class="legend-dot correct"></span>
            <span>正确</span>
          </div>
          <div class="legend-item">
            <span class="legend-dot wrong"></span>
            <span>错误</span>
          </div>
        </div>
      </aside>

      <!-- 主内容区域 -->
      <div class="detail-content">
        <!-- 统计卡片区域 -->
        <div class="stats-section">
          <div class="stat-card total-card">
            <div class="stat-icon">
              <span class="icon-bg">📊</span>
            </div>
            <div class="stat-content">
              <div class="stat-label">总分</div>
              <div class="stat-value">{{ totalScoreText }}</div>
            </div>
          </div>
          <div class="stat-card objective-card">
            <div class="stat-icon">
              <span class="icon-bg">✓</span>
            </div>
            <div class="stat-content">
              <div class="stat-label">客观题得分</div>
              <div class="stat-value">{{ objectiveScoreText }}</div>
            </div>
          </div>
          <div class="stat-card subjective-card">
            <div class="stat-icon">
              <span class="icon-bg">✎</span>
            </div>
            <div class="stat-content">
              <div class="stat-label">主观题得分</div>
              <div class="stat-value">{{ subjectiveScoreText }}</div>
            </div>
          </div>
        </div>

        <!-- 试题详情区域 -->
        <div class="questions-section">
          <div v-if="questions.length === 0" class="empty-state">
            <div class="empty-icon">📝</div>
            <p>暂无试题数据</p>
          </div>
          <div v-else class="question-list">
            <div
              v-for="(q, index) in questions"
              :key="q.id"
              :id="'q-' + q.id"
              class="question-card"
              :class="{ 
                'is-correct-card': isQuestionCorrect(q),
                'is-wrong-card': isQuestionWrong(q)
              }"
            >
              <!-- 题目头部 -->
              <div class="question-header">
                <div class="q-number-badge" :class="{ 'correct': isQuestionCorrect(q), 'wrong': isQuestionWrong(q) }">
                  {{ index + 1 }}
                </div>
                <div class="q-main-info">
                  <div class="q-content">{{ q.content }}</div>
                  <div class="q-tags">
                    <span class="q-type-tag">{{ typeLabel(q.type) }}</span>
                    <span class="q-score-tag">满分 {{ q.score ?? '-' }} 分</span>
                    <span class="q-result-tag" :class="{ 'correct': isQuestionCorrect(q), 'wrong': isQuestionWrong(q) }">
                      <el-icon v-if="isQuestionCorrect(q)"><CircleCheck /></el-icon>
                      <el-icon v-else-if="isQuestionWrong(q)"><CircleClose /></el-icon>
                      {{ isQuestionCorrect(q) ? '回答正确' : isQuestionWrong(q) ? '回答错误' : '待批改' }}
                    </span>
                  </div>
                </div>
                <!-- 得分显示 -->
                <div class="q-score-display">
                  <span class="score-label">得分</span>
                  <span class="score-number" :class="{ 'full': isQuestionCorrect(q), 'zero': isQuestionWrong(q) && perQuestionScore(q).scoreText === '0 分' }">
                    {{ perQuestionScore(q).scoreText }}
                  </span>
                </div>
              </div>

              <!-- 题目图片 -->
              <div v-if="q.image" class="q-image-wrapper">
                <el-image 
                  :src="getImageUrl(q.image)" 
                  :preview-src-list="[getImageUrl(q.image)]"
                  fit="contain"
                  class="q-image"
                  :preview-teleported="true"
                />
              </div>

              <!-- 题目选项 -->
              <div v-if="[1, 2, 3].includes(q.type) && Object.keys(parseOptions(q.options, q.type)).length > 0" class="question-options">
                <div class="options-grid">
                  <div
                    v-for="(optionText, optionKey) in parseOptions(q.options, q.type)"
                    :key="optionKey"
                    class="option-card"
                    :class="{
                      'is-correct': answerIncludesOption(formatAnswerText(q, q.answer), optionKey, q),
                      'is-selected': answerIncludesOption(perQuestionScore(q).userAnswerText, optionKey, q),
                      'is-wrong-selected': answerIncludesOption(perQuestionScore(q).userAnswerText, optionKey, q) && !answerIncludesOption(formatAnswerText(q, q.answer), optionKey, q)
                    }"
                  >
                    <div class="option-key">{{ optionKey }}</div>
                    <div class="option-text">{{ optionText }}</div>
                    <div class="option-status">
                      <el-icon v-if="answerIncludesOption(formatAnswerText(q, q.answer), optionKey, q)" class="correct-icon"><CircleCheck /></el-icon>
                      <el-icon v-else-if="answerIncludesOption(perQuestionScore(q).userAnswerText, optionKey, q)" class="wrong-icon"><CircleClose /></el-icon>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 主观题答案显示 -->
              <div v-if="[4, 5].includes(q.type)" class="subjective-answer-section">
                <div class="answer-block user-answer-block">
                  <div class="answer-block-header">
                    <el-icon><User /></el-icon>
                    <span>学生答案</span>
                  </div>
                  <div class="answer-block-content">
                    <FormulaRenderer :content="perQuestionScore(q).userAnswerText || ''" />
                  </div>
                </div>
                <div class="answer-block correct-answer-block">
                  <div class="answer-block-header">
                    <el-icon><CircleCheck /></el-icon>
                    <span>参考答案</span>
                  </div>
                  <div class="answer-block-content">
                    <FormulaRenderer :content="formatAnswerText(q, q.answer) || ''" />
                  </div>
                </div>
              </div>

              <!-- 客观题答案对比 -->
              <div v-if="[1, 2, 3].includes(q.type)" class="answer-comparison">
                <div class="comparison-item correct-answer">
                  <span class="comparison-label">
                    <el-icon><CircleCheck /></el-icon>
                    正确答案
                  </span>
                  <span class="comparison-value">{{ formatAnswerText(q, q.answer) }}</span>
                </div>
                <div class="comparison-item user-answer" :class="{ 'is-correct': isQuestionCorrect(q), 'is-wrong': isQuestionWrong(q) }">
                  <span class="comparison-label">
                    <el-icon><User /></el-icon>
                    学生答案
                  </span>
                  <span class="comparison-value">{{ perQuestionScore(q).userAnswerText }}</span>
                </div>
              </div>

              <!-- 教师批改意见 -->
              <div v-if="perQuestionScore(q).comment" class="teacher-comment-section">
                <div class="comment-header">
                  <el-icon><Edit /></el-icon>
                  <span>批改意见</span>
                </div>
                <div class="comment-content">{{ perQuestionScore(q).comment }}</div>
              </div>
            </div>
          </div>
        </div>
      
        <!-- 返回顶部按钮 -->
        <div class="back-to-top" @click="scrollToTop" v-show="showBackToTop">
          <el-icon><ArrowUp /></el-icon>
        </div>
      </div>
    </div>
    
    <!-- 个人信息对话框 -->
    <el-dialog 
      v-model="profileDialogVisible" 
      title="个人信息" 
      width="560px"
      :close-on-click-modal="false"
      class="profile-dialog"
    >
      <el-form :model="userForm" label-width="100px" class="profile-form">
        <el-form-item label="头像">
          <AvatarUpload v-model="userForm.avatar" />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="userForm.username" disabled>
            <template #suffix>
              <el-icon color="#909399"><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="真实姓名">
          <el-input v-model="userForm.realName" disabled>
            <template #suffix>
              <el-icon color="#909399"><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="工号">
          <el-input v-model="userForm.teacherNo" disabled>
            <template #suffix>
              <el-icon color="#909399"><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-divider content-position="left">
          <span style="color: #909399; font-size: 13px;">可修改信息</span>
        </el-divider>
        <el-form-item label="邮箱">
          <el-input v-model="userForm.email" placeholder="请输入邮箱" clearable type="email" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" maxlength="11" clearable />
        </el-form-item>
        <el-form-item label="单位">
          <el-input v-model="userForm.department" placeholder="请输入单位" clearable />
        </el-form-item>
        <el-form-item label="职称">
          <el-input v-model="userForm.title" placeholder="请输入职称" clearable />
        </el-form-item>
      </el-form>
      <div class="password-section">
        <el-button @click="openPasswordDialog" :icon="Key" class="change-password-btn">
          修改密码
        </el-button>
      </div>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="profileDialogVisible = false" size="large">取消</el-button>
          <el-button type="primary" @click="saveProfile" size="large">保存修改</el-button>
        </div>
      </template>
    </el-dialog>
    
    <!-- 修改密码对话框 -->
    <el-dialog 
      v-model="passwordDialogVisible" 
      title="修改密码" 
      width="480px"
      :close-on-click-modal="false"
      class="password-dialog"
    >
      <el-form 
        :model="passwordForm" 
        :rules="passwordRules"
        ref="passwordFormRef"
        label-width="100px" 
        class="password-form"
      >
        <el-form-item label="旧密码" prop="oldPassword">
          <el-input v-model="passwordForm.oldPassword" type="password" placeholder="请输入旧密码" show-password clearable />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码（6-20位）" show-password clearable />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请再次输入新密码" show-password clearable />
        </el-form-item>
        <div class="password-tips">
          <el-icon color="#409EFF"><InfoFilled /></el-icon>
          <span>密码长度为6-20位，建议包含字母和数字</span>
        </div>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closePasswordDialog" size="large">取消</el-button>
          <el-button type="primary" @click="changePassword" size="large">确认修改</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>


<script setup>
import { ref, reactive, onMounted, onBeforeUnmount, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getImageUrl, getAvatarUrl } from '@/utils/file'
import { Loading, Edit, Back, User, CircleCheck, CircleClose, ArrowUp, UserFilled, SwitchButton, Lock, Key, InfoFilled } from '@element-plus/icons-vue'
import request from '@/utils/request'
import AvatarUpload from '@/components/AvatarUpload.vue'
import FormulaRenderer from '@/components/FormulaRenderer.vue'

const route = useRoute()
const router = useRouter()

const recordId = ref(Number(route.params.recordId))
const loading = ref(true)
const examRecord = ref(null)
const exam = reactive({})

// 用户信息
let currentUserInfo = null
try {
  const stored = localStorage.getItem('userInfo')
  if (stored) currentUserInfo = JSON.parse(stored)
} catch (_) {}

// 个人信息相关
const profileDialogVisible = ref(false)
const passwordDialogVisible = ref(false)
const passwordFormRef = ref(null)

const userForm = reactive({
  username: currentUserInfo?.username || '',
  realName: currentUserInfo?.realName || '',
  teacherNo: currentUserInfo?.teacherNo || '',
  email: currentUserInfo?.email || '',
  phone: currentUserInfo?.phone || '',
  department: currentUserInfo?.department || '',
  title: currentUserInfo?.title || '',
  avatar: currentUserInfo?.avatar || ''
})

const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const passwordRules = {
  oldPassword: [{ required: true, message: '请输入旧密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度为6-20位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { 
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入的密码不一致'))
        } else {
          callback()
        }
      }, 
      trigger: 'blur' 
    }
  ]
}
const questions = ref([])
const answers = ref([])
const answerMap = reactive({})
const currentQuestionId = ref(null)

// 返回顶部
const showBackToTop = ref(false)

const scrollToTop = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// 监听滚动
const handleScroll = () => {
  showBackToTop.value = window.scrollY > 300
}

const totalScoreText = computed(() => {
  if (!examRecord.value || examRecord.value.totalScore == null) return '-'
  return `${examRecord.value.totalScore} 分`
})

const objectiveScoreText = computed(() => {
  if (!examRecord.value || examRecord.value.objectiveScore == null) return '-'
  return `${examRecord.value.objectiveScore} 分`
})

const subjectiveScoreText = computed(() => {
  if (!examRecord.value || examRecord.value.subjectiveScore == null) return '-'
  return `${examRecord.value.subjectiveScore} 分`
})

// 判断题目是否正确
const isQuestionCorrect = (q) => {
  const answer = answerMap[q.id]
  if (!answer) return false
  if ([1, 2, 3].includes(q.type)) {
    return answer.score != null && answer.score === q.score
  }
  return answer.score != null && answer.score > 0
}

// 判断题目是否错误
const isQuestionWrong = (q) => {
  const answer = answerMap[q.id]
  if ([1, 2, 3].includes(q.type)) {
    if (!answer || answer.score == null) return true
    return answer.score < q.score
  }
  return answer && answer.score != null && answer.score === 0
}

// 正确题目数量
const correctCount = computed(() => {
  return questions.value.filter(q => isQuestionCorrect(q)).length
})

// 错误题目数量
const wrongCount = computed(() => {
  return questions.value.filter(q => isQuestionWrong(q)).length
})

const loadData = async () => {
  loading.value = true
  try {
    const recordRes = await request.get(`/examRecord/${recordId.value}`)
    if (!recordRes || !recordRes.data) {
      ElMessage.error('考试记录不存在或已被删除')
      router.back()
      return
    }
    examRecord.value = recordRes.data

    const examRes = await request.get(`/exam/${examRecord.value.examId}`)
    if (examRes && examRes.data) {
      Object.assign(exam, examRes.data)
    }

    const qRes = await request.get(`/exam/${examRecord.value.examId}/questions`)
    questions.value = (qRes && qRes.data) ? qRes.data : []

    const aRes = await request.get(`/examRecord/${recordId.value}/answers`)
    answers.value = (aRes && aRes.data) ? aRes.data : []
    for (const item of answers.value) {
      if (item && item.questionId != null) {
        answerMap[item.questionId] = item
      }
    }
  } catch (e) {
    ElMessage.error('加载答题详情失败')
  } finally {
    loading.value = false
  }
}

const goBack = () => {
  if (exam.id) {
    router.push(`/teacher/exam/${exam.id}/grades`)
  } else {
    router.back()
  }
}

// 处理用户菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      if (currentUserInfo) {
        Object.assign(userForm, {
          username: currentUserInfo.username || '',
          realName: currentUserInfo.realName || '',
          teacherNo: currentUserInfo.teacherNo || '',
          email: currentUserInfo.email || '',
          phone: currentUserInfo.phone || '',
          department: currentUserInfo.department || '',
          title: currentUserInfo.title || '',
          avatar: currentUserInfo.avatar || ''
        })
      }
      profileDialogVisible.value = true
      break
    case 'logout':
      ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        localStorage.clear()
        ElMessage.success('已退出登录')
        router.push('/login')
      }).catch(() => {})
      break
  }
}

// 保存个人信息
const saveProfile = async () => {
  if (!currentUserInfo || !currentUserInfo.userId) {
    ElMessage.warning('用户信息未找到，请重新登录')
    router.push('/login')
    return
  }

  try {
    const updateData = {
      id: currentUserInfo.userId,
      role: 1, // 教师角色
      realName: userForm.realName,
      teacherNo: userForm.teacherNo,
      email: userForm.email,
      phone: userForm.phone,
      department: userForm.department,
      title: userForm.title,
      avatar: userForm.avatar
    }
    const response = await request.post('/user/update', updateData)

    if (response.code === 200) {
      ElMessage.success('个人信息已保存')
      profileDialogVisible.value = false
      
      const updatedUserInfo = { ...currentUserInfo, ...updateData }
      localStorage.setItem('userInfo', JSON.stringify(updatedUserInfo))
      currentUserInfo = updatedUserInfo
    } else {
      ElMessage.error(response.message || '保存个人信息失败')
    }
  } catch (error) {
    console.error('保存个人信息失败:', error)
    ElMessage.error('网络错误，无法保存个人信息')
  }
}

// 打开修改密码对话框
const openPasswordDialog = () => {
  passwordDialogVisible.value = true
}

// 关闭修改密码对话框
const closePasswordDialog = () => {
  passwordDialogVisible.value = false
  if (passwordFormRef.value) {
    passwordFormRef.value.resetFields()
  }
  passwordForm.oldPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
}

// 修改密码
const changePassword = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid) => {
    if (!valid) return false
    
    if (!currentUserInfo || !currentUserInfo.userId) {
      ElMessage.warning('用户信息未找到，请重新登录')
      router.push('/login')
      return
    }
    
    try {
      const response = await request.post('/user/changePassword', {
        id: currentUserInfo.userId,
        oldPassword: passwordForm.oldPassword,
        newPassword: passwordForm.newPassword
      })
      
      if (response.code === 200) {
        ElMessage.success('密码修改成功，请重新登录')
        closePasswordDialog()
        profileDialogVisible.value = false
        
        setTimeout(() => {
          localStorage.clear()
          router.push('/login')
        }, 1500)
      } else {
        ElMessage.error(response.message || '密码修改失败')
      }
    } catch (error) {
      console.error('修改密码失败:', error)
      ElMessage.error('网络错误，无法修改密码')
    }
  })
}

const scrollToQuestion = (questionId) => {
  currentQuestionId.value = questionId
  setTimeout(() => {
    const el = document.getElementById('q-' + questionId)
    if (el) {
      el.scrollIntoView({ behavior: 'smooth', block: 'start' })
    }
  }, 10)
}

const typeLabel = (type) => {
  if (type === 1) return '单选题'
  if (type === 2) return '多选题'
  if (type === 3) return '判断题'
  if (type === 4) return '填空题'
  if (type === 5) return '简答题'
  return '题目'
}

const parseOptions = (options, type) => {
  try {
    if (type === 3 && !options) return { T: '正确', F: '错误' }
    if (!options) return {}
    if (typeof options === 'string') return JSON.parse(options)
    return options
  } catch (e) { return {} }
}

const perQuestionScore = (q) => {
  const answer = answerMap[q.id]
  let scoreText = '-'
  if (answer && answer.score != null) {
    scoreText = `${answer.score} 分`
  } else if (q.type === 1 || q.type === 2 || q.type === 3) {
    scoreText = '0 分'
  }
  const userAnswerText = answer && answer.userAnswer
    ? formatAnswerText(q, answer.userAnswer)
    : '未作答'
  const comment = answer && answer.teacherComment ? answer.teacherComment : ''
  return { scoreText, userAnswerText, comment }
}

const formatAnswerText = (q, raw) => {
  if (raw == null || raw === '') return '-'
  let text = String(raw).trim()
  if (!text) return '-'

  const isJudgment = q && q.type === 3
  const isObjective = q && [1, 2, 3].includes(q.type)
  
  if (!isObjective) {
    return text
  }

  if (text.startsWith('[') && text.endsWith(']')) {
    try {
      const arr = JSON.parse(text)
      if (Array.isArray(arr)) {
        return arr.map(v => normalizeAnswerUnit(String(v), isJudgment)).join('、')
      }
    } catch (e) {}
  }

  if (text.includes(',')) {
    const parts = text.split(',').map(s => s.trim()).filter(Boolean)
    if (parts.length > 1) {
      return parts.map(s => normalizeAnswerUnit(s, isJudgment)).join('、')
    }
  }

  return normalizeAnswerUnit(text, isJudgment)
}

const normalizeAnswerUnit = (v, isJudgment = false) => {
  if (!v) return v
  const upper = v.toUpperCase()
  if (isJudgment) {
    if (upper === 'T' || upper === 'A' || upper === 'TRUE' || v === '正确') return '正确'
    if (upper === 'F' || upper === 'B' || upper === 'FALSE' || v === '错误') return '错误'
    return v
  }
  if (v.length === 1 && /^[a-zA-Z]$/.test(v)) {
    return upper
  }
  return v
}

const answerIncludesOption = (answerText, optionKey, question) => {
  if (!answerText || !optionKey) return false
  const isJudgment = question && question.type === 3
  const normalized = normalizeAnswerUnit(optionKey, isJudgment)
  return answerText.includes(optionKey) || answerText.includes(normalized)
}

onMounted(() => {
  loadData()
  window.addEventListener('scroll', handleScroll)
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>


<style scoped>
/* ============ 全局容器 ============ */
.student-exam-detail-container {
  min-height: 100vh;
  padding: 0;
  padding-top: 68px;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%);
  display: flex;
  flex-direction: column;
}

/* ============ 顶部导航栏 ============ */
.top-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  backdrop-filter: blur(16px);
  padding: 0 40px;
  height: 68px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 2px solid rgba(102, 126, 234, 0.08);
}

.top-nav::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 50%, #667eea 100%);
  opacity: 0.6;
}

.nav-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.title {
  font-size: 26px;
  font-weight: 700;
  margin: 0;
  letter-spacing: 0.5px;
}

.title-text {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
}

.user-name-left {
  font-size: 16px;
  color: #6a7a8a;
  margin: 0;
}


.nav-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.back-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: 2px solid transparent;
  border-radius: 12px;
  padding: 11px 24px;
  color: white;
  font-weight: 600;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-size: 14px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.25);
}

.back-button:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.35);
}

/* 用户头像下拉菜单 */
.user-avatar {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  padding: 6px 14px;
  border-radius: 12px;
  transition: all 0.3s;
}

.user-avatar:hover {
  background: rgba(102, 126, 234, 0.08);
}

.avatar-img {
  transition: transform 0.3s;
}

.user-avatar:hover .avatar-img {
  transform: scale(1.05);
}

.user-name {
  font-size: 15px;
  font-weight: 500;
  color: #303133;
  transition: all 0.3s;
}

.user-avatar:hover .user-name {
  color: #667eea;
}

/* 下拉菜单美化 */
:deep(.el-dropdown-menu) {
  border-radius: 12px;
  padding: 8px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(102, 126, 234, 0.06);
}

:deep(.el-dropdown-menu__item) {
  border-radius: 8px;
  padding: 10px 16px;
  transition: all 0.3s ease;
  font-size: 14px;
}

:deep(.el-dropdown-menu__item:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.05) 100%);
  color: #667eea;
}

/* ============ 加载状态 ============ */
.loading-container {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 24px;
}

.loading-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 24px 32px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  border-radius: 16px;
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.12);
  color: #667eea;
  font-size: 16px;
  font-weight: 500;
}

.loading-card :deep(.is-loading) {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* ============ 主要内容区域 ============ */
.detail-body {
  flex: 1;
  max-width: 1280px;
  width: 100%;
  margin: 0 auto;
  padding: 32px 24px;
  display: flex;
  gap: 28px;
}


/* ============ 题目导航侧边栏 ============ */
.questions-nav {
  flex-shrink: 0;
  width: 120px;
  position: sticky;
  top: 100px;
  height: fit-content;
  padding: 16px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
}

.nav-header {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.nav-title {
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.nav-progress {
  font-size: 18px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.nav-stats {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  padding: 8px 0;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.nav-stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.nav-stat-item.correct { color: #22c55e; }
.nav-stat-item.wrong { color: #ef4444; }

.stat-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.nav-stat-item.correct .stat-dot { background: #22c55e; }
.nav-stat-item.wrong .stat-dot { background: #ef4444; }

.nav-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 6px;
}

.nav-item {
  width: 100%;
  aspect-ratio: 1;
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 10px;
  background: rgba(249, 250, 251, 0.8);
  color: #667eea;
  font-weight: 700;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
}

.nav-item:hover {
  background: rgba(249, 250, 251, 1);
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.1);
  transform: scale(1.05);
}

.nav-item.is-current {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.25);
  transform: scale(1.08);
}

.nav-item.is-correct {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  border-color: transparent;
  color: white;
}

.nav-item.is-wrong {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  border-color: transparent;
  color: white;
}

.nav-legend {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid rgba(102, 126, 234, 0.1);
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 11px;
  color: #6b7280;
}

.legend-dot {
  width: 12px;
  height: 12px;
  border-radius: 4px;
}

.legend-dot.correct { background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%); }
.legend-dot.wrong { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); }


/* ============ 详情内容区域 ============ */
.detail-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 32px;
}

/* ============ 统计卡片区域 ============ */
.stats-section {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  animation: fadeInUp 0.6s ease-out;
}

.stat-card {
  padding: 24px;
  border-radius: 16px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(12px);
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.08);
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.stat-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.2);
}

.stat-icon {
  flex-shrink: 0;
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  position: relative;
  z-index: 1;
}

.total-card .stat-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
}

.objective-card .stat-icon {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 8px 20px rgba(34, 197, 94, 0.3);
}

.subjective-card .stat-icon {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 8px 20px rgba(249, 115, 22, 0.3);
}

.stat-content {
  flex: 1;
  position: relative;
  z-index: 1;
}

.stat-label {
  font-size: 13px;
  color: #6b7280;
  font-weight: 500;
  margin-bottom: 6px;
}

.stat-value {
  font-size: 28px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* ============ 试题详情区域 ============ */
.questions-section {
  animation: fadeInUp 0.6s ease-out 0.1s both;
}

.empty-state {
  padding: 60px 24px;
  text-align: center;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(12px);
  border-radius: 16px;
  border: 2px dashed rgba(102, 126, 234, 0.1);
}

.empty-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.empty-state p {
  margin: 0;
  font-size: 16px;
  color: #9ca3af;
}

.question-list {
  display: flex;
  flex-direction: column;
  gap: 24px;
}


/* ============ 题目卡片 ============ */
.question-card {
  padding: 28px 32px;
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(16px);
  border: 2px solid rgba(102, 126, 234, 0.12);
  box-shadow: 0 6px 24px rgba(102, 126, 234, 0.1);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  animation: fadeInUp 0.6s ease-out;
}

.question-card::before {
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

.question-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.2);
}

.question-card:hover::before {
  opacity: 1;
}

.question-card.is-correct-card {
  border-color: rgba(34, 197, 94, 0.2);
}

.question-card.is-correct-card::before {
  background: linear-gradient(90deg, #22c55e 0%, #16a34a 50%, #22c55e 100%);
  opacity: 1;
}

.question-card.is-wrong-card {
  border-color: rgba(239, 68, 68, 0.2);
}

.question-card.is-wrong-card::before {
  background: linear-gradient(90deg, #ef4444 0%, #dc2626 50%, #ef4444 100%);
  opacity: 1;
}

/* ============ 题目头部 ============ */
.question-header {
  display: flex;
  align-items: flex-start;
  gap: 18px;
  margin-bottom: 24px;
  padding-bottom: 20px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.1);
}

.q-number-badge {
  flex-shrink: 0;
  width: 48px;
  height: 48px;
  border-radius: 14px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 800;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.2);
}

.q-number-badge.correct {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.3);
}

.q-number-badge.wrong {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
}

.q-main-info {
  flex: 1;
  min-width: 0;
}

.q-content {
  font-size: 17px;
  font-weight: 500;
  line-height: 1.9;
  color: #1e293b;
  margin-bottom: 14px;
  word-wrap: break-word;
  white-space: pre-wrap;
  letter-spacing: 0.01em;
}

.q-tags {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.q-type-tag,
.q-score-tag {
  padding: 6px 14px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.q-type-tag {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.12) 0%, rgba(118, 75, 162, 0.12) 100%);
  color: #667eea;
  border: 1.5px solid rgba(102, 126, 234, 0.25);
}

.q-score-tag {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.12) 0%, rgba(234, 88, 12, 0.12) 100%);
  color: #f97316;
  border: 1.5px solid rgba(249, 115, 22, 0.25);
}

.q-result-tag {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 14px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  white-space: nowrap;
}

.q-result-tag.correct {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.12) 0%, rgba(22, 163, 74, 0.12) 100%);
  color: #16a34a;
  border: 1.5px solid rgba(34, 197, 94, 0.25);
}

.q-result-tag.wrong {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.12) 0%, rgba(220, 38, 38, 0.12) 100%);
  color: #dc2626;
  border: 1.5px solid rgba(239, 68, 68, 0.25);
}


/* 得分显示 */
.q-score-display {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 20px;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 12px;
  border: 2px solid rgba(102, 126, 234, 0.1);
}

.q-score-display .score-label {
  font-size: 12px;
  color: #6b7280;
  margin-bottom: 4px;
}

.q-score-display .score-number {
  font-size: 24px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.q-score-display .score-number.full {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.q-score-display .score-number.zero {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

/* 题目图片样式 */
.q-image-wrapper {
  margin: 20px 0;
  padding: 16px;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 16px;
  border: 2px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
  display: flex;
  justify-content: center;
  align-items: center;
}

.q-image-wrapper:hover {
  border-color: rgba(102, 126, 234, 0.25);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.15);
  transform: translateY(-2px);
}

.q-image {
  max-width: 100%;
  width: auto;
  height: auto;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.q-image:hover {
  transform: scale(1.02);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

/* ============ 题目选项 ============ */
.question-options {
  margin: 20px 0;
  padding: 16px 0;
  border-top: 1px solid rgba(102, 126, 234, 0.08);
  border-bottom: 1px solid rgba(102, 126, 234, 0.08);
}

.options-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.option-card {
  padding: 12px 14px;
  border-radius: 12px;
  background: rgba(249, 250, 251, 0.8);
  border: 2px solid rgba(102, 126, 234, 0.1);
  display: flex;
  align-items: flex-start;
  gap: 10px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: default;
}

.option-card:hover {
  background: rgba(249, 250, 251, 1);
  border-color: rgba(102, 126, 234, 0.15);
}

.option-card.is-correct {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.08) 0%, rgba(22, 163, 74, 0.08) 100%);
  border-color: rgba(34, 197, 94, 0.3);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.1);
}

.option-card.is-selected:not(.is-correct) {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.08) 0%, rgba(234, 88, 12, 0.08) 100%);
  border-color: rgba(249, 115, 22, 0.3);
  box-shadow: 0 4px 12px rgba(249, 115, 22, 0.1);
}

.option-card.is-correct.is-selected {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.12) 0%, rgba(22, 163, 74, 0.12) 100%);
  border-color: rgba(34, 197, 94, 0.4);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.15);
}

.option-card.is-wrong-selected {
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.08) 0%, rgba(220, 38, 38, 0.08) 100%);
  border-color: rgba(239, 68, 68, 0.3);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.1);
}

.option-key {
  flex-shrink: 0;
  width: 28px;
  height: 28px;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: 700;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.2);
}

.option-card.is-correct .option-key {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 2px 8px rgba(34, 197, 94, 0.2);
}

.option-card.is-selected:not(.is-correct) .option-key {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 2px 8px rgba(249, 115, 22, 0.2);
}

.option-card.is-wrong-selected .option-key {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  box-shadow: 0 2px 8px rgba(239, 68, 68, 0.2);
}

.option-text {
  flex: 1;
  font-size: 14px;
  color: #4b5563;
  line-height: 1.5;
  word-break: break-word;
}

.option-card.is-correct .option-text {
  color: #166534;
  font-weight: 500;
}

.option-card.is-selected:not(.is-correct) .option-text {
  color: #c2410c;
  font-weight: 500;
}

.option-card.is-wrong-selected .option-text {
  color: #b91c1c;
  font-weight: 500;
}

.option-status {
  flex-shrink: 0;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.option-status .correct-icon {
  color: #22c55e;
  font-size: 18px;
}

.option-status .wrong-icon {
  color: #ef4444;
  font-size: 18px;
}


/* ============ 答案对比区域 ============ */
.answer-comparison {
  display: flex;
  gap: 16px;
  margin-top: 20px;
  padding: 16px;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-radius: 12px;
  border: 1px solid rgba(102, 126, 234, 0.1);
}

.comparison-item {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: white;
  border-radius: 10px;
  border: 2px solid rgba(102, 126, 234, 0.1);
}

.comparison-item.correct-answer {
  border-color: rgba(34, 197, 94, 0.2);
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.04) 0%, rgba(22, 163, 74, 0.04) 100%);
}

.comparison-item.user-answer.is-correct {
  border-color: rgba(34, 197, 94, 0.3);
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.08) 0%, rgba(22, 163, 74, 0.08) 100%);
}

.comparison-item.user-answer.is-wrong {
  border-color: rgba(239, 68, 68, 0.3);
  background: linear-gradient(135deg, rgba(239, 68, 68, 0.08) 0%, rgba(220, 38, 38, 0.08) 100%);
}

.comparison-label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  white-space: nowrap;
}

.comparison-item.correct-answer .comparison-label { color: #16a34a; }
.comparison-item.user-answer.is-correct .comparison-label { color: #16a34a; }
.comparison-item.user-answer.is-wrong .comparison-label { color: #dc2626; }

.comparison-value {
  flex: 1;
  font-size: 16px;
  font-weight: 700;
  color: #1e293b;
}

.comparison-item.correct-answer .comparison-value { color: #16a34a; }
.comparison-item.user-answer.is-correct .comparison-value { color: #16a34a; }
.comparison-item.user-answer.is-wrong .comparison-value { color: #dc2626; }

/* ============ 主观题答案区域 ============ */
.subjective-answer-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-top: 20px;
}

.answer-block {
  padding: 16px 20px;
  border-radius: 12px;
  border: 2px solid rgba(102, 126, 234, 0.1);
}

.answer-block-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 12px;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

.user-answer-block {
  background: linear-gradient(135deg, rgba(249, 115, 22, 0.04) 0%, rgba(234, 88, 12, 0.04) 100%);
  border-color: rgba(249, 115, 22, 0.2);
}

.user-answer-block .answer-block-header { color: #ea580c; }

.correct-answer-block {
  background: linear-gradient(135deg, rgba(34, 197, 94, 0.04) 0%, rgba(22, 163, 74, 0.04) 100%);
  border-color: rgba(34, 197, 94, 0.2);
}

.correct-answer-block .answer-block-header { color: #16a34a; }

.answer-block-content {
  font-size: 15px;
  line-height: 1.8;
  color: #374151;
  white-space: pre-wrap;
  word-break: break-word;
}

/* ============ 教师批改意见 ============ */
.teacher-comment-section {
  margin-top: 20px;
  padding: 16px 20px;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.06) 0%, rgba(168, 85, 247, 0.06) 100%);
  border-radius: 12px;
  border: 2px solid rgba(139, 92, 246, 0.15);
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 700;
  color: #8b5cf6;
  margin-bottom: 12px;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(139, 92, 246, 0.15);
}

.comment-content {
  font-size: 15px;
  line-height: 1.8;
  color: #6b21a8;
  padding: 12px 16px;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 8px;
  border-left: 4px solid #8b5cf6;
}

/* ============ 返回顶部按钮 ============ */
.back-to-top {
  position: fixed;
  bottom: 40px;
  right: 40px;
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  cursor: pointer;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 999;
}

.back-to-top:hover {
  transform: translateY(-4px) scale(1.1);
  box-shadow: 0 8px 30px rgba(102, 126, 234, 0.5);
}

/* ============ 动画 ============ */
@keyframes fadeInUp {
  0% { opacity: 0; transform: translateY(20px); }
  100% { opacity: 1; transform: translateY(0); }
}


/* ============ 响应式设计 ============ */
@media (max-width: 960px) {
  .top-nav {
    height: 60px;
    padding: 0 16px;
  }

  .title {
    font-size: 18px;
  }

  .user-name-left {
    display: none;
  }

  .detail-body {
    flex-direction: column;
    padding: 24px 16px;
    gap: 24px;
  }

  .questions-nav {
    width: 100%;
    position: relative;
    top: auto;
  }

  .nav-grid {
    grid-template-columns: repeat(6, 1fr);
  }

  .stats-section {
    grid-template-columns: 1fr;
    gap: 16px;
  }

  .stat-card {
    padding: 20px;
  }

  .stat-icon {
    width: 48px;
    height: 48px;
    font-size: 24px;
  }

  .stat-value {
    font-size: 24px;
  }

  .question-card {
    padding: 16px;
  }

  .question-header {
    gap: 12px;
    margin-bottom: 16px;
    padding-bottom: 12px;
  }

  .q-number-badge {
    width: 36px;
    height: 36px;
    font-size: 14px;
  }

  .q-content {
    font-size: 15px;
  }

  .options-grid {
    grid-template-columns: 1fr;
  }

  .answer-comparison {
    flex-direction: column;
  }
}

@media (max-width: 640px) {
  .top-nav {
    height: 56px;
    padding: 0 12px;
  }

  .title {
    font-size: 16px;
  }

  .detail-body {
    flex-direction: column;
    padding: 16px 12px;
    gap: 16px;
  }

  .questions-nav {
    width: 100%;
    padding: 12px;
  }

  .nav-grid {
    grid-template-columns: repeat(8, 1fr);
    gap: 4px;
  }

  .nav-item {
    font-size: 11px;
  }

  .stat-card {
    padding: 16px;
    gap: 12px;
  }

  .stat-icon {
    width: 44px;
    height: 44px;
    font-size: 22px;
  }

  .stat-value {
    font-size: 20px;
  }

  .question-card {
    padding: 14px;
  }

  .question-header {
    gap: 10px;
    margin-bottom: 14px;
    padding-bottom: 10px;
  }

  .q-number-badge {
    width: 32px;
    height: 32px;
    font-size: 12px;
  }

  .q-content {
    font-size: 14px;
  }

  .q-tags {
    gap: 6px;
  }

  .q-type-tag,
  .q-score-tag {
    padding: 3px 10px;
    font-size: 11px;
  }

  .options-grid {
    grid-template-columns: 1fr;
  }

  .option-card {
    padding: 10px 12px;
  }

  .option-key {
    width: 26px;
    height: 26px;
    font-size: 12px;
  }

  .option-text {
    font-size: 13px;
  }
}

/* ============ 个人信息对话框样式 ============ */
.profile-dialog :deep(.el-dialog__header) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  margin: 0;
}

.profile-dialog :deep(.el-dialog__title) {
  color: white;
  font-size: 18px;
  font-weight: 600;
}

.profile-dialog :deep(.el-dialog__headerbtn .el-icon) {
  color: white;
  font-size: 18px;
}

.profile-dialog :deep(.el-dialog__body) {
  padding: 30px;
}

.profile-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #606266;
}

.profile-form :deep(.el-input.is-disabled .el-input__wrapper) {
  background-color: #f5f7fa;
  cursor: not-allowed;
}

.profile-form :deep(.el-input.is-disabled .el-input__inner) {
  color: #909399;
}

.profile-form :deep(.el-divider__text) {
  background-color: white;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.dialog-footer .el-button {
  min-width: 100px;
  border-radius: 8px;
  font-weight: 500;
}

.dialog-footer .el-button--primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: all 0.3s;
}

.dialog-footer .el-button--primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

/* 修改密码按钮区域 */
.password-section {
  padding: 20px 30px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05) 0%, rgba(118, 75, 162, 0.05) 100%);
  border-radius: 8px;
  margin-top: 16px;
  text-align: center;
}

.change-password-btn {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
  border: 2px solid rgba(102, 126, 234, 0.2);
  color: #667eea;
  font-weight: 600;
  border-radius: 8px;
  padding: 10px 24px;
  transition: all 0.3s;
}

.change-password-btn:hover {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: transparent;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.3);
}

/* 修改密码对话框样式 */
.password-dialog :deep(.el-dialog__header) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  margin: 0;
}

.password-dialog :deep(.el-dialog__title) {
  color: white;
  font-size: 18px;
  font-weight: 600;
}

.password-dialog :deep(.el-dialog__headerbtn .el-icon) {
  color: white;
  font-size: 18px;
}

.password-dialog :deep(.el-dialog__body) {
  padding: 30px;
}

.password-form :deep(.el-form-item__label) {
  font-weight: 500;
  color: #606266;
}

.password-form :deep(.el-input__wrapper) {
  border-radius: 8px;
  transition: all 0.3s;
}

.password-form :deep(.el-input__wrapper:hover) {
  border-color: #667eea;
}

.password-form :deep(.el-input__wrapper.is-focus) {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.password-tips {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px;
  background: #ecf5ff;
  border-radius: 8px;
  margin-top: 10px;
  font-size: 13px;
  color: #606266;
}

.password-tips .el-icon {
  font-size: 16px;
}
</style>
