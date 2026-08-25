---
name: EricStack Overview
created: 2026-08-15
updated: 2026-08-15
---

# EricStack Overview

EricStack is an AI-native engineering loop system built on LoopX. It provides 38 skills covering the full engineering lifecycle — from planning and code review to simplification, documentation, and knowledge accumulation.

## At a Glance

- **Skills:** 38 (13 process discipline + 24 engineering abilities + 1 router)
- **Knowledge:** Compounding wiki built with LLM Wiki pattern
- **Source repos:** deepseek-harness (process skills) + gstack (ability skills)
- **Version:** [[.loopx/VERSION]]

## Core Principles

1. **Discipline over creativity** — process skills enforce rigor, not just suggest it
2. **Completeness** — do the full thing when AI makes marginal cost near zero
3. **Compounding knowledge** — every decision, review, and discussion becomes a wiki page
4. **No loss of context** — session state, checkpoints, and retro preserve continuity

## Key Workflows

```
idea → /office-hours → /spec → /plan-eng-review → /cso → /ship → /retro → wiki
```

## Architecture

- [[purpose]] — project goals and key questions
- [[schema]] — wiki structure and conventions
- [[index]] — full content catalog

## Recent Changes

- `2026-08-15` — Initial release; the current catalog has 38 skills plus 2 installed entry points
