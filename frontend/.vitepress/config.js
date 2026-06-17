import { fileURLToPath } from 'url';
import path from 'path';
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
  base: '/brandhub-infrastructure/',
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
          if (cleanId.endsWith('.md') && !cleanId.endsWith('index.md')) {
            console.log('TRANSFORMING MD FILE:', cleanId);
            const escaped = escapeMarkdownHtml(code);
            return escaped;
          }
        }
      }
    ]
  },
  themeConfig: {
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
