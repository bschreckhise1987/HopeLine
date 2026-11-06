-- ============================================================
-- HopeLine saved Scriptures table
-- Run once in Supabase (SQL Editor).
--
-- Stores each user's saved Scriptures (private data).
-- A user can only see, save, and remove their own verses —
-- enforced by Row Level Security, not the app.
-- ============================================================

-- 1. The table
create table if not exists public.saved_scriptures (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id),
    verse_reference text not null,
    verse_text text not null,
    created_at timestamptz default now()
);

-- 2. One save per verse per user (prevents duplicates)
create unique index if not exists saved_scriptures_user_verse_key
    on public.saved_scriptures (user_id, verse_reference);

-- 3. Row Level Security: strictly per-user
alter table public.saved_scriptures enable row level security;

drop policy if exists "Users save their own Scriptures"
    on public.saved_scriptures;
create policy "Users save their own Scriptures"
    on public.saved_scriptures
    for insert
    to authenticated
    with check (auth.uid() = user_id);

drop policy if exists "Users view their own Scriptures"
    on public.saved_scriptures;
create policy "Users view their own Scriptures"
    on public.saved_scriptures
    for select
    to authenticated
    using (auth.uid() = user_id);

drop policy if exists "Users remove their own Scriptures"
    on public.saved_scriptures;
create policy "Users remove their own Scriptures"
    on public.saved_scriptures
    for delete
    to authenticated
    using (auth.uid() = user_id);
