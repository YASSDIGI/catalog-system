-- ============================================
-- カタログ管理システム - Supabase マイグレーション
-- ============================================
-- Supabase Dashboard > SQL Editor で実行してください

-- 1. カテゴリテーブル
CREATE TABLE IF NOT EXISTS catalog_categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#2563eb',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. カタログアイテムテーブル
CREATE TABLE IF NOT EXISTS catalog_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  category_id UUID REFERENCES catalog_categories(id) ON DELETE SET NULL,
  price INTEGER NOT NULL DEFAULT 0,
  unit TEXT NOT NULL DEFAULT '式',
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('active', 'draft', 'archived')),
  sku TEXT DEFAULT '',
  image_url TEXT DEFAULT '',
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. インデックス
CREATE INDEX IF NOT EXISTS idx_catalog_items_category ON catalog_items(category_id);
CREATE INDEX IF NOT EXISTS idx_catalog_items_status ON catalog_items(status);
CREATE INDEX IF NOT EXISTS idx_catalog_items_sku ON catalog_items(sku);

-- 4. updated_at 自動更新トリガー
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_catalog_categories_updated
  BEFORE UPDATE ON catalog_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_catalog_items_updated
  BEFORE UPDATE ON catalog_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 5. RLS（Row Level Security）設定
ALTER TABLE catalog_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalog_items ENABLE ROW LEVEL SECURITY;

-- 公開ページ用: 誰でも active なアイテムとカテゴリを閲覧可能
CREATE POLICY "公開カタログ閲覧" ON catalog_items
  FOR SELECT USING (status = 'active');

CREATE POLICY "カテゴリ閲覧" ON catalog_categories
  FOR SELECT USING (true);

-- 管理者用: 認証ユーザーは全操作可能
CREATE POLICY "管理者 全操作 items" ON catalog_items
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "管理者 全操作 categories" ON catalog_categories
  FOR ALL USING (auth.role() = 'authenticated');

-- 6. カタログ一覧用ビュー（カテゴリ情報を結合）
CREATE OR REPLACE VIEW catalog_items_view AS
SELECT
  i.id,
  i.name,
  i.description,
  i.category_id,
  c.name AS category_name,
  c.color AS category_color,
  i.price,
  i.unit,
  i.status,
  i.sku,
  i.image_url,
  i.sort_order,
  i.created_at,
  i.updated_at
FROM catalog_items i
LEFT JOIN catalog_categories c ON i.category_id = c.id
ORDER BY i.sort_order, i.created_at DESC;

-- 7. 初期データ投入
INSERT INTO catalog_categories (name, color, sort_order) VALUES
  ('Web制作',    '#1a5276', 1),
  ('AI開発',     '#6c3483', 2),
  ('動画制作',   '#a93226', 3),
  ('SNSマーケ',  '#1e8449', 4),
  ('コンサル',   '#b9770e', 5);

-- カテゴリIDを取得して初期アイテムを投入
DO $$
DECLARE
  cat_web UUID;
  cat_ai UUID;
  cat_vid UUID;
  cat_sns UUID;
  cat_con UUID;
BEGIN
  SELECT id INTO cat_web FROM catalog_categories WHERE name = 'Web制作';
  SELECT id INTO cat_ai  FROM catalog_categories WHERE name = 'AI開発';
  SELECT id INTO cat_vid FROM catalog_categories WHERE name = '動画制作';
  SELECT id INTO cat_sns FROM catalog_categories WHERE name = 'SNSマーケ';
  SELECT id INTO cat_con FROM catalog_categories WHERE name = 'コンサル';

  INSERT INTO catalog_items (name, description, category_id, price, unit, status, sku, sort_order) VALUES
    ('コーポレートサイト制作',
     'レスポンシブ対応のモダンなコーポレートサイト。WordPress or Headless CMS対応。ブランドの世界観を的確に表現し、ユーザー体験を最大化します。',
     cat_web, 800000, '式', 'active', 'WEB-001', 1),
    ('LP（ランディングページ）制作',
     'CV最適化されたランディングページ。A/Bテスト対応。データドリブンな設計で、広告効果を最大限に引き出します。',
     cat_web, 350000, '式', 'active', 'WEB-002', 2),
    ('AIチャットボット導入',
     '業務効率化のためのカスタムAIチャットボット。社内FAQ対応から顧客対応まで、最新のLLM技術を活用したソリューション。',
     cat_ai, 500000, '式', 'active', 'AI-001', 3),
    ('商品紹介動画制作',
     '60秒の商品プロモーション動画。企画・撮影・編集・ナレーションまでワンストップ。SNS配信にも最適化。',
     cat_vid, 450000, '本', 'active', 'VID-001', 4),
    ('SNS運用代行',
     'Instagram / X / TikTokの運用代行。コンテンツ企画・投稿作成・コミュニティ管理・月次分析レポート付き。',
     cat_sns, 150000, '月', 'active', 'SNS-001', 5),
    ('DXコンサルティング',
     '中小企業向けDX推進コンサルティング。現状分析から施策提案、導入支援まで。AI活用による業務改善を伴走サポート。',
     cat_con, 200000, '月', 'active', 'CON-001', 6);
END $$;
