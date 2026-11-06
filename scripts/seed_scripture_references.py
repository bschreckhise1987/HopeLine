#!/usr/bin/env python3
"""
HopeLine scripture theme seeder.

Populates the `scripture_references` table with Scripture
references for each recovery theme. The verse text is fetched
live from bible-api.com (free, no key) so every verse is
verified against the source — never hand-typed.

Safe to re-run: verses already in the table (matched by
theme + verse_reference) are skipped.

Usage:
    export SUPABASE_URL="https://your-project.supabase.co"
    export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
    python3 seed_scripture_references.py
"""

import os
import sys
import time
import requests

SUPABASE_URL = os.environ.get("SUPABASE_URL", "").rstrip("/")
SUPABASE_SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")

if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
    sys.exit("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY first.")

# References for each theme. The verse text is fetched from the
# Bible API at seed time so it always matches the published
# translation.
THEME_SCRIPTURES = {
    "anxious": [
        "Philippians 4:6-7",
        "Isaiah 41:10",
        "Psalm 56:3",
        "1 Peter 5:7",
        "Matthew 11:28-30",
        "John 14:27",
        "Psalm 94:19",
        "Proverbs 3:5-6",
        "Psalm 34:4",
        "1 John 4:18",
    ],
    "tempted": [
        "1 Corinthians 10:13",
        "Hebrews 2:18",
        "Psalm 119:11",
        "Matthew 26:41",
        "James 4:7",
        "Ephesians 6:11",
        "Hebrews 4:15-16",
        "Romans 6:14",
        "Galatians 5:16",
        "Psalm 119:105",
    ],
    "ashamed": [
        "1 John 1:9",
        "Psalm 103:12",
        "Romans 8:1",
        "Psalm 51:10",
        "2 Corinthians 5:17",
        "Isaiah 43:25",
        "Micah 7:19",
        "Hebrews 10:22",
        "Psalm 34:5",
        "Isaiah 61:3",
    ],
    "lonely": [
        "Psalm 23:4",
        "Deuteronomy 31:8",
        "Hebrews 13:5",
        "Zephaniah 3:17",
        "Psalm 68:6",
        "Psalm 25:16-17",
        "Isaiah 41:13",
        "Matthew 28:20",
        "Psalm 147:3",
        "Romans 8:38-39",
    ],
    "discouraged": [
        "Galatians 6:9",
        "Isaiah 40:31",
        "Jeremiah 29:11",
        "2 Corinthians 4:16",
        "Lamentations 3:22-23",
        "Psalm 42:11",
        "Joshua 1:9",
        "Proverbs 24:16",
        "Psalm 30:5",
        "Nehemiah 8:10",
    ],
    "grateful": [
        "1 Thessalonians 5:16-18",
        "Psalm 118:24",
        "Romans 15:13",
        "Psalm 107:1",
        "Jeremiah 17:14",
        "Psalm 100:4",
        "Colossians 3:15",
        "Psalm 9:1",
        "Ephesians 5:20",
        "Psalm 16:11",
    ],
}


def fetch_verse_text(reference):
    """Fetch verified verse text from the free Bible API."""
    url = f"https://bible-api.com/{requests.utils.quote(reference)}"
    resp = requests.get(
        url,
        timeout=30,
        # Identify ourselves so the API knows this is a
        # legitimate app seeder, not a script
        headers={"User-Agent": "HopeLine-Scripture-Seeder/1.0"},
    )
    resp.raise_for_status()
    data = resp.json()
    text = data.get("text", "").strip()
    if not text:
        raise RuntimeError(f"empty text for {reference}")
    return " ".join(text.split())


def main():
    headers = {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
        "Content-Type": "application/json",
    }

    # Skip (theme, reference) pairs already seeded so
    # re-runs are safe
    existing = requests.get(
        f"{SUPABASE_URL}/rest/v1/scripture_references"
        "?select=theme,verse_reference",
        headers=headers,
        timeout=30,
    )
    existing.raise_for_status()
    already_there = {
        (row["theme"], row["verse_reference"]) for row in existing.json()
    }
    print(f"{len(already_there)} theme verses already in the table.\n")

    inserted = 0
    for theme, references in THEME_SCRIPTURES.items():
        for sort_order, reference in enumerate(references):
            if (theme, reference) in already_there:
                print(f"  SKIP  {theme:<12} {reference} (already exists)")
                continue

            # Pause between Bible API calls to stay within
            # its free rate limits
            time.sleep(2)

            try:
                verse_text = fetch_verse_text(reference)
            except Exception as exc:
                print(f"  FAIL  {theme:<12} {reference}: {exc}")
                continue

            resp = requests.post(
                f"{SUPABASE_URL}/rest/v1/scripture_references",
                headers=headers,
                json={
                    "theme": theme,
                    "verse_reference": reference,
                    "verse_text": verse_text,
                    "sort_order": sort_order,
                },
                timeout=30,
            )
            if resp.status_code in (200, 201):
                inserted += 1
                print(f"  OK    {theme:<12} {reference}")
            else:
                print(f"  FAIL  {theme:<12} {reference} "
                      f"({resp.status_code}): {resp.text[:200]}")

    print(f"\nDone. {inserted} new theme verses inserted. "
          f"Table now holds {len(already_there) + inserted} total.")


if __name__ == "__main__":
    main()
