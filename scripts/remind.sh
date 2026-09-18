#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# SessionStart (matcher "compact"): reintroduce the brain-first rule after a
# compaction, via hookSpecificOutput.additionalContext.
#
# Anti-clutter design (mirrors the opencode-plugin bounded reminder):
# - Fires ONCE per compaction (SessionStart/source=compact), not per turn, so
#   there is no repeated injection for the model to echo.
# - This script is READ-ONLY: it never calls `positronic_ai ingest`, so the
#   reminder text itself can never be written into the brain. The ingest
#   hooks only capture the `prompt` / `last_assistant_message` fields, which
#   additionalContext never populates — the rule reaches the model without
#   entering stored memory unless the model itself quotes it.
# - Any other source (startup/resume/clear/fork) exits silently.
set -u
payload="$(cat)"
source="$(printf '%s' "$payload" | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("source",""))
except Exception: print("")' 2>/dev/null)"
if [ "${source:-}" = "compact" ]; then
  python3 -c 'import json
print(json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart",
  "additionalContext": "Memory rule: query the positronic brain first "
  "(slash /recall, /ask, or: python3 -m positronic_ai recall \"<topic>\" --json) "
  "before answering project questions — do not re-derive from files what "
  "the brain already holds."}}))'
fi
exit 0
