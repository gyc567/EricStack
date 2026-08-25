---
name: EricStack Overview
created: 2026-08-15
updated: 2026-08-25
---

# EricStack Overview

EricStack is an AI-native engineering loop system built on LoopX. It provides 46 skills covering the full engineering lifecycle — from planning and code review to simplification, documentation, knowledge accumulation, and project-level persistent memory (mindmux/brain.md vendor).

## At a Glance

- **Skills:** 46 (13 process discipline + 32 engineering abilities + 1 router)
- **Knowledge:** Compounding wiki built with LLM Wiki pattern
- **Source repos:** deepseek-harness (process skills) + gstack (ability skills) + mindmux/brain.md (5 vendored ability skills, Apache-2.0)
- **Version:** [[.loopx/VERSION]]

## Core Principles

1. **Discipline over creativity** — process skills enforce rigor, not just suggest it
2. **Completeness** — do the full thing when AI makes marginal cost near zero
3. **Compounding knowledge** — every decision, review, and discussion becomes a wiki page
4. **No loss of context** — session state, checkpoints, and retro preserve continuity
5. **Project memory boundary** — `.loopx/wiki/` (EricStack metadata) and `BRAIN.md`+`brain/` (user project memory) are orthogonal; never confuse the two

## Key Workflows

```
idea → /office-hours → /spec → /plan-eng-review → /cso → /ship → /retro → wiki
                                                                              ↓
                                                                            /brain-ingest (project memory)
```

## Architecture

- [[purpose]] — project goals and key questions
- [[schema]] — wiki structure and conventions
- [[index]] — full content catalog

## Recent Changes

- `2026-08-25` — mindmux/brain.md vendor wired: 5 ability skills added (brain-init / brain-page / brain-bootstrap / brain-ingest / brain-setup); CLI on PATH via `brain` symlink; uninstaller is fail-closed on user project data. Catalog 38 → 46.
- `2026-08-15` — Initial release; the current catalog has 38 skills plus 2 installed entry points.
