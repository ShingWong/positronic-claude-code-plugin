#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# SubagentStop: ingest the subagent's final response (role=assistant), tagged
# with the agent type in the subject. Never blocks the host.
set -u
payload="$(cat)"
last="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("last_assistant_message",""))
except Exception: print("")' 2>/dev/null)"
atype="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("agent_type","subagent"))
except Exception: print("subagent")' 2>/dev/null)"
if [ -n "${last:-}" ]; then
  python3 -m positronic_ai ingest "[$atype] $last" --arousal 0.4 --role assistant >/dev/null 2>&1 || true
fi