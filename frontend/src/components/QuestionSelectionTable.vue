<template>
  <div class="question-table-wrapper">
    <el-table
      ref="tableRef"
      :data="paginatedQuestions"
      stripe
      style="width: 100%"
      @selection-change="handleSelectionChange"
      row-key="id"
      :empty-text="' '"
    >
      <el-table-column type="selection" width="65" :reserve-selection="true" align="center" />
      <el-table-column type="index" label="序号" width="70" align="center" :index="indexMethod" />
      <el-table-column prop="type" label="题型" width="110" align="center">
        <template #default="scope">
          <el-tag :type="getQuestionTypeTag(scope.row.type).type" effect="plain" size="small">
            {{ getQuestionTypeTag(scope.row.type).label }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="content" label="题干" min-width="280" show-overflow-tooltip>
        <template #default="scope">
          <div class="question-content">
            <el-icon class="content-icon"><Document /></el-icon>
            <span>{{ scope.row.content }}</span>
            <el-icon v-if="scope.row.image" class="image-icon" title="包含图片">
              <Picture />
            </el-icon>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="score" label="分值" width="100" align="center">
        <template #default="scope">
          <el-tag type="success" effect="light" round>
            {{ scope.row.score }} 分
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="category" label="知识点" width="150" align="center" show-overflow-tooltip>
        <template #default="scope">
          <el-tag type="info" effect="plain" size="small" class="category-tag">
            {{ scope.row.category || '未分类' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="difficulty" label="难度" width="100" align="center">
        <template #default="scope">
          <div class="difficulty-stars">
            <span v-if="scope.row.difficulty" :class="['stars', `difficulty-${scope.row.difficulty}`]">
              {{ '⭐'.repeat(scope.row.difficulty) }}
            </span>
            <span v-else class="no-difficulty">-</span>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="120" fixed="right" align="center">
        <template #default="scope">
          <el-button link type="primary" size="small" @click="handleViewQuestion(scope.row)">
            <el-icon><View /></el-icon>
            查看
          </el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <!-- 分页 -->
    <div class="pagination-wrapper" v-if="questions && questions.length > 0">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 30, 50]"
        :small="false"
        :background="true"
        layout="total, sizes, prev, pager, next, jumper"
        :total="questions.length"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>
    
    <!-- 自定义空数据显示 -->
    <div v-if="!questions || questions.length === 0" class="empty-state">
      <el-icon class="empty-icon"><DocumentDelete /></el-icon>
      <p class="empty-text">暂无题目数据</p>
      <p class="empty-hint">请先在题库中添加题目</p>
    </div>
  </div>

  <!-- 题目详情对话框 -->
  <el-dialog
    v-model="questionDetailVisible"
    title="题目详情"
    width="900px"
    :close-on-click-modal="false"
  >
    <el-descriptions :column="1" border>
      <el-descriptions-item label="题型">
        {{ getQuestionTypeText(currentQuestion.type) }}
      </el-descriptions-item>
      <el-descriptions-item label="题干">
        {{ currentQuestion.content }}
      </el-descriptions-item>
      <el-descriptions-item label="题目图片" v-if="currentQuestion.image">
        <el-image 
          :src="getImageUrl(currentQuestion.image)" 
          :preview-src-list="[getImageUrl(currentQuestion.image)]"
          fit="contain"
          style="max-width: 500px; max-height: 300px; cursor: pointer;"
          :preview-teleported="true"
        />
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
        <span v-if="currentQuestion.difficulty" class="detail-stars">
          {{ '⭐'.repeat(currentQuestion.difficulty) }}
          <span class="difficulty-text">
            ({{ getDifficultyTag(currentQuestion.difficulty).label }})
          </span>
        </span>
        <span v-else>未设置</span>
      </el-descriptions-item>
    </el-descriptions>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, watch, computed, onMounted, nextTick } from 'vue';
import { ElMessage } from 'element-plus';
import { Document, View, DocumentDelete, Picture } from '@element-plus/icons-vue';
import { getImageUrl } from '@/utils/file';

const props = defineProps({
  questions: { type: Array, default: () => [] },
  questionType: { type: String, required: true }, // 题目类型，用于标识
  selectedQuestions: { type: Array, default: () => [] }, // 外部传入已选题目列表
});

const emit = defineEmits(['question-selected']);

const questionDetailVisible = ref(false);
const currentQuestion = reactive({});
const selectedRows = reactive([]); // Element Plus table 的选中行
const tableRef = ref(null); // 表格引用

// 分页相关
const currentPage = ref(1);
const pageSize = ref(10);

// 计算分页后的数据
const paginatedQuestions = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return props.questions.slice(start, end);
});

// 序号计算方法（根据当前页计算）
const indexMethod = (index) => {
  return (currentPage.value - 1) * pageSize.value + index + 1;
};

// 分页大小改变
const handleSizeChange = (val) => {
  pageSize.value = val;
  currentPage.value = 1;
};

// 当前页改变
const handleCurrentChange = (val) => {
  currentPage.value = val;
};

// 获取题目类型标签
const getQuestionTypeTag = (type) => {
  const typeMap = {
    1: { label: '单选题', type: 'primary' },
    2: { label: '多选题', type: 'success' },
    3: { label: '判断题', type: 'warning' },
    4: { label: '填空题', type: 'info' },
    5: { label: '简答题', type: 'danger' }
  };
  return typeMap[type] || { label: '未知', type: '' };
};

// 获取难度标签
const getDifficultyTag = (difficulty) => {
  const difficultyMap = {
    1: { label: '简单', type: 'success' },
    2: { label: '中等', type: 'warning' },
    3: { label: '困难', type: 'danger' }
  };
  return difficultyMap[difficulty] || { label: '未知', type: 'info' };
};

// 恢复表格选中状态
const restoreSelection = () => {
  if (!tableRef.value || !props.selectedQuestions) return;
  
  // 根据selectedQuestions恢复选中状态
  if (props.selectedQuestions.length > 0) {
    const selectedIds = new Set(props.selectedQuestions.map(q => q.id));
    
    // 遍历当前页的数据
    paginatedQuestions.value.forEach(question => {
      const shouldBeSelected = selectedIds.has(question.id);
      // 只在需要时改变选中状态，避免不必要的操作
      tableRef.value.toggleRowSelection(question, shouldBeSelected);
    });
  }
};

// 处理 Element Plus table 的选择变化
const handleSelectionChange = (selection) => {
  const oldSelectedIds = new Set(selectedRows.map(q => q.id));
  const newSelectedIds = new Set(selection.map(q => q.id));

  // 找出新增的选中项
  selection.forEach(question => {
    if (!oldSelectedIds.has(question.id)) {
      emit('question-selected', { question, isSelected: true });
    }
  });

  // 找出被取消的选中项
  selectedRows.forEach(question => {
    if (!newSelectedIds.has(question.id)) {
      emit('question-selected', { question, isSelected: false });
    }
  });
  
  // 更新内部的 selectedRows 状态
  selectedRows.splice(0, selectedRows.length, ...selection);
};

// 查看题目详情
const handleViewQuestion = (row) => {
  Object.assign(currentQuestion, row);
  questionDetailVisible.value = true;
};

// 获取题目类型文本
const getQuestionTypeText = (type) => {
  switch (type) {
    case 1: return '单选题';
    case 2: return '多选题';
    case 3: return '判断题';
    case 4: return '填空题';
    case 5: return '简答题';
    default: return '未知';
  }
};

// 监听 questions 属性变化，重置页码并恢复选中状态
watch(() => props.questions, () => {
  // 当题目列表变化时，重置到第一页
  currentPage.value = 1;
  // 延迟恢复选中状态，确保表格已渲染
  nextTick(() => {
    restoreSelection();
  });
}, { deep: false });

// 组件挂载后恢复选中状态
onMounted(() => {
  nextTick(() => {
    restoreSelection();
  });
});

</script>

<style scoped>
.question-table-wrapper {
  position: relative;
  min-height: 500px;
}

/* 分页样式 */
.pagination-wrapper {
  margin-top: 20px;
  margin-bottom: 30px;
  display: flex;
  justify-content: center;
  padding: 15px 0;
}

.pagination-wrapper :deep(.el-pagination) {
  gap: 8px;
}

.pagination-wrapper :deep(.el-pagination.is-background .el-pager li:not(.is-disabled).is-active) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
}

.pagination-wrapper :deep(.el-pagination.is-background .btn-next),
.pagination-wrapper :deep(.el-pagination.is-background .btn-prev) {
  background: #fafbff;
  border: 2px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
}

.pagination-wrapper :deep(.el-pagination.is-background .btn-next:hover),
.pagination-wrapper :deep(.el-pagination.is-background .btn-prev:hover) {
  border-color: #667eea;
  color: #667eea;
}

.pagination-wrapper :deep(.el-pagination.is-background .el-pager li) {
  background: #fafbff;
  border: 2px solid rgba(102, 126, 234, 0.15);
  transition: all 0.3s ease;
}

.pagination-wrapper :deep(.el-pagination.is-background .el-pager li:hover) {
  border-color: #667eea;
  color: #667eea;
}

/* 知识点标签样式 */
.category-tag {
  max-width: 150px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: inline-block;
}

/* 空数据状态样式 */
.empty-state {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 40px;
  z-index: 10;
}

.empty-icon {
  font-size: 80px;
  color: #c0c4cc;
  margin-bottom: 16px;
  opacity: 0.6;
}

.empty-text {
  font-size: 16px;
  color: #909399;
  margin: 0 0 8px 0;
  font-weight: 500;
}

.empty-hint {
  font-size: 14px;
  color: #c0c4cc;
  margin: 0;
}

/* 题目内容样式 */
.question-content {
  display: flex;
  align-items: center;
  gap: 8px;
}

.content-icon {
  color: #667eea;
  font-size: 16px;
  flex-shrink: 0;
}

.image-icon {
  color: #409eff;
  font-size: 16px;
  margin-left: 6px;
  flex-shrink: 0;
}

/* Element Plus Table 样式优化 */
:deep(.el-table) {
  font-size: 14px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
  border: 1px solid rgba(102, 126, 234, 0.08);
}

:deep(.el-table__body-wrapper) {
  min-height: 350px;
  max-height: 450px;
  overflow-y: auto;
}

/* 滚动条样式优化 */
:deep(.el-table__body-wrapper)::-webkit-scrollbar {
  width: 8px;
}

:deep(.el-table__body-wrapper)::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

:deep(.el-table__body-wrapper)::-webkit-scrollbar-thumb {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 4px;
}

:deep(.el-table__body-wrapper)::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(135deg, #7a8ef0 0%, #8658b0 100%);
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
  cursor: pointer;
  position: relative;
}

:deep(.el-table__row:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.06) 0%, rgba(118, 75, 162, 0.04) 100%) !important;
  box-shadow: 0 2px 12px rgba(102, 126, 234, 0.12);
}

:deep(.el-table__row:hover td) {
  color: #1D2129;
}

/* 选中行样式优化 */
:deep(.el-table__row.selected) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.12) 0%, rgba(118, 75, 162, 0.08) 100%) !important;
  box-shadow: 0 2px 16px rgba(102, 126, 234, 0.2), inset 3px 0 0 0 #667eea;
}

:deep(.el-table__row.selected td) {
  color: #1D2129 !important;
  font-weight: 500;
}

:deep(.el-table__row.selected:hover) {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.15) 0%, rgba(118, 75, 162, 0.1) 100%) !important;
  box-shadow: 0 4px 20px rgba(102, 126, 234, 0.25), inset 3px 0 0 0 #667eea;
  transform: translateX(2px);
}

:deep(.el-table--striped .el-table__body tr.el-table__row--striped) {
  background: rgba(102, 126, 234, 0.025);
}

/* 选择框样式优化 */
:deep(.el-checkbox__inner) {
  width: 18px;
  height: 18px;
  border-radius: 5px;
  border: 2px solid #dcdfe6;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

:deep(.el-checkbox__inner::after) {
  width: 4px;
  height: 8px;
  left: 5px;
  top: 2px;
  transition: all 0.2s ease;
}

:deep(.el-checkbox__inner:hover) {
  border-color: #667eea;
  transform: scale(1.08);
  box-shadow: 0 0 8px rgba(102, 126, 234, 0.3);
}

:deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: #667eea;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
  animation: checkboxPulse 0.3s ease;
}

:deep(.el-checkbox__input.is-checked .el-checkbox__inner::after) {
  border-color: #fff;
  border-width: 2px;
  animation: checkMark 0.3s ease;
}

:deep(.el-checkbox__input.is-indeterminate .el-checkbox__inner) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: #667eea;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
}

@keyframes checkboxPulse {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.15);
  }
  100% {
    transform: scale(1);
  }
}

@keyframes checkMark {
  0% {
    opacity: 0;
    transform: scale(0) rotate(45deg);
  }
  50% {
    opacity: 1;
    transform: scale(1.2) rotate(45deg);
  }
  100% {
    opacity: 1;
    transform: scale(1) rotate(45deg);
  }
}

/* 按钮样式优化 */
:deep(.el-button--small) {
  padding: 6px 12px;
  font-size: 13px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

:deep(.el-button--small:hover) {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(102, 126, 234, 0.2);
}

/* Tag 样式优化 */
:deep(.el-tag) {
  border-radius: 8px;
  padding: 4px 12px;
  font-weight: 500;
}

/* Element Plus Dialog 样式覆盖 */
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

/* Element Plus Descriptions 样式优化 */
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

/* 难度星星样式 */
.difficulty-stars {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 2px;
}

.difficulty-stars .stars {
  font-size: 16px;
  line-height: 1;
  letter-spacing: 2px;
}

.difficulty-stars .difficulty-1 {
  color: #52c41a;
}

.difficulty-stars .difficulty-2 {
  color: #faad14;
}

.difficulty-stars .difficulty-3 {
  color: #f5222d;
}

.difficulty-stars .no-difficulty {
  color: #d9d9d9;
  font-size: 14px;
}

/* 详情页难度星星样式 */
.detail-stars {
  font-size: 18px;
  letter-spacing: 3px;
}

.detail-stars .difficulty-text {
  font-size: 14px;
  color: #8c8c8c;
  margin-left: 8px;
}
</style>
