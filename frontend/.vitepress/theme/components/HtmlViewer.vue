<template>
  <ClientOnly>
    <Teleport to="body">
      <div class="html-viewer-overlay">
        <div v-if="!filePath" class="html-viewer-error">Không tìm thấy file.</div>
        <iframe
          v-else
          :src="rawUrl"
          :title="fileName"
          class="html-viewer-frame"
          sandbox="allow-scripts allow-same-origin"
        />
      </div>
    </Teleport>
  </ClientOnly>
</template>

<script setup>
import { computed } from 'vue';
import { withBase } from 'vitepress';

const filePath = computed(() => {
  if (typeof window === 'undefined') return '';
  const params = new URLSearchParams(window.location.search);
  return params.get('file') || '';
});

const fileName = computed(() => {
  const p = filePath.value;
  return p ? p.split('/').pop() : '';
});

const rawUrl = computed(() => {
  if (!filePath.value) return '';
  return withBase(`raw/${filePath.value}`);
});
</script>

<style>
.html-viewer-overlay {
  position: fixed;
  top: var(--vp-nav-height, 64px);
  left: var(--vp-sidebar-width, 0px);
  right: 0;
  bottom: 0;
  z-index: 50;
  background: var(--vp-c-bg);
}

.html-viewer-frame {
  width: 100%;
  height: 100%;
  border: none;
  display: block;
}

.html-viewer-error {
  padding: 2rem;
  color: var(--vp-c-danger-1);
}
</style>
