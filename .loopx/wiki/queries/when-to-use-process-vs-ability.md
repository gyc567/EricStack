---
name: When to Use Process vs Ability Skills
created: 2026-08-15
tags: [faq, routing]
---

# Query: When to Use Process vs Ability Skills?

## Question

Given a task, how do I know whether to reach for an `erics-process-*` skill or an `erics-ability-*` skill?

## Answer

**Rule 1: Writing/Review tasks → Process first**

If the task involves writing, editing, reviewing, or ensuring quality, prefer `erics-process-*`. These enforce discipline regardless of whether you "feel like" doing them.

**Rule 2: Action/Execution tasks → Ability**

If the task is "do this thing for me" (plan, debug, benchmark, save state), use `erics-ability-*`.

**Rule 3: When in doubt, ask the router**

Run `/erics-loop-router` with your task description and it will recommend the right skill.

## Quick Reference

| Task | Skill |
|---|---|
| Review a PR | `erics-process-code-review` |
| Plan a feature | `erics-ability-plan-eng-review` |
| Simplify code | `erics-process-find-simplifications` |
| Debug an error | `erics-ability-investigate` |
| Write docs | `erics-process-doc-standards` |
| Brainstorm idea | `erics-ability-office-hours` |
| Benchmark perf | `erics-ability-benchmark` |

## See Also

- [[erics-loop-router]]
