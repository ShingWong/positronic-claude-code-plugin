#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Shing Wong
#
# One-line installer for the positronic Claude Code plugin.
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/ShingWong/positronic-claude-code-plugin/main/install.sh)"
#
# Idempotent and non-interactive: safe to run any number of times.
set -euo pipefail

PAI_URL="git+https://github.com/ShingWong/positronic-agent-interface.git"

# Step 1: install PAI (best-effort). PAI may already be present, and pip
# policy differs per platform (PEP-668 on Debian/Ubuntu), so try --user then
# --break-system-packages and never hard-fail on any of them.
pip install "$PAI_URL" 2>/dev/null \
  || pip install --user "$PAI_URL" 2>/dev/null \
  || python3 -m pip install --break-system-packages "$PAI_URL" 2>/dev/null \
  || true

# Step 2: symlink the plugin into ~/.claude/skills so Claude Code auto-loads
# it as a @skills-dir plugin. The plugin source is resolved by cloning into a
# stable location, NOT via "$0": under the curl-pipe one-liner "$0" is "bash",
# so dirname "$0" resolves to the user's CWD (which has no plugin.json).
# CLAUDE_PLUGIN_ROOT overrides the location for local dev (used as-is).
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$HOME/.local/share/positronic/claude-code-plugin}"

if [ -z "${CLAUDE_PLUGIN_ROOT:-}" ]; then
  if [ ! -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
    if ! git clone --depth 1 https://github.com/ShingWong/positronic-claude-code-plugin.git "$PLUGIN_DIR"; then
      echo "positronic: warning — could not clone the plugin to $PLUGIN_DIR (network?). Hooks will not load." >&2
    fi
  fi
fi

# Real-path guard: a missing/broken plugin must never report silent success.
if [ ! -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
  echo "positronic: warning — no plugin found at $PLUGIN_DIR (missing .claude-plugin/plugin.json). Hooks will not load." >&2
fi

mkdir -p "$HOME/.claude/skills"
ln -sfn "$PLUGIN_DIR" "$HOME/.claude/skills/positronic"

# Step 3: verify PAI is callable (non-fatal — warn and continue).
if python3 -m positronic_ai info --json; then
  echo "positronic: PAI verified."
else
  echo "positronic: warning — 'python3 -m positronic_ai info --json' failed (PAI missing or broken). Re-run this installer after fixing pip, or install PAI manually." >&2
fi

echo "Installed. Restart Claude Code or run /reload-plugins."