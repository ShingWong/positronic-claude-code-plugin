#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# Stop: ingest the assistant's final response (role=assistant). If the payload
# carries no text (e.g. no final message at Stop time), fall back to a turn
# boundary marker. Never blocks shutdown.
set -u
payload="$(cat)"
last="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("last_assistant_message",""))
except Exception: print("")' 2>/dev/null)"
if [ -n "${last:-}" ]; then
  python3 -m positronic_ai ingest "$last" --arousal 0.5 --role assistant >/dev/null 2>&1 || true
else
  python3 -m positronic_ai consolidate "turn boundary" --arousal 0.2 >/dev/null 2>&1 || true
fi