---
name: erics-ability-upgrade
description: Check for EricStack skill updates from upstream deepseek-harness and gstack.
triggers:
  - upgrade
  - sync skills
  - check for updates
  - skill update
  - update available
---

# /erics-ability-upgrade — Check & Sync EricStack Skills

Check whether the local EricStack skills are up to date with upstream
`deepseek-harness` and `gstack` repositories. Run the sync script and
report the status.

## When

- User types `/upgrade` or `/sync-skills`
- LoopX goal starts and you want to verify skill freshness
- After a `loopx refresh-state` to confirm no upstream drift

## What it does

1. Reads `.loopx/sync-state.json` for last-synced commit per source
2. Fetches current HEAD commit from both upstream repos (no clone needed)
3. Compares local vs remote and reports status
4. If updates available, explains what changed and how to sync

## Output format

```
EricStack Skill Status
══════════════════════
Source              Status          Local  → Remote
──────              ──────          ─────  ────────
deepseek-harness    UP-TO-DATE      47f9438 → 47f9438
gstack              UPDATE AVAILABLE 008dd65 → abc1234

Last checked: 2026-08-15T12:00:00Z

To sync: bash .loopx/bin/sync-skills.sh --execute
```

## Implementation

Run the sync script:

```bash
bash .loopx/bin/sync-skills.sh --check
```

Parse the output. If "UPDATE AVAILABLE" appears for either source,
show the summary and the sync command. If all are "UP-TO-DATE",
say so and stop.

## Important

- **Do NOT auto-execute sync.** The `--execute` path is destructive
  (overwrites local skill files with upstream content). Always ask
  the user to confirm before running `--execute`.
- When updates are available, summarize what the user gains (new skills,
  bug fixes, improved prompts) if possible — give them a reason to sync.
- After any successful sync, update the skills index:
  `bash .loopx/bin/sync-skills.sh --execute && bash .loopx/bin/reindex.sh`

## Completion

Report DONE with current status, or DONE_WITH_CONCERNS if the check
failed (network error, GitHub unreachable).
