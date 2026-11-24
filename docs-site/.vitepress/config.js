import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';
import { generateTree } from '../generate-tree.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DOCS_ROOT = path.resolve(__dirname, '../../docs');
const SITE_BASE = process.env.VITEPRESS_BASE || '/';

// Generate sidebar tree before VitePress resolves modules
generateTree();

function escapeMarkdownHtml(code) {
  let output = '';
  let inFencedCode = false;
  const lines = code.split('\n');

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const trimmed = line.trim();

    if (trimmed.startsWith('```')) {
      inFencedCode = !inFencedCode;
      output += line + (i < lines.length - 1 ? '\n' : '');
      continue;
    }

    if (inFencedCode) {
      output += line + (i < lines.length - 1 ? '\n' : '');
    } else {
      let processedLine = '';
      let inInlineCode = false;

      for (let j = 0; j < line.length; j++) {
        const char = line[j];
        if (char === '`') {
          inInlineCode = !inInlineCode;
          processedLine += char;
        } else if (inInlineCode) {
          if (char === '{' && line[j + 1] === '{') {
            processedLine += `{{ String.fromCharCode(123, 123) }}`;
            j++;
          } else if (char === '}' && line[j + 1] === '}') {
            processedLine += `{{ String.fromCharCode(125, 125) }}`;
            j++;
          } else {
            processedLine += char;
          }
        } else {
          if (char === '<') {
            processedLine += '&lt;';
          } else if (char === '>') {
            processedLine += '&gt;';
          } else if (char === '{' && line[j + 1] === '{') {
            processedLine += `{{ String.fromCharCode(123, 123) }}`;
            j++;
          } else if (char === '}' && line[j + 1] === '}') {
            processedLine += `{{ String.fromCharCode(125, 125) }}`;
            j++;
          } else {
            processedLine += char;
          }
        }
      }
      output += processedLine + (i < lines.length - 1 ? '\n' : '');
    }
  }
  return output;
}

function copyDocsHtmlAssets(srcDir, rawOutDir) {
  if (!fs.existsSync(srcDir)) return;
  for (const entry of fs.readdirSync(srcDir, { withFileTypes: true })) {
    if (entry.name.startsWith('.')) continue;
    const srcPath = path.join(srcDir, entry.name);
    const destPath = path.join(rawOutDir, entry.name);
    if (entry.isDirectory()) {
      copyDocsHtmlAssets(srcPath, destPath);
    } else if (entry.name.toLowerCase().endsWith('.html')) {
      fs.mkdirSync(path.dirname(destPath), { recursive: true });
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

export default {
  base: SITE_BASE,
  title: 'BrandHub Docs',
  description: 'BrandHub Architecture, 141 SRS Functional Requirements, Operations & Engineering Knowledge Base',
  srcDir: '../docs',
  ignoreDeadLinks: [
    /^https?:\/\/localhost/,
    /^https?:\/\/127\.0\.0\.1/,
    /^\/view(\?|$)/
  ],
  markdown: {
    attrs: {
      leftDelimiter: '{@attrs:',
      rightDelimiter: '}'
    }
  },
  buildEnd(siteConfig) {
    const rawOutDir = path.join(siteConfig.outDir, 'raw');
    copyDocsHtmlAssets(DOCS_ROOT, rawOutDir);

    // Emit raw Master Plan & Jira Status JSON for the Workload Dashboard in static production builds
    for (const relFile of ['plan/brandhub-master-plan.md', 'plan/jira-status.json']) {
      const src = path.join(DOCS_ROOT, relFile);
      if (fs.existsSync(src)) {
        const dest = path.join(rawOutDir, relFile);
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        fs.copyFileSync(src, dest);
      }
    }
  },
  vite: {
    resolve: {
      alias: {
        'vue/server-renderer': path.resolve(__dirname, '../node_modules/vue/server-renderer'),
        'vue': path.resolve(__dirname, '../node_modules/vue')
      }
    },
    plugins: [
      {
        name: 'serve-dashboard-raw',
        enforce: 'pre',
        apply: 'serve',
        configureServer(server) {
          server.middlewares.use((req, res, next) => {
            const url = (req.url ?? '').split('?')[0];
            const stripped = SITE_BASE !== '/' && url.startsWith(SITE_BASE)
              ? '/' + url.slice(SITE_BASE.length)
              : url;
            if (!stripped.startsWith('/dashboard/')) return next();
            const relPath = stripped.slice('/dashboard/'.length);
            const absPath = path.resolve(__dirname, '../public/dashboard', relPath);
            if (!fs.existsSync(absPath) || !fs.statSync(absPath).isFile()) return next();
            const ext = path.extname(absPath);
            const contentType = {
              '.html': 'text/html; charset=utf-8',
              '.js': 'text/javascript; charset=utf-8'
            }[ext] || 'application/octet-stream';
            res.setHeader('Content-Type', contentType);
            res.end(fs.readFileSync(absPath));
          });
        }
      },
      {
        name: 'html-doc-viewer',
        enforce: 'pre',
        apply: 'serve',
        configureServer(server) {
          server.middlewares.use((req, res, next) => {
            const fullUrl = req.url ?? '';
            const url = fullUrl.split('?')[0];
            const stripped = SITE_BASE !== '/' && url.startsWith(SITE_BASE)
              ? '/' + url.slice(SITE_BASE.length)
              : url;

            if (!stripped.startsWith('/raw/')) return next();

            const relPath = decodeURIComponent(stripped.slice('/raw/'.length));
            const absPath = path.resolve(DOCS_ROOT, relPath);
            if (!absPath.startsWith(DOCS_ROOT) || !fs.existsSync(absPath) || !fs.statSync(absPath).isFile()) {
              return next();
            }

            const ext = path.extname(absPath).toLowerCase();
            const contentType = {
              '.html': 'text/html; charset=utf-8',
              '.md': 'text/markdown; charset=utf-8',
              '.json': 'application/json; charset=utf-8'
            }[ext] || 'text/plain; charset=utf-8';
            res.setHeader('Content-Type', contentType);
            res.end(fs.readFileSync(absPath));
          });
        }
      },
      {
        name: 'docs-tree-watcher',
        configureServer(server) {
          const handleDocsChange = (filePath) => {
            const basename = path.basename(filePath);
            if (basename.startsWith('.') || basename.toLowerCase() === 'index.md') {
              return;
            }
            if (filePath.replace(/\\/g, '/').includes('/docs/')) {
              generateTree();
            }
          };

          server.watcher.on('add', handleDocsChange);
          server.watcher.on('unlink', handleDocsChange);
          server.watcher.on('addDir', handleDocsChange);
          server.watcher.on('unlinkDir', handleDocsChange);
        }
      },
      {
        name: 'escape-markdown-html',
        enforce: 'pre',
        transform(code, id) {
          const cleanId = id.split('?')[0].replace(/\\/g, '/');
          if (
            cleanId.endsWith('.md') &&
            !cleanId.endsWith('/docs/index.md') &&
            !cleanId.endsWith('/docs/view.md') &&
            !cleanId.endsWith('/docs/dashboard.md')
          ) {
            return escapeMarkdownHtml(code);
          }
        }
      }
    ]
  },
  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'BrandHub Docs',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Architecture', link: '/architecture/README' },
      { text: 'BA & 141 FRs', link: '/ba/README' },
      { text: 'Features', link: '/feature/README' },
      { text: 'Master Plan', link: '/plan/brandhub-master-plan' },
      { text: 'Sprints', link: '/plan/sprint-plan-v2-overview' },
      { text: 'AI Iterations', link: '/plan/iterations/README' },
      { text: 'Dashboard', link: '/dashboard' }
    ],
    sidebar: [
      {
        items: []
      }
    ],
    search: {
      provider: 'local'
    }
  }
};
