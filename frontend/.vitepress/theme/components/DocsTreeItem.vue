<template>
  <div class="docs-tree-item" :style="{ '--depth': depth }">
    <!-- Directory Node -->
    <div v-if="node.type === 'directory'" class="directory-node">
      <div 
        @click="toggle" 
        class="node-row directory-row"
        :class="{ 'is-open': isOpen }"
        role="button"
        tabindex="0"
        @keydown.enter="toggle"
        @keydown.space.prevent="toggle"
      >
        <!-- Chevron Toggle -->
        <span class="chevron-wrapper" :class="{ 'rotated': isOpen }">
          <svg viewBox="0 0 24 24" width="14" height="14" stroke="currentColor" stroke-width="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="9 18 15 12 9 6"></polyline>
          </svg>
        </span>

        <!-- Folder Icon -->
        <span class="icon-wrapper folder-icon" :class="{ 'text-brand': isOpen }">
          <!-- Folder Open -->
          <svg v-if="isOpen" viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
            <path d="M2 10h20"></path>
          </svg>
          <!-- Folder Closed -->
          <svg v-else viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
          </svg>
        </span>

        <!-- Folder Name -->
        <span class="node-name">{{ node.name }}</span>
      </div>

      <!-- Recursive Children with Guide Line -->
      <div v-show="isOpen" class="node-children">
        <DocsTreeItem 
          v-for="child in node.children" 
          :key="child.path" 
          :node="child" 
          :depth="depth + 1"
          :search-query="searchQuery"
        />
      </div>
    </div>

    <!-- File Node -->
    <div v-else class="file-node">
      <a 
        :href="withBase(node.path)" 
        class="node-row file-row"
        :class="{ 'active-link': isActive }"
      >
        <!-- File Icon -->
        <span class="icon-wrapper file-icon">
          <!-- HTML File Icon -->
          <svg v-if="node.ext === '.html'" viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="html-icon-color">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <path d="M8 13h2"></path>
            <path d="M14 13h2"></path>
            <path d="M11 10v6"></path>
          </svg>
          <!-- Markdown File Icon -->
          <svg v-else viewBox="0 0 24 24" width="16" height="16" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="md-icon-color">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
          </svg>
        </span>

        <!-- File Name -->
        <span class="node-name">{{ node.name }}</span>
      </a>
    </div>
  </div>
</template>

<script setup>
import { ref, watch, computed } from 'vue';
import { useRoute, withBase } from 'vitepress';

const props = defineProps({
  node: {
    type: Object,
    required: true
  },
  depth: {
    type: Number,
    default: 0
  },
  searchQuery: {
    type: String,
    default: ''
  }
});

// All directories open by default for a complete visual overview
const isOpen = ref(true);
const route = useRoute();

// Toggle directory collapse state
const toggle = () => {
  isOpen.value = !isOpen.value;
};

// Check if this item matches the current active route
const isActive = computed(() => {
  if (props.node.type !== 'file') return false;
  
  // Normalize paths for comparison (remove trailing slashes, clean urls, etc.)
  const cleanRoute = route.path.replace(/\.html$/, '').replace(/\/$/, '');
  const cleanPath = withBase(props.node.path).replace(/\.html$/, '').replace(/\/$/, '');
  
  return cleanRoute === cleanPath;
});

// Auto-expand folder when search query changes to ensure matches are visible
watch(() => props.searchQuery, (newQuery) => {
  if (newQuery) {
    isOpen.value = true;
  }
});
</script>

<style scoped>
.docs-tree-item {
  user-select: none;
  font-family: var(--vp-font-family-mono), Consolas, Monaco, monospace;
  font-size: 0.9rem;
}

.node-row {
  display: flex;
  align-items: center;
  padding: 6px 8px;
  margin: 2px 0;
  border-radius: 6px;
  cursor: pointer;
  color: var(--vp-c-text-2);
  transition: all 0.15s ease-in-out;
  text-decoration: none;
}

.node-row:hover {
  background-color: var(--vp-c-bg-mute);
  color: var(--vp-c-text-1);
}

.directory-row {
  font-weight: 500;
}

.directory-row.is-open {
  color: var(--vp-c-text-1);
}

.file-row {
  margin-left: 20px; /* Aligns file icons with folders (folder row has chevron + folder icon) */
}

.active-link {
  color: var(--vp-c-brand-1) !important;
  background-color: var(--vp-c-brand-soft) !important;
  font-weight: 600;
}

.chevron-wrapper {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-right: 6px;
  color: var(--vp-c-text-3);
  transition: transform 0.2s ease;
}

.chevron-wrapper.rotated {
  transform: rotate(90deg);
}

.icon-wrapper {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  margin-right: 8px;
  color: var(--vp-c-text-3);
}

.folder-icon.text-brand {
  color: var(--vp-c-brand-1);
}

.file-icon {
  color: var(--vp-c-text-3);
}

.html-icon-color {
  color: #e34f26; /* HTML5 Orange */
}

.md-icon-color {
  color: var(--vp-c-brand-1);
}

.node-name {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.node-children {
  position: relative;
  margin-left: 14px;
  padding-left: 12px;
  border-left: 1px solid var(--vp-c-divider);
  /* Micro animation for collapsing */
  transition: max-height 0.3s ease-out;
}
</style>
