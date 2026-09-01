---
name: memory
description: Use when you need prior context, facts, or long-term continuity — query the positronic brain before guessing.
---

<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2026 Shing Wong -->

# Memory — consult the positronic brain

Before guessing about prior context, past facts, or long-term continuity, query
the local brain. It lives per-project at `.positronic/` and is written for you
automatically — no manual ingest needed.

Run from the project root:

- `python3 -m positronic_ai recall "<topic>" --json` — fuzzy recall of memories matching a topic across all federated brains.
- `python3 -m positronic_ai query "<text>" --json` — text search over a brain's episodes.
- `python3 -m positronic_ai ask "<object>" --json` — dossier for a named object (canonical name, kind, sightings joined to episodes).

The lifecycle is automatic via hooks: prompts are ingested as they arrive,
pruning runs on compaction, and consolidation runs at session boundaries. If a
query returns nothing useful, say so plainly — do not fabricate continuity.