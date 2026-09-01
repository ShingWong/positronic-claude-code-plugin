#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
set -u
payload="$(cat)"
prompt="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("prompt",""))
except Exception: print("")' 2>/dev/null)"
if [ -n "${prompt:-}" ]; then
  python3 -m positronic_ai ingest "$prompt" --arousal 0.5 >/dev/null 2>&1 || true
fi