/**
 * build.js
 * Supabase の環境変数を HTML に注入してdistへ出力
 */
const fs = require('fs');
const path = require('path');

const DIST = path.join(__dirname, 'dist');
const SRC = path.join(__dirname, 'public');

// 環境変数（Vercel の Environment Variables から自動取得）
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

// dist ディレクトリ作成
if (!fs.existsSync(DIST)) fs.mkdirSync(DIST, { recursive: true });

// public 配下の全ファイルを dist にコピー＆置換
function processDir(srcDir, distDir) {
  if (!fs.existsSync(distDir)) fs.mkdirSync(distDir, { recursive: true });

  for (const file of fs.readdirSync(srcDir)) {
    const srcPath = path.join(srcDir, file);
    const distPath = path.join(distDir, file);
    const stat = fs.statSync(srcPath);

    if (stat.isDirectory()) {
      processDir(srcPath, distPath);
    } else {
      let content = fs.readFileSync(srcPath, 'utf-8');

      // プレースホルダーを環境変数で置換
      content = content
        .replace(/__SUPABASE_URL__/g, SUPABASE_URL)
        .replace(/__SUPABASE_ANON_KEY__/g, SUPABASE_ANON_KEY);

      fs.writeFileSync(distPath, content);
      console.log(`✓ ${file}`);
    }
  }
}

console.log('');
console.log('🔨 Building catalog-system...');
console.log(`   SUPABASE_URL: ${SUPABASE_URL ? SUPABASE_URL.slice(0, 30) + '...' : '(not set)'}`);
console.log(`   SUPABASE_KEY: ${SUPABASE_ANON_KEY ? '****' + SUPABASE_ANON_KEY.slice(-8) : '(not set)'}`);
console.log('');

processDir(SRC, DIST);

console.log('');
console.log('✅ Build complete → dist/');
console.log('');
