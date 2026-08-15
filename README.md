# EricStack

**AI-native engineering loop system — 26 skills covering planning, review, simplification, documentation, and knowledge accumulation.**

> EricStack transforms EricStack from a project into a compounding engineering intelligence. Every decision, review, and discussion becomes a persistent wiki page. Every process is a closed loop.

## What Is EricStack?

EricStack is a LoopX-powered skill system for engineering teams. It provides **26 skills** organized in two tiers:

| Tier | Count | Purpose |
|---|---|---|
| `erics-process-*` (Discipline) | 11 | Enforce standards — code review, prose quality, docs, simplification |
| `erics-ability-*` (Action) | 15 | Execute workflows — planning, debugging, benchmarking, retros |

Skills run inside Claude Code (or any LoopX-compatible host). No separate server, no daemon, no API keys required for the skill system itself.

## Core Features

- **26 production-ready skills** — process discipline + engineering abilities
- **Compounding knowledge base** — powered by [llm_wiki](https://github.com/nashsu/llm_wiki), every decision persists
- **Auto-update detection** — checks both EricStack version and upstream skill sources on every routing decision
- **Zero-dependency skills** — all skills run with Read, Write, Bash, Grep — no special CLIs required
- **Brand-clean** — all `gstack-` / `dsh-` / `deepseek-harness` references removed, rebranded to EricStack

## Quick Start

### 1. Clone

```bash
git clone https://github.com/gyc567/EricStack.git
cd EricStack
```

### 2. Open in llm_wiki (recommended for knowledge base)

Download [llm_wiki](https://github.com/nashsu/llm_wiki/releases), then:

```bash
# In llm_wiki app: File → Open Project → select EricStack directory
```

### 3. Use Skills in Claude Code

```
/erics-loop-router     # Ask: "which skill for this?" — routes to the right skill
```

Or invoke any skill directly:

| Command | What it does |
|---|---|
| `/erics-process-code-review` | Full PR review: coverage, prose, invariants |
| `/erics-ability-plan-eng-review` | Architecture + data flow review |
| `/erics-ability-investigate` | 4-phase debugging: investigate → analyze → hypothesize → implement |
| `/erics-ability-cso` | Security audit (OWASP Top 10 + STRIDE) |
| `/erics-ability-health` | Code quality dashboard: types, lint, tests, dead code |
| `/erics-ability-benchmark` | Performance regression detection (Core Web Vitals) |
| `/erics-ability-office-hours` | YC-style six forcing questions |
| `/erics-ability-spec` | Vague intent → executable spec in 5 phases |
| `/erics-ability-retro` | Weekly retrospective with shipping streaks |
| `/erics-ability-context-save` | Save working context: git state + decisions + remaining |
| `/erics-ability-context-restore` | Resume from saved context |
| `/erics-ability-upgrade` | Check for updates |
| `/erics-process-find-simplifications` | Find dead code, over-built surfaces, simplification candidates |
| `/erics-process-prose-standard` | Prose completeness + editorial discipline |
| `/erics-process-trim-cot-leakage` | Remove chain-of-thought leakage from docs |

**See all 26 skills:** [`.loopx/erics-skills-index.md`](.loopx/erics-skills-index.md)

## Architecture

```
EricStack/
├── .loopx/
│   ├── skills/
│   │   ├── erics-loop-router/      # Skill router
│   │   ├── erics-process-* (×11)  # Discipline skills
│   │   └── erics-ability-* (×15)  # Action skills
│   ├── wiki/                       # LLM Wiki knowledge base
│   │   ├── concepts/              # Concept pages
│   │   ├── entities/              # Decision records
│   │   └── queries/               # Q&A pairs
│   ├── sync-state.json            # Upstream sync state
│   ├── VERSION                    # Current version
│   └── bin/sync-skills.sh        # Update checker
└── INTEGRATION.md                  # Full integration docs
```

## Knowledge Base

EricStack's knowledge base follows the [LLM Wiki](https://github.com/nashsu/llm_wiki) pattern — a persistent, compounding wiki that grows with your project.

```
.loopx/wiki/
├── index.md      # Skills + decisions + docs catalog
├── overview.md   # Auto-updated project summary
├── log.md       # Operation history (append-only)
├── concepts/    # Patterns, practices, principles
├── entities/    # Decisions, people, features
└── queries/     # Common questions with verified answers
```

## Keeping Skills Up to Date

```bash
# Check for updates (runs automatically on every skill routing)
bash .loopx/bin/sync-skills.sh --check

# Sync upstream skill sources (when updates available)
bash .loopx/bin/sync-skills.sh --execute

# Check EricStack version
cat .loopx/VERSION
```

## Skill Naming

| Prefix | Meaning | When to use |
|---|---|---|
| `erics-process-*` | Discipline / Standards | Writing, reviewing, ensuring quality |
| `erics-ability-*` | Action / Productivity | Executing a specific workflow |

When both apply, prefer `erics-process-*` for writing/review tasks.

## License

MIT License — see [`LICENSE`](LICENSE)
