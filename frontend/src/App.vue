<template>
  <router-view />
</template>

<script setup>
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

:root {
  --bg-grad-1: #e3f2fd;
  --bg-grad-2: #f3e5f5;
  --bg-grad-3: #e8eaf6;

  --primary: #667eea;
  --primary-2: #764ba2;

  /* Element Plus primary color binding */
  --el-color-primary: var(--primary);

  /* Hover variants */
  --primary-hover: #5568d3;     /* slightly darker */
  --primary-2-hover: #6a3f8f;   /* slightly darker */

  --card-bg: #ffffff;
  --border: #eef2f7;

  --text-primary: #303133;
  --text-secondary: #606266;
  --text-muted: #909399;
}

#app {
  width: 100%;
  height: 100vh;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial,
    'Noto Sans', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol',
    'Noto Color Emoji';
}
</style>

