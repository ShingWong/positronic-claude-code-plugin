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

## Memory lifecycle: compaction-driven

Forgetting and summarization run on Claude Code's **compaction event**, not on
a timer or prompt counter. When a session compacts (context summarized away),
the `PreCompact` hook fires and:

1. **prunes** the brain — τ-decay demotes/expires episodes per the retention
   profile (`positronic_ai prune`), and
2. writes a **consolidation marker** — a `kind='consolidation'` episode
   (`positronic_ai consolidate "session compacted"`).

This is the primary lifecycle. It costs nothing when nothing compacts, and it
fires exactly when old context is summarized away — the natural era boundary
for forgetting and for a summary marker.

**Why automatic prune/consolidate counters are disabled by default.** PAI's
counter-based auto-triggers (`auto.consolidate_every` / `auto.prune_every`)
are an *opt-in fallback* for sessions that never compact (long-running,
low-churn context). They are off by default (`0`) because the compaction hook
already covers the normal case, and a blind counter would fire regardless of
whether an actual era boundary occurred. Enable them only if you want a
fixed-cadence fallback:

```bash
positronic config consolidate_every 300
positronic config prune_every 1000
```

(`0` disables either.)

**Dedup.** `ingest.sh` passes `--dedup`, so a repeated user prompt is skipped
(string-compare against the last episode) instead of re-ingesting itself into
the brain.

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

## CLAUDE.md setup (recommended)

The hooks ingest and prune automatically, but the model only *retrieves* if
something tells it to. Add one rule to your project's `CLAUDE.md` so it
reaches for the brain instead of re-deriving:

```markdown
## Memory

This project has a polytemporal memory brain (`.positronic/`). Before
answering about prior work, decisions, or history, run
`python -m positronic_ai recall "<topic>" --json` and use the results.
Don't guess from scratch — recall is milliseconds.
```

The bundled `memory` skill teaches the same behavior on demand. Retrieval is
single-digit milliseconds; the setup is one rule. A fuller worked example
(including subagent coverage and a plan-docs step) is in the
[positronic-agent-interface README](https://github.com/ShingWong/positronic-agent-interface).

## Privacy

`.positronic/` holds brain state and may contain PII. It is git-ignored and
must never be committed.