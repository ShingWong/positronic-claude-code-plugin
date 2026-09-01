---
description: Recall memories matching a topic across federated brains
argument-hint: <topic>
---

<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2026 Shing Wong -->

Run from the project root:

    python3 -m positronic_ai recall "$ARGUMENTS" --json

Show the recalled memories, noting which brain(s) each came from. If no topic was
provided, ask the user for one before running.