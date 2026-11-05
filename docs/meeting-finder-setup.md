# Nationwide Meeting Finder — Setup Guide

This pipeline powers "find meetings near me, anywhere in the US" using
free services only: no API keys, no subscriptions.

**Flow:** US BMLT root servers (NA data) → sync script → Supabase
`meetings` table (PostGIS) → `nearby_meetings` function → HopeLine app.

## One-Time Setup

### 1. Run the SQL migration

In Supabase, open **SQL Editor**, paste the contents of
`supabase/migration.sql`, and run it. This adds PostGIS, the geo index,
and the `nearby_meetings` function the app calls.

### 2. Run the sync script (seed the data)

From the repo root:

```bash
pip install requests
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"   # Supabase Dashboard → Settings → API
python3 scripts/sync_meetings.py
```

It pulls every published NA meeting from ~26 US root servers
(one polite request per server, upserts in batches of 500) and removes
rows not seen in 45 days. Expect roughly 15,000–25,000 meetings.

### 3. Keep it current (optional, free)

Re-run the script weekly. Two free options:

- Manually after a `git pull`
- A GitHub Actions scheduled workflow using a repository secret for the
  service role key (the repo already has GitHub access set up)

## App Side

`NearbyMeetingService.swift` is already written. Use it in
`MeetingsView` with the existing `LocationService`:

```swift
let meetings = try await NearbyMeetingService.shared
    .fetchNearbyMeetingsWithWidening(
        latitude: location.coordinate.latitude,
        longitude: location.coordinate.longitude
    )
```

It automatically widens the radius (10 → 25 → 50 → 100 miles) when a
rural area returns nothing, and each result includes `distanceMiles`
already sorted nearest-first by PostGIS.

## Notes

- `meeting_type` is set to `"NA"` for every synced row, leaving room to
  add `"AA"` rows later from intergroup feeds that publish the same
  Meeting Guide JSON format.
- BMLT data is community-maintained; the weekly refresh handles
  closed meetings and venue changes.
- The anon key is enough for the app (read-only via RLS policy); the
  service role key is only needed by the sync script.
