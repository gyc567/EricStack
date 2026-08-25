---
name: Loop Engineering
created: 2026-08-15
tags: [core-concept, process]
---

# Loop Engineering

## What It Is

Loop Engineering is the practice of structuring an AI agent's work as a series of closed feedback loops — each loop has a clear entry, a process, an output, and a validation step. Unlike ad-hoc prompting, loops are durable, composable, and improve over time.

## Why It Matters

Without loops, AI agents produce one-off outputs that don't compound. With loops:
- Decisions accumulate as [[agent-notes]]
- Reviews are grounded in shared standards
- Knowledge persists beyond individual sessions

## EricStack Loop Structure

```
Plan → Review → Ship → Retro → Knowledge
  ↑                              ↓
  └──────── Context Save ←────────┘
```

Each arrow is a skill. Each skill is a closed loop with inputs, process, and outputs.

## See Also

- [[concepts/agent-notes]]
- [[concepts/boil-the-ocean]]
- [[erics-ability-autoplan]]
