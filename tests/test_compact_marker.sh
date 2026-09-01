#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# PreCompact marker composition: compact.sh must write a content-carrying
# consolidation episode (anchor body_text + objects), not the bare id.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$(mktemp -d)"
trap 'rm -rf "$DIR"' EXIT
cd "$DIR"
export PYTHONPATH="${PYTHONPATH:-}:/usr/local/devel/positronic/positronic-engram/engine/src"

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