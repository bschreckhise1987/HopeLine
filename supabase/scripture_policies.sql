-- ============================================================
-- HopeLine Scripture feature: RLS policies
-- Run once in Supabase (SQL Editor).
--
-- daily_scriptures is public content (like the meetings
-- table), so anyone using the app can read it — including
-- users who aren't signed in yet.
--
-- scripture_activity is personal data: signed-in users can
-- only insert rows for themselves.
-- ============================================================

-- 1. Public read access for daily scriptures
drop policy if exists "Public read access for daily scriptures"
    on public.daily_scriptures;
create policy "Public read access for daily scriptures"
    on public.daily_scriptures
    for select
    using (true);

-- 2. Signed-in users can record their own scripture views
drop policy if exists "Users record their own scripture views"
    on public.scripture_activity;
create policy "Users record their own scripture views"
    on public.scripture_activity
    for insert
    to authenticated
    with check (auth.uid() = user_id);

-- 3. Signed-in users can see their own scripture history
drop policy if exists "Users view their own scripture history"
    on public.scripture_activity;
create policy "Users view their own scripture history"
    on public.scripture_activity
    for select
    to authenticated
    using (auth.uid() = user_id);
