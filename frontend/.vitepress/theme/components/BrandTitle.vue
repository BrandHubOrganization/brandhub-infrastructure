<template>
  <a class="brand-title" href="/">
    <img src="/logo.svg" alt="BrandHub logo" class="brand-logo" />
    <span class="brand-text">Brand<span class="brand-hub">Hub</span></span>
  </a>
</template>

<style scoped>
.brand-title {
  display: flex;
  align-items: center;
  gap: 8px;
  text-decoration: none;
  user-select: none;
}

.brand-logo {
  height: 26px;
  width: 26px;
  border-radius: 6px;
  flex-shrink: 0;
}

.brand-text {
  font-family: 'Inter', system-ui, sans-serif;
  font-weight: 700;
  font-size: 0.9375rem;
  letter-spacing: -0.01em;
  color: #0a0a0a;
}

.brand-hub {
  color: #f05a28;
}

:global(.dark) .brand-text {
  color: #fafafa;
}
</style>
