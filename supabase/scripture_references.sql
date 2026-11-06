-- ============================================================
-- HopeLine Scripture theme references table
-- Run once in Supabase (SQL Editor).
--
-- Stores the pool of Scripture references for each recovery
-- theme (anxious, tempted, ashamed, lonely, discouraged,
-- grateful). The verse text is stored too — fetched and
-- verified from the Bible API by the seed script — so the
-- app can display theme Scriptures instantly without
-- hitting the Bible API's rate limits.
--
-- Adding more verses later never requires an app update:
-- just insert more rows (or extend the seed script).
-- ============================================================

-- 1. The table
create table if not exists public.scripture_references (
    id uuid primary key default gen_random_uuid(),
    theme text not null,
    verse_reference text not null,
    verse_text text not null,
    sort_order integer default 0,
    created_at timestamptz default now()
);

-- 2. Row Level Security: public content, readable by anyone
--    (like daily_scriptures and meetings)
alter table public.scripture_references enable row level security;

drop policy if exists "Public read access for scripture references"
    on public.scripture_references;
create policy "Public read access for scripture references"
    on public.scripture_references
    for select
    using (true);

-- 3. Helpful index for theme lookups
create index if not exists idx_scripture_references_theme
    on public.scripture_references (theme, sort_order);
