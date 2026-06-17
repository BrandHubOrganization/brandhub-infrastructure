import DefaultTheme from 'vitepress/theme';
import { h } from 'vue';
import DocsTree from './components/DocsTree.vue';

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      // Render our dynamic folder explorer before any default sidebar navigation links
      'sidebar-nav-before': () => h(DocsTree)
    });
  },
  enhanceApp({ app }) {
    // Also register the component globally
    app.component('DocsTree', DocsTree);
  }
};
