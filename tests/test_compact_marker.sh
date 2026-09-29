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
# PreCompact marker composition: compact.sh must write a content-carrying
# consolidation episode (anchor body_text + objects), not the bare id.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$(mktemp -d)"
trap 'rm -rf "$DIR"' EXIT
cd "$DIR"
# memeng reaches this test as a declared dependency of positronic_ai, so there
# is normally nothing to add. Only fall back to a sibling engram checkout when
# memeng genuinely will not import. No absolute default: a path baked into a
# published repository works only on the machine that wrote it and discloses
# that machine's directory layout.
if ! python3 -c 'import memeng' >/dev/null 2>&1; then
  for _root in "${POSITRONIC_WORKSPACE:-}" "$ROOT/.."; do
    [ -n "$_root" ] || continue
    if [ -d "$_root/positronic-engram/engine/src/memeng" ]; then
      export PYTHONPATH="${PYTHONPATH:-}:$_root/positronic-engram/engine/src"
      break
    fi
  done
fi

python3 -m positronic_ai init --brain kairos --profile balanced --embed lexical >/dev/null 2>&1
python3 -m positronic_ai ingest "decided: ship the prune fix to main on web2" --arousal 1.0 >/dev/null 2>&1

printf '{}' | bash "$ROOT/scripts/compact.sh"

marker="$(python3 -m positronic_ai query --sql "SELECT subject_norm FROM episode WHERE kind='consolidation' ORDER BY tau DESC LIMIT 1" --json 2>/dev/null | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(d.get('results',[{}])[0].get('subject_norm',''))")"

if [ -z "$marker" ]; then
  echo "FAIL: no consolidation episode written" >&2
  exit 1
fi
if [ "$marker" = "session compacted" ]; then
  echo "FAIL: marker is the bare id, not composed content" >&2
  exit 1
fi
case "$marker" in
  *"ship the prune fix to main"*) ;;
  *) echo "FAIL: marker lacks anchor body_text: $marker" >&2; exit 1 ;;
esac
case "$marker" in
  *"objects:"*) ;;
  *) echo "FAIL: marker lacks object names: $marker" >&2; exit 1 ;;
esac
echo "compact marker OK: $marker"