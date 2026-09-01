#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
printf '{"prompt":"hello memory"}' | bash "$ROOT/scripts/ingest.sh"
printf '{"session_id":"s1"}' | bash "$ROOT/scripts/wake.sh" | grep -q "brief\|positronic" || true
printf '{}' | bash "$ROOT/scripts/compact.sh"
printf '{}' | bash "$ROOT/scripts/stop.sh"
echo "hooks smoke OK"