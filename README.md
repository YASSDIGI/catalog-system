# 📦 カタログ管理システム

Supabase + GitHub + Vercel で運用するサービスカタログ管理システム。

## ファイル構成

```
catalog-system/
├── public/
│   ├── index.html          ← 公開カタログページ（お客様向け）
│   └── admin.html          ← 管理画面（ログイン認証付き）
├── supabase/
│   └── migration.sql       ← DBマイグレーション
├── build.js                ← ビルドスクリプト（環境変数を注入）
├── vercel.json             ← Vercel設定
├── package.json
├── .env.example
└── .gitignore
```

**公開URL（デプロイ後）**

| URL | 用途 |
|-----|------|
| `https://your-domain.vercel.app/` | 公開カタログ |
| `https://your-domain.vercel.app/admin` | 管理画面 |

---

## 🚀 セットアップ手順

### Step 1: Supabase プロジェクト準備

1. [supabase.com/dashboard](https://supabase.com/dashboard) にログイン
2. 既存のプロジェクトを使うか、新規作成

### Step 2: テーブル作成

1. Supabase Dashboard → **SQL Editor** を開く
2. `supabase/migration.sql` の中身をコピー＆ペースト
3. **Run** をクリック

作成されるもの：
- `catalog_categories` テーブル
- `catalog_items` テーブル
- `catalog_items_view` ビュー
- RLS ポリシー（公開/管理者）
- サンプルデータ（6件）

### Step 3: API情報を確認

Supabase Dashboard → **Settings → API** から：

- **Project URL** → `https://xxxxx.supabase.co`
- **anon public key** → `eyJhbGciOiJIUzI1NiIs...`

この2つをメモしておく。

### Step 4: 管理者アカウント作成

Supabase Dashboard → **Authentication → Users** → **Add User** で管理者のメール/パスワードを作成。

※ または、管理画面の「新規アカウント作成」ボタンからも作成可能。

### Step 5: GitHub にプッシュ

```bash
cd catalog-system
git init
git add .
git commit -m "初回コミット: カタログ管理システム"

# GitHub で新しいリポジトリを作成して
git remote add origin https://github.com/YOUR_USERNAME/catalog-system.git
git push -u origin main
```

### Step 6: Vercel にデプロイ

1. [vercel.com](https://vercel.com) にログイン
2. **Add New → Project**
3. GitHub リポジトリ `catalog-system` をインポート
4. **Environment Variables** に以下を追加：

| Key | Value |
|-----|-------|
| `NEXT_PUBLIC_SUPABASE_URL` | `https://xxxxx.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIs...` |

5. **Deploy** をクリック

### Step 7: 動作確認

- `https://your-domain.vercel.app/` → 公開カタログ表示
- `https://your-domain.vercel.app/admin` → ログイン画面 → Step 4 のアカウントでログイン

---

## 📝 使い方

### 管理画面（/admin）

- **新規追加**: サービス名・価格・カテゴリ・説明を入力して保存
- **ステータス管理**: 「公開中」にしたアイテムだけが公開ページに表示
- **カテゴリ管理**: カテゴリの追加・削除・色変更
- **CSV出力**: 全データをCSVでダウンロード

### 公開ページ（/）

- 管理画面で「公開中」にしたアイテムがリアルタイムで反映
- カテゴリフィルター・キーワード検索
- 各サービスからお問い合わせメール送信

---

## 🔒 セキュリティ

### RLS（Row Level Security）

| ルール | 説明 |
|--------|------|
| 未認証ユーザー | `status = 'active'` のアイテムのみ閲覧可 |
| 認証ユーザー | 全アイテムの閲覧・作成・更新・削除可 |

- **anon key** は公開OK（RLSで保護されるため）
- 管理操作には Supabase Auth のログインが必須

---

## 🔧 カスタマイズ

### お問い合わせメール

`public/index.html` 内の `CONTACT_EMAIL` を変更：

```javascript
const CONTACT_EMAIL = 'your@email.com';
```

### 会社名

```javascript
const COMPANY_NAME = 'あなたの会社名';
```

### デザイン

`public/index.html` のCSS変数で全体の色味を調整：

```css
:root {
  --ink: #0a0a0a;       /* メイン文字色 */
  --accent: #c4553a;    /* アクセントカラー */
  --paper: #faf9f7;     /* 背景色 */
}
```

---

## 🔄 更新フロー

```
コード変更 → git push → Vercel が自動デプロイ
```

カタログデータの更新は管理画面（/admin）から直接操作するだけでOK。コードの変更・デプロイは不要。
