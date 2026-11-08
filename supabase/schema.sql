-- Hook: cross-device sync schema
-- Paste this whole file into the Supabase dashboard → SQL Editor → Run.
-- Requires: a Supabase project (free tier is enough), auth with email
-- autoconfirm enabled (default when no SMTP is configured — Hook signs
-- users up with a synthetic `<nickname>@hook.local` email, no mail is sent).

-- ---------------------------------------------------------------------------
-- One JSON snapshot per user. The client builds/merges the payload; Postgres
-- only stores it and enforces ownership through RLS.
-- ---------------------------------------------------------------------------
create table if not exists public.sync_snapshots (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.sync_snapshots enable row level security;

drop policy if exists "sync owner read" on public.sync_snapshots;
create policy "sync owner read"
  on public.sync_snapshots for select
  using (auth.uid () = user_id);

drop policy if exists "sync owner insert" on public.sync_snapshots;
create policy "sync owner insert"
  on public.sync_snapshots for insert
  with check (auth.uid () = user_id);

drop policy if exists "sync owner update" on public.sync_snapshots;
create policy "sync owner update"
  on public.sync_snapshots for update
  using (auth.uid () = user_id)
  with check (auth.uid () = user_id);

-- No delete policy on purpose: rows leave with the auth user (on delete
-- cascade) and clients only ever upsert.

-- ---------------------------------------------------------------------------
-- Autoconfirm: sign-ups never receive mail. Double-check it is on:
-- Dashboard → Authentication → Sign In / Providers → Email →
-- "Confirm email" OFF. With no custom SMTP configured this is the default.
-- ---------------------------------------------------------------------------

-- Sanity checks (run in SQL Editor if anything misbehaves):
--   select * from public.sync_snapshots;          -- rows appear after first sync
--   select email from auth.users order by created_at desc limit 5;  -- nicknames as @hook.local
