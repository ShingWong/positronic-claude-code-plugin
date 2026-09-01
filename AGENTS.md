<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2026 Shing Wong -->

# AGENTS.md — positronic-claude-code-plugin

Claude Code plugin for the positron brain. Every file is GPL-3.0-or-later
(see `LICENSE`; JSON/markdown carry the license note here or in the manifest).

## Layout

```
positronic-claude-code-plugin/
  .claude-plugin/plugin.json      # manifest (name, version, license)
  hooks/hooks.json                # lifecycle hooks
  scripts/                        # hook handlers (shell, chmod +x)
  tests/hooks_smoke.sh            # smoke test
  LICENSE  README.md  AGENTS.md  .gitignore
```

## Hooks table

| Hook              | Script              | Behavior                                                            |
|-------------------|---------------------|---------------------------------------------------------------------|
| `SessionStart`    | `scripts/wake.sh`   | `positronic_ai wake --json` — prints the brief to stdout            |
| `UserPromptSubmit`| `scripts/ingest.sh` | extracts `prompt` → `positronic_ai ingest ... --role user --dedup`   |
| `PreCompact`      | `scripts/compact.sh`| `positronic_ai prune --json` + `consolidate "session compacted"`     |
| `Stop`            | `scripts/stop.sh`   | `positronic_ai ingest "last_assistant_message" --role assistant` (fallback: `consolidate "turn boundary"`) |
| `SubagentStop`    | `scripts/subagent_stop.sh` | ingests subagent `last_assistant_message` (role=assistant, `[agent_type]` prefix) |

Hooks are shell commands; scripts resolve everything via `${CLAUDE_PLUGIN_ROOT}`
and read the hook JSON payload on stdin. They must never block or fail the host
— all `positronic_ai` calls are `|| true`.

## PII

`.positronic/` contains brain state and may include PII — it is git-ignored.
Never commit it.

## Test

```bash
bash tests/hooks_smoke.sh
```

Feeds synthetic hook JSON to each script and asserts exit 0 (and non-empty
stdout for `wake`). Requires a seeded brain or PAI present for full behavior;
the `|| true` guards make it pass regardless, printing `hooks smoke OK`.