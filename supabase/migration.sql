-- ============================================================
-- HopeLine Meetings: nationwide geo-search migration
-- Run this once in Supabase (SQL Editor) after the sync script
-- has populated the table, or before — order doesn't matter.
-- ============================================================

-- 1. Enable PostGIS (free, included in Supabase)
create extension if not exists postgis;

-- 2. Extra columns the BMLT feed provides
alter table public.meetings
    add column if not exists end_time text,
    add column if not exists timezone text,
    add column if not exists types text,      -- e.g. "O,DISC,JFT"
    add column if not exists country text;

-- 3. Geography column auto-derived from latitude/longitude.
--    PostGIS uses this for fast "near me" queries.
alter table public.meetings
    add column if not exists geog geography(point, 4326)
    generated always as (
        st_setsrid(st_makepoint(longitude, latitude), 4326)::geography
    ) stored;

-- 4. Index that makes radius searches fast even with 25k+ rows
create index if not exists idx_meetings_geog
    on public.meetings using gist (geog);

-- 5. Unique constraint so the sync script can upsert safely
alter table public.meetings
    drop constraint if exists meetings_meeting_guide_id_key;
alter table public.meetings
    add constraint meetings_meeting_guide_id_key
    unique (meeting_guide_id);

-- 6. Row Level Security: meetings are public directory data,
--    so anyone (anon) can read them, but nobody can write
--    except the sync script (service_role key bypasses RLS).
alter table public.meetings enable row level security;

drop policy if exists "Public read access for meetings" on public.meetings;
create policy "Public read access for meetings"
    on public.meetings
    for select
    using (true);

-- 7. The "near me" function the app calls.
--    Pass in the user's coordinates + radius in miles,
--    get back meetings sorted by distance.
create or replace function public.nearby_meetings(
    lat double precision,
    lng double precision,
    radius_miles double precision default 10
)
returns table (
    id uuid,
    meeting_guide_id text,
    name text,
    meeting_type text,
    meeting_day text,
    meeting_time text,
    end_time text,
    address text,
    city text,
    state text,
    postal_code text,
    latitude double precision,
    longitude double precision,
    is_online boolean,
    online_url text,
    distance_miles double precision
)
language sql stable
as $$
    select
        m.id,
        m.meeting_guide_id,
        m.name,
        m.meeting_type,
        m.meeting_day,
        m.meeting_time,
        m.end_time,
        m.address,
        m.city,
        m.state,
        m.postal_code,
        m.latitude,
        m.longitude,
        m.is_online,
        m.online_url,
        st_distance(
            m.geog,
            st_setsrid(st_makepoint(lng, lat), 4326)::geography
        ) / 1609.344
    from public.meetings m
    where m.geog is not null
      and st_dwithin(
            m.geog,
            st_setsrid(st_makepoint(lng, lat), 4326)::geography,
            radius_miles * 1609.344
          )
    order by m.geog <-> st_setsrid(st_makepoint(lng, lat), 4326)::geography
$$;

-- 8. Let the app's anon key run the function
grant execute on function public.nearby_meetings(double precision, double precision, double precision) to anon, authenticated;
