import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';
import { generateTree } from '../generate-tree.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Run the directory scanner on startup (critical for production builds)
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
            j++; // skip next {
          } else if (char === '}' && line[j + 1] === '}') {
            processedLine += `{{ String.fromCharCode(125, 125) }}`;
            j++; // skip next }
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
            j++; // skip next {
          } else if (char === '}' && line[j + 1] === '}') {
            processedLine += `{{ String.fromCharCode(125, 125) }}`;
            j++; // skip next }
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

export default {
  base: '/',
  title: "BrandHub Docs",
  description: "BrandHub Infrastructure, Project Plans, and Sprints Documentation",
  srcDir: '../docs',
  markdown: {
    attrs: {
      leftDelimiter: '{@attrs:',
      rightDelimiter: '}'
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
        name: 'html-doc-viewer',
        enforce: 'pre',
        apply: 'serve',
        configureServer(server) {
          server.middlewares.use((req, res, next) => {
            const fullUrl = req.url ?? '';
            const url = fullUrl.split('?')[0];

            // Strip VitePress base prefix: /brandhub-infrastructure/view/... → /view/...
            const base = '/brandhub-infrastructure';
            const stripped = url.startsWith(base) ? url.slice(base.length) : url;

            // /view/path/to/file.html  — viewer shell
            // /raw/path/to/file.html   — raw content for iframe
            const isView = stripped.startsWith('/view/');
            const isRaw  = stripped.startsWith('/raw/');
            if (!isView && !isRaw) return next();

            const relPath = isView ? stripped.slice('/view/'.length) : stripped.slice('/raw/'.length);
            const docsDir = path.resolve(__dirname, '../../docs');
            const absPath = path.resolve(docsDir, relPath);

            console.log(`[html-doc-viewer] mode=${isView?'view':'raw'} relPath=${relPath} exists=${fs.existsSync(absPath)}`);

            // Only intercept if file actually exists in docs
            if (!fs.existsSync(absPath)) return next();

            // /raw/ → serve raw file content for iframe
            if (isRaw) {
              res.setHeader('Content-Type', 'text/html; charset=utf-8');
              res.end(fs.readFileSync(absPath, 'utf-8'));
              return;
            }

            // /view/ → serve viewer shell with BrandHub bar + iframe
            const fileName = path.basename(relPath);
            const rawUrl = `/brandhub-infrastructure/raw/${relPath}`;
            const docsBase = '/brandhub-infrastructure/';
            const shell = `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${fileName} — BrandHub Docs</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { height: 100%; font-family: Inter, system-ui, sans-serif; background: #fafafa; }
    .viewer-bar {
      display: flex; align-items: center; gap: 12px;
      padding: 10px 16px;
      background: #ffffff;
      border-bottom: 1px solid #e4e4e7;
      position: sticky; top: 0; z-index: 10;
    }
    .viewer-bar a {
      color: #f05a28; text-decoration: none; font-size: 0.85rem; font-weight: 500;
    }
    .viewer-bar a:hover { text-decoration: underline; }
    .viewer-bar .sep { color: #a1a1aa; }
    .viewer-bar .filename { font-size: 0.85rem; color: #3f3f46; font-weight: 600; }
    .viewer-bar .actions { margin-left: auto; display: flex; gap: 8px; }
    .viewer-bar .btn {
      font-size: 0.8rem; padding: 4px 10px;
      border: 1px solid #e4e4e7; border-radius: 6px;
      background: #f4f4f5; color: #3f3f46;
      cursor: pointer; text-decoration: none;
      transition: border-color 0.15s;
    }
    .viewer-bar .btn:hover { border-color: #f05a28; color: #f05a28; }
    iframe { width: 100%; border: none; height: calc(100vh - 45px); display: block; }
  </style>
</head>
<body>
  <div class="viewer-bar">
    <a href="${docsBase}">← Docs</a>
    <span class="sep">/</span>
    <span class="filename">${fileName}</span>
    <div class="actions">
      <a class="btn" href="${rawUrl}" target="_blank">Raw</a>
      <a class="btn" href="${rawUrl}" download="${fileName}">Tải về</a>
    </div>
  </div>
  <iframe src="${rawUrl}" title="${fileName}"></iframe>
</body>
</html>`;
            res.setHeader('Content-Type', 'text/html; charset=utf-8');
            res.end(shell);
          });
        }
      },
      {
        name: 'docs-tree-watcher',
        configureServer(server) {
          const handleDocsChange = (filePath) => {
            const basename = path.basename(filePath);
            // Ignore hidden files and the homepage index.md
            if (basename.startsWith('.') || basename.toLowerCase() === 'index.md') {
              return;
            }
            // Only trigger if inside the docs directory
            if (filePath.replace(/\\/g, '/').includes('/docs/')) {
              console.log(`[DocsTree] File structure change detected: ${filePath}. Re-generating tree...`);
              generateTree();
            }
          };

          // Watch for file additions, removals, and directory changes
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
          const cleanId = id.split('?')[0];
          // Escape raw HTML-like tags and double curly braces for all markdown files EXCEPT index.md (homepage)
          if (cleanId.endsWith('.md') && !cleanId.endsWith('index.md') && !cleanId.endsWith('view.md')) {
            console.log('TRANSFORMING MD FILE:', cleanId);
            const escaped = escapeMarkdownHtml(code);
            return escaped;
          }
        }
      }
    ]
  },
  themeConfig: {
    logo: '/logo.svg',
    siteTitle: 'BrandHub',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Project Plan', link: '/plan/BrandHub_Project_Plan' },
      { text: 'Sprints', link: '/plan/sprints/README' },
      { text: 'AI Iterations', link: '/plan/iterations/README' }
    ],
    // Configure a dummy group to force VitePress to render the sidebar container,
    // which then mounts our custom DocsTree component in the sidebar slot.
    sidebar: [
      {
        items: []
      }
    ],
    search: {
      provider: 'local'
    }
  }
}
