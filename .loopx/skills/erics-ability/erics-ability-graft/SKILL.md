---
name: erics-ability-graft
description: Use when you need to understand code structure, trace call chains, or navigate a large codebase — wraps Graft for fast codebase orientation.
triggers:
  - graft
  - code map
  - trace calls
  - find callers
  - understand codebase
  - 代码结构
  - 调用链
  - 代码理解
  - call graph
---

# Graft — Codebase Knowledge Graph

Graft builds a persistent, indexed understanding of your codebase as linked markdown files in `graft/`. It answers structural questions without re-exploring the repo on every task.

**Prerequisite:** Run `graft init` once before using this skill. If Graft is not installed, see the installation section below.

---

## When to Use Graft

| Task | Graft Command |
|---|---|
| New codebase / unfamiliar code | `graft map` |
| "Where is this function called?" | `graft callers <symbol>` |
| "Find code matching a pattern" | `graft grep "<regex>"` |
| "What does this file do?" | `graft skeleton <file>` |
| "Is my graph stale?" | `graft check` |
| "Query the codebase in natural language" | `graft ask "<question>"` |
| "View dependency graph" | `graft viz` |
| "Rebuild the graph" | `graft build [--deep]` |

---

## Core Commands Reference

### `graft init`
First-time setup. Builds the initial graph and wires into Claude Code (statusline + hooks).
```bash
graft init --agents claude        # Non-interactive, Claude Code specific
graft init --dry-run              # Preview without building
```

### `graft build [--deep]`
Rebuild or update the graph. Use after major refactors.
- `--deep` adds per-symbol summaries and crux lines (requires LLM API key).

### `graft map [dir]`
Show project structure at a given token budget. Good for onboarding or understanding architecture.
```bash
graft map                          # Default budget
graft map --limit 2000            # Custom token budget
```

### `graft callers <symbol> [-d N]`
Find all callers (or callees) of a symbol, with N-level depth.
```bash
graft callers handleRequest        # Who calls handleRequest?
graft callers handleRequest -d 2  # + who those callers call
```

### `graft grep "<regex>" [--in <path>]`
Search with context — shows the surrounding call graph, not just grep lines.
```bash
graft grep "authenticate" --in ./src
```

### `graft skeleton <file>`
Plain-English summary of what a file does.
```bash
graft skeleton src/auth/login.ts
```

### `graft check`
Staleness check. Exits 1 if files have changed since last build.
```bash
graft check                        # For CI/CD pipelines
```

### `graft ask "<question>"`
Natural language query with full graph context.
```bash
graft ask "How does the payment flow work end to end?"
```

### `graft viz`
Interactive dependency graph viewer (terminal UI).

---

## Relationship to Other Skills

| Skill | Distinction |
|---|---|
| `erics-ability-investigate` | Investigate = debugging (root cause). Graft = code structure understanding. |
| `erics-process-code-review` | Code review = quality discipline. Graft = fast codebase orientation for reviewers. |
| `erics-ability-plan-eng-review` | Plan review = architecture decisions. Graft = structural map for understanding existing code. |
| `erics-ability-health` | Health = metrics dashboard (types, lint, tests). Graft = call graph and symbol relationships. |
| llm_wiki | Wiki = decisions, discussions, experience (Why). Graft = code structure (What/How). |

Graft and llm_wiki are **complementary**:
- llm_wiki answers: "Why was this design chosen?"
- Graft answers: "Where is this implemented and what does it call?"

---

## Installation

Graft requires Node.js. If not installed, skip — EricStack works without Graft.

```bash
# Install
npm install -g @nanonets/graft

# Initialize for Claude Code (non-interactive)
graft init --agents claude

# Verify
graft check
```

If `graft check` exits 1, run `graft build` to refresh.

---

## Auto-Sync

Graft auto-syncs on every query against the working tree. After `graft init`, no manual refresh is needed for normal sessions. For CI, add `graft check` as a pre-step to detect stale graphs before key operations.
