#!/usr/bin/env python3
"""
HopeLine nationwide meeting sync.

Pulls every published NA meeting from the ~26 US BMLT root servers
(free, no API key) in the open Meeting Guide JSON format, then upserts
them into the Supabase `meetings` table and removes stale rows.

Usage:
    export SUPABASE_URL="https://your-project.supabase.co"
    export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
    python3 sync_meetings.py

Run it once to seed the table, then re-run weekly to stay current
(venues move, meetings close). Can be automated free with a
GitHub Actions scheduled workflow.
"""

import os
import sys
import json
import time
from datetime import datetime, timedelta, timezone

import requests

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

SUPABASE_URL = os.environ.get("SUPABASE_URL", "").rstrip("/")
SUPABASE_SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")

if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
    sys.exit("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables first.")

SERVER_LIST_URL = (
    "https://raw.githubusercontent.com/bmlt-enabled/aggregator/main/serverList.json"
)

# US root servers from the canonical BMLT server list.
# (Worldwide servers like NZ, India, Germany are excluded on purpose —
#  this app targets nationwide US coverage.)
US_SERVER_IDS = {
    100,  # Texas, Louisiana, Mississippi, Arkansas
    101,  # Metro Richmond (VA/DC)
    102,  # Greater New York
    103,  # Southern California Region
    105,  # Greater Philadelphia Region
    106,  # Ohio Region
    116,  # NA Hawai'i
    117,  # San Jose Area
    119,  # Wisconsin Region
    120,  # NA New Jersey
    121,  # Connecticut Region
    122,  # Volunteer Region (Tennessee)
    127,  # Michigan NA
    129,  # NA Minnesota
    131,  # NA Colorado
    134,  # New England
    135,  # Show-Me Region (Missouri)
    137,  # Southeastern Zonal Forum
    138,  # NA Kentucky
    141,  # Plains States Zonal Forum
    147,  # Greater Illinois Region
    152,  # Western States Zonal Forum
    153,  # Tri-State Region
    154,  # Indiana Region
    155,  # Montana Region
    157,  # Chicagoland Region
    164,  # NA Utah
}

BATCH_SIZE = 500
STALE_AFTER_DAYS = 45

WEEKDAYS = [
    "Sunday", "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday",
]

# ---------------------------------------------------------------------------
# Fetch + transform
# ---------------------------------------------------------------------------


def fetch_us_servers():
    resp = requests.get(SERVER_LIST_URL, timeout=30)
    resp.raise_for_status()
    servers = json.loads(resp.text)
    return [s for s in servers if s.get("id") in US_SERVER_IDS]


def fetch_meetings(root_url):
    """All meetings from one root server, in Meeting Guide JSON format."""
    url = root_url.rstrip("/") + "/client_interface/tsml/?switcher=GetSearchResults"
    resp = requests.get(url, timeout=120)
    resp.raise_for_status()
    return resp.json()


def to_row(meeting, source_name):
    """Map one Meeting Guide JSON record to one Supabase row."""
    coordinates = meeting.get("coordinates") or ""
    lat, lng = None, None
    if "," in coordinates:
        try:
            lat_s, lng_s = coordinates.split(",", 1)
            lat, lng = float(lat_s), float(lng_s)
        except ValueError:
            pass

    day = meeting.get("day")
    conference_url = meeting.get("conference_url")

    return {
        "meeting_guide_id": meeting.get("slug"),
        "name": meeting.get("name"),
        "address": meeting.get("address"),
        "city": meeting.get("city"),
        "state": meeting.get("state"),
        "postal_code": meeting.get("postal_code"),
        "country": meeting.get("country"),
        "latitude": lat,
        "longitude": lng,
        "meeting_type": "NA",          # room to add "AA" feeds later
        "meeting_day": WEEKDAYS[day] if isinstance(day, int) and 0 <= day <= 6 else None,
        "meeting_time": meeting.get("time"),
        "end_time": meeting.get("end_time"),
        "types": ",".join(meeting.get("types") or []),
        "is_online": bool(conference_url),
        "online_url": conference_url,
        "last_updated": datetime.now(timezone.utc).isoformat(),
    }


# ---------------------------------------------------------------------------
# Supabase upsert / cleanup
# ---------------------------------------------------------------------------


def supabase_headers():
    return {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
        "Content-Type": "application/json",
    }


def upsert_rows(rows):
    """Upsert rows in batches, keyed on meeting_guide_id."""
    inserted = 0
    for start in range(0, len(rows), BATCH_SIZE):
        batch = rows[start:start + BATCH_SIZE]
        resp = requests.post(
            f"{SUPABASE_URL}/rest/v1/meetings"
            "?on_conflict=meeting_guide_id",
            headers={**supabase_headers(), "Prefer": "resolution=merge-duplicates"},
            json=batch,
            timeout=120,
        )
        if resp.status_code not in (200, 201):
            print(f"    Upsert failed ({resp.status_code}): {resp.text[:300]}")
        else:
            inserted += len(batch)
    return inserted


def delete_stale_rows():
    cutoff = (
        datetime.now(timezone.utc) - timedelta(days=STALE_AFTER_DAYS)
    ).isoformat()
    resp = requests.delete(
        f"{SUPABASE_URL}/rest/v1/meetings?filter=last_updated=lt.{cutoff}",
        headers={**supabase_headers(), "Prefer": "return=count"},
        timeout=120,
    )
    return resp.headers.get("content-range", "0").split("/")[-1] if resp.ok else "0"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main():
    print("Fetching US BMLT root server list...")
    servers = fetch_us_servers()
    print(f"  {len(servers)} US servers found.\n")

    all_rows = []
    for server in servers:
        name = server.get("name", "?")
        url = server.get("url", "")
        try:
            meetings = fetch_meetings(url)
            rows = [
                to_row(m, name)
                for m in meetings
                if m.get("slug") and m.get("name")
            ]
            all_rows.extend(rows)
            print(f"  {name:<45} {len(rows):>5} meetings")
        except Exception as exc:
            print(f"  {name:<45} FAILED ({exc})")
        time.sleep(1)  # be polite to each server

    # Drop exact-duplicate slugs (some servers overlap)
    seen = set()
    unique_rows = []
    for row in all_rows:
        if row["meeting_guide_id"] not in seen:
            seen.add(row["meeting_guide_id"])
            unique_rows.append(row)

    print(f"\nTotal unique meetings to sync: {len(unique_rows)}")

    print("Upserting into Supabase...")
    count = upsert_rows(unique_rows)
    print(f"  {count} rows upserted.")

    print("Removing stale rows (not seen in 45 days)...")
    removed = delete_stale_rows()
    print(f"  {removed} stale rows removed.")

    print("\nDone.")


if __name__ == "__main__":
    main()
