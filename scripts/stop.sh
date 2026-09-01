#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
# Stop: record a turn boundary marker. Never blocks shutdown.
set -u
python3 -m positronic_ai consolidate "turn boundary" --arousal 0.2 >/dev/null 2>&1 || true