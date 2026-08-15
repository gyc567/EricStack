---
name: Skill Naming Convention
created: 2026-08-15
tags: [decision, convention]
---

# Decision: Skill Naming Convention

## Decision

All EricStack skills follow a two-tier naming system:

| Tier | Prefix | Meaning | Examples |
|---|---|---|---|
| Process Discipline | `erics-process-*` | Enforce standards, review quality | code-review, prose-standard |
| Engineering Ability | `erics-ability-*` | Execute actions, productivity | plan-eng-review, investigate |

## Rationale

- `process` = discipline/standards (what you should do regardless of preference)
- `ability` = productivity/actions (what you can do when you choose to act)
- `erics-` prefix prevents namespace collision with upstream repos
- Router always prefers `process` when both could apply to a writing/review task

## Source

[[sources/INTEGRATION.md]] — Brand naming rules section

## See Also

- [[erics-loop-router]]
- [[index]]
