import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DOCS_DIR = path.resolve(__dirname, '../docs');
const OUTPUT_FILE = path.resolve(__dirname, 'docs-tree.json');

function scanDirectory(dirPath, relativePath = '') {
  const items = fs.readdirSync(dirPath);
  const result = [];

  for (const item of items) {
    // Ignore hidden files, homepage index.md, and the internal html-viewer page
    if (item.startsWith('.') || (relativePath === '' && item.toLowerCase() === 'index.md') || (relativePath === '' && item.toLowerCase() === 'view.md')) {
      continue;
    }

    const fullPath = path.join(dirPath, item);
    const stat = fs.statSync(fullPath);
    const cleanRelPath = relativePath ? `${relativePath}/${item}` : item;

    if (stat.isDirectory()) {
      // Ignore .vitepress if it happens to be in docs (usually in frontend)
      if (item === '.vitepress') {
        continue;
      }
      
      const children = scanDirectory(fullPath, cleanRelPath);
      // Only add directory if it has contents
      result.push({
        name: item,
        path: `/${cleanRelPath}`,
        type: 'directory',
        children: children
      });
    } else {
      // It's a file
      let linkPath = `/${cleanRelPath}`;
      // For .md files, strip the extension to match VitePress routing
      if (item.endsWith('.md')) {
        linkPath = `/${cleanRelPath.substring(0, cleanRelPath.length - 3)}`;
      }
      // For .html files, route through VitePress /view page with query param
      if (item.endsWith('.html')) {
        linkPath = `/view?file=${cleanRelPath}`;
      }

      result.push({
        name: item,
        path: linkPath,
        type: 'file',
        ext: path.extname(item).toLowerCase()
      });
    }
  }

  // Sort: directories first, then files, both alphabetically
  return result.sort((a, b) => {
    if (a.type !== b.type) {
      return a.type === 'directory' ? -1 : 1;
    }
    return a.name.localeCompare(b.name, undefined, { sensitivity: 'base' });
  });
}

export function generateTree() {
  try {
    if (!fs.existsSync(DOCS_DIR)) {
      console.warn(`Docs directory does not exist at ${DOCS_DIR}`);
      return;
    }
    const tree = scanDirectory(DOCS_DIR);
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(tree, null, 2), 'utf-8');
    console.log(`[DocsTree] Generated directory tree in ${OUTPUT_FILE}`);
  } catch (error) {
    console.error('[DocsTree] Failed to generate directory tree:', error);
  }
}

// Run immediately if executed directly
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  generateTree();
}