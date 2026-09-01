#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# SessionStart: wake the brain and print the brief so Claude sees it.
set -u
out="$(python3 -m positronic_ai wake --json 2>/dev/null)" || out=""
if [ -n "$out" ]; then
  printf '%s\n' "$out"
else
  printf 'positronic: wake unavailable (brain not seeded or PAI absent)\n'
fi
exit 0