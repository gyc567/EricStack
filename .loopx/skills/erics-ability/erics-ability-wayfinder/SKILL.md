---
name: erics-ability-wayfinder
description: Multi-session grilling orchestrator for efforts too large to hold in one conversation. Charts the effort as a MAP.md and runs grilling sessions inside individual decision tickets. 多会话质询编排器：把过大工作绘成地图 MAP.md，在独立决策工单里运行质询。
triggers:
  - wayfinder
  - /wayfinder
  - chart this effort
  - too big for one session
  - break this into decisions
  - 大工作量分拆
  - 质询地图
  - 编排多轮质询
---

## What it does

`wayfinder` is the grilling family member you reach for when an idea is too big to hold in one session. Instead of trying to fit the whole thing into a single conversation, it:

1. **Maps the effort** as a tree of decision tickets in `MAP.md`.
2. **Runs grilling sessions inside individual tickets** — typically one ticket per session, using `erics-ability-grill-me` or `erics-ability-grill-with-docs`.
3. **Settles tickets one at a time**, recording the outcome back into the map.

The map is the durable artefact. Sessions come and go; the map persists across them.

## When to reach for it

Reach for it when any of these are true:

- The first grilling session runs over 30–40 questions and you can feel the context straining.
- The idea spans multiple subsystems, services, or repositories.
- Different parts of the work need different stakeholders to weigh in.
- You want to hand the effort to a colleague who wasn't in any single session.

If the idea fits in one conversation, stay in `erics-ability-grill-me` or `erics-ability-grill-with-docs`. Wayfinder adds overhead (the map, the tickets) that earns its keep only when sessions have to fork.

## The artefacts

| File | Purpose |
|---|---|
| `MAP.md` (at repo root) | The effort map — tree of decision tickets with status. Append-only; **supersede by editing in place with a date stamp**. |
| `tickets/<slug>.md` | One decision ticket per leaf. Holds the question, the constraints, the session transcript pointer, and the outcome. |
| `CONTEXT.md` (optional) | Resolved vocabulary for the effort. Same format as `erics-ability-grill-with-docs`. |
| `docs/adr/NNNN-<slug>.md` | ADRs for load-bearing decisions. Same format as `erics-ability-grill-with-docs`. |

## MAP.md format

```markdown
# MAP: <effort name>

> Created <YYYY-MM-DD>. Updated <YYYY-MM-DD>.

## Status legend

`○` open   `◐` in-progress   `●` settled   `✕` cancelled   `↻` superseded

## Tree

```
● 0. <root decision>                      → ADR-0001
├── ◐ 1. <first child decision>
│   ├── ○ 1a. <grandchild>
│   └── ○ 1b. <grandchild>
├── ● 2. <second child decision>           → ADR-0002, ticket-tickets/2-*.md
└── ✕ 3. <cancelled decision>
```

## Tickets

- [tickets/1-*.md](tickets/1-*.md) — in-progress
- [tickets/2-*.md](tickets/2-*.md) — settled, see ADR-0002
```

The tree is the source of truth for **what decisions exist and which depend on which**. Tickets are the source of truth for **why each one was settled the way it was**.

## Ticket format

File: `tickets/<id>-<kebab-slug>.md`

```markdown
# Ticket <id>: <decision in one line>

Status: ○ open | ◐ in-progress | ● settled | ✕ cancelled
Created: <YYYY-MM-DD>
Settled: <YYYY-MM-DD> (if status is ● or ✕)
Depends on: <ticket ids this is blocked by>
Blocks: <ticket ids this unblocks>

## Question

The single decision this ticket is about. One sentence.

## Constraints

- Anything pinned by ancestor tickets that this one must respect.
- Anything pinned in `CONTEXT.md` that's load-bearing here.

## Session

- Pointer to the conversation / transcript where this was grilled.
- Skill used: `erics-ability-grill-me` or `erics-ability-grill-with-docs`.

## Outcome

(Empty while `○` or `◐`. Once settled, link the ADR or write a 3-bullet summary: decision, what was given up, what's unblocked.)
```

## The wayfinding loop

```
1. OPEN THE MAP
   - If MAP.md exists: read it, surface what's open, ask the user which ticket to work next.
   - If not: run a *short* grilling round to discover the top of the tree.

2. PICK A LEAF
   - A leaf ticket is one with no open dependents.
   - If no leaves exist, the user needs to define the next level of children.

3. FORK A SESSION FOR THE LEAF
   - New conversation, invoked as `erics-ability-grill-me` or `erics-ability-grill-with-docs`.
   - Constrained by everything settled in ancestor tickets.

4. SETTLE THE LEAF
   - On settlement, write the ticket's Outcome section.
   - If the outcome is load-bearing: offer an ADR.
   - Update MAP.md: leaf → ●, mark any tickets it unblocks.

5. STOP OR CONTINUE
   - Ask the user: another leaf, or pause? Wayfinder doesn't auto-advance.
```

## It's working if

- `MAP.md` stays the single source of truth for the effort's structure — anyone reading it cold knows what's done, what's open, and what depends on what.
- No single session exceeds ~40 questions. If one does, it means the leaf is too big and should split.
- Tickets that are settled have a 3-bullet Outcome you can read in 30 seconds.
- The map survives the agent that created it: a fresh agent reading only `MAP.md` + `CONTEXT.md` can pick up the work.

## Common questions

**Why not just have one giant `grill-with-docs` session?**
Context windows, focus, and parallelisability. A 200-question session drifts into the "dumb zone" where questions get worse; a map lets each session stay sharp by narrowing scope to one leaf. Tickets can also be forked to colleagues without giving them the whole conversation.

**How fine-grained should the tickets be?**
Roughly: one ticket per decision you'd defend in an ADR. If you can't write a 3-bullet outcome for the ticket, it's two tickets.

**Does wayfinder auto-advance through tickets?**
No. Each leaf is its own session, owned by you or whoever you hand it to. The map is a dashboard, not a queue.

**Can I run wayfinder over multiple repos?**
Yes — put `MAP.md` and `tickets/` in a parent directory, symlink or reference the repo paths. The map stays valid as long as the tickets pin their repos.

**What if a settled ticket needs to be revisited?**
Mark it `↻ superseded`, write the new ticket, link both. Same convention as ADRs.

## Where it fits

`wayfinder` is the **top of the grilling family tree** — used when nothing else is large enough. Under it:

- Leaves are grilled with `erics-ability-grill-me` (no code) or `erics-ability-grill-with-docs` (codebase-aligned).
- Settlements that produce software feed into `erics-ability-spec`, then implementation.

EricStack-specific notes:

- **No Brain Context preflight.** The map and `CONTEXT.md` are the context; do not load `bin/erics-brain-cache`.
- **No Prior Learnings search.** Map-driven effort; cross-project learnings would muddy the ticket/ADR record.
- **No Plan Status Footer.** Not a plan-review skill.
