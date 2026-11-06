#!/usr/bin/env python3
"""
HopeLine nationwide meeting sync.

Pulls every published NA meeting from the US BMLT root servers
(free, no API key) in the open Meeting Guide JSON format, then upserts
them into the Supabase `meetings` table and removes stale rows.

Usage:
    export SUPABASE_URL="https://your-project.supabase.co"
    export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
    python3 sync_meetings.py

Run it once to seed the table, then re-run weekly to stay current
(venues move, meetings close). Can be automated free with a
GitHub Actions scheduled workflow.

Note: a few root servers sit behind bot-protection pages that
occasionally reject scripted requests. Those servers are logged as
FAILED and skipped — just re-run the script later; the upsert makes
re-runs safe.
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
    "100",  # Texas, Louisiana, Mississippi, Arkansas
    "101",  # Metro Richmond (VA/DC)
    "102",  # Greater New York
    "103",  # Southern California Region
    "105",  # Greater Philadelphia Region
    "106",  # Ohio Region
    "116",  # NA Hawai'i
    "117",  # San Jose Area
    "119",  # Wisconsin Region
    "120",  # NA New Jersey
    "121",  # Connecticut Region
    "122",  # Volunteer Region (Tennessee)
    "127",  # Michigan NA
    "129",  # NA Minnesota
    "131",  # NA Colorado
    "134",  # New England
    "135",  # Show-Me Region (Missouri)
    "137",  # Southeastern Zonal Forum
    "138",  # NA Kentucky
    "141",  # Plains States Zonal Forum
    "147",  # Greater Illinois Region
    "152",  # Western States Zonal Forum
    "153",  # Tri-State Region
    "154",  # Indiana Region
    "155",  # Montana Region
    "157",  # Chicagoland Region
    "164",  # NA Utah
}

BATCH_SIZE = 500
STALE_AFTER_DAYS = 45
RETRY_PAUSE_SECONDS = 8   # pause before retrying a rate-limited server
REQUEST_HEADERS = {
    # BMLT servers reject the default python-requests user
    # agent with a 406, so identify ourselves instead
    "User-Agent": "HopeLine-Meeting-Sync/1.0 (student capstone project)",
}

WEEKDAYS = [
    "Sunday", "Monday", "Tuesday", "Wednesday",
    "Thursday", "Friday", "Saturday",
]

# ---------------------------------------------------------------------------
# Fetch servers
# ---------------------------------------------------------------------------


def fetch_us_servers():
    resp = requests.get(SERVER_LIST_URL, timeout=30, headers=REQUEST_HEADERS)
    resp.raise_for_status()
    servers = json.loads(resp.text)
    # ids may arrive as strings or ints depending on the source,
    # so normalize before comparing
    return [
        s for s in servers
        if str(s.get("id", "")) in US_SERVER_IDS
    ]


# ---------------------------------------------------------------------------
# Fetch + transform meetings
# ---------------------------------------------------------------------------


def _get_json(url):
    """GET a URL, retrying once if the server returns an HTML
    'one moment please' interstitial instead of JSON."""
    for attempt in (1, 2):
        resp = requests.get(url, timeout=120, headers=REQUEST_HEADERS)
        resp.raise_for_status()
        if resp.text.lstrip().startswith("["):
            return resp.json()
        if attempt == 1:
            time.sleep(RETRY_PAUSE_SECONDS)
    raise RuntimeError("server returned an HTML page instead of JSON "
                       "(bot protection or outage)")


def fetch_meetings(root_url):
    """All meetings from one root server.

    Tries the Meeting Guide (TSML) format first — the same format the
    HopeLine app uses. Older root servers don't support it, so it falls
    back to the standard BMLT JSON format and converts the fields.
    """
    base = root_url.rstrip("/")

    try:
        return _get_json(
            base + "/client_interface/tsml/?switcher=GetSearchResults"
        ), "tsml"
    except Exception:
        pass

    return _get_json(
        base + "/client_interface/json/?switcher=GetSearchResults"
    ), "bmlt"


def _hhmm(value):
    """'19:30:00' -> '19:30'; returns None if unusable."""
    if not value:
        return None
    parts = value.split(":")
    return ":".join(parts[:2]) if len(parts) >= 2 else value


def _end_time(start_time, duration):
    """'19:30' + '01:15:00' -> '20:45'"""
    if not start_time or not duration:
        return None
    try:
        h, m = (int(x) for x in start_time.split(":")[:2])
        dh, dm = (int(x) for x in duration.split(":")[:2])
        total = (h * 60 + m + dh * 60 + dm) % (24 * 60)
        return f"{total // 60:02d}:{total % 60:02d}"
    except (ValueError, ZeroDivisionError):
        return None


def to_row(meeting, server_id, fmt):
    """Map one meeting record (either format) to one Supabase row."""
    if fmt == "tsml":
        # Meeting Guide JSON format
        coordinates = meeting.get("coordinates") or ""
        lat, lng = None, None
        if "," in coordinates:
            try:
                lat_s, lng_s = coordinates.split(",", 1)
                lat, lng = float(lat_s), float(lng_s)
            except ValueError:
                pass

        day = meeting.get("day")
        slug = meeting.get("slug") or ""
        # slugs are generated as {name-slug}-{meeting id}; prefix the
        # server id so ids stay unique across servers and stable across
        # endpoint formats
        meeting_id = slug.rsplit("-", 1)[-1] if slug else ""
        conference_url = meeting.get("conference_url")

        return {
            "meeting_guide_id": f"na-{server_id}-{meeting_id}" if meeting_id else None,
            "name": meeting.get("name"),
            "address": meeting.get("address"),
            "city": meeting.get("city"),
            "state": meeting.get("state"),
            "postal_code": meeting.get("postal_code"),
            "country": meeting.get("country"),
            "latitude": lat,
            "longitude": lng,
            "meeting_type": "NA",
            "meeting_day": WEEKDAYS[day] if isinstance(day, int) and 0 <= day <= 6 else None,
            "meeting_time": _hhmm(meeting.get("time")),
            "end_time": _hhmm(meeting.get("end_time")),
            "types": ",".join(meeting.get("types") or []),
            "is_online": bool(conference_url),
            "online_url": conference_url,
            "last_updated": datetime.now(timezone.utc).isoformat(),
        }

    # Standard BMLT JSON format
    def _num(value):
        try:
            return float(value) if value not in (None, "") else None
        except (TypeError, ValueError):
            return None

    try:
        weekday = int(meeting.get("weekday_tinyint", 0))
        day_index = weekday - 1 if 1 <= weekday <= 7 else None
    except (TypeError, ValueError):
        day_index = None

    start = _hhmm(meeting.get("start_time"))
    virtual_link = meeting.get("virtual_meeting_link")

    return {
        "meeting_guide_id": f"na-{server_id}-{meeting.get('id_bigint')}",
        "name": meeting.get("meeting_name"),
        "address": meeting.get("location_street"),
        "city": meeting.get("location_municipality"),
        "state": meeting.get("location_province"),
        "postal_code": meeting.get("location_postal_code_1"),
        "country": meeting.get("location_nation"),
        "latitude": _num(meeting.get("latitude")),
        "longitude": _num(meeting.get("longitude")),
        "meeting_type": "NA",
        "meeting_day": WEEKDAYS[day_index] if day_index is not None else None,
        "meeting_time": start,
        "end_time": _end_time(start, meeting.get("duration_time")),
        "types": meeting.get("formats"),
        "is_online": bool(virtual_link) or meeting.get("venue_type") in ("2", "3"),
        "online_url": virtual_link or None,
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
    failed_servers = []
    for server in servers:
        name = server.get("name", "?")
        server_id = str(server.get("id", ""))
        url = server.get("url", "")
        try:
            meetings, fmt = fetch_meetings(url)
            rows = [
                to_row(m, server_id, fmt)
                for m in meetings
                if m.get("name") or m.get("meeting_name")
            ]
            # drop rows without a usable id
            rows = [r for r in rows if r["meeting_guide_id"]]
            all_rows.extend(rows)
            print(f"  {name:<45} {len(rows):>5} meetings  ({fmt})")
        except Exception as exc:
            failed_servers.append(name)
            print(f"  {name:<45} FAILED ({exc})")
        time.sleep(1)  # be polite to each server

    print(f"\nTotal meetings to sync: {len(all_rows)}")

    print("Upserting into Supabase...")
    count = upsert_rows(all_rows)
    print(f"  {count} rows upserted.")

    print("Removing stale rows (not seen in 45 days)...")
    removed = delete_stale_rows()
    print(f"  {removed} stale rows removed.")

    if failed_servers:
        print(f"\n{len(failed_servers)} server(s) failed and were skipped:")
        for name in failed_servers:
            print(f"  - {name}")
        print("Re-run the script later to pick them up — "
              "upserts make re-runs safe.")

    print("\nDone.")


if __name__ == "__main__":
    main()
