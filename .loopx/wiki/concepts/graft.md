---
name: graft
created: 2026-08-15
tags: [tool, code-understanding, graft]
---

# Graft — Codebase Knowledge Graph

[Graft](https://github.com/NanoNets/Graft) by NanoNets is a **codebase context layer** that builds a persistent knowledge graph so AI coding agents don't have to re-explore the repo on every task.

## Core Idea

```
Every task, an agent starts blind — re-grepping, re-reading, re-mapping.
Graft builds understanding once, persists it in graft/, reuses it forever.
```

## How It Works

**Two-pass build:**
1. **Tier 1 (tree-sitter)** — parses every file into a structural call graph. Free, deterministic, no LLM needed.
2. **Pass 2 (LLM)** — summarizes files into typed nodes (`part_of`, `uses`, `calls`, `produces`).

Output lives in `graft/` as linked markdown files. Commit it to share with teammates.

## Key Commands

| Command | Use case |
|---|---|
| `graft init --agents claude` | First-time setup |
| `graft map` | Project structure at token budget |
| `graft callers <symbol>` | Find all callers of a function |
| `graft grep "<regex>"` | Search with call-graph context |
| `graft skeleton <file>` | Plain-English file summary |
| `graft check` | Staleness check (exits 1 if stale) |
| `graft ask "<question>"` | Natural language query |
| `graft viz` | Interactive graph viewer |

## EricStack Integration

EricStack's `erics-ability-graft` skill wraps Graft commands for common engineering scenarios:

- **Investigate** + Graft: trace call chains faster
- **Code review** + Graft: understand blast radius of changes
- **Plan review** + Graft: structural map for architecture review

See [[erics-ability-graft]] for the full skill documentation.

## Benchmark

- **46% fewer tool calls**, 42% fewer tokens, 60% less time (vs cold Claude Code)
- **+12 pts** on SWE-bench Verified (66% vs 54% baseline)
- **21% cheaper, 14% faster** on PocketBase real implementation tasks

## Limitations

- Requires Node.js (EricStack works without it)
- `--deep` summary layer requires LLM API key
- Not a replacement for llm_wiki — see [[concepts/knowledge-base]] for comparison
