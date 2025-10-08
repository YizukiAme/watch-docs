import fs from 'fs/promises';
import path from 'path';

const ROOT = path.resolve(process.cwd(), 'public');
const DOC_DIR = path.join(ROOT, 'docs');
const OUT = path.join(ROOT, 'docs.json');

async function walk(dir) {
  const entries = await fs.readdir(dir, { withFileTypes: true });
  const files = [];
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) files.push(...await walk(full));
    else files.push(full);
  }
  return files;
}

function extOf(p) { return path.extname(p).toLowerCase().replace('.', ''); }

(async () => {
  await fs.mkdir(DOC_DIR, { recursive: true });
  const all = await walk(DOC_DIR);
  const items = await Promise.all(all.map(async f => {
    const st = await fs.stat(f);
    const rel = '/' + path.posix.join('docs', path.relative(DOC_DIR, f).split(path.sep).join('/'));
    return { name: path.basename(f), path: rel, size: st.size, mtime: st.mtimeMs, ext: extOf(f) };
  }));
  items.sort((a,b)=>b.mtime-a.mtime);
  await fs.writeFile(OUT, JSON.stringify({ updatedAt: Date.now(), items }, null, 2));
  console.log('Manifest written:', OUT, items.length, 'files');
})();
