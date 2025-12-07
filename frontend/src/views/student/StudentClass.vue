<template>
  <div class="student-class-container">
    <div class="top-nav">
      <div class="nav-left">
        <h1 class="title">
          <span class="title-text">明德大数据</span>
        </h1>
        <span class="user-name-left">{{ userInfo.realName || '学生' }}</span>
      </div>
      
      <div class="nav-right">
        <el-button class="back-button" @click="goToHomePage">
          <el-icon><Back /></el-icon>
          返回主页
        </el-button>
        
        <!-- 用户头像下拉菜单 -->
        <el-dropdown @command="handleCommand">
          <div class="user-avatar">
            <el-avatar 
              :size="42" 
              :icon="userInfo.avatar ? undefined : UserFilled" 
              :src="userInfo.avatar ? 'http://localhost:8080/api' + userInfo.avatar : undefined"
              class="avatar-img" 
            />
            <span class="user-name">{{ userInfo.realName || '个人设置' }}</span>
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

    <div class="main-content">
      <div class="exam-section">
        <div class="section-header">
          <h2 class="section-title"><span class="title-dot"></span>我的考试</h2>
        </div>

        <div class="stats-cards">
          <div 
            class="stat-card"
            :class="{ 'is-active': selectedStatus === 'unfinished', 'stat-card-pending': true }"
            @click="selectStatus('unfinished')"
          >
            <div class="stat-icon-wrapper">
              <div class="stat-icon"><el-icon><Document /></el-icon></div>
              <div class="icon-bg-circle"></div>
            </div>
            <div class="stat-content">
              <div class="stat-label">未完成</div>
              <div class="stat-value-wrapper">
                <div class="stat-value">{{ examStats.unfinished }}</div>
                <span class="stat-unit">场</span>
              </div>
            </div>
          </div>
          <div 
            class="stat-card"
            :class="{ 'is-active': selectedStatus === 'to_be_graded', 'stat-card-to_be_graded': true }"
            @click="selectStatus('to_be_graded')"
          >
            <div class="stat-icon-wrapper">
              <div class="stat-icon"><el-icon><Edit /></el-icon></div>
              <div class="icon-bg-circle"></div>
            </div>
            <div class="stat-content">
              <div class="stat-label">待批改</div>
              <div class="stat-value-wrapper">
                <div class="stat-value">{{ examStats.to_be_graded }}</div>
                <span class="stat-unit">场</span>
              </div>
            </div>
          </div>
          <div 
            class="stat-card"
            :class="{ 'is-active': selectedStatus === 'graded', 'stat-card-graded': true }"
            @click="selectStatus('graded')"
          >
            <div class="stat-icon-wrapper">
              <div class="stat-icon"><el-icon><CircleCheck /></el-icon></div>
              <div class="icon-bg-circle"></div>
            </div>
            <div class="stat-content">
              <div class="stat-label">已批改</div>
              <div class="stat-value-wrapper">
                <div class="stat-value">{{ examStats.graded }}</div>
                <span class="stat-unit">场</span>
              </div>
            </div>
          </div>
        </div>

        <div class="recent-exams-wrapper"> <!-- New wrapper for styling -->
          <div class="list-title-wrapper">
            <h3 
              class="list-title"
              :class="{ 'is-active': selectedStatus === '' }"
              @click="selectStatus('')"
            >
              <span class="title-dot"></span>
              全部考试
            </h3>
            <template v-if="selectedStatus !== ''">
              <span class="list-title-divider">/</span>
              <h3 class="list-title sub-title">{{ listTitle }}</h3>
            </template>
          </div>
          
          <div v-if="filteredExamList.length === 0" class="empty-list">
            <div class="empty-illustration">
              <div class="document-icon"></div>
              <div class="pencil-icon"></div>
            </div>
            <p class="empty-text">暂无考试安排</p>
            <p class="empty-subtext">等待教师发布考试后，将在这里显示</p>
          </div>
          <div v-else class="exam-list">
            <div 
              v-for="(examRecord, index) in filteredExamList" 
              :key="examRecord.id"
              class="exam-card"
              :data-status="getRealtimeExamStatus(examRecord)"
              :style="{ animationDelay: `${0.3 + index * 0.05}s` }"
              @click="goToExamAction(examRecord)"
            >
              <div class="exam-header">
                <div class="exam-name-wrapper">
                  <div class="exam-name">{{ examRecord.examTitle }}</div>
                  <div class="exam-name-underline"></div>
                </div>
                <div class="exam-header-right">
                  <el-tag 
                    :type="getExamStatusType(examRecord)" 
                    size="small"
                    class="exam-status-tag"
                    effect="plain"
                  >
                    {{ getExamStatusText(examRecord) }}
                  </el-tag>
                  <div
                    v-if="getRealtimeExamStatus(examRecord) === 'graded' && examRecord.totalScore !== null"
                    class="exam-score-pill"
                  >
                    <span class="exam-score-label">得分</span>
                    <span class="exam-score-value">{{ examRecord.totalScore }}分</span>
                  </div>
                </div>
              </div>
              
              <div class="exam-time">
                <div class="time-item">
                  <div class="time-icon-bg">
                    <el-icon class="time-icon"><Timer /></el-icon>
                  </div>
                  <span class="time-label">开始</span>
                  <span class="time-value">{{ formatTime(examRecord.examStartTime) }}</span>
                </div>
                <div class="time-divider"></div>
                <div class="time-item">
                  <div class="time-icon-bg">
                    <el-icon class="time-icon"><Timer /></el-icon>
                  </div>
                  <span class="time-label">截止</span>
                  <span class="time-value">{{ formatTime(examRecord.examEndTime) }}</span>
                </div>
              </div>

              <div class="exam-footer">
                <div class="exam-info">
                  <span class="info-item">
                    <div class="info-icon-wrapper">
                      <el-icon><Reading /></el-icon>
                    </div>
                    <span class="info-text">
                      <span class="info-label">客观</span>
                      <span class="info-value">{{ examRecord.objectiveScore !== null ? examRecord.objectiveScore : '-' }}分</span>
                    </span>
                  </span>
                  <span class="info-item">
                    <div class="info-icon-wrapper">
                      <el-icon><TrophyBase /></el-icon>
                    </div>
                    <span class="info-text">
                      <span class="info-label">主观</span>
                      <span class="info-value">{{ examRecord.subjectiveScore !== null ? examRecord.subjectiveScore : '-' }}分</span>
                    </span>
                  </span>
                  <span class="info-item">
                    <div class="info-icon-wrapper">
                      <el-icon><TrophyBase /></el-icon>
                    </div>
                    <span class="info-text">
                      <span class="info-label">总分</span>
                      <span class="info-value">{{ examRecord.totalScore !== null ? examRecord.totalScore : '-' }}分</span>
                    </span>
                  </span>
                </div>
                <div 
                  class="enter-button"
                  :class="{ 'is-disabled': !isExamCardButtonClickable(examRecord) }"
                  @click.stop="goToExamAction(examRecord)"
                >
                  <span>{{ getExamCardButtonText(examRecord) }}</span>
                  <el-icon class="arrow-icon"><ArrowRight /></el-icon>
                </div>
              </div>
            </div>
          </div>
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
        <el-form-item label="学号">
          <el-input v-model="userForm.studentNo" disabled>
            <template #suffix>
              <el-icon color="#909399"><Lock /></el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-divider content-position="left">
          <span style="color: #909399; font-size: 13px;">可修改信息</span>
        </el-divider>
        <el-form-item label="邮箱">
          <el-input 
            v-model="userForm.email" 
            placeholder="请输入邮箱"
            clearable
            type="email"
          />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input 
            v-model="userForm.phone" 
            placeholder="请输入手机号" 
            maxlength="11"
            clearable
          />
        </el-form-item>
      </el-form>
      <div class="password-section">
        <el-button 
          @click="openPasswordDialog" 
          :icon="Key" 
          class="change-password-btn"
        >
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
          <el-input 
            v-model="passwordForm.oldPassword" 
            type="password" 
            placeholder="请输入旧密码"
            show-password
            clearable
          />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input 
            v-model="passwordForm.newPassword" 
            type="password" 
            placeholder="请输入新密码（6-20位）"
            show-password
            clearable
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input 
            v-model="passwordForm.confirmPassword" 
            type="password" 
            placeholder="请再次输入新密码"
            show-password
            clearable
          />
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
import { ref, onMounted, onBeforeUnmount, computed, reactive } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage, ElMessageBox, ElLoading, ElDropdown, ElDropdownMenu, ElDropdownItem, ElAvatar } from 'element-plus';
import request from '@/utils/request';
import { Clock, CircleCheck, CircleClose, Timer, Reading, TrophyBase, ArrowRight, Back, Document, UserFilled, User, Setting, SwitchButton, Edit, Lock, Key, InfoFilled } from '@element-plus/icons-vue';
import AvatarUpload from '@/components/AvatarUpload.vue';

const route = useRoute();
const router = useRouter();
const classId = ref(null);
const className = ref('班级名称');
const teacherName = ref('老师姓名');
const examList = ref([]);
const filteredExamList = ref([]);
const selectedStatus = ref('');
const examStats = ref({
  unfinished: 0,
  to_be_graded: 0,
  graded: 0,
});

// 驱动前端时间变化的引用，用于在考试结束时自动刷新状态
const nowRef = ref(Date.now());
let statusTimer = null;
let lastAutoRefreshAt = 0;

// 用户信息
const userInfo = reactive({
  id: '',
  username: '',
  realName: '',
  studentNo: '',
  className: '',
  email: '',
  phone: '',
  avatar: '',
});

// 个人信息表单
const userForm = reactive({ ...userInfo });
const profileDialogVisible = ref(false);
const passwordDialogVisible = ref(false);

// 修改密码表单
const passwordFormRef = ref(null);
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
});

// 密码验证规则
const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入旧密码', trigger: 'blur' }
  ],
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
};

const listTitle = computed(() => {
  if (selectedStatus.value === 'unfinished') {
    return '未完成考试';
  } else if (selectedStatus.value === 'to_be_graded') {
    return '待批改考试';
  }
  else if (selectedStatus.value === 'graded') {
    return '已批改考试';
  }
  return '全部考试';
});

let currentUserInfo = null;
try {
  const storedUserInfo = localStorage.getItem('userInfo');
  if (storedUserInfo) {
    currentUserInfo = JSON.parse(storedUserInfo);
    // Populate userInfo reactive object
    Object.assign(userInfo, currentUserInfo);
  }
} catch (e) {
  console.error("Failed to parse userInfo from localStorage:", e);
}


onMounted(() => {
  classId.value = route.params.id;
  loadClassDetails();
  
  // 检查是否从批改界面返回（老师批改完后）
  if (sessionStorage.getItem('refreshExamListFromGrading') === 'true') {
    sessionStorage.removeItem('refreshExamListFromGrading');
    // 刷新考试列表以获取最新的批改状态
    loadExamList(true);
  } else {
    loadExamList(true);
  }

  // 定时刷新当前时间，从而重新计算考试实时状态
  statusTimer = setInterval(async () => {
    nowRef.value = Date.now();
    filterExams();
    updateExamStats();
    await autoRefreshExamListIfNeeded();
  }, 1000);
});

onBeforeUnmount(() => {
  if (statusTimer) {
    clearInterval(statusTimer);
    statusTimer = null;
  }
});

const loadClassDetails = async () => {
  try {
    const res = await request.get(`/class/${classId.value}`);
    if (res.code === 200) {
      className.value = res.data.name;
      teacherName.value = res.data.teacherName;
    } else {
      ElMessage.error(res.msg || '获取班级详情失败');
    }
  } catch (error) {
    console.error('获取班级详情失败:', error);
    ElMessage.error('网络错误，无法获取班级详情');
  }
};

const loadExamList = async (withLoading = true) => {
  let loadingInstance = null;
  try {
    if (withLoading) {
      loadingInstance = ElLoading.service({
        lock: true,
        text: '加载考试列表中...',
        background: 'rgba(255, 255, 255, 0.8)',
      });
    }

    if (!currentUserInfo || !currentUserInfo.userId) {
      console.error("Student ID not found for loading exam list. This should have been caught by router guard.");
      return;
    }

    const res = await request.get(`/examRecord/student/${currentUserInfo.userId}/class/${classId.value}`);
    if (res.code === 200) {
      examList.value = res.data;
      filterExams();
      updateExamStats();
    } else {
      ElMessage.error(res.msg || '获取考试列表失败');
    }
  } catch (error) {
    console.error('获取考试列表失败:', error);
    ElMessage.error('网络错误，无法获取考试列表');
  } finally {
    if (loadingInstance) {
      loadingInstance.close();
    }
  }
};

// 到达考试截止时间后，自动从后端刷新一次列表以获取最新批改状态
const autoRefreshExamListIfNeeded = async () => {
  const now = nowRef.value;
  if (!examList.value || examList.value.length === 0) return;

  const needRefresh = examList.value.some(examRecord => {
    if (!examRecord || !examRecord.examEndTime) return false;
    const end = new Date(examRecord.examEndTime).getTime();
    if (!end) return false;
    // 对于还未标记为已批改的考试，在截止时间之后触发一次刷新
    return now >= end && examRecord.status !== 2;
  });

  if (needRefresh && now - lastAutoRefreshAt > 5000) {
    lastAutoRefreshAt = now;
    await loadExamList(false);
  }
};

const getRealtimeExamStatus = (examRecord) => {
  const now = new Date(nowRef.value);
  const examEndTime = new Date(examRecord.examEndTime);

  if (examRecord.status === 2) {
    return 'graded'; // 已批改
  }
  if (examRecord.status === 1) {
    return 'to_be_graded'; // 待批改
  }
  
  if (examRecord.status === 0) {
    if (now > examEndTime) {
      return 'to_be_graded'; // 考试时间已截止，但未提交，也视为待批改
    }
    return 'unfinished'; // 未到截止时间，或已到开始时间正在进行中
  }
  return 'unfinished'; // 默认未完成
};

const getExamStatusType = (examRecord) => {
  const status = getRealtimeExamStatus(examRecord);
  if (status === 'unfinished') return 'info';
  if (status === 'to_be_graded') return 'warning';
  if (status === 'graded') return 'success'; // 改回 success 绿色
  return 'info';
};

const getExamStatusText = (examRecord) => {
  const status = getRealtimeExamStatus(examRecord);
  const now = new Date();
  const examStartTime = new Date(examRecord.examStartTime); 
  const examEndTime = new Date(examRecord.examEndTime);

  if (status === 'graded') return '已批改'; // 改回已批改
  if (status === 'to_be_graded') {
    if (examRecord.submitTime) return '已提交'; // 已经提交的
    return '已截止'; // 时间截止但未提交的
  }
  if (status === 'unfinished') {
    if (now < examStartTime) return '未开始';
    if (now >= examStartTime && now <= examEndTime) return '进行中';
    if (now > examEndTime) return '已截止'; // 考试时间已过但未提交
  }
  return '未知状态';
};

const getExamCardButtonText = (examRecord) => {
  const status = getRealtimeExamStatus(examRecord);
  const now = new Date();
  const examStartTime = new Date(examRecord.examStartTime);
  const examEndTime = new Date(examRecord.examEndTime);

  if (status === 'graded') return '查看详情';
  if (status === 'to_be_graded') {
    if (examRecord.submitTime) return '等待批改'; // 已提交的
    return '已截止'; // 时间截止但未提交的
  }
  if (status === 'unfinished') {
    if (now < examStartTime) return '即将开始';
    if (now >= examStartTime && now <= examEndTime) return '进入考试';
    if (now > examEndTime) return '已截止';
  }
  return '未知操作';
};

const isExamCardButtonClickable = (examRecord) => {
  const status = getRealtimeExamStatus(examRecord);
  const now = new Date();
  const examStartTime = new Date(examRecord.examStartTime);
  const examEndTime = new Date(examRecord.examEndTime);

  // 已批改状态：仅在考试结束后才能查看详情
  if (status === 'graded') {
    return now > examEndTime;
  }
  
  // 未完成状态下，到达考试时间可以进入考试
  if (status === 'unfinished' && now >= examStartTime && now <= examEndTime) return true;

  // 已截止但未提交的，也可以进入详情查看 (虽然可能没有得分)
  if (status === 'to_be_graded' && now > examEndTime && !examRecord.submitTime) return true; 

  return false;
};

const goToExamAction = async (examRecord) => {
  const now = new Date();
  const examStartTime = new Date(examRecord.examStartTime);
  const examEndTime = new Date(examRecord.examEndTime);
  const status = getRealtimeExamStatus(examRecord);
  if (!currentUserInfo || !currentUserInfo.userId) {
    console.error("Student ID not found for exam action. This should have been caught by router guard.");
    return;
  }

  if (!isExamCardButtonClickable(examRecord)) {
    let message = '当前考试无法进入';
    if (status === 'graded' && now <= examEndTime) {
      message = '考试尚未结束，成绩将在考试结束后开放查看。';
    } else if (now < examStartTime) {
      message = '考试尚未开始，请耐心等待！';
    } else if (status === 'to_be_graded' && examRecord.submitTime) {
      message = '考试已提交，正在等待老师批改结果！';
    } else if (status === 'to_be_graded' && now > examEndTime && !examRecord.submitTime) {
      message = '考试已截止，您未能按时提交，请查看详情！'; // 提示查看详情
    } else if (now > examEndTime && status === 'unfinished') {
      message = '考试已截止，您未能按时提交！';
    }
    ElMessage.warning(message);
    return;
  }

  if (status === 'graded' || (status === 'to_be_graded' && now > examEndTime && !examRecord.submitTime)) {
    router.push(`/student/exam-detail/${examRecord.id}`);
  } else if (status === 'unfinished' && now >= examStartTime && now <= examEndTime) {
    // 可选：提前start以便记录时间；即使失败，进入考试页也会再次尝试start
    try {
      await request.post('/examRecord/start', null, {
        params: { studentId: currentUserInfo.userId, examId: examRecord.examId }
      });
    } catch (_) { /* ignore */ }
    ElMessage.success(`即将进入考试：${examRecord.examTitle}`);
    router.push(`/student/exam/${examRecord.examId}`);
    await loadExamList();
  }
};

const formatTime = (timeString) => {
  if (!timeString) return '-';
  const date = new Date(timeString);
  return date.toLocaleString('zh-CN', { hour12: false });
};

const filterExams = () => {
  if (selectedStatus.value === '') {
    filteredExamList.value = examList.value;
  } else if (selectedStatus.value === 'unfinished') {
    filteredExamList.value = examList.value.filter(examRecord => 
      getRealtimeExamStatus(examRecord) === 'unfinished'
    );
  } else if (selectedStatus.value === 'to_be_graded') {
    filteredExamList.value = examList.value.filter(examRecord => 
      getRealtimeExamStatus(examRecord) === 'to_be_graded'
    );
  } else if (selectedStatus.value === 'graded') {
    filteredExamList.value = examList.value.filter(examRecord => 
      getRealtimeExamStatus(examRecord) === 'graded'
    );
  }
};

const updateExamStats = () => {
  let unfinishedCount = 0;
  let toBeGradedCount = 0;
  let gradedCount = 0;

  examList.value.forEach(examRecord => {
    const status = getRealtimeExamStatus(examRecord);
    if (status === 'unfinished') {
      unfinishedCount++;
    }
    else if (status === 'to_be_graded') {
      toBeGradedCount++;
    }
    else if (status === 'graded') {
      gradedCount++;
    }
  });

  examStats.value.unfinished = unfinishedCount;
  examStats.value.to_be_graded = toBeGradedCount;
  examStats.value.graded = gradedCount;
};

const selectStatus = (status) => {
  selectedStatus.value = status;
  filterExams();
};

const goToHomePage = () => {
  router.push('/student/home');
};

// 处理用户菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      if (currentUserInfo) {
        Object.assign(userForm, currentUserInfo);
      }
      profileDialogVisible.value = true;
      break;
    // case 'settings':
    //   ElMessage.info('设置功能开发中...');
    //   break;
    case 'logout':
      handleLogout();
      break;
  }
};

// 退出登录
const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    localStorage.clear();
    ElMessage.success('已退出登录');
    router.push('/login');
  }).catch(() => {});
};

// 保存个人信息
const saveProfile = async () => {
  if (!currentUserInfo || !currentUserInfo.userId) {
    ElMessage.warning('用户信息未找到，请重新登录');
    router.push('/login');
    return;
  }

  try {
    const updateData = {
      id: currentUserInfo.userId,
      role: 0, // 学生角色
      realName: userForm.realName,
      studentNo: userForm.studentNo,
      major: userForm.major,
      email: userForm.email,
      phone: userForm.phone,
      avatar: userForm.avatar
    };
    const response = await request.post('/user/update', updateData);

    if (response.code === 200) {
      ElMessage.success('个人信息已保存');
      profileDialogVisible.value = false;
      
      const updatedUserInfo = { ...currentUserInfo, ...updateData };
      localStorage.setItem('userInfo', JSON.stringify(updatedUserInfo));
      Object.assign(userInfo, updatedUserInfo);
      currentUserInfo = updatedUserInfo;
    } else {
      ElMessage.error(response.message || '保存个人信息失败');
    }
  } catch (error) {
    console.error('保存个人信息失败:', error);
    ElMessage.error('网络错误，无法保存个人信息');
  }
};

// 打开修改密码对话框
const openPasswordDialog = () => {
  passwordDialogVisible.value = true;
};

// 关闭修改密码对话框
const closePasswordDialog = () => {
  passwordDialogVisible.value = false;
  if (passwordFormRef.value) {
    passwordFormRef.value.resetFields();
  }
  passwordForm.oldPassword = '';
  passwordForm.newPassword = '';
  passwordForm.confirmPassword = '';
};

// 修改密码
const changePassword = async () => {
  if (!passwordFormRef.value) return;
  
  await passwordFormRef.value.validate(async (valid) => {
    if (!valid) {
      return false;
    }
    
    if (!currentUserInfo || !currentUserInfo.userId) {
      ElMessage.warning('用户信息未找到，请重新登录');
      router.push('/login');
      return;
    }
    
    try {
      const response = await request.post('/user/changePassword', {
        id: currentUserInfo.userId,
        oldPassword: passwordForm.oldPassword,
        newPassword: passwordForm.newPassword
      });
      
      if (response.code === 200) {
        ElMessage.success('密码修改成功，请重新登录');
        closePasswordDialog();
        profileDialogVisible.value = false;
        
        setTimeout(() => {
          localStorage.clear();
          router.push('/login');
        }, 1500);
      } else {
        ElMessage.error(response.message || '密码修改失败');
      }
    } catch (error) {
      console.error('修改密码失败:', error);
      ElMessage.error('网络错误，无法修改密码');
    }
  });
};

</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

/* 整个页面容器 */
.student-class-container {
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%); /* Outer page background */
  font-family: 'Inter', 'PingFang SC', 'Helvetica Neue', Helvetica, 'microsoft yahei', Arial, sans-serif;
  min-height: 100vh; /* Ensure it takes full viewport height */
  padding-top: 75px; /* Adjust for fixed top-nav */
  position: relative;
  overflow-x: hidden;
}

.student-class-container::before {
  content: '';
  position: fixed;
  top: -50%;
  right: -10%;
  width: 800px;
  height: 800px;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.06) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

.student-class-container::after {
  content: '';
  position: fixed;
  bottom: -30%;
  left: -10%;
  width: 600px;
  height: 600px;
  background: radial-gradient(circle, rgba(118, 75, 162, 0.06) 0%, transparent 70%);
  border-radius: 50%;
  pointer-events: none;
  z-index: 0;
}

/* 顶部导航栏 */
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

.back-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s;
}

.back-button:hover::before {
  left: 100%;
}

.back-button:hover {
  transform: translateY(-3px) scale(1.02);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.35);
  filter: brightness(1.05);
}

.back-button:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

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

/* 下拉菜单美化（与老师端一致） */
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

/* 主要内容区 */
.main-content {
  flex: 1;
  padding: 30px;
  max-width: 1300px;
  margin: 0 auto;
  width: 100%;
  box-sizing: border-box;
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 20px;
  box-shadow: 0 8px 30px rgba(102, 126, 234, 0.12);
  margin-top: 30px;
  padding: 40px 45px;
  position: relative;
  z-index: 1;
  border: 2px solid rgba(102, 126, 234, 0.08);
}

.exam-section {
  padding: 0;
  animation: none;
}

.section-header {
  margin-bottom: 25px;
  display: flex;
  align-items: center;
}

.section-title {
  font-size: 26px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0 0 28px 0;
  position: relative;
  padding-left: 18px;
  cursor: default;
  letter-spacing: 0.5px;
}

.section-title .title-dot {
  content: '•';
  position: absolute;
  top: 5px;
  left: 0;
  font-size: 26px;
  color: #667eea;
  margin-right: 12px;
  transform: none;
  width: auto;
  height: auto;
  background-color: transparent;
  border-radius: 0;
}

/* 统计卡片 */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 18px;
  margin-bottom: 35px;
  padding-bottom: 0;
  border-bottom: none;
}

.stat-card {
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 16px;
  padding: 24px 28px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  display: flex;
  align-items: center;
  position: relative;
  overflow: hidden;
  border: 2px solid rgba(102, 126, 234, 0.1);
  opacity: 1;
  animation: fadeIn 0.6s ease-out forwards;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  flex-direction: row;
}

.stat-card:hover {
  transform: translateY(-5px) scale(1.02);
  box-shadow: 0 8px 30px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.3);
}

.stat-card:active {
  transform: translateY(-1px) scale(0.995);
  box-shadow: 0 1px 5px rgba(0, 0, 0, 0.03);
}

.stat-card.is-active {
  border-color: #667eea;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.25);
  background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
  transform: scale(1.03);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: -30px;
  right: -20px;
  width: 100px;
  height: 100px;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.12) 0%, transparent 70%);
  border-radius: 50%;
  filter: blur(20px);
  transform: rotate(20deg);
  transition: all 0.4s ease;
}

.stat-card::after {
  content: '';
  position: absolute;
  bottom: -15px;
  left: -15px;
  width: 60px;
  height: 60px;
  background: radial-gradient(circle, rgba(102, 126, 234, 0.03) 0%, transparent 70%);
  border-radius: 50%;
  filter: blur(10px);
  transform: rotate(-10deg);
  transition: all 0.3s ease;
}

/* 未完成卡片 - 蓝色主题 */
.stat-card-pending::before {
  background: radial-gradient(circle, rgba(59, 130, 246, 0.12) 0%, transparent 70%);
}

.stat-card-pending::after {
  background: radial-gradient(circle, rgba(59, 130, 246, 0.03) 0%, transparent 70%);
}

.stat-card-pending .stat-icon-wrapper {
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  border-color: rgba(59, 130, 246, 0.2);
}

.stat-card-pending .stat-icon {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-pending .stat-value {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-pending.is-active {
  border-color: #3b82f6;
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  box-shadow: 0 8px 25px rgba(59, 130, 246, 0.25);
}

.stat-card-pending:hover {
  border-color: rgba(59, 130, 246, 0.3);
  box-shadow: 0 8px 30px rgba(59, 130, 246, 0.15);
}

/* 待批改卡片 - 橙色主题 */
.stat-card-to_be_graded::before {
  background: radial-gradient(circle, rgba(249, 115, 22, 0.12) 0%, transparent 70%);
}

.stat-card-to_be_graded::after {
  background: radial-gradient(circle, rgba(249, 115, 22, 0.03) 0%, transparent 70%);
}

.stat-card-to_be_graded .stat-icon-wrapper {
  background: linear-gradient(135deg, #ffedd5 0%, #fed7aa 100%);
  border-color: rgba(249, 115, 22, 0.2);
}

.stat-card-to_be_graded .stat-icon {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-to_be_graded .stat-value {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-to_be_graded.is-active {
  border-color: #f97316;
  background: linear-gradient(135deg, #ffedd5 0%, #fed7aa 100%);
  box-shadow: 0 8px 25px rgba(249, 115, 22, 0.25);
}

.stat-card-to_be_graded:hover {
  border-color: rgba(249, 115, 22, 0.3);
  box-shadow: 0 8px 30px rgba(249, 115, 22, 0.15);
}

/* 已批改卡片 - 绿色主题 */
.stat-card-graded::before {
  background: radial-gradient(circle, rgba(34, 197, 94, 0.12) 0%, transparent 70%);
}

.stat-card-graded::after {
  background: radial-gradient(circle, rgba(34, 197, 94, 0.03) 0%, transparent 70%);
}

.stat-card-graded .stat-icon-wrapper {
  background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
  border-color: rgba(34, 197, 94, 0.2);
}

.stat-card-graded .stat-icon {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-graded .stat-value {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.stat-card-graded.is-active {
  border-color: #22c55e;
  background: linear-gradient(135deg, #dcfce7 0%, #bbf7d0 100%);
  box-shadow: 0 8px 25px rgba(34, 197, 94, 0.25);
}

.stat-card-graded:hover {
  border-color: rgba(34, 197, 94, 0.3);
  box-shadow: 0 8px 30px rgba(34, 197, 94, 0.15);
}

.stat-icon-wrapper {
  position: relative;
  width: 58px;
  height: 58px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20px;
  flex-shrink: 0;
  background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
  border-radius: 16px;
  border: 2px solid rgba(102, 126, 234, 0.12);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.stat-card:hover .stat-icon-wrapper {
  transform: scale(1.1) rotate(5deg);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.3);
}

.stat-card-pending:hover .stat-icon-wrapper {
  box-shadow: 0 6px 20px rgba(59, 130, 246, 0.15);
}

.stat-card-to_be_graded:hover .stat-icon-wrapper {
  box-shadow: 0 6px 20px rgba(249, 115, 22, 0.15);
}

.stat-card-graded:hover .stat-icon-wrapper {
  box-shadow: 0 6px 20px rgba(34, 197, 94, 0.15);
}

.stat-icon {
  font-size: 26px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  transition: all 0.3s ease;
}

.stat-content {
  flex-grow: 1;
  text-align: left;
}

.stat-label {
  font-size: 14px;
  color: #606266;
  margin-bottom: 4px;
  font-weight: 500;
}

.stat-value-wrapper {
  display: flex;
  align-items: baseline;
  justify-content: flex-start;
  gap: 4px;
}

.stat-value {
  font-size: 36px;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  line-height: 1.2;
}

.stat-unit {
  font-size: 13px;
  color: #909399;
  font-weight: 400;
}

.card-corner-accent {
  display: none;
}

/* 最近考试列表 - Wrapper for consistent background */
.recent-exams-wrapper {
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 16px;
  padding: 28px 32px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  margin-top: 30px;
  border: 2px solid rgba(102, 126, 234, 0.08);
}

.list-title-wrapper {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 0;
  border-bottom: none;
}

.list-title {
  font-size: 20px;
  color: #333;
  font-weight: 600;
  margin: 0;
  position: relative;
  cursor: default;
  transition: none;
  display: flex;
  align-items: center;
}

.list-title::after {
  display: none;
}

.list-title:hover {
  color: #333;
}

.list-title.is-active {
  color: #333;
}

.list-title .title-dot {
  width: 7px;
  height: 7px;
  background-color: #667eea;
  border-radius: 50%;
  margin-right: 10px;
  display: inline-block;
  flex-shrink: 0;
}

.list-title-divider {
  margin: 0 8px;
  font-size: 18px;
  color: #ccc;
}

.list-title.sub-title {
  font-size: 18px;
  color: #6a7a8a;
  cursor: default;
  transition: color 0.3s ease;
}

.empty-list {
  padding: 60px 0;
  text-align: center;
  background-color: #fdfdfd;
  border-radius: 10px;
  margin-top: 20px;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.02);
}

.empty-illustration {
  width: 100px;
  height: 100px;
  margin: 0 auto 25px;
  position: relative;
}

.document-icon {
  position: absolute;
  top: 10px;
  left: 20px;
  width: 60px;
  height: 80px;
  background-color: #e0e6ed;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.document-icon::before {
  content: '';
  position: absolute;
  top: 15px;
  left: 10px;
  width: 40px;
  height: 3px;
  background-color: #c0c4cc;
  box-shadow: 0 8px 0 #c0c4cc, 0 16px 0 #c0c4cc;
}

.pencil-icon {
  position: absolute;
  bottom: 15px;
  right: 15px;
  width: 40px;
  height: 8px;
  background-color: #ffcc80;
  border-radius: 4px;
  transform: rotate(-30deg);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}

.pencil-icon::before {
  content: '';
  position: absolute;
  right: -5px;
  top: -3px;
  width: 0;
  height: 0;
  border-left: 8px solid #a1887f;
  border-top: 7px solid transparent;
  border-bottom: 7px solid transparent;
}

.empty-text {
  font-size: 18px;
  color: #606266;
  font-weight: 500;
  margin-bottom: 8px;
}

.empty-subtext {
  font-size: 14px;
  color: #909399;
  line-height: 1.5;
}

.exam-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(520px, 1fr));
  gap: 20px;
}

.exam-card {
  background: linear-gradient(135deg, #ffffff 0%, #fafbff 100%);
  border-radius: 16px;
  padding: 24px 28px;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.08);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  border: 2px solid rgba(102, 126, 234, 0.1);
  opacity: 1;
  animation: slideInUp 0.6s ease-out forwards;
  cursor: pointer;
}

.exam-card::before {
  content: '';
  position: absolute;
  top: 0;
  right: 0;
  width: 120px;
  height: 120px;
  border-radius: 0 16px 0 100%;
  opacity: 0.05;
  transition: all 0.3s ease;
  pointer-events: none;
}

.exam-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.18);
  border-color: rgba(102, 126, 234, 0.3);
}

.exam-card:hover::before {
  opacity: 0.08;
  transform: scale(1.1);
}

.exam-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
}

.exam-header-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
}

.exam-name-wrapper {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  flex-grow: 1;
  margin-right: 10px;
}

.exam-name {
  font-size: 19px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 6px;
  line-height: 1.4;
  letter-spacing: 0.3px;
}

.exam-name-underline {
  width: 40px;
  height: 3px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border-radius: 2px;
  transition: width 0.3s ease;
}

.exam-card:hover .exam-name-underline {
  width: 60px;
}

.exam-status-tag {
  font-size: 12px;
  padding: 4px 10px;
  height: auto;
  border-radius: 15px;
  font-weight: 500;
}

.exam-score-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px;
  border-radius: 999px;
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.35);
  color: #fff;
  font-size: 12px;
}

.exam-score-label {
  opacity: 0.9;
}

.exam-score-value {
  font-weight: 700;
}

/* 考试卡片状态色彩 */
.exam-card[data-status="unfinished"]::before {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.exam-card[data-status="unfinished"] .exam-name-underline {
  background: linear-gradient(90deg, #3b82f6 0%, #2563eb 100%);
}

.exam-card[data-status="to_be_graded"]::before {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
}

.exam-card[data-status="to_be_graded"] .exam-name-underline {
  background: linear-gradient(90deg, #f97316 0%, #ea580c 100%);
}

.exam-card[data-status="graded"]::before {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
}

.exam-card[data-status="graded"] .exam-name-underline {
  background: linear-gradient(90deg, #22c55e 0%, #16a34a 100%);
}

.exam-time {
  display: flex;
  align-items: center;
  justify-content: space-around;
  background: linear-gradient(135deg, #f8f9ff 0%, #ffffff 100%);
  border-radius: 12px;
  padding: 14px 16px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.06);
  border: 1px solid rgba(102, 126, 234, 0.12);
}

.time-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #555;
  font-size: 13px;
}

.time-icon-bg {
  background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
  border-radius: 50%;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  border: 1px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
}

.exam-card:hover .time-icon-bg {
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.15);
}

.time-icon {
  font-size: 15px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.time-label {
  font-weight: 400;
  color: #888;
}

.time-value {
  color: #1f2937;
  font-weight: 700;
}

.time-divider {
  width: 1px;
  height: 25px;
  background-color: #e0e6ed;
}

.exam-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #f0f2f5;
}

.exam-info {
  display: flex;
  gap: 12px;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #888;
  font-size: 13px;
}

.info-icon-wrapper {
  background: linear-gradient(135deg, #eef2ff 0%, #e0e7ff 100%);
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid rgba(102, 126, 234, 0.15);
}

.info-icon-wrapper .el-icon {
  font-size: 13px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.info-text {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.info-label {
  font-weight: 400;
}

.info-value {
  font-weight: 700;
  color: #1f2937;
}

.enter-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #ffffff;
  padding: 10px 22px;
  border-radius: 24px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 6px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.3);
  border: 2px solid transparent;
}

.enter-button:hover:not(.is-disabled) {
  transform: translateY(-3px) scale(1.05);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
  filter: brightness(1.08);
  background: linear-gradient(135deg, #5a67d8 0%, #6a5ba1 100%);
}

.enter-button:active:not(.is-disabled) {
  transform: translateY(-1px) scale(1.0);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
}

.enter-button.is-disabled {
  background: #e0e6ed;
  color: #a0a4b0;
  cursor: not-allowed;
  box-shadow: none;
  opacity: 0.9;
  transform: none;
}

/* 按钮状态色彩 */
.exam-card[data-status="unfinished"] .enter-button:not(.is-disabled) {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  box-shadow: 0 4px 16px rgba(59, 130, 246, 0.3);
}

.exam-card[data-status="unfinished"] .enter-button:hover:not(.is-disabled) {
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  box-shadow: 0 8px 24px rgba(59, 130, 246, 0.4);
}

.exam-card[data-status="to_be_graded"] .enter-button:not(.is-disabled) {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
  box-shadow: 0 4px 16px rgba(249, 115, 22, 0.3);
}

.exam-card[data-status="to_be_graded"] .enter-button:hover:not(.is-disabled) {
  background: linear-gradient(135deg, #ea580c 0%, #c2410c 100%);
  box-shadow: 0 8px 24px rgba(249, 115, 22, 0.4);
}

.exam-card[data-status="graded"] .enter-button:not(.is-disabled) {
  background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%);
  box-shadow: 0 4px 16px rgba(34, 197, 94, 0.3);
}

.exam-card[data-status="graded"] .enter-button:hover:not(.is-disabled) {
  background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
  box-shadow: 0 8px 24px rgba(34, 197, 94, 0.4);
}

.arrow-icon {
  font-size: 14px;
  transition: transform 0.2s ease;
}

.enter-button:hover:not(.is-disabled) .arrow-icon {
  transform: translateX(3px);
}

/* 动画 */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(15px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes slideInUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}

/* 用户头像下拉菜单样式 */
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

/* 个人信息对话框样式 */
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

.profile-form :deep(.el-input:not(.is-disabled) .el-input__wrapper) {
  background-color: white !important;
  cursor: text;
}

.profile-form :deep(.el-input:not(.is-disabled) .el-input__inner) {
  color: #606266;
  cursor: text;
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

