<template>
  <div class="exam-create-container">
    <!-- 顶部导航栏 -->
    <div class="top-nav">
      <div class="nav-left">
        <h1 class="platform-logo">在线考试系统</h1>
      </div>
      <div class="nav-right">
        <el-button @click="goBackToClassExam" class="back-button">
          <el-icon class="back-icon"><Back /></el-icon>
          <span class="back-text">返回考试管理</span>
        </el-button>
        <el-dropdown @command="handleCommand" trigger="click">
          <div class="user-display">
            <el-avatar 
              :size="36" 
              :icon="userInfo.avatar ? undefined : UserFilled" 
              :src="userInfo.avatar ? 'http://localhost:8080/api' + userInfo.avatar : undefined"
              class="user-avatar" 
            />
            <span class="user-name">{{ userInfo.realName || '教师' }}</span>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon><User /></el-icon>个人信息
              </el-dropdown-item>
              <el-dropdown-item command="logout" divided>
                <el-icon><SwitchButton /></el-icon>退出登录
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 主内容区域 -->
    <div class="main-content">
      <!-- 创建流程导航 -->
      <el-steps :active="activeStep" align-center finish-status="success" class="create-steps">
        <el-step title="1 信息设置"></el-step>
        <el-step title="2 选择题目"></el-step>
        <el-step title="3 创建完成"></el-step>
      </el-steps>

      <!-- 步骤内容区域 -->
      <div class="step-content">
        <!-- 步骤 1: 信息设置 -->
        <div v-if="activeStep === 0" class="step-panel info-settings">
          <h3 class="step-title">考试信息设置</h3>
          <el-form :model="examForm" :rules="rules" ref="examFormRef" label-width="140px" class="exam-form">
            <el-form-item label="考试名称" prop="title" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <el-icon class="label-icon"><Document /></el-icon>
                  考试名称
                </span>
              </template>
              <el-input v-model="examForm.title" placeholder="请输入考试名称" clearable>
                <template #prefix>
                  <el-icon><Edit /></el-icon>
                </template>
              </el-input>
            </el-form-item>
            <el-form-item label="所属课程" prop="courseId" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <el-icon class="label-icon"><Reading /></el-icon>
                  所属课程
                </span>
              </template>
              <el-select v-model="examForm.courseId" placeholder="请选择课程" @change="handleCourseChange" filterable :disabled="true">
                <template #prefix>
                  <el-icon><Reading /></el-icon>
                </template>
                <el-option
                  v-for="course in courses"
                  :key="course.id"
                  :label="course.name"
                  :value="course.id"
                ></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="所属班级" prop="classId" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <el-icon class="label-icon"><User /></el-icon>
                  所属班级
                </span>
              </template>
              <el-input v-model="examForm.className" :disabled="true" placeholder="班级名">
                <template #prefix>
                  <el-icon><User /></el-icon>
                </template>
              </el-input>
            </el-form-item>
            <el-form-item label="开始时间" prop="startTime" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <el-icon class="label-icon"><Clock /></el-icon>
                  开始时间
                </span>
              </template>
              <el-date-picker
                v-model="examForm.startTime"
                type="datetime"
                placeholder="选择考试开始时间"
                format="YYYY-MM-DD HH:mm:ss"
                value-format="YYYY-MM-DD HH:mm:ss"
                :disabled-date="disabledStartDate"
                style="width: 100%;"
              >
                <template #prefix>
                  <el-icon><Clock /></el-icon>
                </template>
              </el-date-picker>
            </el-form-item>
            <el-form-item label="结束时间" prop="endTime" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <el-icon class="label-icon"><Clock /></el-icon>
                  结束时间
                </span>
              </template>
              <el-date-picker
                v-model="examForm.endTime"
                type="datetime"
                placeholder="选择考试结束时间"
                format="YYYY-MM-DD HH:mm:ss"
                value-format="YYYY-MM-DD HH:mm:ss"
                :disabled-date="disabledEndDate"
                style="width: 100%;"
              >
                <template #prefix>
                  <el-icon><Clock /></el-icon>
                </template>
              </el-date-picker>
            </el-form-item>
            <el-form-item label="考试持续时长" prop="duration" class="form-item-with-icon">
              <template #label>
                <span class="form-label">
                  <el-icon class="label-icon"><Timer /></el-icon>
                  考试持续时长
                </span>
              </template>
              <div class="duration-display">
                <el-input-number :model-value="calculatedDuration" :min="1" controls-position="right" :disabled="true"></el-input-number>
                <span class="duration-unit">分钟</span>
              </div>
            </el-form-item>
            <el-form-item class="button-form-item">
              <el-button type="primary" @click="goToSelectQuestions" class="next-step-button">开始选题</el-button>
            </el-form-item>
          </el-form>
        </div>

        <!-- 步骤 2: 选择题目 -->
        <div v-if="activeStep === 1" class="step-panel select-questions">
          <div class="select-questions-header">
            <h3 class="step-title">选择题目</h3>
            <div class="selected-count" v-if="selectedQuestions.length > 0">
              <el-icon><CircleCheck /></el-icon>
              <span>已选择 <strong>{{ selectedQuestions.length }}</strong> 道题目</span>
            </div>
          </div>
          
          <!-- 搜索和筛选区域 -->
          <div class="question-filters">
            <div class="search-wrapper">
              <el-input
                v-model="searchKeyword"
                placeholder="搜索题目内容..."
                clearable
                size="large"
                @clear="handleSearchClear"
              >
                <template #prefix>
                  <el-icon><Search /></el-icon>
                </template>
              </el-input>
            </div>
            <div class="filter-wrapper">
              <el-select
                v-model="selectedQuestionType"
                placeholder="全部题型"
                clearable
                size="large"
                @clear="handleTypeFilterClear"
              >
                <el-option label="全部题型" value="" />
                <el-option label="单选题" value="1" />
                <el-option label="多选题" value="2" />
                <el-option label="判断题" value="3" />
                <el-option label="填空题" value="4" />
                <el-option label="简答题" value="5" />
              </el-select>
            </div>
            <div class="filter-wrapper">
              <el-select
                v-model="selectedDifficulty"
                placeholder="全部难度"
                clearable
                size="large"
                @clear="handleDifficultyFilterClear"
              >
                <el-option label="全部难度" value="" />
                <el-option label="⭐ 简单" value="1" />
                <el-option label="⭐⭐ 中等" value="2" />
                <el-option label="⭐⭐⭐ 困难" value="3" />
              </el-select>
            </div>
          </div>
          
          <!-- 两栏布局区域（包裹左表和右侧外栏，以便顶部对齐） -->
          <div class="selection-region">
            <div class="selection-body">
              <div class="selection-left">
                <div class="question-list">
                  <div class="question-table-wrapper">
                    <QuestionSelectionTable 
                      :key="tableUpdateKey"
                      :questions="filteredQuestions" 
                      :selectedQuestions="selectedQuestions"
                      @question-selected="handleQuestionSelected" 
                    />
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 页面右侧浮动侧栏（在卡片外侧） -->
            <div v-if="activeStep === 1" class="selected-sidebar">
              <div class="selected-questions-panel">
                <div class="selected-panel-header">
                  <h4 class="selected-title">
                    <el-icon><CircleCheck /></el-icon>
                    已选择的题目 ({{ selectedQuestions.length }}道)
                  </h4>
                  <el-button v-if="selectedQuestions.length > 0" size="small" type="danger" @click="clearAllSelectedQuestions" link>
                    <el-icon><Delete /></el-icon>
                    清空全部
                  </el-button>
                </div>
                <div v-if="selectedQuestions.length > 0" class="selected-questions-list">
                  <transition-group name="selected-list" tag="div" class="selected-list-container">
                    <div 
                      v-for="(question, index) in selectedQuestions" 
                      :key="question.id"
                      class="selected-question-item"
                      @click="openSelectedQuestionDetail(question)"
                    >
                      <div class="selected-item-index">{{ index + 1 }}</div>
                      <div class="selected-item-info">
                        <div class="selected-item-header">
                          <el-tag :type="getQuestionTypeTag(question.type)" size="small">
                            {{ getQuestionTypeText(question.type) }}
                          </el-tag>
                          <span class="selected-item-score">{{ question.score }}分</span>
                          <span v-if="question.difficulty" class="selected-item-difficulty">
                            {{ '⭐'.repeat(question.difficulty) }}
                          </span>
                        </div>
                        <div class="selected-item-content">{{ question.content }}</div>
                      </div>
                      <el-button 
                        size="small" 
                        type="danger" 
                        @click.stop="removeSelectedQuestion(question.id)"
                        link
                      >
                        <el-icon><Close /></el-icon>
                      </el-button>
                    </div>
                  </transition-group>
                </div>
                <div v-else class="empty-selected">
                  <div class="empty-icon">📝</div>
                  <div class="empty-text">还没有选择题目</div>
                  <div class="empty-hint">从左侧选择题目添加到试卷</div>
                </div>
              </div>
            </div>
          </div>
          
          <el-dialog
            v-model="selectedQuestionDetailVisible"
            title="题目详情"
            width="900px"
            :close-on-click-modal="false"
          >
            <el-descriptions :column="1" border>
              <el-descriptions-item label="题型">
                {{ getQuestionTypeText(detailQuestion.type) }}
              </el-descriptions-item>
              <el-descriptions-item label="题干">
                {{ detailQuestion.content }}
              </el-descriptions-item>
              <el-descriptions-item label="选项" v-if="[1,2].includes(detailQuestion.type)">
                <div v-if="detailParsedOptions">
                  <p v-for="(opt, key) in detailParsedOptions" :key="key">{{ key }}: {{ opt }}</p>
                </div>
              </el-descriptions-item>
              <el-descriptions-item label="答案">
                {{ detailQuestion.answer }}
              </el-descriptions-item>
              <el-descriptions-item label="分值">
                {{ detailQuestion.score }}分
              </el-descriptions-item>
              <el-descriptions-item label="知识点">
                {{ detailQuestion.category }}
              </el-descriptions-item>
              <el-descriptions-item label="难度">
                <span v-if="detailQuestion.difficulty" :style="{ color: getDifficultyColor(detailQuestion.difficulty) }">
                  {{ '⭐'.repeat(detailQuestion.difficulty) }}
                </span>
                <span v-else>-</span>
              </el-descriptions-item>
            </el-descriptions>
          </el-dialog>

          <div class="navigation-buttons">
            <el-button @click="prevStep" size="large" class="prev-step-button">上一步</el-button>
            <el-button type="primary" @click="confirmCreateExam" :disabled="selectedQuestions.length === 0" size="large" class="create-button">开始创建</el-button>
          </div>
        </div>

        <!-- 步骤 3: 创建完成 -->
        <div v-if="activeStep === 2" class="step-panel create-complete">
          
          <!-- 基本信息 -->
          <div class="summary-section">
            <h4 class="section-title">
              <el-icon><Document /></el-icon>
              基本信息
            </h4>
            <el-descriptions :column="2" border class="exam-summary">
              <el-descriptions-item label="考试名称" :span="2">
                <strong>{{ createdExamSummary.title }}</strong>
              </el-descriptions-item>
              <el-descriptions-item label="所属课程">{{ createdExamSummary.courseName }}</el-descriptions-item>
              <el-descriptions-item label="所属班级">{{ createdExamSummary.className }}</el-descriptions-item>
              <el-descriptions-item label="开始时间">{{ createdExamSummary.startTime }}</el-descriptions-item>
              <el-descriptions-item label="结束时间">{{ createdExamSummary.endTime }}</el-descriptions-item>
              <el-descriptions-item label="考试时长">
                <el-tag type="warning" effect="light">
                  <el-icon><Timer /></el-icon>
                  {{ createdExamSummary.duration }} 分钟
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="总分数">
                <el-tag type="danger" effect="light" size="large">
                  <strong>{{ createdExamSummary.totalScore }}</strong> 分
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="客观题总分">
                <el-tag type="success" effect="light">
                  <strong>{{ createdExamSummary.objectiveScore }}</strong> 分
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="主观题总分">
                <el-tag type="primary" effect="light">
                  <strong>{{ createdExamSummary.subjectiveScore }}</strong> 分
                </el-tag>
              </el-descriptions-item>
            </el-descriptions>
          </div>
          
          <!-- 题目统计 -->
          <div class="summary-section">
            <h4 class="section-title">
              <el-icon><Reading /></el-icon>
              题目统计
            </h4>
            <div class="question-stats">
              <div class="stat-card total">
                <div class="stat-icon">
                  <el-icon><Document /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-label">题目总数</div>
                  <div class="stat-value">{{ createdExamSummary.totalQuestions }}</div>
                </div>
              </div>
              
              <div class="stat-card" v-if="createdExamSummary.singleChoiceCount > 0">
                <div class="stat-icon primary">
                  <el-icon><Edit /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-label">单选题</div>
                  <div class="stat-value">{{ createdExamSummary.singleChoiceCount }} 道</div>
                </div>
              </div>
              
              <div class="stat-card" v-if="createdExamSummary.multipleChoiceCount > 0">
                <div class="stat-icon success">
                  <el-icon><Edit /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-label">多选题</div>
                  <div class="stat-value">{{ createdExamSummary.multipleChoiceCount }} 道</div>
                </div>
              </div>
              
              <div class="stat-card" v-if="createdExamSummary.trueFalseCount > 0">
                <div class="stat-icon warning">
                  <el-icon><CircleCheck /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-label">判断题</div>
                  <div class="stat-value">{{ createdExamSummary.trueFalseCount }} 道</div>
                </div>
              </div>
              
              <div class="stat-card" v-if="createdExamSummary.fillBlankCount > 0">
                <div class="stat-icon info">
                  <el-icon><Edit /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-label">填空题</div>
                  <div class="stat-value">{{ createdExamSummary.fillBlankCount }} 道</div>
                </div>
              </div>
              
              <div class="stat-card" v-if="createdExamSummary.essayCount > 0">
                <div class="stat-icon danger">
                  <el-icon><Reading /></el-icon>
                </div>
                <div class="stat-info">
                  <div class="stat-label">简答题</div>
                  <div class="stat-value">{{ createdExamSummary.essayCount }} 道</div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 组卷功能 -->
          <div class="summary-section paper-arrangement">
            <h4 class="section-title">
              <el-icon><Grid /></el-icon>
              试卷组卷
            </h4>
            
            <!-- 组卷模式选择 -->
            <div class="paper-mode-selector">
              <el-radio-group v-model="paperArrangementMode" size="large">
                <el-radio-button value="manual">
                  <el-icon><Edit /></el-icon>
                  自由组卷
                </el-radio-button>
                <el-radio-button value="random">
                  <el-icon><Refresh /></el-icon>
                  随机乱序
                </el-radio-button>
                <el-radio-button value="difficulty">
                  <el-icon><TrendCharts /></el-icon>
                  难度递增
                </el-radio-button>
              </el-radio-group>
              <el-button type="primary" @click="applyPaperArrangement" :loading="arrangingPaper">
                <el-icon><MagicStick /></el-icon>
                应用排序
              </el-button>
            </div>
            
            <!-- 题目列表（分组展示 + 仅组内可排序） -->
            <div class="question-order-list">
              <div
                v-for="group in groupedOrder"
                :key="group.type"
                class="order-group"
              >
                <div class="order-group-header">
                  <div class="group-title">
                    {{ group.label }}
                    <span class="group-count">（{{ group.count }} 道，合计 {{ group.totalScore }} 分）</span>
                  </div>
                </div>
                <div class="order-list-header">
                  <span class="header-item">序号</span>
                  <span class="header-item">题型</span>
                  <span class="header-item">题干</span>
                  <span class="header-item">难度</span>
                  <span class="header-item">分值</span>
                  <span class="header-item" v-if="paperArrangementMode === 'manual'">操作</span>
                </div>
                <transition-group name="list" tag="div" class="order-list-body">
                  <div 
                    v-for="question in group.items" 
                    :key="question.id"
                    class="order-list-item"
                  >
                    <span class="item-index">{{ getRowIndex(question) + 1 }}</span>
                    <span class="item-type">
                      <el-tag :type="getQuestionTypeTag(question.type)" size="small">
                        {{ getQuestionTypeText(question.type) }}
                      </el-tag>
                    </span>
                    <span class="item-content">{{ question.content }}</span>
                    <span class="item-difficulty">
                      <span v-if="question.difficulty" :style="{ color: getDifficultyColor(question.difficulty) }">
                        {{ '⭐'.repeat(question.difficulty) }}
                      </span>
                      <span v-else style="color: #d9d9d9;">-</span>
                    </span>
                    <span class="item-score">{{ question.score }}分</span>
                    <span class="item-actions" v-if="paperArrangementMode === 'manual'">
                      <el-button 
                        size="small" 
                        :disabled="getRowIndex(question) === 0 || sortedSelectedQuestions[getRowIndex(question) - 1]?.type !== question.type"
                        @click="moveQuestionUp(getRowIndex(question))"
                        link
                      >
                        <el-icon><Top /></el-icon>
                      </el-button>
                      <el-button 
                        size="small" 
                        :disabled="getRowIndex(question) === sortedSelectedQuestions.length - 1 || sortedSelectedQuestions[getRowIndex(question) + 1]?.type !== question.type"
                        @click="moveQuestionDown(getRowIndex(question))"
                        link
                      >
                        <el-icon><Bottom /></el-icon>
                      </el-button>
                    </span>
                  </div>
                </transition-group>
              </div>
            </div>
          </div>
          
          <div class="navigation-buttons">
            <el-button @click="prevStep" size="large" class="prev-step-button">上一步</el-button>
            <el-button type="success" size="large" @click="sendExam" :loading="isSending" :disabled="isSending" class="send-exam-button">
              <el-icon><CircleCheck /></el-icon>
              发送试卷
            </el-button>
          </div>
        </div>
      </div>
    </div>

    <!-- 个人信息对话框 -->
    <el-dialog
      v-model="profileDialogVisible"
      title="个人信息"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="userForm" label-width="100px">
        <el-form-item label="头像">
          <AvatarUpload v-model="userForm.avatar" />
        </el-form-item>
        <el-form-item label="用户名">
          <el-input v-model="userForm.username" disabled></el-input>
        </el-form-item>
        <el-form-item label="真实姓名">
          <el-input v-model="userForm.realName"></el-input>
        </el-form-item>
        <el-form-item label="教师编号" v-if="userInfo.role === 'teacher'">
          <el-input v-model="userForm.teacherNo" disabled></el-input>
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="userForm.email"></el-input>
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="userForm.phone"></el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="profileDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveProfile">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed, h } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage, ElMessageBox, ElNotification } from 'element-plus';
import { Back, UserFilled, User, SwitchButton, Document, Edit, CircleCheck, Plus, Clock, Timer, Reading, Search, Grid, Refresh, TrendCharts, MagicStick, Top, Bottom, Close, Delete } from '@element-plus/icons-vue';
import request from '@/utils/request';
import QuestionSelectionTable from '@/components/QuestionSelectionTable.vue'; // 显式导入 QuestionSelectionTable 组件
import AvatarUpload from '@/components/AvatarUpload.vue';

const route = useRoute();
const router = useRouter();

const userInfo = reactive({
  id: '',
  userId: '',
  username: '',
  realName: '',
  role: '',
  teacherNo: '',
  email: '',
  phone: '',
  avatar: '',
});
const userForm = reactive({});
const profileDialogVisible = ref(false);

// 初始化用户信息
try {
  const storedUserInfo = localStorage.getItem('userInfo');
  if (storedUserInfo) {
    const parsed = JSON.parse(storedUserInfo);
    Object.assign(userInfo, {
      id: parsed.id || '',
      userId: parsed.userId || '',
      username: parsed.username || '',
      realName: parsed.realName || '',
      role: parsed.role || '',
      teacherNo: parsed.teacherNo || '',
      email: parsed.email || '',
      phone: parsed.phone || '',
      avatar: parsed.avatar || '',
    });
  }
} catch (e) {
  console.error('Failed to parse userInfo from localStorage in TeacherExamCreate:', e);
}

const activeStep = ref(0); // 当前激活的步骤，0-indexed
const examFormRef = ref(null); // 表单引用
const selectedClassId = ref(null); // 从路由获取的班级ID
const selectedClassName = ref(''); // 从路由获取的班级名称

// 考试表单数据
const examForm = reactive({
  title: '',
  courseId: null,
  classId: null, // 默认当前班级
  className: '', // 班级名称，仅用于显示
  startTime: null,
  endTime: null,
  duration: 60, // 考试持续时长，默认60分钟
  teacherId: null, // 当前创建考试的教师ID
});

// 实时计算考试持续时长
const calculatedDuration = computed(() => {
  if (examForm.startTime && examForm.endTime) {
    // 将字符串转换为 Date 对象
    const start = new Date(examForm.startTime.replace(' ', 'T'));
    const end = new Date(examForm.endTime.replace(' ', 'T'));
    
    // 检查日期解析是否有效
    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      console.error('Invalid date parsing for duration calculation.', { 
        startTime: examForm.startTime, 
        endTime: examForm.endTime 
      });
      return 0;
    }

    // 计算时间差（毫秒）
    const diffMs = end.getTime() - start.getTime();
    // 转换为分钟
    const diffMinutes = Math.round(diffMs / (1000 * 60));
    
    console.log('Duration calculated:', {
      start: examForm.startTime,
      end: examForm.endTime,
      minutes: diffMinutes
    });
    
    return Math.max(0, diffMinutes); // 确保时长不为负
  }
  return 0;
});

// 禁用开始时间：不能选择过去的日期
const disabledStartDate = (time) => {
  // 禁用今天之前的日期
  return time.getTime() < Date.now() - 24 * 60 * 60 * 1000;
};

// 禁用结束时间：不能早于开始时间
const disabledEndDate = (time) => {
  if (!examForm.startTime) {
    // 如果没有选择开始时间，禁用今天之前的日期
    return time.getTime() < Date.now() - 24 * 60 * 60 * 1000;
  }
  // 禁用早于开始时间的日期
  const startDate = new Date(examForm.startTime);
  return time.getTime() < startDate.getTime();
};

// 表单验证规则
const rules = reactive({
  title: [{ required: true, message: '请输入考试名称', trigger: 'blur' }],
  courseId: [{ required: true, message: '请选择所属课程', trigger: 'change' }],
  startTime: [{ required: true, message: '请选择考试开始时间', trigger: 'change' }],
  endTime: [
    { required: true, message: '请选择考试结束时间', trigger: 'change' },
    {
      validator: (rule, value, callback) => {
        if (value && examForm.startTime) {
          const start = new Date(examForm.startTime);
          const end = new Date(value);
          if (end.getTime() <= start.getTime()) {
            callback(new Error('结束时间必须晚于开始时间'));
          } else {
            callback();
          }
        } else {
          callback();
        }
      },
      trigger: 'change'
    }
  ],
});

const courses = ref([]); // 课程列表，用于选择
const questions = ref([]); // 当前课程下的所有题目
const selectedQuestions = reactive([]); // 选中的题目

// 组卷功能
const paperArrangementMode = ref('manual'); // manual: 自由组卷, random: 随机乱序, difficulty: 难度递增
const arrangingPaper = ref(false); // 是否正在应用排序
const isSending = ref(false); // 是否正在发送试卷
const sortedSelectedQuestions = ref([]); // 排序后的题目列表

// 搜索关键词
const searchKeyword = ref('');

// 题目类型筛选
const selectedQuestionType = ref('');

// 表格更新键，用于强制刷新题目选择表格
const tableUpdateKey = ref(0);

// 难度筛选
const selectedDifficulty = ref('');

// 统一的题目过滤（支持搜索、类型筛选和难度筛选）
const filteredQuestions = computed(() => {
  return questions.value.filter(q => {
    // 类型筛选
    const matchType = !selectedQuestionType.value || q.type === parseInt(selectedQuestionType.value);
    
    // 难度筛选
    const matchDifficulty = !selectedDifficulty.value || q.difficulty === parseInt(selectedDifficulty.value);
    
    // 搜索筛选
    const matchSearch = !searchKeyword.value || 
                        q.content.toLowerCase().includes(searchKeyword.value.toLowerCase()) ||
                        (q.category && q.category.toLowerCase().includes(searchKeyword.value.toLowerCase()));
    
    return matchType && matchDifficulty && matchSearch;
  });
});

const createdExamSummary = reactive({
  id: null,
  title: '',
  courseName: '',
  className: '',
  startTime: '',
  endTime: '',
  duration: 0,
  totalQuestions: 0,
  totalScore: 0,
  objectiveScore: 0, // 客观题总分（单选、多选、判断）
  subjectiveScore: 0, // 主观题总分（填空、简答）
  singleChoiceCount: 0,
  multipleChoiceCount: 0,
  trueFalseCount: 0,
  fillBlankCount: 0,
  essayCount: 0,
});

// 获取当前用户信息
const loadUserInfo = () => {
  try {
    const storedUserInfo = localStorage.getItem('userInfo');
    if (storedUserInfo) {
      const currentUserInfo = JSON.parse(storedUserInfo);
      Object.assign(userInfo, currentUserInfo);
      examForm.teacherId = userInfo.userId; // 设置创建教师ID
    } else {
      ElMessage.warning('未找到用户信息，请重新登录');
      router.push('/login');
    }
  } catch (e) {
    console.error("Failed to parse userInfo from localStorage:", e);
    ElMessage.error('用户信息解析失败，请重新登录');
    router.push('/login');
  }
};

// 组卷功能实现

// 应用排序
const applyPaperArrangement = () => {
  arrangingPaper.value = true;
  
  try {
    // 在各题型内进行排列，不跨题型
    const list = [...sortedSelectedQuestions.value];
    const typePriorityMap = { 1: 1, 2: 2, 4: 3, 5: 4 };

    // 根据当前列表分组并记录出现顺序
    const groupsMap = new Map();
    const orderTypes = [];
    list.forEach(q => {
      if (!groupsMap.has(q.type)) {
        groupsMap.set(q.type, []);
        orderTypes.push(q.type);
      }
      groupsMap.get(q.type).push(q);
    });

    // 决定分组顺序：按既定优先级，其次保留首次出现顺序
    const groupTypes = orderTypes.slice().sort((a, b) => {
      const pa = typePriorityMap[a] ?? 999;
      const pb = typePriorityMap[b] ?? 999;
      if (pa !== pb) return pa - pb;
      return orderTypes.indexOf(a) - orderTypes.indexOf(b);
    });

    const newList = [];
    groupTypes.forEach(t => {
      let grp = groupsMap.get(t) || [];
      if (paperArrangementMode.value === 'random') {
        grp = shuffleArray(grp);
      } else if (paperArrangementMode.value === 'difficulty') {
        grp = [...grp].sort((a, b) => (a.difficulty || 1) - (b.difficulty || 1));
      }
      newList.push(...grp);
    });

    if (paperArrangementMode.value === 'random') {
      ElMessage.success('已在各题型内随机乱序');
    } else if (paperArrangementMode.value === 'difficulty') {
      ElMessage.success('已在各题型内按难度递增排序');
    }

    sortedSelectedQuestions.value = newList;
    // manual模式不需要自动排序
  } catch (error) {
    console.error('应用排序失败:', error);
    ElMessage.error('应用排序失败');
  } finally {
    arrangingPaper.value = false;
  }
};

// 上移题目
const moveQuestionUp = (index) => {
  if (index > 0) {
    const cur = sortedSelectedQuestions.value[index];
    const prev = sortedSelectedQuestions.value[index - 1];
    if (cur.type !== prev.type) {
      ElMessage.info('只能在相同题型内调整顺序');
      return;
    }
    const temp = sortedSelectedQuestions.value[index];
    sortedSelectedQuestions.value[index] = sortedSelectedQuestions.value[index - 1];
    sortedSelectedQuestions.value[index - 1] = temp;
    // 触发响应式更新
    sortedSelectedQuestions.value = [...sortedSelectedQuestions.value];
  }
};

// 下移题目
const moveQuestionDown = (index) => {
  if (index < sortedSelectedQuestions.value.length - 1) {
    const cur = sortedSelectedQuestions.value[index];
    const next = sortedSelectedQuestions.value[index + 1];
    if (cur.type !== next.type) {
      ElMessage.info('只能在相同题型内调整顺序');
      return;
    }
    const temp = sortedSelectedQuestions.value[index];
    sortedSelectedQuestions.value[index] = sortedSelectedQuestions.value[index + 1];
    sortedSelectedQuestions.value[index + 1] = temp;
    // 触发响应式更新
    sortedSelectedQuestions.value = [...sortedSelectedQuestions.value];
  }
};

// 数组随机打乱（Fisher-Yates shuffle）
const shuffleArray = (array) => {
  const arr = [...array];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
};

const groupedOrder = computed(() => {
  const map = new Map();
  sortedSelectedQuestions.value.forEach(q => {
    if (!map.has(q.type)) map.set(q.type, []);
    map.get(q.type).push(q);
  });
  const typeOrder = [1, 2, 4, 5];
  const groupTypes = Array.from(map.keys()).sort((a, b) => {
    const ia = typeOrder.indexOf(a);
    const ib = typeOrder.indexOf(b);
    return (ia === -1 ? 999 : ia) - (ib === -1 ? 999 : ib);
  });
  return groupTypes.map(t => {
    const items = map.get(t) || [];
    const totalScore = items.reduce((s, it) => s + (it.score || 0), 0);
    return { type: t, label: getQuestionTypeText(t), count: items.length, totalScore, items };
  });
});

const getRowIndex = (q) => {
  return sortedSelectedQuestions.value.findIndex(it => it.id === q.id);
};

// 获取题型标签类型
const getQuestionTypeTag = (type) => {
  const tagMap = {
    1: '',
    2: 'success',
    3: 'info',
    4: 'warning',
    5: 'danger'
  };
  return tagMap[type] || '';
};

// 获取题型文本
const getQuestionTypeText = (type) => {
  const textMap = {
    1: '单选题',
    2: '多选题',
    3: '判断题',
    4: '填空题',
    5: '简答题'
  };
  return textMap[type] || '未知';
};

// 获取难度颜色
const getDifficultyColor = (difficulty) => {
  const colorMap = {
    1: '#52c41a', // 简单 - 绿色
    2: '#faad14', // 中等 - 橙色
    3: '#f5222d'  // 困难 - 红色
  };
  return colorMap[difficulty] || '#d9d9d9';
};

// ===== 已选择题目管理函数 =====

// 移除单个已选择的题目
const removeSelectedQuestion = (questionId) => {
  const index = selectedQuestions.findIndex(q => q.id === questionId);
  if (index !== -1) {
    selectedQuestions.splice(index, 1);

    tableUpdateKey.value++;

    ElMessage.success('已移除题目');
  }
};

const selectedQuestionDetailVisible = ref(false);
const detailQuestion = reactive({});
const detailParsedOptions = ref(null);

const openSelectedQuestionDetail = (q) => {
  Object.assign(detailQuestion, q || {});
  detailParsedOptions.value = null;
  try {
    if (q && q.options) {
      const raw = typeof q.options === 'string' ? JSON.parse(q.options) : q.options;
      detailParsedOptions.value = raw;
    }
  } catch (e) {
    detailParsedOptions.value = null;
  }
  selectedQuestionDetailVisible.value = true;
};

// 清空所有已选择的题目
const clearAllSelectedQuestions = () => {
  ElMessageBox.confirm('确定要清空所有已选择的题目吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    selectedQuestions.splice(0);
    
    // 强制更新题目选择表格的显示状态
    tableUpdateKey.value++;
    
    ElMessage.success('已清空所有题目');
  }).catch(() => {
    // 用户取消操作
  });
};

// 返回老师班级考试管理界面
const goBackToClassExam = () => {
  if (selectedClassId.value) {
    router.push(`/teacher/class/${selectedClassId.value}?tab=exams`);
  } else {
    router.push('/teacher/home'); // 如果没有班级ID，返回教师主页
  }
};

// 处理顶部用户下拉菜单命令
const handleCommand = (command) => {
  switch (command) {
    case 'profile':
      Object.assign(userForm, userInfo);
      profileDialogVisible.value = true;
      break;
    case 'logout':
      handleLogout();
      break;
  }
};

// 登出
const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    localStorage.removeItem('userInfo');
    router.push('/login');
    ElMessage.success('退出成功');
  }).catch(() => {});
};

// 保存个人信息
const saveProfile = async () => {
  if (!userInfo.userId) {
    ElMessage.warning('用户信息未找到，请重新登录');
    router.push('/login');
    return;
  }
  try {
    const updateData = {
      id: userInfo.userId,
      role: 1, // 教师角色
      realName: userForm.realName,
      teacherNo: userForm.teacherNo,
      email: userForm.email,
      phone: userForm.phone,
      avatar: userForm.avatar,
    };
    const response = await request.post('/user/update', updateData);
    if (response.code === 200) {
      ElMessage.success('个人信息已保存');
      profileDialogVisible.value = false;
      // 更新本地用户信息
      Object.assign(userInfo, updateData);
      const updatedUserInfo = { ...userInfo, ...updateData };
      localStorage.setItem('userInfo', JSON.stringify(updatedUserInfo));
    } else {
      ElMessage.error(response.message || '保存个人信息失败');
    }
  } catch (error) {
    console.error('保存个人信息失败:', error);
    ElMessage.error('网络错误，无法保存个人信息');
  }
};

// 加载课程列表
const loadCourses = async () => {
  try {
    const res = await request.get('/course/list');
    if (res.code === 200) {
      courses.value = res.data || [];
    } else {
      ElMessage.error(res.message || '加载课程列表失败');
    }
  } catch (error) {
    console.error('加载课程列表失败:', error);
    ElMessage.error('加载课程列表失败');
  }
};

// 处理课程选择变化，用于加载对应课程的题目
const handleCourseChange = async (courseId) => {
  examForm.courseId = courseId; // 确保 examForm 中的 courseId 更新
  questions.value = []; // 清空之前的题目
  selectedQuestions.splice(0); // 清空选中的题目
  activeQuestionTab.value = '1'; // 切换回单选题tab
  await loadQuestionsByCourse(courseId);
};

// 根据课程ID加载所有题目
const loadQuestionsByCourse = async (courseId) => {
  if (!courseId) return;
  try {
    const res = await request.get(`/question/course/${courseId}`);
    if (res.code === 200) {
      questions.value = res.data || [];
    } else {
      ElMessage.error(res.message || '加载题目失败');
    }
  } catch (error) {
    console.error('加载题目失败:', error);
    ElMessage.error('加载题目失败');
  }
};

// 根据题目类型加载题目 (实际是过滤已加载的题目)
const loadQuestionsByType = (type) => {
  // questions.value 已经包含了所有题目，这里只需要在计算属性中过滤即可
  // 确保当切换tab时，相关的计算属性会自动更新
};

// 处理题目选择事件
const handleQuestionSelected = ({ question, isSelected }) => {
  const index = selectedQuestions.findIndex(q => q.id === question.id);
  if (isSelected && index === -1) {
    selectedQuestions.push(question);
  } else if (!isSelected && index !== -1) {
    selectedQuestions.splice(index, 1);
  }
  // console.log('当前选中的题目:', selectedQuestions);
};

// 处理搜索清除事件
const handleSearchClear = () => {
  searchKeyword.value = '';
};

// 处理类型筛选清除事件
const handleTypeFilterClear = () => {
  selectedQuestionType.value = '';
};

// 处理难度筛选清除事件
const handleDifficultyFilterClear = () => {
  selectedDifficulty.value = '';
};

// 步骤 1: 开始选题
const goToSelectQuestions = async () => {
  if (!examFormRef.value) return;
  await examFormRef.value.validate(async (valid) => {
    if (valid) {
      // 验证开始时间不能晚于结束时间
      if (new Date(examForm.startTime) >= new Date(examForm.endTime)) {
        ElMessage.error('考试开始时间不能晚于或等于结束时间！');
        return;
      }
      // 检查是否选择了课程，进而加载了题目
      if (!examForm.courseId) {
        ElMessage.warning('请先选择所属课程，以便加载题目。');
        return;
      }
      activeStep.value = 1;
      // 确保题目列表已加载
      if (questions.value.length === 0) {
        await loadQuestionsByCourse(examForm.courseId);
      }
    } else {
      ElMessage.error('请填写完整的考试信息！');
    }
  });
};

// 返回上一步
const prevStep = () => {
  if (activeStep.value > 0) {
    activeStep.value--;
  }
};

// 步骤 2: 确认创建考试
const confirmCreateExam = () => {
  if (selectedQuestions.length === 0) {
    ElMessage.warning('请至少选择一道题目！');
    return;
  }

  // 验证用户信息
  if (!userInfo.userId && !userInfo.id) {
    ElMessage.error('用户信息获取失败，请重新登录');
    router.push('/login');
    return;
  }

  // 汇总考试信息（不插入数据库，仅显示摘要）
  let totalScore = 0;
  let objectiveScore = 0; // 客观题总分
  let subjectiveScore = 0; // 主观题总分
  let singleChoiceCount = 0;
  let multipleChoiceCount = 0;
  let trueFalseCount = 0;
  let fillBlankCount = 0;
  let essayCount = 0;

  selectedQuestions.forEach(q => {
    const s = Number(q.score) || 0;
    totalScore += s;
    // 客观题：单选(1)、多选(2)、判断(3)
    if (q.type === 1 || q.type === 2 || q.type === 3) {
      objectiveScore += s;
    }
    // 主观题：填空(4)、简答(5)
    else if (q.type === 4 || q.type === 5) {
      subjectiveScore += s;
    }
    
    if (q.type === 1) singleChoiceCount++;
    else if (q.type === 2) multipleChoiceCount++;
    else if (q.type === 3) trueFalseCount++;
    else if (q.type === 4) fillBlankCount++;
    else if (q.type === 5) essayCount++;
  });

  Object.assign(createdExamSummary, {
    title: examForm.title,
    courseName: courses.value.find(c => c.id === examForm.courseId)?.name || '未知课程',
    className: examForm.className,
    startTime: examForm.startTime,
    endTime: examForm.endTime,
    duration: calculatedDuration.value,
    totalQuestions: selectedQuestions.length,
    totalScore: totalScore,
    objectiveScore: objectiveScore, // 客观题总分
    subjectiveScore: subjectiveScore, // 主观题总分
    singleChoiceCount: singleChoiceCount,
    multipleChoiceCount: multipleChoiceCount,
    trueFalseCount: trueFalseCount,
    fillBlankCount: fillBlankCount,
    essayCount: essayCount,
    id: null, // 暂时为空，发送试卷时才创建
  });

  // 初始化题目排序列表（按题型组卷：单选(1) -> 多选(2) -> 填空(4) -> 简答(5)，其他类型置后）
  const typePriorityMap = { 1: 1, 2: 2, 4: 3, 5: 4 };
  sortedSelectedQuestions.value = [...selectedQuestions].sort((a, b) => {
    const pa = typePriorityMap[a.type] ?? 999;
    const pb = typePriorityMap[b.type] ?? 999;
    if (pa !== pb) return pa - pb;
    return 0; // 稳定排序下，同一类型保持原相对顺序
  });
  
  // 直接进入步骤3显示摘要，不插入数据库
  activeStep.value = 2;
};

// 步骤 3: 发送试卷（创建考试并发布）
const sendExam = async () => {
  if (isSending.value) return;
  ElMessageBox.confirm('确定要发送本次试卷吗？发送后学生即可参加考试。', '提示', {
    confirmButtonText: '确定发送',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    isSending.value = true;
    try {
      // 准备考试数据
      const examData = {
        title: examForm.title,
        classId: examForm.classId,
        startTime: examForm.startTime,
        endTime: examForm.endTime,
        duration: createdExamSummary.duration,
        type: 1, // 类型: 1-正式考试
        totalScore: createdExamSummary.totalScore,
        score: createdExamSummary.totalScore, // 兼容后端字段要求
        passScore: Math.round(createdExamSummary.totalScore * 0.6), // 默认60%及格
        allowRetake: 0,
        maxAttempts: 1,
        shuffleQuestions: 0,
        shuffleOptions: 0,
        showAnswer: 0,
        autoGrade: 1,
        creatorId: userInfo.userId || userInfo.id,
        status: 1, // 状态: 1-已发布（直接发布，不保存草稿）
        questionIds: sortedSelectedQuestions.value.map(q => q.id), // 使用排序后的题目列表
      };

      console.log('创建并发送考试:', examData);

      // 调用后端接口创建并发布考试
      const res = await request.post('/exam', examData);
      
      if (res.code === 200) {
        if (res.data && res.data.id) {
          createdExamSummary.id = res.data.id;
        }
        ElNotification({
          title: '成功',
          message: '试卷已成功发送！学生现在可以参加考试。',
          type: 'success',
          duration: 4000
        });
        
        // 返回老师班级界面考试管理板块
        goBackToClassExam();
      } else {
        ElMessage.error(res.message || '发送试卷失败');
      }
    } catch (error) {
      console.error('发送试卷失败:', error);
      ElMessage.error('发送试卷失败：' + (error.message || '未知错误'));
    } finally {
      isSending.value = false;
    }
  }).catch(() => {});
};

onMounted(async () => {
  loadUserInfo();
  await loadCourses(); // 确保课程列表加载完成，以便el-select能显示课程名

  // 从路由获取班级ID和名称以及课程ID
  selectedClassId.value = route.params.classId;
  selectedClassName.value = route.query.className; // 从 query 获取班级名称
  const routeCourseId = route.query.courseId;

  if (selectedClassId.value) {
    examForm.classId = Number(selectedClassId.value);
    examForm.className = selectedClassName.value;
  } else {
    ElMessage.warning('未能获取班级信息，请从班级列表进入！');
    // 可以选择跳转到教师主页或其他地方
    // router.push('/teacher/home');
  }

  if (routeCourseId) {
    examForm.courseId = Number(routeCourseId);
    // 手动触发一次 handleCourseChange 来加载题目，并确保el-select显示名称
    // 由于el-select已经 disabled，它不会触发change事件，所以这里手动设置课程名称
    const selectedCourse = courses.value.find(c => c.id === examForm.courseId);
    if (selectedCourse) {
      // el-select在disabled状态下会直接显示v-model的值，但为了确保文本显示，如果需要的话可以手动给examForm.courseName赋值
      // 然而el-select绑定v-model到courseId，且options有label，即使disabled也会显示label。这里不需要额外设置examForm.courseName。
    } else {
      console.warn('Course not found in loaded courses for ID:', examForm.courseId);
    }
    // 强制加载一次题目，因为课程ID已确定
    await loadQuestionsByCourse(examForm.courseId);
  }
});
</script>

<style scoped>
.exam-create-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 50%, #e8eaf6 100%);
  font-family: 'Inter', sans-serif;
}

.top-nav {
  height: 64px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40px;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  width: 100%;
  z-index: 1000;
  backdrop-filter: blur(10px);
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(248, 249, 255, 0.95) 100%);
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

.platform-logo {
  font-size: 26px;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
  letter-spacing: 0.5px;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
}

.nav-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.user-display {
  display: flex;
  align-items: center;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 25px;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
  gap: 10px;
}

.user-display:hover {
  background: rgba(255, 255, 255, 1);
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
  transform: translateY(-1px);
}

.user-avatar {
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.25);
  border: 2px solid #fff;
}

.user-name {
  font-size: 15px;
  color: #333;
  font-weight: 500;
  letter-spacing: 0.3px;
}

.back-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border: none;
  border-radius: 10px;
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 8px;
  position: relative;
  overflow: hidden;
}

.back-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
  transition: left 0.5s;
}

.back-button:hover::before {
  left: 100%;
}

.back-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.35);
}

.back-button:active {
  transform: translateY(0);
  box-shadow: 0 3px 8px rgba(102, 126, 234, 0.25);
}

.back-icon {
  font-size: 16px;
  transition: transform 0.3s ease;
}

.back-button:hover .back-icon {
  transform: translateX(-3px);
}

.back-text {
  font-weight: 500;
  letter-spacing: 0.3px;
}

.main-content {
  flex-grow: 1;
  padding: 30px;
  max-width: 1200px;
  margin: 94px auto 20px auto; /* 64px导航栏 + 30px间距 */
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
}

.create-steps {
  margin-bottom: 40px;
  padding: 30px 20px;
  background: linear-gradient(135deg, #f8f9ff 0%, #fff5f8 100%);
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.step-content {
  padding: 20px 30px;
}

.step-panel {
  background: linear-gradient(145deg, #ffffff 0%, #fafbfc 100%);
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(102, 126, 234, 0.1);
  position: relative;
  overflow: hidden;
  animation: fadeInUp 0.5s ease-out;
}

/* 考试信息设置面板居中 */
.info-settings {
  max-width: 800px;
  margin: 0 auto;
}

.step-panel::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border-radius: 16px 16px 0 0;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.step-title {
  font-size: 24px;
  font-weight: 600;
  color: #333;
  margin-bottom: 30px;
  text-align: center;
  position: relative;
}

.step-title::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 60px;
  height: 3px;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  border-radius: 2px;
}

.exam-form {
  max-width: 650px;
  margin: 0 auto;
  padding: 20px;
}

/* 表单项样式 */
.form-item-with-icon {
  margin-bottom: 28px;
  transition: all 0.3s ease;
}

.form-item-with-icon:hover {
  transform: translateX(4px);
}

/* 表单标签样式 */
.form-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
  color: #333;
  font-size: 15px;
}

.label-icon {
  color: #667eea;
  font-size: 18px;
}

/* 持续时长显示 */
.duration-display {
  display: flex;
  align-items: center;
  gap: 12px;
}

.duration-unit {
  font-size: 15px;
  color: #606266;
  font-weight: 500;
  padding: 0 12px;
  background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 100%);
  border-radius: 8px;
  height: 32px;
  display: flex;
  align-items: center;
}

/* 按钮form-item居中 */
.button-form-item {
  margin-top: 20px;
}

.button-form-item :deep(.el-form-item__content) {
  display: flex;
  justify-content: center;
  margin-left: 0 !important;
}

.next-step-button, .send-exam-button {
  width: auto;
  min-width: 200px;
  max-width: 300px;
  margin: 0;
  padding: 14px 24px;
  font-size: 16px;
  font-weight: 600;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.35);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.next-step-button::before, .send-exam-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s;
}

.next-step-button:hover::before, .send-exam-button:hover::before {
  left: 100%;
}

.next-step-button:hover, .send-exam-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.45);
}

.next-step-button:active, .send-exam-button:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 导航按钮容器中的创建按钮特殊样式 */
.navigation-buttons .create-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.35);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.navigation-buttons .create-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s;
}

.navigation-buttons .create-button:hover::before {
  left: 100%;
}

.navigation-buttons .create-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.45);
}

.navigation-buttons .create-button:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 选择题目头部 */
.select-questions-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.select-questions-header .step-title {
  margin-bottom: 0;
}

.selected-count {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 24px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.12) 0%, rgba(118, 75, 162, 0.08) 100%);
  border-radius: 25px;
  border: 2px solid rgba(102, 126, 234, 0.3);
  color: #667eea;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
  animation: slideInRight 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  transition: all 0.3s ease;
}

.selected-count:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.35);
  border-color: rgba(102, 126, 234, 0.5);
}

.selected-count .el-icon {
  font-size: 20px;
  color: #667eea;
  animation: checkIconPulse 0.6s ease;
}

.selected-count strong {
  font-size: 18px;
  font-weight: 700;
  color: #667eea;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

@keyframes checkIconPulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.2);
  }
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* 搜索和筛选区域 */
.question-filters {
  display: flex;
  gap: 20px;
  margin: 25px 0;
  align-items: center;
}

.search-wrapper {
  flex: 1;
}

.filter-wrapper {
  width: 200px;
  flex-shrink: 0;
}

/* 搜索框样式 */
.search-wrapper :deep(.el-input__wrapper) {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  border: 2px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
  background: #fafbff;
}

.search-wrapper :deep(.el-input__wrapper:hover) {
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.12);
}

.search-wrapper :deep(.el-input__wrapper.is-focus) {
  border-color: #667eea;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.25);
  background: #fff;
}

.search-wrapper :deep(.el-input__prefix) {
  color: #667eea;
  font-size: 18px;
}

.search-wrapper :deep(.el-input__inner) {
  font-size: 15px;
  color: #303133;
}

.search-wrapper :deep(.el-input__inner::placeholder) {
  color: #a8abb2;
  font-size: 14px;
}

/* 筛选下拉框样式 */
.filter-wrapper :deep(.el-select__wrapper) {
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  border: 2px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
  background: #fafbff;
}

.filter-wrapper :deep(.el-select__wrapper:hover) {
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.12);
}

.filter-wrapper :deep(.el-select__wrapper.is-focused) {
  border-color: #667eea;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.25);
  background: #fff;
}

/* 题目列表区域 */
.question-list {
  margin-bottom: 25px;
}

/* 两栏布局：左表右侧栏（牛客风格） */
.selection-body {
  display: flex;
  gap: 24px;
  align-items: flex-start;
}

.selection-left {
  flex: 1;
  min-width: 0; /* 允许内容收缩，避免溢出 */
}

.selection-right {
  width: 320px;
  position: sticky;
  top: 10px;
  align-self: flex-start;
}

/* 右侧面板在侧边栏中的尺寸与滚动 */
.selection-right .selected-questions-panel {
  margin: 0;
  height: 80vh;
  display: flex;
  flex-direction: column;
}

.selection-right .selected-questions-list {
  flex: 1;
  max-height: none;
  overflow-y: auto;
}

/* 左侧题目列表等高（与右侧一致） */
.selection-left .question-list {
  height: 70vh;
  display: flex;
  flex-direction: column;
}

.question-table-wrapper {
  flex: 1;
  min-height: 0;
  overflow: auto;
}

/* 右侧面板空状态 */
.empty-selected {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 30px 16px;
  text-align: center;
  color: #909399;
}

/* 将选择题外侧右栏浮出到卡片外（页面右侧） */
.step-panel.select-questions {
  overflow: visible; /* 允许外侧浮出的侧栏显示 */
}


.selection-region { position: relative; }

.selected-sidebar {
  position: fixed;
  top: 120px; /* 与顶部导航/步骤条错开，必要时可微调 */
  right: 24px; /* 贴近页面右侧 */
  transform: none; /* 固定定位不再需要位移 */
  width: 320px;
  z-index: 950;
}

.selected-sidebar .selected-questions-panel {
  margin: 0;
  height: 70vh;
  display: flex;
  flex-direction: column;
}

.selected-sidebar .selected-questions-list {
  flex: 1;
  overflow-y: auto;
  max-height: none; /* 取消全局 400px 限制，填满 70vh 可用区 */
  overscroll-behavior: contain; /* 防滚动穿透，提高侧栏滚动可控性 */
}

.empty-icon {
  font-size: 36px;
  margin-bottom: 8px;
  opacity: 0.35;
}

.empty-text {
  font-size: 14px;
  margin-bottom: 4px;
}

.empty-hint {
  font-size: 12px;
  color: #c0c4cc;
}

/* 响应式：小屏改为上下布局 */
@media (max-width: 1200px) {
  .selection-body {
    flex-direction: column;
  }
  .selection-right {
    position: static;
    width: 100%;
  }
  .selection-right .selected-questions-panel {
    height: auto;
  }
  .selection-right .selected-questions-list {
    max-height: 320px;
  }
  .selection-left .question-list {
    height: auto;
  }
  .question-table-wrapper {
    max-height: 320px;
  }
}

/* 已取消小屏回退：侧栏在所有屏宽保持固定在页面右侧 */

.navigation-buttons {
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  gap: 16px;
  flex-wrap: nowrap;
  position: sticky;
  bottom: 0;
  padding: 12px 0;
  background: linear-gradient(180deg, rgba(255,255,255,0.92) 0%, rgba(255,255,255,0.98) 70%);
  backdrop-filter: blur(6px);
  border-top: 1px solid #f0f3f8;
  z-index: 5;
}

.prev-step-button {
  flex: 1 1 0;
  min-width: 150px;
  max-width: 200px;
  width: 100%;
  height: 50px;
  background-color: #fff;
  color: #606266;
  border: 1px solid #dcdfe6;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
}

.prev-step-button:hover {
  background-color: #f7f9fc;
  border-color: #c0c4cc;
  color: #409eff;
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.08);
}

.create-button {
  flex: 1 1 0;
  min-width: 150px;
  max-width: 200px;
  width: 100%;
  height: 50px;
  font-size: 18px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border-radius: 12px;
}

.exam-summary {
  max-width: 800px;
  margin: 0 auto 30px auto;
}

/* 创建完成页面样式 */
.create-complete {
  max-width: 900px;
  margin: 0 auto;
}

.complete-header {
  text-align: center;
  padding: 30px 0;
  margin-bottom: 40px;
  background: linear-gradient(135deg, #e8f5e9 0%, #e0f2f1 100%);
  border-radius: 16px;
  border: 2px solid #4caf50;
}

.success-icon {
  font-size: 60px;
  color: #4caf50;
  margin-bottom: 15px;
  animation: successPulse 1s ease infinite;
}

@keyframes successPulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.1);
  }
}

.complete-header .step-title {
  font-size: 28px;
  color: #2e7d32;
  margin-bottom: 10px;
  font-weight: 700;
}

.complete-hint {
  font-size: 14px;
  color: #66bb6a;
  margin: 0;
}

.summary-section {
  margin-bottom: 35px;
  padding: 25px;
  background: #fff;
  border-radius: 16px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.1);
  transition: all 0.3s ease;
}

.summary-section:hover {
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
  transform: translateY(-2px);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 18px;
  font-weight: 600;
  color: #667eea;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.2);
}

.section-title .el-icon {
  font-size: 22px;
}

/* 题目统计卡片 */
.question-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 20px;
  background: linear-gradient(135deg, #f8f9ff 0%, #fff5f8 100%);
  border-radius: 12px;
  border: 2px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
  cursor: default;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.2);
  border-color: rgba(102, 126, 234, 0.3);
}

.stat-card.total {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.15) 0%, rgba(118, 75, 162, 0.1) 100%);
  border-color: #667eea;
  grid-column: span 2;
}

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  font-size: 24px;
  flex-shrink: 0;
}

.stat-icon.primary {
  background: linear-gradient(135deg, #409eff 0%, #53a8ff 100%);
}

.stat-icon.success {
  background: linear-gradient(135deg, #67c23a 0%, #85ce61 100%);
}

.stat-icon.warning {
  background: linear-gradient(135deg, #e6a23c 0%, #ebb563 100%);
}

.stat-icon.info {
  background: linear-gradient(135deg, #909399 0%, #a6a9ad 100%);
}

.stat-icon.danger {
  background: linear-gradient(135deg, #f56c6c 0%, #f78989 100%);
}

.stat-info {
  flex: 1;
}

.stat-label {
  font-size: 13px;
  color: #909399;
  margin-bottom: 5px;
  font-weight: 500;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* 组卷功能样式 */
.paper-arrangement {
  margin-top: 30px;
}

.paper-mode-selector {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 25px;
  padding: 20px;
  background: linear-gradient(135deg, #f8f9ff 0%, #fff5f8 100%);
  border-radius: 12px;
}

.paper-mode-selector :deep(.el-radio-group) {
  flex: 1;
  display: flex;
  gap: 10px;
}

.paper-mode-selector :deep(.el-radio-button) {
  flex: 1;
}

.paper-mode-selector :deep(.el-radio-button__inner) {
  width: 100%;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border-radius: 10px;
  border: 2px solid #e4e7ed;
  transition: all 0.3s ease;
}

.paper-mode-selector :deep(.el-radio-button__inner:hover) {
  border-color: #667eea;
  color: #667eea;
  transform: translateY(-2px);
}

.paper-mode-selector :deep(.el-radio-button.is-active .el-radio-button__inner) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: #667eea;
  color: #fff;
}

.paper-mode-selector .el-button {
  height: 50px;
  padding: 0 30px;
  font-size: 15px;
  border-radius: 10px;
}

.question-order-list {
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 12px;
  overflow: hidden;
}

.order-list-header {
  display: grid;
  grid-template-columns: 60px 100px 1fr 100px 80px 100px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border-radius: 10px 10px 0 0;
  overflow: hidden;
  font-weight: 600;
  font-size: 14px;
}

.order-list-header .header-item {
  padding: 15px;
  text-align: center;
  border-right: 1px solid rgba(255, 255, 255, 0.2);
}

.order-list-header .header-item:last-child {
  border-right: none;
}

.order-list-item {
  display: grid;
  grid-template-columns: 60px 100px 1fr 100px 80px 100px;
  border-bottom: 1px solid #f0f0f0;
  transition: all 0.3s ease;
}

.order-list-item:hover {
  background: #f8f9ff;
}

.order-list-item > span {
  padding: 15px;
  display: flex;
  align-items: center;
}

.order-group {
  margin: 18px 0 28px;
  border: 1px solid #f0f3f8;
  border-radius: 10px;
  overflow: hidden;
  background: #fff;
}

.order-group-header {
  padding: 12px 14px;
  background: #f9fbff;
  border-bottom: 1px solid #eef2f7;
}

.group-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
}

.group-count {
  margin-left: 8px;
  font-size: 13px;
  color: #8c8c8c;
  font-weight: 400;
}

.order-group .order-list-body {
  max-height: none;
  overflow: visible;
}

.item-index {
  font-weight: 600;
  color: #667eea;
}

.item-content {
  justify-content: flex-start;
  text-align: left;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-actions {
  gap: 5px;
}

.item-actions .el-button {
  font-size: 16px;
}

/* 列表动画 */
.list-move,
.list-enter-active,
.list-leave-active {
  transition: all 0.5s ease;
}

.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

.list-leave-active {
  position: absolute;
}

/* 已选择题目列表样式 */
.selected-questions-panel {
  margin: 30px 0;
  background: #fff;
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 12px;
  overflow: hidden;
}

.selected-panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: #f9fbff;
  border-bottom: 1px solid rgba(102, 126, 234, 0.15);
  position: sticky;
  top: 0;
  z-index: 2;
}

.selected-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 600;
  color: #667eea;
  margin: 0;
}

.selected-title .el-icon {
  font-size: 20px;
}

.selected-questions-list {
  max-height: 400px;
  overflow-y: auto;
}

.selected-list-container {
  padding: 0;
}

.selected-question-item {
  display: flex;
  align-items: center;
  gap: 15px;
  padding: 15px 25px;
  border-bottom: 1px solid #f5f5f5;
  transition: all 0.3s ease;
}

.selected-question-item:hover {
  background: #f8f9ff;
}

.selected-question-item:last-child {
  border-bottom: none;
}

.selected-item-index {
  flex-shrink: 0;
  width: 32px;
  height: 32px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
}

.selected-item-info {
  flex: 1;
  min-width: 0;
}

.selected-item-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.selected-item-score {
  font-size: 13px;
  color: #52c41a;
  font-weight: 600;
}

.selected-item-difficulty {
  font-size: 14px;
  color: #faad14;
}

.selected-item-content {
  font-size: 14px;
  color: #606266;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 已选择题目列表动画 */
.selected-list-move,
.selected-list-enter-active,
.selected-list-leave-active {
  transition: all 0.3s ease;
}

.selected-list-enter-from,
.selected-list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

.selected-list-leave-active {
  position: absolute;
  width: calc(100% - 50px);
}

/* 发送试卷按钮 */
.send-exam-button {
  flex: 1 1 0;
  min-width: 150px;
  max-width: 200px;
  width: 100%;
  height: 50px;
  font-size: 18px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  background: linear-gradient(135deg, #4caf50 0%, #66bb6a 100%);
  border: none;
  border-radius: 12px;
  box-shadow: 0 4px 16px rgba(76, 175, 80, 0.35);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.send-exam-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: rgba(255, 255, 255, 0.2);
  transition: left 0.6s;
}

.send-exam-button:hover::before {
  left: 100%;
}

.send-exam-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(76, 175, 80, 0.45);
}

.send-exam-button:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
}

.send-exam-button .el-icon {
  font-size: 20px;
}

/* Element Plus 样式覆盖 */
:deep(.el-input-number .el-input__inner) {
  text-align: left;
}

/* 输入框样式优化 */
:deep(.el-input__wrapper) {
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
  border: 1px solid #e4e7ed;
}

:deep(.el-input__wrapper:hover) {
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
  border-color: #667eea;
}

:deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25);
  border-color: #667eea;
}

:deep(.el-input__prefix) {
  color: #667eea;
}

/* 选择器样式优化 */
:deep(.el-select .el-input__wrapper) {
  border-radius: 8px;
}

/* 日期选择器样式优化 */
:deep(.el-date-editor) {
  width: 100%;
}

:deep(.el-date-editor .el-input__wrapper) {
  border-radius: 8px;
}

:deep(.el-date-editor .el-input__prefix) {
  color: #667eea;
}

/* 数字输入框样式优化 */
:deep(.el-input-number) {
  width: 180px;
}

:deep(.el-input-number .el-input__wrapper) {
  border-radius: 8px;
}

/* 表单验证错误样式 */
:deep(.el-form-item.is-error .el-input__wrapper) {
  box-shadow: 0 4px 12px rgba(245, 108, 108, 0.25);
}

:deep(.el-form-item__error) {
  font-size: 13px;
  padding-top: 4px;
}
:deep(.el-step.is-process .el-step__title) {
  color: #667eea !important;
  font-weight: bold;
}
:deep(.el-step.is-process .el-step__icon.is-text) {
  background-color: #667eea !important;
  border-color: #667eea !important;
  color: #fff !important;
}
:deep(.el-step.is-success .el-step__title) {
  color: #4CAF50 !important;
}
:deep(.el-step.is-success .el-step__icon.is-text) {
  background-color: #4CAF50 !important;
  border-color: #4CAF50 !important;
  color: #fff !important;
}
:deep(.el-step__description) {
  font-size: 13px;
  color: #909399;
}
:deep(.el-steps--horizontal) {
  padding: 20px 0;
}
:deep(.el-tabs--card > .el-tabs__header) {
  border-bottom: none;
  margin-bottom: 0;
}

:deep(.el-tabs--card > .el-tabs__header .el-tabs__nav) {
  border: 2px solid rgba(102, 126, 234, 0.15);
  border-radius: 12px;
  background: linear-gradient(145deg, #ffffff 0%, #fafbfc 100%);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  padding: 4px;
}

:deep(.el-tabs--card > .el-tabs__header .el-tabs__item) {
  border: none !important;
  margin: 0 4px;
  height: 42px;
  line-height: 42px;
  padding: 0 24px;
  border-radius: 8px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  font-weight: 500;
  font-size: 14px;
}

:deep(.el-tabs--card > .el-tabs__header .el-tabs__item:first-child) {
  margin-left: 0;
}

:deep(.el-tabs--card > .el-tabs__header .el-tabs__item:last-child) {
  margin-right: 0;
}

:deep(.el-tabs--card > .el-tabs__header .el-tabs__item.is-active) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff !important;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.35);
  transform: translateY(-1px);
  font-weight: 600;
}

:deep(.el-tabs--card > .el-tabs__header .el-tabs__item:not(.is-active):hover) {
  color: #667eea;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.05) 100%);
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.15);
}

:deep(.el-tabs__content) {
  padding-top: 10px;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .top-nav {
    padding: 0 15px;
  }
  .platform-logo {
    font-size: 20px;
  }
  .nav-right {
    gap: 10px;
  }
  .main-content {
    padding: 15px;
    margin: 84px auto 10px auto; /* 64px导航栏 + 20px间距 */
    border-radius: 12px;
  }
  .create-steps {
    margin-bottom: 20px;
  }
  .step-content {
    padding: 10px;
  }
  .step-panel {
    padding: 25px 20px;
  }
  .step-title {
    font-size: 20px;
    margin-bottom: 20px;
  }
  .exam-form {
    max-width: 100%;
    padding: 10px;
  }
  .form-item-with-icon:hover {
    transform: none;
  }
  .duration-display {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  .duration-unit {
    width: fit-content;
  }
  .navigation-buttons {
    flex-direction: row;
    flex-wrap: wrap;
    gap: 10px;
  }
  .next-step-button, .prev-step-button, .create-button, .send-exam-button {
    flex: 1 1 calc(50% - 5px);
    min-width: 140px;
  }
  
  /* 搜索框响应式 */
  .question-search {
    margin: 20px 0;
  }
  
  .question-search :deep(.el-input__inner) {
    font-size: 14px;
  }
  
  /* 标签页响应式优化 */
  :deep(.el-tabs--card > .el-tabs__header .el-tabs__item) {
    padding: 0 12px;
    font-size: 13px;
    margin: 0 2px;
  }
  
  /* 选择题目头部响应式 */
  .select-questions-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .selected-count {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .top-nav {
    padding: 0 10px;
  }
  .platform-logo {
    font-size: 18px;
  }
  .user-name {
    display: none;
  }
  .main-content {
    margin: 74px auto 5px auto; /* 64px导航栏 + 10px间距 */
    padding: 10px;
  }
  .step-panel {
    padding: 15px;
  }
  .step-title {
    font-size: 18px;
    margin-bottom: 15px;
  }
  
  /* 小屏幕按钮垂直布局 */
  .navigation-buttons {
    flex-direction: column;
  }
  .next-step-button, .prev-step-button, .create-button, .send-exam-button {
    width: 100%;
    min-width: auto;
  }
}
</style>
