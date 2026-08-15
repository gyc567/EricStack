---
name: Agent Notes
created: 2026-08-15
tags: [knowledge, decisions]
---

# Agent Notes

## Definition

Agent Notes are durable, evidence-backed records of significant engineering decisions. They live in `.agents/notes/` and are the primary vehicle for compounding knowledge across sessions.

## When to Write One

Write an Agent Note when:
- A non-obvious decision was made about architecture, design, or approach
- A simplification was intentionally rejected with rationale
- A feature was removed and the removal needs to be remembered
- A pattern was established that future code should follow

## Lifecycle

| Stage | Meaning |
|---|---|
| `proposed` | Under consideration |
| `implemented` | Accepted and shipped |
| `archived` | Superseded but kept for history |

## Format

```
# Agent Note: <action-oriented title>
Status: proposed | implemented | archived
## Problem
## Proposal
## Why not keep it?
## Acceptance criteria
## Risks
```

## See Also

- [[erics-process-archive-agent-notes]]
- [[erics-process-find-simplifications]]
