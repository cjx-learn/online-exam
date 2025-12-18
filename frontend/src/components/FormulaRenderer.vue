<template>
  <div class="formula-renderer" ref="containerRef"></div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'

const props = defineProps({
  content: { type: String, default: '' }
})

const containerRef = ref(null)
const katexReady = ref(false)

onMounted(() => {
  loadKatex()
})

const loadKatex = () => {
  if (window.katex) {
    katexReady.value = true
    render()
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
    render()
  }
  document.head.appendChild(js)
}

watch(() => props.content, () => {
  render()
})

watch(katexReady, () => {
  render()
})

const render = () => {
  if (!containerRef.value) return
  
  const text = props.content
  if (!text) {
    containerRef.value.innerHTML = '<span class="empty">未作答</span>'
    return
  }

  // 分段处理公式和文本
  const parts = []
  const regex = /(\$\$[\s\S]+?\$\$|\$[^$\n]+?\$)/g
  let lastIndex = 0
  let match
  
  while ((match = regex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      parts.push({ type: 'text', content: text.slice(lastIndex, match.index) })
    }
    const formula = match[0]
    const isBlock = formula.startsWith('$$')
    const inner = isBlock ? formula.slice(2, -2) : formula.slice(1, -1)
    parts.push({ type: isBlock ? 'block' : 'inline', content: inner })
    lastIndex = regex.lastIndex
  }
  if (lastIndex < text.length) {
    parts.push({ type: 'text', content: text.slice(lastIndex) })
  }

  // 渲染 HTML
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
      // KaTeX 未加载，显示原始文本
      html += (part.type === 'block' ? '$$' : '$') + part.content + (part.type === 'block' ? '$$' : '$')
    }
  }
  
  containerRef.value.innerHTML = html
}
</script>

<style scoped>
.formula-renderer {
  font-size: 14px;
  line-height: 1.8;
  color: #333;
  word-break: break-word;
}
.formula-renderer .empty {
  color: #999;
  font-style: italic;
}
.formula-renderer :deep(.katex-block) {
  margin: 12px 0;
  text-align: center;
}
.formula-renderer :deep(.katex) {
  font-size: 1.1em;
}
</style>
