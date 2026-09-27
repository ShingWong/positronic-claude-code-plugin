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