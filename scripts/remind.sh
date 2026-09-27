#!/usr/bin/env bash
# =====================================================================
# Project Positronic — Polytemporal Cognitive Engram Memory Substrate
# Copyright (C) 2026 Shing Wong. All Rights Reserved.
# =====================================================================
# This program is DUAL-LICENSED. You may redistribute and/or modify it 
# under the terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your 
# option) any later version.
#
# Alternatively, commercial entities, multi-tenant instances, and Managed 
# Service Providers (MSPs) may utilize this program under a separate, 
# proprietary Commercial License Waiver issued directly by the copyright 
# holder, completely exempt from the network-use copyleft restrictions of 
# the AGPLv3 Section 13.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with this program. If not, see <https://gnu.org>.
# =====================================================================
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
