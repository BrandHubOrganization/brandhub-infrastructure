import DefaultTheme from 'vitepress/theme';
import { h } from 'vue';
import DocsTree from './components/DocsTree.vue';
import BrandTitle from './components/BrandTitle.vue';
import HtmlViewer from './components/HtmlViewer.vue';
import './brandhub.css';

export default {
  extends: DefaultTheme,
  Layout() {
    return h(DefaultTheme.Layout, null, {
      'sidebar-nav-before': () => h(DocsTree),
      'nav-bar-title-before': () => h(BrandTitle),
    });
  },
  enhanceApp({ app }) {
    app.component('DocsTree', DocsTree);
    app.component('BrandTitle', BrandTitle);
    app.component('HtmlViewer', HtmlViewer);
  }
};
