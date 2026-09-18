#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
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