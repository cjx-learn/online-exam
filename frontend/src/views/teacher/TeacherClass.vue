<template>
  <div class="teacher-class-container">
    <!-- 顶部操作区 -->
    <div class="top-header">
      <div class="header-left">
        <h1 class="system-title">在线考试系统</h1>
      </div>
      <div class="header-right">
        <el-button type="danger" @click="goBack" class="back-btn">
          <el-icon><Back /></el-icon>
          返回主界面
        </el-button>
        
        <!-- 用户头像下拉菜单 -->
        <el-dropdown @command="handleUserCommand">
          <div class="user-avatar">
            <el-avatar :size="42" :icon="UserFilled" class="avatar-img" />
            <span class="user-name">{{ userInfo.realName || '教师' }}</span>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="profile">
                <el-icon><User /></el-icon>
                修改信息
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

    <!-- 主体区域 -->
    <div class="main-container">
      <!-- 左侧导航栏 -->
      <div class="sidebar">
        <div class="sidebar-header">
          <h3>{{ classInfo.name }}</h3>
          <p>{{ classInfo.code }}</p>
        </div>
        <el-menu
          :default-active="activeMenu"
          class="sidebar-menu"
          background-color="transparent"
          text-color="rgba(255, 255, 255, 0.85)"
          active-text-color="#ffffff"
          @select="handleMenuSelect"
        >
          <el-menu-item index="students">
            <el-icon><User /></el-icon>
            <span>学生管理</span>
          </el-menu-item>
          <el-menu-item index="questions">
            <el-icon><Document /></el-icon>
            <span>题库查看</span>
          </el-menu-item>
          <el-menu-item index="exams">
            <el-icon><EditPen /></el-icon>
            <span>考试管理</span>
          </el-menu-item>
          <el-menu-item index="grading">
            <el-icon><Reading /></el-icon>
            <span>主观题试卷批改</span>
          </el-menu-item>
        </el-menu>
      </div>

      <!-- 右侧内容区 -->
      <div class="content-area">
        <!-- 学生管理 -->
        <div v-if="activeMenu === 'students'" class="content-panel">
          <div class="panel-header">
            <h2>学生管理</h2>
          </div>
          <el-table :data="studentList" stripe style="width: 100%">
            <el-table-column type="index" label="序号" width="80" align="center" />
            <el-table-column prop="studentNo" label="学号" width="140" show-overflow-tooltip />
            <el-table-column prop="realName" label="姓名" width="120" show-overflow-tooltip />
            <el-table-column prop="username" label="用户名" width="150" show-overflow-tooltip />
            <el-table-column prop="email" label="邮箱" min-width="200" show-overflow-tooltip />
            <el-table-column prop="phone" label="手机号" width="150" />
            <el-table-column label="操作" width="120" fixed="right" align="center">
              <template #default="scope">
                <el-button
                  type="danger"
                  size="small"
                  @click="handleDeleteStudent(scope.row)"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 题库查看 -->
        <div v-if="activeMenu === 'questions'" class="content-panel">
          <div class="panel-header">
            <h2>题库管理</h2>
          </div>
          
          <!-- 搜索和筛选区域 -->
          <div class="question-filters">
            <el-input 
              v-model="questionSearchKeyword" 
              placeholder="搜索题目内容或知识点..." 
              clearable
              class="search-input"
              @input="filterQuestions"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            <el-select 
              v-model="selectedQuestionType" 
              placeholder="全部题型" 
              clearable 
              @change="filterQuestions" 
              class="filter-select"
            >
              <el-option label="全部题型" value=""></el-option>
              <el-option label="单选题" :value="1"></el-option>
              <el-option label="多选题" :value="2"></el-option>
              <el-option label="判断题" :value="3"></el-option>
              <el-option label="填空题" :value="4"></el-option>
              <el-option label="简答题" :value="5"></el-option>
            </el-select>
            <el-select 
              v-model="selectedQuestionDifficulty" 
              placeholder="全部难度" 
              clearable 
              @change="filterQuestions" 
              class="filter-select"
            >
              <el-option label="全部难度" value=""></el-option>
              <el-option label="⭐ 简单" :value="1"></el-option>
              <el-option label="⭐⭐ 中等" :value="2"></el-option>
              <el-option label="⭐⭐⭐ 困难" :value="3"></el-option>
            </el-select>
            <div class="btn-group">
              <el-button type="primary" @click="showAddQuestionDialog" class="add-question-btn">
                <el-icon><Plus /></el-icon>
                添加题目
              </el-button>
              <el-upload
                ref="excelUploadRef"
                :action="''"
                :auto-upload="false"
                :show-file-list="false"
                accept=".xlsx,.xls"
                :on-change="handleExcelFileChange"
              >
                <el-button type="success" class="upload-excel-btn">
                  <el-icon><Upload /></el-icon>
                  批量导入
                </el-button>
              </el-upload>
              <el-button type="info" @click="downloadExcelTemplate" class="download-template-btn">
                <el-icon><Download /></el-icon>
                下载模板
              </el-button>
            </div>
          </div>
          <el-table :data="paginatedQuestionList" stripe style="width: 100%">
            <el-table-column type="index" label="序号" width="60" :index="getQuestionIndex" />
            <el-table-column prop="content" label="题干" min-width="200" show-overflow-tooltip />
            <el-table-column prop="type" label="题型" width="100">
              <template #default="scope">
                <el-tag :type="getQuestionTypeTag(scope.row.type)">
                  {{ getQuestionTypeText(scope.row.type) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="score" label="分值" width="80" />
            <el-table-column prop="category" label="知识点" width="120" />
            <el-table-column prop="difficulty" label="难度" width="100" align="center">
              <template #default="scope">
                <span v-if="scope.row.difficulty" :style="{ color: getDifficultyColor(scope.row.difficulty), fontSize: '16px' }">
                  {{ '⭐'.repeat(scope.row.difficulty) }}
                </span>
                <span v-else style="color: #d9d9d9;">-</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150" fixed="right">
              <template #default="scope">
                <el-button
                  type="primary"
                  size="small"
                  @click="handleViewQuestion(scope.row)"
                >
                  查看
                </el-button>
                <el-button
                  type="danger"
                  size="small"
                  @click="handleDeleteQuestion(scope.row)"
                >
                  删除
                </el-button>
              </template>
            </el-table-column>
          </el-table>
          
          <!-- 分页 -->
          <el-pagination
            v-model:current-page="questionCurrentPage"
            v-model:page-size="questionPageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="filteredQuestionList.length"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleQuestionSizeChange"
            @current-change="handleQuestionPageChange"
            style="margin-top: 20px; justify-content: center;"
          />
        </div>

        <!-- 考试管理 -->
        <div v-if="activeMenu === 'exams'" class="content-panel">
          <div class="panel-header">
            <h2>考试管理</h2>
            <el-button type="danger" @click="showCreateExamDialog">
              <el-icon><Plus /></el-icon>
              创建考试
            </el-button>
          </div>
          <el-table :data="examList" stripe style="width: 100%">
            <el-table-column type="index" label="序号" width="60" />
            <el-table-column prop="title" label="考试名称" min-width="180" />
            <el-table-column prop="startTime" label="开始时间" width="170">
              <template #default="scope">
                {{ formatTime(scope.row.startTime) }}
              </template>
            </el-table-column>
            <el-table-column prop="endTime" label="结束时间" width="170">
              <template #default="scope">
                {{ formatTime(scope.row.endTime) }}
              </template>
            </el-table-column>
            <el-table-column prop="duration" label="时长(分钟)" width="110" />
            <el-table-column prop="totalScore" label="总分" width="80" />
            <el-table-column label="状态" width="100">
              <template #default="scope">
                <el-tag :type="getExamStatusTag(scope.row)">
                  {{ getExamStatusText(scope.row) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column label="查看试题" width="120" fixed="right" align="center">
              <template #default="scope">
                <el-button class="action-btn btn-view" size="small" @click="handleViewPaper(scope.row)">
                  <el-icon><Document /></el-icon>
                  查看试题
                </el-button>
              </template>
            </el-table-column>
            <el-table-column label="查看成绩" width="120" fixed="right" align="center">
              <template #default="scope">
                <el-button 
                  v-if="isExamEnded(scope.row)" 
                  class="action-btn btn-grades" 
                  size="small" 
                  @click="handleViewGrades(scope.row)"
                >
                  <el-icon><Histogram /></el-icon>
                  查看成绩
                </el-button>
                <el-button 
                  v-else 
                  class="action-btn btn-grades-disabled" 
                  size="small" 
                  disabled
                >
                  <el-icon><Histogram /></el-icon>
                  考试未结束
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 主观题批改 -->
        <div v-if="activeMenu === 'grading'" class="content-panel">
          <div class="panel-header">
            <h2>主观题试卷批改</h2>
          </div>
          <el-table :data="gradingList" stripe style="width: 100%">
            <el-table-column type="index" label="序号" width="60" />
            <el-table-column prop="examName" label="考试名称" min-width="200" />
            <el-table-column prop="startTime" label="考试时间" width="170">
              <template #default="scope">
                {{ formatTime(scope.row.startTime) }}
              </template>
            </el-table-column>
            <el-table-column label="批改进度" width="200">
              <template #default="scope">
                <div style="display: flex; align-items: center; gap: 8px;">
                  <el-progress
                    :percentage="getGradingProgress(scope.row)"
                    :color="getProgressColor(scope.row)"
                    :stroke-width="12"
                    style="flex: 1;"
                  />
                  <span style="font-size: 12px; color: #606266; white-space: nowrap;">
                    {{ scope.row.gradedCount }}/{{ scope.row.pendingCount + scope.row.gradedCount }}
                  </span>
                </div>
              </template>
            </el-table-column>
            <el-table-column prop="pendingCount" label="待批改" width="80" align="center">
              <template #default="scope">
                <el-tag v-if="scope.row.pendingCount > 0" type="warning" size="small">
                  {{ scope.row.pendingCount }}
                </el-tag>
                <el-tag v-else type="success" size="small">完成</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150" fixed="right">
              <template #default="scope">
                <el-button
                  type="primary"
                  size="small"
                  @click="handleGrading(scope.row)"
                >
                  去批改
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </div>

    <!-- 添加题目对话框 -->
    <el-dialog
      v-model="questionDialogVisible"
      title="添加题目"
      width="700px"
      :close-on-click-modal="false"
    >
      <el-form :model="questionForm" :rules="questionRules" ref="questionFormRef" label-width="100px">
        <el-form-item label="题型" prop="type">
          <el-radio-group v-model="questionForm.type">
            <el-radio :value="1">单选题</el-radio>
            <el-radio :value="2">多选题</el-radio>
            <el-radio :value="3">判断题</el-radio>
            <el-radio :value="4">填空题</el-radio>
            <el-radio :value="5">简答题</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="题干" prop="content">
          <el-input
            v-model="questionForm.content"
            type="textarea"
            :rows="3"
            placeholder="请输入题干"
          />
        </el-form-item>
        <el-form-item label="选项A" prop="optionA" v-if="[1, 2].includes(questionForm.type)">
          <el-input v-model="questionForm.optionA" placeholder="请输入选项A" />
        </el-form-item>
        <el-form-item label="选项B" prop="optionB" v-if="[1, 2].includes(questionForm.type)">
          <el-input v-model="questionForm.optionB" placeholder="请输入选项B" />
        </el-form-item>
        <el-form-item label="选项C" prop="optionC" v-if="[1, 2].includes(questionForm.type)">
          <el-input v-model="questionForm.optionC" placeholder="请输入选项C" />
        </el-form-item>
        <el-form-item label="选项D" prop="optionD" v-if="[1, 2].includes(questionForm.type)">
          <el-input v-model="questionForm.optionD" placeholder="请输入选项D" />
        </el-form-item>
        <el-form-item label="答案" prop="answer">
          <el-input v-model="questionForm.answer" placeholder="请输入答案" />
        </el-form-item>
        <el-form-item label="分值" prop="score">
          <el-input-number v-model="questionForm.score" :min="1" :max="100" />
        </el-form-item>
        <el-form-item label="知识点" prop="category">
          <el-input v-model="questionForm.category" placeholder="请输入知识点" />
        </el-form-item>
        <el-form-item label="难度" prop="difficulty">
          <el-radio-group v-model="questionForm.difficulty">
            <el-radio :value="1">⭐ 简单</el-radio>
            <el-radio :value="2">⭐⭐ 中等</el-radio>
            <el-radio :value="3">⭐⭐⭐ 困难</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="questionDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmAddQuestion">确定</el-button>
      </template>
    </el-dialog>

    <!-- 题目详情对话框 -->
    <el-dialog
      v-model="questionDetailVisible"
      title="题目详情"
      width="1100px"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="题型">
          {{ getQuestionTypeText(currentQuestion.type) }}
        </el-descriptions-item>
        <el-descriptions-item label="题干">
          {{ currentQuestion.content }}
        </el-descriptions-item>
        <el-descriptions-item label="选项" v-if="[1, 2].includes(currentQuestion.type)">
          <div v-if="currentQuestion.options">
            <p v-for="(opt, key) in JSON.parse(currentQuestion.options)" :key="key">
              {{ key }}: {{ opt }}
            </p>
          </div>
        </el-descriptions-item>
        <el-descriptions-item label="答案">
          {{ currentQuestion.answer }}
        </el-descriptions-item>
        <el-descriptions-item label="分值">
          {{ currentQuestion.score }}分
        </el-descriptions-item>
        <el-descriptions-item label="知识点">
          {{ currentQuestion.category }}
        </el-descriptions-item>
        <el-descriptions-item label="难度">
          <span v-if="currentQuestion.difficulty" :style="{ color: getDifficultyColor(currentQuestion.difficulty), fontSize: '16px' }">
            {{ '⭐'.repeat(currentQuestion.difficulty) }}
          </span>
          <span v-else>未设置</span>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 个人信息对话框 -->
    <el-dialog 
      v-model="profileDialogVisible" 
      title="个人信息" 
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form :model="userForm" label-width="80px">
        <el-form-item label="真实姓名">
          <el-input v-model="userForm.realName" disabled />
        </el-form-item>
        <el-form-item label="工号">
          <el-input v-model="userForm.teacherNo" disabled />
        </el-form-item>
        <el-form-item label="密码">
          <el-input v-model="userForm.password" type="password" placeholder="留空则不修改" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="userForm.email" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="userForm.phone" />
        </el-form-item>
        <el-form-item label="单位">
          <el-input v-model="userForm.department" />
        </el-form-item>
        <el-form-item label="职称">
          <el-input v-model="userForm.title" />
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
import { ref, reactive, onMounted, watch, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Back, User, Document, EditPen, Reading, Plus, UserFilled, SwitchButton, Edit, Search, Histogram, Upload, Download
} from '@element-plus/icons-vue'
import * as XLSX from 'xlsx'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()

// 班级ID
const classId = ref(route.params.id)

// 用户信息
const userInfo = reactive({
  id: '',
  username: '',
  realName: '教师',
  teacherNo: '',
  email: '',
  phone: '',
  department: '',
  title: ''
})

// 个人信息表单
const userForm = reactive({ ...userInfo })

// 个人信息对话框
const profileDialogVisible = ref(false)

let currentUserInfo = null;
try {
  const storedUserInfo = localStorage.getItem('userInfo');
  if (storedUserInfo) {
    currentUserInfo = JSON.parse(storedUserInfo);
    // Populate userInfo reactive object
    if (currentUserInfo && currentUserInfo.userId) {
      Object.assign(userInfo, {
        id: currentUserInfo.userId,
        username: currentUserInfo.username,
        realName: currentUserInfo.realName,
        teacherNo: currentUserInfo.teacherNo || '',
        email: currentUserInfo.email || '',
        phone: currentUserInfo.phone || '',
        department: currentUserInfo.department || '',
        title: currentUserInfo.title || '',
      });
    }
  }
} catch (e) {
  console.error("Failed to parse userInfo from localStorage in TeacherClass:", e);
}

// 班级信息
const classInfo = reactive({
  id: null,
  name: '',
  code: '',
  teacherName: '',
  courseId: null, // 新增 courseId 字段
})

// 当前激活的菜单
const activeMenu = ref('students')

// 学生列表
const studentList = ref([])

// 题目列表
const questionList = ref([])

// 筛选题目类型
const selectedQuestionType = ref('');

// 搜索关键词
const questionSearchKeyword = ref('');

// 筛选难度
const selectedQuestionDifficulty = ref('');

// 题目分页
const questionCurrentPage = ref(1);
const questionPageSize = ref(10);

// 过滤后的题目列表（全部数据）
const filteredQuestionList = computed(() => {
  return questionList.value.filter(q => {
    // 类型筛选
    const matchType = !selectedQuestionType.value || q.type === selectedQuestionType.value;
    
    // 难度筛选
    const matchDifficulty = !selectedQuestionDifficulty.value || q.difficulty === selectedQuestionDifficulty.value;
    
    // 搜索筛选
    const matchSearch = !questionSearchKeyword.value || 
                        q.content.toLowerCase().includes(questionSearchKeyword.value.toLowerCase()) ||
                        (q.category && q.category.toLowerCase().includes(questionSearchKeyword.value.toLowerCase()));
    
    return matchType && matchDifficulty && matchSearch;
  });
});

// 分页后的题目列表（当前页显示的数据）
const paginatedQuestionList = computed(() => {
  const start = (questionCurrentPage.value - 1) * questionPageSize.value;
  const end = start + questionPageSize.value;
  return filteredQuestionList.value.slice(start, end);
});

// 考试列表
const examList = ref([])

// 批改列表
const gradingList = ref([])

// 对话框
const questionDialogVisible = ref(false)
const questionDetailVisible = ref(false)
const questionFormRef = ref(null)
const excelUploadRef = ref(null)

// 题目表单
const questionForm = reactive({
  type: 1,
  content: '',
  optionA: '',
  optionB: '',
  optionC: '',
  optionD: '',
  answer: '',
  score: 5,
  category: '',
  difficulty: 1, // 添加 difficulty 字段，默认为简单
  courseId: null, // 添加 courseId 字段
})

// 当前查看的题目
const currentQuestion = ref({})

// 表单验证规则
const questionRules = {
  type: [{ required: true, message: '请选择题型', trigger: 'change' }],
  content: [{ required: true, message: '请输入题干', trigger: 'blur' }],
  answer: [{ required: true, message: '请输入答案', trigger: 'blur' }],
  score: [{ required: true, message: '请输入分值', trigger: 'blur' }],
  category: [{ required: true, message: '请输入知识点', trigger: 'blur' }],
  difficulty: [{ required: true, message: '请选择难度', trigger: 'change' }],
  optionA: [{ required: true, message: '请输入选项A', trigger: 'blur' }],
  optionB: [{ required: true, message: '请输入选项B', trigger: 'blur' }],
  optionC: [{ required: true, message: '请输入选项C', trigger: 'blur' }],
  optionD: [{ required: true, message: '请输入选项D', trigger: 'blur' }]
}

// 加载班级信息
const loadClassInfo = async () => {
  try {
    const response = await request.get(`/class/${classId.value}`)
    if (response.code === 200) {
      Object.assign(classInfo, response.data)
      questionForm.courseId = classInfo.courseId; // 将 courseId 赋值给 questionForm
    }
  } catch (error) {
    console.error('加载班级信息失败:', error)
  }
}

// 加载学生列表
const loadStudentList = async () => {
  try {
    const response = await request.get(`/class/${classId.value}/students`)
    if (response.code === 200) {
      studentList.value = response.data || []
    }
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  }
}

// 加载题目列表
const loadQuestionList = async () => {
  try {
    if (!classInfo.courseId) {
      console.error("Course ID not found for current class. Cannot load question list.");
      ElMessage.error('课程信息未加载，无法获取题目列表！');
      return;
    }
    console.log('Fetching question list for course ID:', classInfo.courseId, 'Type:', typeof classInfo.courseId);

    // 不再通过参数筛选，改为前端过滤
    const response = await request.get(`/question/course/${classInfo.courseId}`);
    if (response.code === 200) {
      questionList.value = response.data || []
    }
  } catch (error) {
    console.error('加载题目列表失败:', error)
    ElMessage.error('加载题目列表失败')
  }
}

// 题目过滤函数（用于触发筛选）
const filterQuestions = () => {
  // 由于使用了 computed，这里不需要额外操作
  // 筛选逻辑在 filteredQuestionList 中自动执行
  // 筛选后重置到第一页
  questionCurrentPage.value = 1;
}

// 计算题目序号（考虑分页）
const getQuestionIndex = (index) => {
  return (questionCurrentPage.value - 1) * questionPageSize.value + index + 1;
}

// 分页大小变化
const handleQuestionSizeChange = (val) => {
  questionPageSize.value = val;
  questionCurrentPage.value = 1;
}

// 当前页变化
const handleQuestionPageChange = (val) => {
  questionCurrentPage.value = val;
}

// 获取难度颜色
const getDifficultyColor = (difficulty) => {
  const colorMap = {
    1: '#52c41a', // 简单 - 绿色
    2: '#faad14', // 中等 - 橙色
    3: '#f5222d'  // 困难 - 红色
  };
  return colorMap[difficulty] || '#d9d9d9';
}

// 计算批改进度百分比
const getGradingProgress = (row) => {
  const total = row.pendingCount + row.gradedCount
  if (total === 0) return 0
  return Math.round((row.gradedCount / total) * 100)
}

// 获取进度条颜色
const getProgressColor = (row) => {
  const percentage = getGradingProgress(row)
  if (percentage === 100) return '#67c23a' // 绿色 - 完成
  if (percentage >= 50) return '#e6a23c' // 橙色 - 进行中
  return '#f56c6c' // 红色 - 刚开始
}

// 加载考试列表
const loadExamList = async () => {
  try {
    const response = await request.get(`/exam/class/${classId.value}`)
    if (response.code === 200) {
      examList.value = response.data || []
    }
  } catch (error) {
    console.error('加载考试列表失败:', error)
    ElMessage.error('加载考试列表失败')
  }
}

// 加载批改列表
const loadGradingList = async () => {
  try {
    const response = await request.get(`/grading/class/${classId.value}`)
    if (response.code === 200) {
      gradingList.value = response.data || []
    }
  } catch (error) {
    console.error('加载批改列表失败:', error)
    ElMessage.error('加载批改列表失败')
  }
}

// 菜单选择
const handleMenuSelect = (index) => {
  activeMenu.value = index
  switch (index) {
    case 'students':
      loadStudentList()
      break
    case 'questions':
      if (classInfo.courseId) {
        loadQuestionList()
      } else {
        ElMessage.error('课程信息未加载，无法获取题目列表！');
        console.error("Course ID not found for current class. Cannot load question list.");
      }
      break
    case 'exams':
      loadExamList()
      break
    case 'grading':
      loadGradingList()
      break
  }
}

// 删除学生
const handleDeleteStudent = (row) => {
  ElMessageBox.confirm(`确定要将学生 ${row.realName} 从班级中移除吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      console.log('Attempting to delete student...');
      console.log('Class ID:', classId.value, 'Type:', typeof classId.value);
      console.log('Student row:', row);
      console.log('Student ID (row.id):', row.id, 'Type:', typeof row.id);

      const response = await request.delete(`/class/${classId.value}/student/${row.id}`)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadStudentList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      console.error('删除学生失败:', error)
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 显示添加题目对话框
const showAddQuestionDialog = () => {
  Object.assign(questionForm, {
    type: 1,
    content: '',
    optionA: '',
    optionB: '',
    optionC: '',
    optionD: '',
    answer: '',
    score: 5,
    category: '',
    difficulty: 1, // 默认难度为简单
    courseId: classInfo.courseId, // 确保 courseId 正确设置
  })
  questionDialogVisible.value = true
}

// 确认添加题目
const confirmAddQuestion = async () => {
  if (!questionFormRef.value) return
  
  // 如果是单选题或多选题，先验证选项是否为空
  if ([1, 2].includes(questionForm.type)) {
    if (!questionForm.optionA || !questionForm.optionA.trim()) {
      ElMessage.warning('请输入选项A')
      return
    }
    if (!questionForm.optionB || !questionForm.optionB.trim()) {
      ElMessage.warning('请输入选项B')
      return
    }
    if (!questionForm.optionC || !questionForm.optionC.trim()) {
      ElMessage.warning('请输入选项C')
      return
    }
    if (!questionForm.optionD || !questionForm.optionD.trim()) {
      ElMessage.warning('请输入选项D')
      return
    }
  }
  
  await questionFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        const data = {
          ...questionForm,
          courseId: classInfo.courseId // 修改为 courseId
        }
        
        // 如果是选择题，组装选项
        if ([1, 2].includes(questionForm.type)) {
          data.options = JSON.stringify({
            A: questionForm.optionA,
            B: questionForm.optionB,
            C: questionForm.optionC,
            D: questionForm.optionD
          })
        }
        
        const response = await request.post('/question', data)
        if (response.code === 200) {
          ElMessage.success('添加成功')
          questionDialogVisible.value = false
          loadQuestionList()
        } else {
          ElMessage.error(response.message || '添加失败')
        }
      } catch (error) {
        console.error('添加题目失败:', error)
        ElMessage.error('添加失败')
      }
    }
  })
}

// 查看题目
const handleViewQuestion = (row) => {
  currentQuestion.value = row
  questionDetailVisible.value = true
}

// 删除题目
const handleDeleteQuestion = (row) => {
  ElMessageBox.confirm('确定要删除该题目吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const response = await request.delete(`/question/${row.id}`)
      if (response.code === 200) {
        ElMessage.success('删除成功')
        loadQuestionList()
      } else {
        ElMessage.error(response.message || '删除失败')
      }
    } catch (error) {
      console.error('删除题目失败:', error)
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

// 显示创建考试对话框
const showCreateExamDialog = () => {
  // 跳转到创建考试页面，并传递班级ID、班级名称和课程ID
  router.push({
    name: 'TeacherExamCreate',
    params: { classId: classId.value },
    query: {
      className: classInfo.name,
      courseId: classInfo.courseId
    }
  });
}

// 查看试卷
const handleViewPaper = (row) => {
  router.push(`/teacher/exam/${row.id}/paper`)
}

// 查看成绩
const handleViewGrades = (row) => {
  router.push(`/teacher/exam/${row.id}/grades`)
}

// 去批改
const handleGrading = (row) => {
  router.push({
    name: 'TeacherGrading',
    params: {
      examId: row.examId || row.id,
      classId: classId.value
    }
  })
}

// 获取题型标签
const getQuestionTypeTag = (type) => {
  const tagMap = {
    1: '',
    2: 'success',
    3: 'info',
    4: 'warning',
    5: 'danger'
  }
  return tagMap[type] || ''
}

// 获取题型文本
const getQuestionTypeText = (type) => {
  const textMap = {
    1: '单选题',
    2: '多选题',
    3: '判断题',
    4: '填空题',
    5: '简答题'
  }
  return textMap[type] || '未知'
}

// 获取考试状态标签
const getExamStatusTag = (exam) => {
  const now = new Date()
  const startTime = new Date(exam.startTime)
  const endTime = new Date(exam.endTime)
  
  if (now < startTime) return 'info'
  if (now > endTime) return ''
  return 'success'
}

// 获取考试状态文本
const getExamStatusText = (exam) => {
  const now = new Date()
  const startTime = new Date(exam.startTime)
  const endTime = new Date(exam.endTime)
  
  if (now < startTime) return '未开始'
  if (now > endTime) return '已结束'
  return '进行中'
}

// 判断考试是否已结束
const isExamEnded = (exam) => {
  const now = new Date()
  const endTime = new Date(exam.endTime)
  return now > endTime
}

// 格式化时间
const formatTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${year}-${month}-${day} ${hours}:${minutes}`
}

// 处理用户菜单命令
const handleUserCommand = (command) => {
  switch (command) {
    case 'profile':
      Object.assign(userForm, currentUserInfo)
      profileDialogVisible.value = true
      break
    case 'logout':
      handleLogout()
      break
  }
}

// 保存个人信息
const saveProfile = async () => {
  if (!currentUserInfo || !currentUserInfo.userId) {
    ElMessage.warning('用户信息未找到，请重新登录');
    router.push('/login');
    return;
  }
  try {
    // 假设后端有一个 /user/update 接口来更新用户信息
    const updateData = {
      id: currentUserInfo.userId,
      realName: userForm.realName,
      teacherNo: userForm.teacherNo,
      email: userForm.email,
      phone: userForm.phone,
      department: userForm.department,
      title: userForm.title,
      // password: userForm.password // 密码字段需要额外处理，这里暂时不包含
    };
    // 如果密码字段有值，则添加到更新数据中
    if (userForm.password) {
      updateData.password = userForm.password;
    }
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
  profileDialogVisible.value = false
}

// 退出登录
const handleLogout = () => {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    localStorage.clear()
    ElMessage.success('已退出登录')
    router.push('/login')
  }).catch(() => {})
}

// 返回主界面
const goBack = () => {
  router.push('/teacher/home')
}

// Excel批量导入处理
const handleExcelFileChange = async (file) => {
  const rawFile = file.raw
  if (!rawFile) return
  
  const isExcel = rawFile.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' || 
                  rawFile.type === 'application/vnd.ms-excel' ||
                  rawFile.name.endsWith('.xlsx') || rawFile.name.endsWith('.xls')
  if (!isExcel) {
    ElMessage.error('请上传 Excel 文件（.xlsx 或 .xls）')
    return
  }
  
  try {
    const data = await readExcelFile(rawFile)
    if (data.length === 0) {
      ElMessage.warning('Excel 文件中没有数据')
      return
    }
    await batchAddQuestions(data)
  } catch (error) {
    console.error('解析 Excel 文件失败:', error)
    ElMessage.error('解析 Excel 文件失败，请检查文件格式')
  }
}

// 读取Excel文件
const readExcelFile = (file) => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = (e) => {
      try {
        const data = e.target.result
        const workbook = XLSX.read(data, { type: 'array' })
        const sheetName = workbook.SheetNames[0]
        const worksheet = workbook.Sheets[sheetName]
        const jsonData = XLSX.utils.sheet_to_json(worksheet)
        
        const typeMap = { '单选题': 1, '多选题': 2, '判断题': 3, '填空题': 4, '简答题': 5 }
        const difficultyMap = { '简单': 1, '中等': 2, '困难': 3 }
        
        const questions = jsonData.map(row => {
          const questionType = typeMap[row['题型']] || 1
          let answer = row['答案'] || ''
          
          // 判断题答案转换为 T/F 格式
          if (questionType === 3) {
            const answerLower = answer.toString().toLowerCase()
            if (answerLower === '正确' || answerLower === '对' || answerLower === 'true' || answerLower === 't' || answerLower === '是') {
              answer = 'T'
            } else {
              answer = 'F'
            }
          }
          
          const question = {
            type: questionType,
            content: row['题干'] || '',
            answer: answer,
            score: parseInt(row['分值']) || 5,
            category: row['知识点'] || '',
            difficulty: difficultyMap[row['难度']] || 1,
            courseId: classInfo.courseId
          }
          if ([1, 2].includes(question.type)) {
            question.options = JSON.stringify({
              A: row['选项A'] || '', B: row['选项B'] || '',
              C: row['选项C'] || '', D: row['选项D'] || ''
            })
          }
          return question
        })
        resolve(questions)
      } catch (error) { reject(error) }
    }
    reader.onerror = reject
    reader.readAsArrayBuffer(file)
  })
}

// 批量添加题目
const batchAddQuestions = async (questions) => {
  if (!classInfo.courseId) {
    ElMessage.error('课程信息未加载，无法添加题目')
    return
  }
  let successCount = 0, failCount = 0
  ElMessage.info(`正在导入 ${questions.length} 道题目...`)
  
  for (const question of questions) {
    try {
      const response = await request.post('/question', question)
      if (response.code === 200) successCount++
      else failCount++
    } catch { failCount++ }
  }
  
  if (successCount > 0) {
    ElMessage.success(`成功导入 ${successCount} 道题目${failCount > 0 ? `，${failCount} 道失败` : ''}`)
    loadQuestionList()
  } else {
    ElMessage.error('导入失败，请检查数据格式')
  }
  if (excelUploadRef.value) excelUploadRef.value.clearFiles()
}

// 下载Excel模板
const downloadExcelTemplate = () => {
  const templateData = [
    { '题型': '单选题', '题干': '示例：以下哪个是正确的？', '选项A': '选项A内容', '选项B': '选项B内容', '选项C': '选项C内容', '选项D': '选项D内容', '答案': 'A', '分值': 5, '知识点': '示例知识点', '难度': '简单' },
    { '题型': '多选题', '题干': '示例：以下哪些是正确的？', '选项A': '选项A', '选项B': '选项B', '选项C': '选项C', '选项D': '选项D', '答案': 'A,B,C', '分值': 10, '知识点': '示例知识点', '难度': '中等' },
    { '题型': '判断题', '题干': '示例：这是判断题？', '选项A': '', '选项B': '', '选项C': '', '选项D': '', '答案': '正确（或填：对/T/是）', '分值': 3, '知识点': '示例知识点', '难度': '简单' },
    { '题型': '填空题', '题干': '示例：请填写____', '选项A': '', '选项B': '', '选项C': '', '选项D': '', '答案': '正确答案', '分值': 5, '知识点': '示例知识点', '难度': '中等' },
    { '题型': '简答题', '题干': '示例：请简述观点', '选项A': '', '选项B': '', '选项C': '', '选项D': '', '答案': '参考答案', '分值': 20, '知识点': '示例知识点', '难度': '困难' }
  ]
  const worksheet = XLSX.utils.json_to_sheet(templateData)
  const workbook = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(workbook, worksheet, '题目模板')
  worksheet['!cols'] = [{ wch: 10 }, { wch: 40 }, { wch: 15 }, { wch: 15 }, { wch: 15 }, { wch: 15 }, { wch: 15 }, { wch: 8 }, { wch: 15 }, { wch: 8 }]
  XLSX.writeFile(workbook, '题目导入模板.xlsx')
  ElMessage.success('模板下载成功')
}

// 页面加载
onMounted(async () => {
  await loadClassInfo();
  
  // 检查是否需要刷新批改列表（从批改界面返回）
  if (sessionStorage.getItem('refreshGradingList') === 'true') {
    sessionStorage.removeItem('refreshGradingList');
    activeMenu.value = 'grading';
    loadGradingList();
    return;
  }
  
  const tab = route.query.tab;
  if (tab === 'students' || tab === 'questions' || tab === 'exams' || tab === 'grading') {
    activeMenu.value = tab;
    if (tab === 'students') {
      loadStudentList();
    } else if (tab === 'exams') {
      loadExamList();
    } else if (tab === 'questions') {
      if (classInfo.courseId) {
        loadQuestionList();
      }
    } else if (tab === 'grading') {
      loadGradingList();
    }
  } else {
    loadStudentList();
  }
})

// 监听 activeMenu 变化，加载对应数据
watch(activeMenu, async (newMenu) => {
  if (newMenu === 'questions') {
    // 确保 classInfo.courseId 已加载
    if (classInfo.courseId) {
      loadQuestionList();
    } else {
      // 如果 classInfo.courseId 尚未加载，则等待其加载完成后再尝试加载题目
      const unwatchCourseId = watch(() => classInfo.courseId, (newCourseId) => {
        if (newCourseId) {
          loadQuestionList();
          unwatchCourseId(); // 一旦加载成功，就取消监听
        }
      });
    }
  } else if (newMenu === 'grading') {
    loadGradingList();
  }
});
watch(classId, (newClassId) => {
  if (newClassId) {
    selectedQuestionType.value = ''; // 班级ID变化时重置筛选条件
  }
});
</script>

<style scoped>
.teacher-class-container {
  min-height: 100vh;
  background: linear-gradient(135deg, var(--bg-grad-1) 0%, var(--bg-grad-2) 50%, var(--bg-grad-3) 100%);
  position: relative;
  overflow-x: hidden;
}

/* 背景装饰 */
.teacher-class-container::before {
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

.teacher-class-container::after {
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

/* 顶部操作区 */
.top-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 400;
  height: 64px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9ff 100%);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 40px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.top-header::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, var(--primary) 0%, var(--primary-2) 50%, var(--primary) 100%);
  opacity: 0.6;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.system-title {
  font-size: 26px;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 100%);
  background-clip: text;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  margin: 0;
  letter-spacing: 0.5px;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-btn {
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 100%) !important;
  border: none !important;
  color: #fff !important;
  font-weight: 600;
  border-radius: 10px;
  padding: 10px 20px;
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.35);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.back-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.6s;
}

.back-btn:hover::before {
  left: 100%;
}

.back-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.45);
}

.back-btn:active {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

/* 用户头像区域 */
.user-avatar {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 25px;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
}

.user-avatar:hover {
  background: rgba(255, 255, 255, 1);
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
  transform: translateY(-1px);
}

.avatar-img {
  transition: transform 0.3s;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.25);
  border: 2px solid #fff;
}

.user-avatar:hover .avatar-img {
  transform: scale(1.05);
}

.user-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
  letter-spacing: 0.3px;
  transition: all 0.3s;
}

.user-avatar:hover .user-name {
  color: var(--primary);
  transform: translateY(-1px);
}

/* 主体区域 */
.main-container {
  display: flex;
  padding-top: 70px;
  min-height: calc(100vh - 70px);
  position: relative;
  z-index: 1;
}

/* 左侧导航栏 */
.sidebar {
  width: 240px;
  background: linear-gradient(180deg, #4a3f6b 0%, #5d4a7a 50%, #6b5b8e 100%);
  position: fixed;
  left: 0;
  top: 70px;
  bottom: 0;
  overflow-y: auto;
  box-shadow: 4px 0 20px rgba(102, 126, 234, 0.25);
  transition: all 0.3s ease;
}

.sidebar::-webkit-scrollbar {
  width: 6px;
}

.sidebar::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.08);
}

.sidebar::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.25);
  border-radius: 3px;
}

.sidebar::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.4);
}

.sidebar-header {
  padding: 28px 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.15);
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.25) 0%, rgba(118, 75, 162, 0.2) 100%);
  position: relative;
  overflow: hidden;
}

.sidebar-header::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -20%;
  width: 150px;
  height: 150px;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
  border-radius: 50%;
}

.sidebar-header h3 {
  color: #fff;
  font-size: 17px;
  font-weight: 600;
  margin: 0 0 10px 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  position: relative;
  z-index: 1;
  text-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
  line-height: 1.4;
}

.sidebar-header p {
  color: rgba(255, 255, 255, 0.85);
  font-size: 13px;
  margin: 0;
  position: relative;
  z-index: 1;
  font-weight: 500;
}

.sidebar-menu {
  border-right: none;
  padding: 12px 8px;
}

.sidebar-menu .el-menu-item {
  height: 52px;
  line-height: 52px;
  margin: 4px 0;
  border-radius: 10px;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  position: relative;
  overflow: hidden;
}

.sidebar-menu .el-menu-item::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%) scaleY(0);
  width: 4px;
  height: 60%;
  background: linear-gradient(180deg, #a8d5ff 0%, #c8b6ff 100%);
  border-radius: 0 2px 2px 0;
  transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  box-shadow: 0 0 8px rgba(168, 213, 255, 0.5);
}

.sidebar-menu .el-menu-item:hover {
  background: linear-gradient(135deg, rgba(168, 213, 255, 0.2) 0%, rgba(200, 182, 255, 0.15) 100%);
  transform: translateX(4px);
  color: #fff !important;
}

.sidebar-menu .el-menu-item:hover::before {
  transform: translateY(-50%) scaleY(1);
}

.sidebar-menu .el-menu-item.is-active {
  background: linear-gradient(135deg, rgba(168, 213, 255, 0.3) 0%, rgba(200, 182, 255, 0.25) 100%);
  color: #fff !important;
  box-shadow: 0 4px 12px rgba(168, 213, 255, 0.3);
}

.sidebar-menu .el-menu-item.is-active::before {
  transform: translateY(-50%) scaleY(1);
}

.sidebar-menu .el-menu-item .el-icon {
  font-size: 18px;
  margin-right: 12px;
  transition: all 0.3s ease;
}

.sidebar-menu .el-menu-item:hover .el-icon,
.sidebar-menu .el-menu-item.is-active .el-icon {
  transform: scale(1.15) rotate(-5deg);
}

.sidebar-menu .el-menu-item span {
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.3px;
}

/* 右侧内容区 */
.content-area {
  flex: 1;
  margin-left: 240px;
  padding: 32px;
  min-height: calc(100vh - 70px);
  animation: fadeIn 0.5s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.content-panel {
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 16px;
  padding: 32px;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.08);
  border: 1px solid rgba(102, 126, 234, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.content-panel::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--primary) 0%, var(--primary-2) 100%);
  opacity: 0.8;
}

.content-panel:hover {
  box-shadow: 0 12px 48px rgba(102, 126, 234, 0.12);
  transform: translateY(-2px);
}

.panel-header {
  display: flex; /* 使用 Flexbox 布局 */
  justify-content: space-between; /* 子元素两端对齐 */
  align-items: center; /* 垂直居中对齐 */
  margin-bottom: 32px;
  padding-bottom: 20px;
  border-bottom: 2px solid rgba(102, 126, 234, 0.1);
  background: linear-gradient(to right, #f7f9fc 0%, transparent 100%);
  position: relative;
}

.panel-header::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 60px;
  height: 2px;
  background: linear-gradient(90deg, var(--primary) 0%, var(--primary-2) 100%);
  border-radius: 1px;
}

.panel-header h2 {
  font-size: 22px;
  font-weight: 600;
  color: #1D2129;
  margin: 0;
  position: relative;
  padding-left: 16px;
  line-height: 1.4;
}

.panel-header h2::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 70%;
  background: linear-gradient(180deg, var(--primary) 0%, var(--primary-2) 100%);
  border-radius: 2px;
}

/* 题库筛选区域样式 */
.question-filters {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 20px;
  margin-bottom: 20px;
  background: linear-gradient(135deg, #f8f9ff 0%, #fff5f8 100%);
  border-radius: 12px;
  border: 1px solid rgba(102, 126, 234, 0.1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.question-filters .search-input {
  width: 400px;
  flex-shrink: 0;
}

.question-filters .filter-select {
  width: 140px;
  flex-shrink: 0;
}

.question-filters .btn-group {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-left: auto;
}

.question-filters .add-question-btn {
  white-space: nowrap;
  padding: 8px 16px;
  font-size: 13px;
  font-weight: 500;
  border-radius: 6px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  border: none !important;
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
  transition: all 0.3s ease;
}

.question-filters .add-question-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.question-filters .upload-excel-btn {
  white-space: nowrap;
  padding: 8px 16px;
  font-size: 13px;
  font-weight: 500;
  border-radius: 6px;
  background: linear-gradient(135deg, #52c41a 0%, #73d13d 100%) !important;
  border: none !important;
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(82, 196, 26, 0.3);
  transition: all 0.3s ease;
}

.question-filters .upload-excel-btn:hover {
  background: linear-gradient(135deg, #389e0d 0%, #52c41a 100%) !important;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(82, 196, 26, 0.4);
}

.question-filters .download-template-btn {
  white-space: nowrap;
  padding: 8px 16px;
  font-size: 13px;
  font-weight: 500;
  border-radius: 6px;
  background: linear-gradient(135deg, #909399 0%, #a6a9ad 100%) !important;
  border: none !important;
  color: #fff !important;
  box-shadow: 0 2px 8px rgba(144, 147, 153, 0.3);
  transition: all 0.3s ease;
}

.question-filters .download-template-btn:hover {
  background: linear-gradient(135deg, #606266 0%, #909399 100%) !important;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(144, 147, 153, 0.4);
}

.question-filters .download-template-btn:hover {
  background: linear-gradient(135deg, #606266 0%, #909399 100%) !important;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(144, 147, 153, 0.45);
}

.question-filters :deep(.el-input__wrapper) {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border-radius: 8px;
  transition: all 0.3s ease;
}

.question-filters :deep(.el-input__wrapper:hover) {
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
}

.question-filters :deep(.el-select .el-input__wrapper) {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

/* 按钮统一样式优化 */
:deep(.el-button) {
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  letter-spacing: 0.3px;
}

:deep(.el-button--primary) {
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

:deep(.el-button--primary:hover) {
  background: linear-gradient(135deg, #5568d3 0%, #6a3f8f 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

:deep(.el-button--primary:active) {
  transform: translateY(0);
}

:deep(.el-button--danger) {
  background: linear-gradient(135deg, #F53F3F 0%, #FF6B6B 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(245, 63, 63, 0.25);
}

:deep(.el-button--danger:hover) {
  background: linear-gradient(135deg, #D93026 0%, #F53F3F 100%);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(245, 63, 63, 0.35);
}

:deep(.el-button--danger:active) {
  transform: translateY(0);
}

/* 表格样式优化 */
:deep(.el-table) {
  font-size: 14px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

:deep(.el-table th) {
  background: linear-gradient(135deg, #f7f9fc 0%, #f0f4f8 100%);
  color: #1D2129;
  font-weight: 600;
  font-size: 14px;
  padding: 16px 0;
  border-bottom: 2px solid rgba(102, 126, 234, 0.1);
}

:deep(.el-table th .cell) {
  padding: 0 16px;
  display: flex;
  align-items: center;
}

:deep(.el-table td) {
  color: #4E5969;
  padding: 14px 0;
  transition: all 0.3s ease;
}

:deep(.el-table td .cell) {
  padding: 0 16px;
}

:deep(.el-table__row) {
  transition: all 0.3s ease;
}

:deep(.el-table__row:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.04) 0%, rgba(118, 75, 162, 0.02) 100%) !important;
  transform: scale(1.001);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.08);
}

:deep(.el-table__row:hover td) {
  color: #1D2129;
}

:deep(.el-table--striped .el-table__body tr.el-table__row--striped) {
  background: rgba(102, 126, 234, 0.02);
}

:deep(.el-table .el-button--small) {
  padding: 6px 12px;
  font-size: 13px;
}

/* Tag 标签优化 */
:deep(.el-tag) {
  border-radius: 6px;
  padding: 4px 10px;
  font-weight: 500;
  font-size: 12px;
  border: none;
  letter-spacing: 0.3px;
}

:deep(.el-tag--success) {
  background: linear-gradient(135deg, rgba(0, 180, 42, 0.15) 0%, rgba(0, 180, 42, 0.08) 100%);
  color: #00B42A;
}

:deep(.el-tag--warning) {
  background: linear-gradient(135deg, rgba(255, 125, 0, 0.15) 0%, rgba(255, 125, 0, 0.08) 100%);
  color: #FF7D00;
}

:deep(.el-tag--danger) {
  background: linear-gradient(135deg, rgba(245, 63, 63, 0.15) 0%, rgba(245, 63, 63, 0.08) 100%);
  color: #F53F3F;
}

:deep(.el-tag--info) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.15) 0%, rgba(102, 126, 234, 0.08) 100%);
  color: var(--primary);
}

/* Empty 空状态优化 */
:deep(.el-empty) {
  padding: 60px 0;
}

:deep(.el-empty__image) {
  width: 160px;
  height: 160px;
}

:deep(.el-empty__description) {
  margin-top: 20px;
}

:deep(.el-empty__description p) {
  font-size: 15px;
  color: #86909C;
  font-weight: 500;
  line-height: 1.6;
}

/* 对话框优化 */
:deep(.el-dialog) {
  border-radius: 16px;
  overflow: hidden;
}

:deep(.el-dialog__header) {
  background: linear-gradient(135deg, #f7f9fc 0%, #f0f4f8 100%);
  padding: 24px 28px;
  border-bottom: 1px solid rgba(102, 126, 234, 0.1);
}

:deep(.el-dialog__title) {
  font-size: 18px;
  font-weight: 600;
  color: #1D2129;
}

:deep(.el-dialog__body) {
  padding: 28px;
}

:deep(.el-dialog__footer) {
  padding: 20px 28px;
  background: #fafbfc;
  border-top: 1px solid rgba(102, 126, 234, 0.06);
}

:deep(.el-form-item__label) {
  font-weight: 500;
  color: #4E5969;
}

:deep(.el-input__wrapper) {
  border-radius: 8px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
}

:deep(.el-input__wrapper:hover) {
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
}

:deep(.el-input__wrapper.is-focus) {
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
  border-color: var(--primary);
}

:deep(.el-textarea__inner) {
  border-radius: 8px;
  transition: all 0.3s ease;
}

:deep(.el-textarea__inner:hover) {
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.1);
}

:deep(.el-textarea__inner:focus) {
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
  border-color: var(--primary);
}

/* 下拉菜单优化 */
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
  color: var(--primary);
}

/* 分页器优化 */
:deep(.el-pagination) {
  margin-top: 24px;
  justify-content: center;
}

:deep(.el-pagination .btn-prev),
:deep(.el-pagination .btn-next),
:deep(.el-pagination .el-pager li) {
  border-radius: 8px;
  transition: all 0.3s ease;
  font-weight: 500;
}

:deep(.el-pagination .el-pager li:hover),
:deep(.el-pagination .btn-prev:hover),
:deep(.el-pagination .btn-next:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.08) 0%, rgba(118, 75, 162, 0.05) 100%);
  color: var(--primary);
  transform: translateY(-2px);
}

:deep(.el-pagination .el-pager li.is-active) {
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-2) 100%);
  color: #fff;
}

/* 描述列表优化 */
:deep(.el-descriptions) {
  border-radius: 12px;
  overflow: hidden;
}

:deep(.el-descriptions__label) {
  font-weight: 600;
  color: #4E5969;
  background: linear-gradient(135deg, #f7f9fc 0%, #f0f4f8 100%);
}

:deep(.el-descriptions__content) {
  color: #1D2129;
}

/* 响应式优化 */
@media (max-width: 1024px) {
  .content-area {
    padding: 24px;
  }

  .content-panel {
    padding: 24px;
  }
}

.filter-and-add-controls {
  display: flex;
  flex-direction: row; /* 确保横向排列 */
  flex-wrap: wrap; /* 允许换行 */
  justify-content: flex-end; /* 靠右对齐 */
  align-items: center; /* 垂直居中 */
  gap: 10px; /* 筛选框和按钮之间的间距 */
  width: auto; /* 自适应宽度 */
}

.question-type-select {
  width: 150px; /* 筛选框的默认宽度 */
  min-width: 120px; /* 最小宽度 */
  flex-shrink: 1; /* 允许缩小 */
  flex-grow: 1; /* 允许增长 */
}

.add-question-btn {
  width: auto; /* 确保按钮在桌面端有合适宽度 */
  min-width: 90px; /* 最小宽度 */
  flex-shrink: 1; /* 允许缩小 */
  flex-grow: 1; /* 允许增长 */
}

@media (max-width: 768px) {
  .top-header {
    padding: 0 20px;
    height: 60px;
  }

  .system-title {
    font-size: 20px;
  }

  .sidebar {
    width: 200px;
    top: 60px;
  }

  .main-container {
    padding-top: 60px;
  }

  .content-area {
    margin-left: 200px;
    padding: 20px;
  }

  .content-panel {
    padding: 20px;
    border-radius: 12px;
  }

  .panel-header {
    /* 移除所有覆盖，让全局样式生效 */
  }

  .filter-and-add-controls {
    /* 移除所有覆盖，让全局样式生效 */
  }

  .question-type-select {
    /* 移除所有覆盖，让全局样式生效 */
  }

  .add-question-btn {
    /* 移除所有覆盖，让全局样式生效 */
  }

  :deep(.el-table) {
    font-size: 13px;
  }

  :deep(.el-table th),
  :deep(.el-table td) {
    padding: 12px 0;
  }

  :deep(.el-button--small) {
    padding: 5px 10px;
    font-size: 12px;
  }
}

@media (max-width: 480px) {
  /* 在极小屏幕上，让筛选框和按钮弹性换行 */
  .filter-and-add-controls {
    /* 移除所有覆盖，让全局样式生效 */
  }

  .question-type-select,
  .add-question-btn {
    /* 移除所有覆盖，让全局样式生效，让其根据 flex-wrap 行为自动调整 */
  }
}

/* 加载动画 */
@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

.loading {
  animation: pulse 1.5s ease-in-out infinite;
}

/* 考试管理 - 操作按钮美化 */
.action-buttons { gap: 8px; }
.action-btn {
  border: none;
  border-radius: 18px;
  padding: 6px 12px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  box-shadow: 0 4px 12px rgba(0,0,0,.06);
}
.action-btn .el-icon { font-size: 14px; }
.btn-view { background: linear-gradient(135deg, #e3f2fd, #e8eaf6); color: #3f51b5; }
.btn-view:hover { filter: brightness(0.98); transform: translateY(-1px); }
.btn-grades { background: linear-gradient(135deg, #e8f5e9, #f1f8e9); color: #2e7d32; }
.btn-grades:hover { filter: brightness(0.98); transform: translateY(-1px); }
.btn-grades-disabled { 
  background: linear-gradient(135deg, #f5f5f5, #eeeeee); 
  color: #9e9e9e; 
  cursor: not-allowed;
}
.btn-grades-disabled:hover { 
  transform: none; 
  filter: none;
}
</style>
