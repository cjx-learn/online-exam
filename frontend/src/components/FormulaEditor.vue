<template>
  <div class="formula-editor">
    <div class="editor-toolbar">
      <div class="toolbar-left">
        <el-dropdown trigger="click" @command="insertFormula">
          <el-button size="small" type="primary" plain>
            <el-icon><Plus /></el-icon> 插入公式
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="fraction">分数 a/b</el-dropdown-item>
              <el-dropdown-item command="sqrt">根号 √</el-dropdown-item>
              <el-dropdown-item command="power">幂次 x²</el-dropdown-item>
              <el-dropdown-item command="sum">求和 Σ</el-dropdown-item>
              <el-dropdown-item command="integral">积分 ∫</el-dropdown-item>
              <el-dropdown-item command="limit">极限 lim</el-dropdown-item>
              <el-dropdown-item divided command="greek">希腊字母</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
        <el-tooltip content="行内公式: $x^2$  独立公式: $$\frac{a}{b}$$" placement="top">
          <el-icon class="help-icon"><QuestionFilled /></el-icon>
        </el-tooltip>
      </div>
      <span class="char-count">{{ localValue.length }} 字</span>
    </div>

    <div class="editor-main">
      <div class="input-panel">
        <div class="panel-header">输入区域</div>
        <div class="panel-body">
          <el-input
            ref="textareaRef"
            v-model="localValue"
            type="textarea"
            :rows="rows"
            placeholder="请输入答案..."
            resize="none"
            @input="handleInput"
          />
        </div>
      </div>
      <div class="divider"></div>
      <div class="preview-panel">
        <div class="panel-header">预览效果</div>
        <div class="panel-body preview-body" ref="previewRef"></div>
      </div>
    </div>

    <el-dialog v-model="greekVisible" title="希腊字母" width="400px">
      <div class="greek-grid">
        <span v-for="g in greekLetters" :key="g.cmd" class="greek-item" @click="insertGreek(g.cmd)">
          <span class="greek-sym">{{ g.sym }}</span>
          <span class="greek-name">{{ g.name }}</span>
        </span>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, nextTick, computed } from 'vue'
import { QuestionFilled, Plus } from '@element-plus/icons-vue'

const props = defineProps({
  modelValue: { type: String, default: '' },
  rows: { type: Number, default: 6 }
})

// 根据行数计算编辑器高度
const editorHeight = computed(() => {
  const lineHeight = 24 // 每行约24px
  const padding = 20 // 上下padding
  const headerHeight = 30 // panel-header高度
  return `${props.rows * lineHeight + padding + headerHeight}px`
})

const emit = defineEmits(['update:modelValue'])

const localValue = ref(props.modelValue)
const textareaRef = ref(null)
const previewRef = ref(null)
const greekVisible = ref(false)
const katexReady = ref(false)

const greekLetters = [
  { name: 'α', cmd: '\\alpha', sym: 'α' },
  { name: 'β', cmd: '\\beta', sym: 'β' },
  { name: 'γ', cmd: '\\gamma', sym: 'γ' },
  { name: 'δ', cmd: '\\delta', sym: 'δ' },
  { name: 'θ', cmd: '\\theta', sym: 'θ' },
  { name: 'λ', cmd: '\\lambda', sym: 'λ' },
  { name: 'π', cmd: '\\pi', sym: 'π' },
  { name: 'σ', cmd: '\\sigma', sym: 'σ' },
  { name: 'φ', cmd: '\\phi', sym: 'φ' },
  { name: 'ω', cmd: '\\omega', sym: 'ω' },
  { name: 'Δ', cmd: '\\Delta', sym: 'Δ' },
  { name: 'Σ', cmd: '\\Sigma', sym: 'Σ' },
  { name: '∞', cmd: '\\infty', sym: '∞' },
  { name: '±', cmd: '\\pm', sym: '±' },
  { name: '×', cmd: '\\times', sym: '×' },
  { name: '÷', cmd: '\\div', sym: '÷' }
]

const templates = {
  fraction: '\\frac{a}{b}',
  sqrt: '\\sqrt{x}',
  power: 'x^{2}',
  sum: '\\sum_{i=1}^{n}',
  integral: '\\int_{a}^{b}',
  limit: '\\lim_{x \\to \\infty}'
}

onMounted(() => {
  loadKatex()
})

const loadKatex = () => {
  if (window.katex) {
    katexReady.value = true
    updatePreview()
    return
  }
  const css = document.createElement('link')
  css.rel = 'stylesheet'
  css.href = 'https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css'
  document.head.appendChild(css)

  const js = document.createElement('script')
  js.src = 'https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js'
  js.onload = () => {
    katexReady.value = true
    updatePreview()
  }
  document.head.appendChild(js)
}

watch(() => props.modelValue, (v) => {
  if (v !== localValue.value) localValue.value = v
})

watch(localValue, () => {
  updatePreview()
})

const updatePreview = () => {
  if (!previewRef.value) return
  
  const text = localValue.value
  if (!text) {
    previewRef.value.innerHTML = '<span style="color:#c0c4cc;font-style:italic">在左侧输入，这里预览</span>'
    return
  }

  // 分段处理
  const parts = []
  let remaining = text
  
  // 匹配 $$...$$ 和 $...$
  const regex = /(\$\$[\s\S]+?\$\$|\$[^$\n]+?\$)/g
  let lastIndex = 0
  let match
  
  while ((match = regex.exec(text)) !== null) {
    // 添加公式前的文本
    if (match.index > lastIndex) {
      parts.push({ type: 'text', content: text.slice(lastIndex, match.index) })
    }
    // 添加公式
    const formula = match[0]
    const isBlock = formula.startsWith('$$')
    const inner = isBlock ? formula.slice(2, -2) : formula.slice(1, -1)
    parts.push({ type: isBlock ? 'block' : 'inline', content: inner })
    lastIndex = regex.lastIndex
  }
  // 添加剩余文本
  if (lastIndex < text.length) {
    parts.push({ type: 'text', content: text.slice(lastIndex) })
  }

  // 渲染
  let html = ''
  for (const part of parts) {
    if (part.type === 'text') {
      let t = part.content
      t = t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      t = t.replace(/\n/g, '<br>')
      html += t
    } else if (window.katex) {
      try {
        const rendered = window.katex.renderToString(part.content.trim(), {
          displayMode: part.type === 'block',
          throwOnError: false
        })
        if (part.type === 'block') {
          html += '<div class="katex-block">' + rendered + '</div>'
        } else {
          html += rendered
        }
      } catch (e) {
        html += (part.type === 'block' ? '$$' : '$') + part.content + (part.type === 'block' ? '$$' : '$')
      }
    } else {
      html += (part.type === 'block' ? '$$' : '$') + part.content + (part.type === 'block' ? '$$' : '$')
    }
  }
  
  previewRef.value.innerHTML = html
}

const handleInput = () => {
  emit('update:modelValue', localValue.value)
}

const insertFormula = (cmd) => {
  if (cmd === 'greek') {
    greekVisible.value = true
    return
  }
  const tpl = templates[cmd]
  if (tpl) insertText('$' + tpl + '$')
}

const insertGreek = (cmd) => {
  insertText(cmd)
  greekVisible.value = false
}

const insertText = (text) => {
  const ta = textareaRef.value?.$el?.querySelector('textarea')
  if (!ta) {
    localValue.value += text
    handleInput()
    return
  }
  const s = ta.selectionStart
  const e = ta.selectionEnd
  localValue.value = localValue.value.slice(0, s) + text + localValue.value.slice(e)
  handleInput()
  nextTick(() => {
    ta.focus()
    ta.setSelectionRange(s + text.length, s + text.length)
  })
}
</script>

<style scoped>
.formula-editor {
  border: 1px solid #dcdfe6;
  border-radius: 8px;
  overflow: hidden;
  background: #fff;
}
.editor-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
}
.toolbar-left {
  display: flex;
  align-items: center;
  gap: 10px;
}
.help-icon {
  color: #909399;
  cursor: pointer;
}
.char-count {
  font-size: 12px;
  color: #909399;
}
.editor-main {
  display: flex;
  height: v-bind(editorHeight);
}
.input-panel, .preview-panel {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-width: 0;
}
.divider {
  width: 1px;
  background: #e4e7ed;
  flex-shrink: 0;
}
.panel-header {
  padding: 6px 12px;
  font-size: 12px;
  color: #909399;
  background: #fafafa;
  border-bottom: 1px solid #ebeef5;
  flex-shrink: 0;
}
.panel-body {
  flex: 1;
  overflow: hidden;
}
.input-panel .panel-body {
  display: flex;
  flex-direction: column;
}
.input-panel .panel-body :deep(.el-textarea) {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.input-panel .panel-body :deep(.el-textarea__inner) {
  border: none;
  flex: 1;
  font-family: Consolas, Monaco, 'Courier New', monospace;
  font-size: 14px;
  line-height: 1.6;
  padding: 10px 12px;
  resize: none;
  box-shadow: none !important;
}
.preview-body {
  padding: 10px 12px;
  font-size: 14px;
  line-height: 1.8;
  overflow-y: auto;
  height: 100%;
  word-break: break-word;
}
.preview-body :deep(.katex-block) {
  margin: 10px 0;
  text-align: center;
}
.preview-body :deep(.katex) {
  font-size: 1.1em;
}
.greek-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}
.greek-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 10px;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}
.greek-item:hover {
  background: #ecf5ff;
  border-color: #409eff;
}
.greek-sym {
  font-size: 20px;
}
.greek-name {
  font-size: 11px;
  color: #909399;
}
</style>
