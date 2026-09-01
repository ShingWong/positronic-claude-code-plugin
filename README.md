<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2026 Shing Wong -->

# positronic-claude-code-plugin

Polytemporal memory for Claude Code. This plugin wires Claude Code lifecycle
hooks into the `positronic_ai` Python package (PAI CLI), giving each session
wake/ingest/prune/consolidate behavior backed by a local brain at
`.positronic/brains/{name}/memory.db`.

The plugin is GPL-3.0-or-later. See `LICENSE`.

## Hooks

Hooks are shell commands resolved from `${CLAUDE_PLUGIN_ROOT}` (never absolute
paths). Each script reads the hook JSON payload on stdin and exits 0 even on
failure so Claude Code is never blocked.

| Hook              | Script              | Behavior                                                            |
|-------------------|---------------------|---------------------------------------------------------------------|
| `SessionStart`    | `scripts/wake.sh`   | `positronic_ai wake --json` — prints the brief to stdout            |
| `UserPromptSubmit`| `scripts/ingest.sh` | extracts `prompt` from JSON → `positronic_ai ingest ... --arousal 0.5` |
| `PreCompact`      | `scripts/compact.sh`| `positronic_ai prune --json` + `consolidate "session compacted"`     |
| `Stop`            | `scripts/stop.sh`   | `consolidate "turn boundary" --arousal 0.2`                          |

## Install

> One line:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ShingWong/positronic-claude-code-plugin/main/install.sh)"
```

Preflight: `python3` and `pip` on PATH (Debian/Ubuntu usually need
`python3-pip`; the installer falls back to `--user` then
`--break-system-packages` for PEP-668 hosts).

What it does:

1. Installs the `positronic_ai` (PAI) package from GitHub — best-effort, skips
   cleanly if already present.
2. Symlinks this plugin into `~/.claude/skills/positronic` so Claude Code
   auto-loads it as a `@skills-dir` plugin.
3. Verifies with `python3 -m positronic_ai info --json`.

Uninstall:

```bash
rm ~/.claude/skills/positronic
```

(Optionally `pip uninstall positronic-agent-interface` to remove PAI itself.)

Manual install: place this repo (or a checkout) somewhere permanent and add the
plugin via Claude Code's plugin mechanism pointing at the repo root containing
`.claude-plugin/plugin.json`.

## Layout

```
positronic-claude-code-plugin/
  .claude-plugin/plugin.json      # manifest (name, version, license)
  hooks/hooks.json                # lifecycle hooks
  scripts/                        # hook handlers (shell, chmod +x)
  tests/hooks_smoke.sh            # smoke test
  LICENSE  README.md  AGENTS.md  .gitignore
```

## Privacy

`.positronic/` holds brain state and may contain PII. It is git-ignored and
must never be committed.