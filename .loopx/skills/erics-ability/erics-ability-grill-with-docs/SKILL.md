---
name: erics-ability-grill-with-docs
description: Stateful grilling session that reads the codebase and writes CONTEXT.md (vocabulary) plus ADRs under docs/adr/ (hard decisions). Use when grilling an idea that needs to align with an existing codebase. 状态化质询技能：阅读代码库、记录上下文到 CONTEXT.md、把硬决策写入 ADR。
triggers:
  - grill with docs
  - grill-with-docs
  - /grill-with-docs
  - 配合代码库拷问
  - 代码库对齐质询
  - interview me about my codebase
  - align idea with code
---

## What it does

`grill-with-docs` is `erics-ability-grill-me` plus a working directory. The interview is the same — rounds of the whole frontier, you own the scope — but it reads your codebase to align the idea against it, and writes what it learns as it goes, not at the end.

Two kinds of files land during the session:

| File | What goes in it |
|---|---|
| `CONTEXT.md` (at repo root) | **Resolved vocabulary.** What you and the agent have agreed terms mean in *this* codebase. Written first, appended to. |
| `docs/adr/NNNN-<slug>.md` | **Hard decisions.** Architecture-/design-level choices that are now load-bearing. One per ADR. |

The split mirrors the split inside `erics-ability-grill-me`: **facts** (vocabulary, where things live, what "user" means here) are the skill's job to record; **decisions** (which approach, what to ship, what to cut) are yours, and the skill waits for them.

## When to reach for it

Reach for it when the idea you want to grill lives in or against an existing codebase. Use `erics-ability-grill-me` instead if there is no codebase yet, or if the question is purely about business/product direction.

The build chain it sits at the front of:

```
erics-ability-grill-with-docs  →  erics-ability-spec  →  implement  →  code-review
        (codebase-aligned)         (spec)            (code)         (review)
```

If you started with `erics-ability-grill-me` in a fresh session and realised the idea is software-shaped, you can hand the same conversation here. If you already know the effort is too big to hold in one session, skip ahead to `erics-ability-wayfinder` and run this skill inside its decision tickets.

## The split of work

The skill keeps three lanes separate:

1. **Reading the repo.** When a frontier question needs something the codebase can settle (where the auth flow lives, what `User` is in this schema, which file handles retries), dispatch a sub-agent or use Grep/Glob to find out. Do not ask the user something the repo can answer.

2. **Writing `CONTEXT.md`.** Anything agreed-upon vocabulary goes here. Terms, names, file roles, conventions. The point is that the next agent — or you, three weeks from now — can read one file and know what words mean in this codebase.

3. **Writing ADRs.** When the grilling settles a real decision (Postgres vs SQLite, queue vs cron, monolith vs split), the skill pauses and asks if you want an ADR. Only decisions, not facts. One decision per ADR. Numbered sequentially.

ADRs are not append-only: when a decision is **superseded**, the new ADR links back and the old one gets a status change at the top.

## CONTEXT.md format

```markdown
# CONTEXT

> Resolved vocabulary for this codebase. Append-only; supersede by editing in place with a date stamp.

## <term>

**Meaning in this codebase:** <one sentence>
**Where it lives:** <path>:<line> or <module>
**Last confirmed:** <YYYY-MM-DD>

## <term>
...
```

## ADR format (Nygard-style)

File: `docs/adr/NNNN-<kebab-slug>.md`

```markdown
# NNNN. <Short imperative title>

Date: <YYYY-MM-DD>

## Status

Proposed | Accepted | Superseded by [NNNN](NNNN-<slug>.md)

## Context

What is the issue we're seeing that motivates this decision?

## Decision

What did we choose?

## Consequences

What becomes easier? What becomes harder? What did we give up?
```

The skill never writes the Status as `Accepted` without your explicit yes. `Proposed` is the default until you say go.

## The grilling loop (this skill)

```
Round N:
  1. Compute the frontier from your last answers + any facts the skill just learned.
  2. For each frontier question:
     - If the answer is in the codebase → go read it (sub-agent / Grep / Glob).
     - If the answer is a decision → ask, with a recommendation on a `➡️` line.
  3. Settle this round's answers.
  4. If a new vocabulary term got pinned → append to CONTEXT.md.
  5. If a new hard decision got pinned → ask: "Write this as an ADR?" then draft.
  6. Recompute frontier. If empty → stop and confirm shared understanding.
```

## It's working if

- Each round arrives as a numbered list with recommendations on separate `➡️` lines, answerable by number.
- Files appear **during** the session, not batched at the end — `CONTEXT.md` after the first round that needs vocabulary, the first ADR the moment a decision is pinned.
- Research running in the background does not stall the round; only the questions that depend on it wait.
- It stops at the end and asks you to confirm shared understanding, instead of starting work.

## Common questions

**Does it actually need the grilling primitive?**
Yes. This skill's body is mostly pointers to `erics-ability-grill-me` plus the file-writing layer; the interview technique itself comes from there. A known rough edge across harnesses: a skill that names another skill does not reliably cause it to load. If a session starts asking everything at once with no recommendations attached, the skill is improvising rather than grilling — ask it directly whether it loaded `erics-ability-grill-me` and recover.

**Do I have to write ADRs for every decision?**
No. ADRs are for decisions that will be load-bearing for future work — architecture choices, schema choices, module boundaries. "We'll use kebab-case for filenames" is a convention; "We'll use Postgres" is an ADR.

**What goes in CONTEXT.md vs the ADR?**
Vocabulary → `CONTEXT.md`. Decisions → ADR. "User means the row in `users` table" is vocabulary. "We store users in Postgres, not SQLite" is a decision.

**Can I edit the files mid-session?**
Yes. The skill treats `CONTEXT.md` and `docs/adr/` as live. If you rewrite a term or supersede a decision, the skill follows your version.

**What if the codebase has no `docs/adr/` yet?**
The skill creates it. If it already exists, it appends to the existing sequence (find the highest `NNNN` and continue from there).

## Where it fits

`grill-with-docs` is the **stateful front door** of the grilling family — the one you reach for when the answer is partly in the repo. Its portability is narrower than `erics-ability-grill-me`: it needs a working directory, and it leaves files behind, but those files are the artefact that lets a fresh agent pick the work up later.

EricStack-specific notes:

- **No Brain Context preflight.** The codebase *is* the context; do not load `bin/erics-brain-cache`.
- **No Prior Learnings search.** Decision-driven session; cross-project learnings would muddy the ADR record.
- **No Plan Status Footer.** Not a plan-review skill.
