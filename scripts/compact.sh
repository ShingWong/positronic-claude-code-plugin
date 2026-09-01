#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# PreCompact: prune the episode then record a consolidation marker.
set -u
python3 -m positronic_ai prune --json >/dev/null 2>&1 || true
python3 -m positronic_ai consolidate "session compacted" --arousal 0.2 >/dev/null 2>&1 || true