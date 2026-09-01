#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# PreCompact: prune the episode then record a content-carrying consolidation
# marker composed from engram's own anchors + object graph (reuse, no new
# verb). Falls back to the bare marker when the span has no anchors.
set -u
python3 -m positronic_ai prune --json >/dev/null 2>&1 || true
payload="$(python3 - <<'PY'
import json, subprocess

def q(sql):
    r = subprocess.run(["python3", "-m", "positronic_ai", "query", "--sql", sql, "--json"],
                       capture_output=True, text=True)
    try:
        return json.loads(r.stdout)
    except Exception:
        return {}

anchors = q("SELECT json_extract(features_json,'$.body_text') t FROM episode WHERE is_anchor=1 AND kind='message' ORDER BY tau DESC LIMIT 4")
objs = q("SELECT canonical_name FROM object ORDER BY COALESCE(last_seen_tau,first_seen_tau) DESC LIMIT 8")
frags = [r.get("t") for r in anchors.get("results", []) if r.get("t")]
names = [r.get("canonical_name") for r in objs.get("results", []) if r.get("canonical_name")]
if not frags:
    print("session compacted")
else:
    text = " | ".join(frags[:4])
    if names:
        text += " objects: " + ", ".join(names[:8])
    print(text[:1000])
PY
)"
if [ -n "$payload" ]; then
  python3 -m positronic_ai consolidate "$payload" --arousal 0.3 >/dev/null 2>&1 || true
fi