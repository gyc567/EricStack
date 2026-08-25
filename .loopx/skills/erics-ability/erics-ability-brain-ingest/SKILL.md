---
name: erics-ability-brain-ingest
description: Use when the user says "brain ingest", "ingest into brain", "digest to brain", "消化到 brain", or "capture this conversation". Breaks the input into atomic knowledge points, places them on existing root pages or new pages, and writes via the `brain` CLI.
triggers:
  - brain ingest
  - ingest into brain
  - digest to brain
  - 消化到 brain
  - capture this conversation
---

# /brain-ingest — Digest Input into the Brain

You are a **meticulous indexer**. Input is messy; the brain is structured;
your job is to convert one into the other without losing meaning or
fabricating content.

## When to ingest (auto-trigger rule)

Don't wait to be asked. When any of the following crystallizes in chat
or while coding, ingest immediately:

- An architectural decision with stated trade-offs
- A constraint the team agreed to (legal, perf, cost, vendor lock-in)
- A reversal of an earlier decision (with what triggered it)
- An external reference that future sessions will need (postmortem,
  RFC, ticket, paper)
- A concept the team has converged on a shared meaning for

**The 6-month test:** "Will this still matter in six months, and is it
hard to reconstruct from the code alone?" If yes, ingest.

**Don't ingest:**

- Pure implementation detail (function names, file paths)
- In-progress task state (use `erics-ability-context-save`)
- One-off deploy / branch / config (ephemeral)
- Conversation tone, hedges, off-topic chat

## Pre-flight

```bash
[ -f BRAIN.md ] || fail "Brain not initialized — run /brain init first"
CLI="$HOME/.claude/skills/brain-page/bin/brain.mjs"
[ -x "$CLI" ] || fail "brain CLI not installed — re-run install-ericsstack.sh"
```

If the user has just been told their project isn't initialized, stop
here — do not prompt them to init; that's a separate workflow.

## HARD GATE — DeepSeek Harness projects

If the project contains `notes/implemented/` or `notes/archived/`, **do
not ingest into brain**. Tell the user:

> This project uses the DeepSeek Harness Agent Notes system. Ingesting
> into brain would create a second decision corpus. Use
> `/erics-process-archive-agent-notes` to record this knowledge instead.

## Ingest flow

### Step 1: Identify the input

Acceptable inputs (auto-detected):

- The current conversation transcript (default)
- A file path (Markdown, plain text, JSON, code)
- A URL (fetch and parse first via WebFetch)
- A PR / commit reference (`git log`, `gh pr view`)

### Step 2: Decompose into atomic points

For each unit of knowledge in the input, produce a tuple:

```
{ point: <one-sentence fact>,
  category: <project|concept|decision|person|reference>,
  placement: <root:<slug> | new-page:<suggested-id> | existing-page:<id>>,
  confidence: <stated | inferred | uncertain> }
```

Rules:

- **One fact per point.** Multi-clause sentences must be split.
- **State trade-offs** for decisions: reasons chosen, reasons rejected.
- **Prefer existing pages.** `node "$CLI" list-pages` first; new pages
  only when no existing page fits.
- **Mark confidence.** `stated` (user said it), `inferred` (you derived
  it from context), `uncertain` (you guessed; needs review).

### Step 3: Decide per-point action

| Confidence | Placement | Action |
|---|---|---|
| stated | root page | `update-root <slug>` (append a section, don't overwrite) |
| stated | existing page | `append-timeline --kind evidence --summary "..."` |
| stated | new page | `create-page` + `update-truth` |
| inferred | any | `append-timeline --kind note --summary "inferred: ..."` (do not create pages from inferences) |
| uncertain | any | `append-timeline --kind note --summary "uncertain: ..."` + flag to user |

### Step 4: Write through the CLI

For each point, execute the chosen action. Examples:

```bash
# Decision on an existing root page (stack)
cat <<'EOF' | node "$CLI" update-root stack
# Stack

## Postgres over SQLite
Chose Postgres for concurrent writers and JSONB.
Rejected SQLite (single-writer contention at >10 w/s).
EOF

# New evidence on an existing decision page
node "$CLI" append-timeline --id decision-postgres-over-sqlite \
  --kind evidence \
  --source "load test 2026-08-20, 50 concurrent writers, 99p < 80ms" \
  --summary "load test confirmed contention-free write path"

# A new person page
node "$CLI" create-page --id person-alice-architect \
  --category person \
  --title "Alice — staff architect"
node "$CLI" append-timeline --id person-alice-architect \
  --kind note \
  --summary "joined 2024-Q2, owns auth + data subsystems, RFC reviewer"
```

**Order matters:** create pages before appending to them.

### Step 5: Verify and report

```bash
node "$CLI" reindex
node "$CLI" lint-links
```

Output a short ingest report:

```
BRAIN INGEST
════════════════════════════════════════
Input:           <source description>
Points extracted: N
  - 2 root-page updates (stack, architecture)
  - 3 evidence appends (decision-X, decision-Y, decision-Z)
  - 1 new person page (person-alice-architect)
  - 4 note appends (marked for review)
════════════════════════════════════════
Flagged for review (uncertain / inferred):
  - "we're using Postgres 16"  (inferred from package.json; actual version not in input)
  - "Alice owns billing"        (uncertain; not stated explicitly)
```

### Step 6: Hand off

Tell the user:

- Where the new knowledge landed (page ids / root page slugs)
- What was flagged for review
- Suggest: "Run `/brain-page <id>` to spot-check, or
  `/erics-process-code-review` if you want a fresh read."

## Idempotency / dedup

Before creating a page, **always** `list-pages` and check for existing
ids / titles. For decision pages, prefix with `decision-` to avoid
collisions with concept / person / reference pages.

If a similar page exists, **append** to its timeline rather than
creating a near-duplicate. Never overwrite a `compiled_truth` from
ingest unless the user explicitly says "this reverses the prior
understanding".

## Concurrency note

brain is git-tracked Markdown, not a database. If two EricStack skills
ingest simultaneously, last-write-wins on `compiled_truth` and both
append to the timeline. This is by design — the timeline preserves
the history of writes. For strict ordering, ingest serially.

## Important Rules

- **Never hand-edit** brain files. Always go through the CLI.
- **Never** create pages from inferences or uncertain points.
- **Always** summarize the change in `update-truth` / `append-timeline`.
- **Always** run `reindex && lint-links` at the end.
- **Always** output a report so the user can spot-check.
- **Refuse** on DeepSeek Harness projects.