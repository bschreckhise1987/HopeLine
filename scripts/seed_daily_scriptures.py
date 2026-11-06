#!/usr/bin/env python3
"""
HopeLine daily scripture seeder.

Populates the `daily_scriptures` table with a curated starter set
of recovery-oriented Scriptures. The verse text is fetched live
from bible-api.com (free, no key) so every verse is verified
against the source — never hand-typed.

Safe to re-run: verses already in the table (matched by
verse_reference) are skipped, so nothing is duplicated.

Usage:
    export SUPABASE_URL="https://your-project.supabase.co"
    export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
    python3 seed_daily_scriptures.py
"""

import os
import time
import sys
import requests

SUPABASE_URL = os.environ.get("SUPABASE_URL", "").rstrip("/")
SUPABASE_SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")

if not SUPABASE_URL or not SUPABASE_SERVICE_ROLE_KEY:
    sys.exit("Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY first.")

# Each entry: the reference, a short prayer, and a reflection
# prompt. The verse text is fetched from the Bible API at seed
# time so it always matches the published translation.
SCRIPTURES = [
    # --- Anxious or Afraid ---
    ("Philippians 4:6-7",
     "Lord, I bring You everything that's racing through my mind right now. Quiet my heart and guard it with Your peace. Amen.",
     "What is one worry you have been carrying that you could hand over today?"),
    ("Isaiah 41:10",
     "Father, I feel weak and afraid. Remind me that You are with me and You will hold me up. Amen.",
     "Where in your recovery do you most need to feel God's presence right now?"),
    ("Psalm 56:3",
     "God, when I am afraid, I choose to trust You — even with the fear that feels too big to name. Amen.",
     "What is one fear you could trust God with for just today?"),
    ("1 Peter 5:7",
     "Lord, You know how heavy this is. I'm setting it down at Your feet because You care about me. Amen.",
     "What burden have you been carrying alone that was never yours to hold?"),
    ("Matthew 11:28-30",
     "Jesus, I am tired and worn out. Teach me to rest in You instead of pushing through on my own. Amen.",
     "What would it look like to actually rest today instead of just surviving?"),

    # --- Tempted or Craving ---
    ("1 Corinthians 10:13",
     "Lord, when the urge feels stronger than me, open my eyes to the way out You always provide. Amen.",
     "What has been your way out in the past, and how can you reach for it sooner today?"),
    ("Hebrews 2:18",
     "Father, You were tempted and You understand. Help me in this exact moment of struggle. Amen.",
     "What is one small, practical step you can take in the next ten minutes?"),
    ("Psalm 119:11",
     "God, I'm putting Your words in my heart today so they're there when I need them most. Amen.",
     "What is one truth or verse you could keep ready for the moment temptation hits?"),
    ("Matthew 26:41",
     "Lord, keep me awake to what's really going on inside me today, so I'm not caught off guard. Amen.",
     "What situation, time of day, or feeling most often catches you off guard?"),
    ("James 4:7",
     "God, I can't do this alone — but I can stand close to You and let You do the fighting. Amen.",
     "Who or what helps you stay close to God when you're under pressure?"),

    # --- Ashamed or Guilty ---
    ("1 John 1:9",
     "Father, I'm not hiding anymore. I confess it all to You and receive Your forgiveness. Amen.",
     "What have you been afraid to bring into the light, even with God?"),
    ("Psalm 103:12",
     "Lord, thank You for removing my failures as far as the east is from the west. Help me believe it. Amen.",
     "Why is it easier to hold onto guilt than to accept forgiveness?"),
    ("Romans 8:1",
     "God, silence the voice of condemnation in my head with the truth that I am in Christ. Amen.",
     "Whose voice does your shame sound like — and what does God's voice actually say?"),
    ("Psalm 51:10",
     "Create in me a clean heart, O God, and renew a right spirit within me. Amen.",
     "What is one area of your life where you're asking God to do a new work?"),
    ("2 Corinthians 5:17",
     "Lord, thank You that my past does not define me. I am being made new. Amen.",
     "What old identity are you still carrying that God has already replaced?"),

    # --- Lonely or Isolated ---
    ("Psalm 23:4",
     "Lord, even in the darkest valley, You are with me. I am not walking alone. Amen.",
     "Where have you felt God's presence in a dark season before?"),
    ("Deuteronomy 31:8",
     "Father, You go ahead of me and You stand beside me. I will not be shaken or abandoned. Amen.",
     "What would change today if you believed God was already in the room?"),
    ("Hebrews 13:5",
     "God, when people leave or let me down, remind me that You never will. Amen.",
     "What loss or goodbye makes loneliness feel sharpest right now?"),
    ("Zephaniah 3:17",
     "Lord, You are with me and You rejoice over me. Let that be louder than my loneliness. Amen.",
     "How does it feel to picture God rejoicing over you specifically?"),
    ("Psalm 68:6",
     "Father, You set the lonely in families. Lead me to the people You have prepared for me. Amen.",
     "Who is one safe person you could reach out to this week?"),

    # --- Discouraged ---
    ("Galatians 6:9",
     "God, I'm tired of doing right when it feels like nothing is changing. Renew my hope. Amen.",
     "What harvest might be growing in your life that you can't see yet?"),
    ("Isaiah 40:31",
     "Lord, I'm exhausted. Be my strength today so I can keep going without burning out. Amen.",
     "What does resting in God's strength look like instead of pushing in yours?"),
    ("Jeremiah 29:11",
     "Father, my future feels uncertain, but You already see it. Give me hope for what's ahead. Amen.",
     "What is one hopeful thing about your future you can name out loud today?"),
    ("2 Corinthians 4:16",
     "God, even as things wear down on the outside, renew me on the inside day by day. Amen.",
     "What is one sign of inner growth in you that others might not see?"),
    ("Lamentations 3:22-23",
     "Lord, thank You that Your compassion never runs out and Your mercies are new this morning. Amen.",
     "What happened yesterday that you need to let be covered by today's new mercy?"),

    # --- Grateful ---
    ("1 Thessalonians 5:16-18",
     "Father, open my eyes to Your gifts today and turn my complaining into gratitude. Amen.",
     "What are three things — big or small — you can thank God for right now?"),
    ("Psalm 118:24",
     "Lord, this day is a gift. Help me live it with joy instead of just getting through it. Amen.",
     "What is one thing you would miss about today if it were your last?"),
    ("Romans 15:13",
     "God, fill me with hope and joy and peace today so I can overflow into the people around me. Amen.",
     "Who in your life needs the hope you've been finding?"),
    ("Psalm 107:1",
     "Father, thank You for being good and for loving me enough to bring me this far. Amen.",
     "What is one story from your recovery that you need to remember to thank God for?"),
    ("Jeremiah 17:14",
     "Lord, You are my healer. Heal me — in body, mind, and spirit — and I will praise You. Amen.",
     "What kind of healing are you asking God for most right now?"),
]


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

    # Skip verses already seeded so re-runs are safe
    existing = requests.get(
        f"{SUPABASE_URL}/rest/v1/daily_scriptures?select=verse_reference",
        headers=headers,
        timeout=30,
    )
    existing.raise_for_status()
    already_there = {
        row["verse_reference"] for row in existing.json()
    }
    print(f"{len(already_there)} verses already in the table.\n")

    inserted = 0
    for reference, prayer, prompt in SCRIPTURES:
        if reference in already_there:
            print(f"  SKIP  {reference} (already exists)")
            continue

        # Pause between Bible API calls to stay within
        # its free rate limits
        time.sleep(2)

        try:
            verse_text = fetch_verse_text(reference)
        except Exception as exc:
            print(f"  FAIL  {reference}: {exc}")
            continue

        resp = requests.post(
            f"{SUPABASE_URL}/rest/v1/daily_scriptures",
            headers=headers,
            json={
                "verse_reference": reference,
                "verse_text": verse_text,
                "prayer": prayer,
                "reflection_prompt": prompt,
            },
            timeout=30,
        )
        if resp.status_code in (200, 201):
            inserted += 1
            print(f"  OK    {reference}")
        else:
            print(f"  FAIL  {reference} ({resp.status_code}): {resp.text[:200]}")

    print(f"\nDone. {inserted} new verses inserted. "
          f"Table now holds {len(already_there) + inserted} total.")


if __name__ == "__main__":
    main()
