import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DOCS_DIR = path.resolve(__dirname, '../docs');
const OUTPUT_FILE = path.resolve(__dirname, 'docs-tree.json');

const ALLOWED_EXTENSIONS = new Set(['.md', '.html']);
const ROOT_SKIP_FILES = new Set(['index.md', 'view.md', 'dashboard.md']);

function scanDirectory(dirPath, relativePath = '') {
  const items = fs.readdirSync(dirPath);
  const result = [];

  for (const item of items) {
    if (item.startsWith('.')) {
      continue;
    }
    if (relativePath === '' && ROOT_SKIP_FILES.has(item.toLowerCase())) {
      continue;
    }

    const fullPath = path.join(dirPath, item);
    const stat = fs.statSync(fullPath);
    const cleanRelPath = relativePath ? `${relativePath}/${item}` : item;

    if (stat.isDirectory()) {
      if (item === '.vitepress' || item === '_incoming') {
        continue;
      }

      const children = scanDirectory(fullPath, cleanRelPath);
      if (children.length > 0) {
        result.push({
          name: item,
          path: `/${cleanRelPath}`,
          type: 'directory',
          children
        });
      }
    } else {
      const ext = path.extname(item).toLowerCase();
      if (!ALLOWED_EXTENSIONS.has(ext)) {
        continue;
      }

      let linkPath = `/${cleanRelPath}`;
      if (ext === '.md') {
        linkPath = `/${cleanRelPath.substring(0, cleanRelPath.length - 3)}`;
      } else if (ext === '.html') {
        linkPath = `/view?file=${cleanRelPath}`;
      }

      result.push({
        name: item,
        path: linkPath,
        type: 'file',
        ext
      });
    }
  }

  // Sort: README.md first, then directories alphabetically, then files alphabetically
  return result.sort((a, b) => {
    const aIsReadme = a.type === 'file' && a.name.toLowerCase() === 'readme.md';
    const bIsReadme = b.type === 'file' && b.name.toLowerCase() === 'readme.md';
    if (aIsReadme !== bIsReadme) {
      return aIsReadme ? -1 : 1;
    }
    if (a.type !== b.type) {
      return a.type === 'directory' ? -1 : 1;
    }
    return a.name.localeCompare(b.name, undefined, { numeric: true, sensitivity: 'base' });
  });
}

export function generateTree() {
  try {
    if (!fs.existsSync(DOCS_DIR)) {
      console.warn(`[DocsTree] Docs directory does not exist at ${DOCS_DIR}`);
      return;
    }
    const tree = scanDirectory(DOCS_DIR);
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(tree, null, 2) + '\n', 'utf-8');
    console.log(`[DocsTree] Generated directory tree in ${OUTPUT_FILE}`);
  } catch (error) {
    console.error('[DocsTree] Failed to generate directory tree:', error);
  }
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  generateTree();
}
