---
description: Ask the positronic brain for a dossier on an object or subject
argument-hint: <object>
---

<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2026 Shing Wong -->

Run from the project root:

    python3 -m positronic_ai ask "$ARGUMENTS" --json

Show the object dossier: canonical name, kind, status, salience, and sightings
joined to episodes. If no object was provided, ask the user for one before
running.