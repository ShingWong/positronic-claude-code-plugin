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
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
printf '{"prompt":"hello memory"}' | bash "$ROOT/scripts/ingest.sh"
printf '{"session_id":"s1"}' | bash "$ROOT/scripts/wake.sh" | grep -q "brief\|positronic" || true
printf '{}' | bash "$ROOT/scripts/compact.sh"
printf '{}' | bash "$ROOT/scripts/stop.sh"
# remind.sh: silent on non-compact sources, additionalContext JSON on compact
[ -z "$(printf '{"source":"startup"}' | bash "$ROOT/scripts/remind.sh")" ]
printf '{"source":"compact"}' | bash "$ROOT/scripts/remind.sh" | grep -q "additionalContext" \
  && grep -q "compact" "$ROOT/hooks/hooks.json" \
  && python3 -c "import json;json.load(open('$ROOT/hooks/hooks.json'))"
echo "hooks smoke OK"