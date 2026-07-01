<template>
  <div class="docs-tree-container">
    <!-- Search Bar & Stats Header -->
    <div class="tree-header">
      <div class="search-wrapper">
        <svg class="search-icon" viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"></circle>
          <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
        </svg>
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="Tìm kiếm tài liệu..." 
          class="search-input"
        />
        <button 
          v-if="searchQuery" 
          @click="searchQuery = ''" 
          class="clear-button" 
          title="Xóa tìm kiếm"
        >
          <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
      <div class="tree-stats">
        <span>{{ totalFiles }} tệp</span>
      </div>
    </div>

    <!-- Tree Root list -->
    <div class="tree-body">
      <div v-if="filteredTree.length > 0" class="tree-scroll">
        <DocsTreeItem 
          v-for="node in filteredTree" 
          :key="node.path" 
          :node="node" 
          :depth="0"
          :search-query="searchQuery"
        />
      </div>
      <div v-else class="empty-state">
        <svg class="empty-icon" viewBox="0 0 24 24" width="36" height="36" stroke="currentColor" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"></circle>
          <path d="m21 21-4.3-4.3"></path>
          <path d="M8 11h6"></path>
        </svg>
        <p class="empty-text">Không tìm thấy tài liệu phù hợp</p>
        <button @click="searchQuery = ''" class="reset-button">Đặt lại</button>
      </div>
    </div>
  </div>

  <div 
    class="resize-handle" 
    :class="{ 'is-resizing': isResizing }"
    @mousedown="startResize"
  ></div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import rawTree from '../../../docs-tree.json';
import DocsTreeItem from './DocsTreeItem.vue';

const searchQuery = ref('');

const isResizing = ref(false);
const sidebarWidth = ref(320); // Default sidebar width

const startResize = (event) => {
  event.preventDefault();
  isResizing.value = true;
  document.body.style.cursor = 'col-resize';
  document.body.style.userSelect = 'none'; // Prevent text/element selection while dragging
  
  window.addEventListener('mousemove', resize);
  window.addEventListener('mouseup', stopResize);
};

const applyWidth = (width) => {
  document.documentElement.style.setProperty('--vp-sidebar-width', `${width}px`);
  // Force VitePress sidebar + content layout to use the new width
  const sidebarEl = document.querySelector('.VPSidebar');
  const contentEl = document.querySelector('.VPContent');
  if (sidebarEl) sidebarEl.style.width = `${width}px`;
  if (contentEl) contentEl.style.paddingLeft = `${width}px`;
};

const resize = (event) => {
  if (!isResizing.value) return;
  const sidebarEl = document.querySelector('.VPSidebar');
  const sidebarLeft = sidebarEl ? sidebarEl.getBoundingClientRect().left : 0;
  const newWidth = Math.max(200, Math.min(600, event.clientX - sidebarLeft));
  sidebarWidth.value = newWidth;
  applyWidth(newWidth);
};

const stopResize = () => {
  if (!isResizing.value) return;
  isResizing.value = false;
  document.body.style.cursor = '';
  document.body.style.userSelect = '';
  
  // Persist user preference
  localStorage.setItem('vp-sidebar-width', `${sidebarWidth.value}px`);
  
  window.removeEventListener('mousemove', resize);
  window.removeEventListener('mouseup', stopResize);
};

onMounted(() => {
  const savedWidth = localStorage.getItem('vp-sidebar-width');
  if (savedWidth) {
    const widthVal = parseInt(savedWidth);
    if (!isNaN(widthVal) && widthVal >= 200 && widthVal <= 600) {
      sidebarWidth.value = widthVal;
      applyWidth(widthVal);
    }
  } else {
    applyWidth(320);
  }
});

onUnmounted(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('mousemove', resize);
    window.removeEventListener('mouseup', stopResize);
  }
});

const countFiles = (nodes) => {
  let count = 0;
  for (const node of nodes) {
    if (node.type === 'file') {
      count++;
    } else if (node.type === 'directory' && node.children) {
      count += countFiles(node.children);
    }
  }
  return count;
};

const totalFiles = computed(() => countFiles(rawTree));

const filterTreeNodes = (nodes, query) => {
  if (!query) return nodes;
  
  const cleanQuery = query.toLowerCase();
  
  return nodes
    .map(node => {
      if (node.type === 'directory') {
        const filteredChildren = filterTreeNodes(node.children || [], query);
        const isMatched = node.name.toLowerCase().includes(cleanQuery);
        if (filteredChildren.length > 0 || isMatched) {
          return { ...node, children: filteredChildren };
        }
      } else {
        if (node.name.toLowerCase().includes(cleanQuery)) {
          return node;
        }
      }
      return null;
    })
    .filter(Boolean);
};

const filteredTree = computed(() => {
  return filterTreeNodes(rawTree, searchQuery.value);
});
</script>

<style scoped>
.docs-tree-container {
  /* Styled transparently to fit natively in VitePress sidebar */
  border: none;
  background-color: transparent;
  margin: 0;
  box-shadow: none;
  display: flex;
  flex-direction: column;
  /* Fill viewport height minus navbar height and padding to keep header fixed */
  height: calc(100vh - var(--vp-nav-height, 64px) - 40px);
  overflow: hidden;
}

.tree-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 0 10px 0;
  border-bottom: 1px solid var(--vp-c-divider);
  background-color: transparent;
  gap: 12px;
  margin-bottom: 10px;
  flex-shrink: 0;
}

.search-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  flex: 1;
}

.search-icon {
  position: absolute;
  left: 10px;
  color: var(--vp-c-text-3);
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: 6px 30px 6px 30px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background-color: var(--vp-c-bg-mute);
  color: var(--vp-c-text-1);
  font-size: 0.85rem;
  font-family: var(--vp-font-family-base);
  outline: none;
  transition: border-color 0.2s ease, background-color 0.2s ease;
}

.search-input:focus {
  border-color: var(--vp-c-brand-1);
  background-color: var(--vp-c-bg);
}

.clear-button {
  position: absolute;
  right: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2px;
  border-radius: 4px;
  color: var(--vp-c-text-3);
  cursor: pointer;
  transition: color 0.15s ease, background-color 0.15s ease;
}

.clear-button:hover {
  color: var(--vp-c-text-1);
  background-color: var(--vp-c-bg-mute);
}

.tree-stats {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
  white-space: nowrap;
  font-family: var(--vp-font-family-mono);
}

.tree-body {
  padding: 0;
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.tree-scroll {
  flex: 1;
  overflow-y: auto;
  scrollbar-width: thin;
  padding-right: 4px;
}

/* Custom Scrollbar */
.tree-scroll::-webkit-scrollbar {
  width: 4px;
}

.tree-scroll::-webkit-scrollbar-track {
  background: transparent;
}

.tree-scroll::-webkit-scrollbar-thumb {
  background-color: var(--vp-c-divider);
  border-radius: 2px;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 30px 10px;
  text-align: center;
}

.empty-icon {
  color: var(--vp-c-text-3);
  margin-bottom: 10px;
}

.empty-text {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  margin-bottom: 10px;
}

.reset-button {
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--vp-c-brand-1);
  padding: 4px 10px;
  border: 1px solid var(--vp-c-brand-1);
  border-radius: 6px;
  cursor: pointer;
  background-color: transparent;
  transition: background-color 0.15s ease, color 0.15s ease;
}

.reset-button:hover {
  background-color: var(--vp-c-brand-1);
  color: var(--vp-c-bg);
}
</style>

<style>
:root {
  --vp-sidebar-width: 320px;
}

/* Unscoped styles to hide default VitePress sidebar elements, disable outer scroll, and reduce thick padding */
.VPSidebar {
  overflow: hidden !important;
  padding: 70px 12px 12px 16px !important;
}
.VPSidebar .container {
  padding: 0 !important;
  max-width: 100% !important;
}
.VPSidebar .nav {
  padding: 0 !important;
}
.VPSidebarGroup {
  display: none !important;
}

/* Resize handle style */
.resize-handle {
  position: fixed;
  top: var(--vp-nav-height, 64px);
  bottom: 0;
  left: var(--vp-sidebar-width);
  width: 24px;
  margin-left: -12px; /* Center it over the border-right of the sidebar */
  cursor: col-resize;
  z-index: 100;
  background-color: transparent;
  transition: background-color 0.2s ease;
}

@media (min-width: 1440px) {
  .resize-handle {
    left: calc(calc(100vw - 1440px) / 2 + var(--vp-sidebar-width));
  }
}

/* Vertical line indicator */
.resize-handle::after {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: 11px; /* Center of 24px (24 / 2 - 2 / 2 = 11) */
  width: 2px;
  background-color: transparent;
  transition: background-color 0.2s ease;
}

/* Grab knob pill handle in the center (always visible for easy discovery) */
.resize-handle::before {
  content: '⋮';
  display: flex;
  align-items: center;
  justify-content: center;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 14px;
  height: 36px;
  background-color: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  color: var(--vp-c-text-3);
  font-size: 14px;
  font-family: sans-serif;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  opacity: 1; /* Always visible so users know they can resize */
  transition: border-color 0.2s ease, color 0.2s ease, background-color 0.2s ease, transform 0.1s ease;
  pointer-events: none;
}

.resize-handle:hover::after,
.resize-handle.is-resizing::after {
  background-color: var(--vp-c-brand-1);
}

.resize-handle:hover::before,
.resize-handle.is-resizing::before {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
  transform: translate(-50%, -50%) scale(1.1); /* Slightly enlarge on hover for visual feedback */
}

/* Hide the resize handler on mobile screens where sidebar is hidden/overlay */
@media (max-width: 959px) {
  .resize-handle {
    display: none;
  }
}
</style>

