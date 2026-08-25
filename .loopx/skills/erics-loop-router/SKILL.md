---
name: erics-loop-router
description: Routes engineering tasks to the correct erics-process (discipline) or erics-ability (productivity) skill. Inspects task type and routes accordingly. (ericstack)
allowed-tools:
  - Read
  - Bash
triggers:
  - erics-loop-router
  - which skill for this
  - route this
  - ericstack route
  - process review
  - estack router
  - 查看全部技能
  - all skills
  - skill index
---

# EricStack LoopX Skill Router

Inspect the user's request, determine whether it maps to a **process discipline skill** (`erics-process-*`) or an **engineering ability skill** (`erics-ability-*`), and recommend the correct skill with a one-line rationale.

## Startup Auto-Check

On every routing decision, silently check for updates (no output if current):

```bash
LOCAL_VERSION=$(cat .loopx/VERSION 2>/dev/null || echo "")
REMOTE_TAG=$(git ls-remote --tags https://github.com/gyc567/EricStack.git \
  2>/dev/null | awk -F/ '{print $NF}' | grep '^v' | sort -V | tail -1 | sed 's/v//')
if [ -n "$LOCAL_VERSION" ] && [ -n "$REMOTE_TAG" ] && [ "$LOCAL_VERSION" != "$REMOTE_TAG" ]; then
  echo "EricStack update available: v$LOCAL_VERSION → v$REMOTE_TAG. Run /upgrade to see details."
fi
```

Show the update notice as a one-line hint only when a new version is available.
Skip this check if any tool call has already failed (session may be offline).

## Decision Logic

### Rule 1: Process Discipline优先于 Ability（当两者都存在时）

"帮我 review 这个 PR" → `erics-process-code-review`（纪律审查覆盖完整性）
"帮我检查代码质量" → `erics-process-code-review`

### Rule 2: Ability 专属场景直接路由

"帮我 plan 这个功能" → `erics-ability-plan-eng-review`
"帮我 debug 这个 error" → `erics-ability-investigate`
"我有个想法想讨论" → `erics-ability-office-hours`
"帮我做安全审计" → `erics-ability-cso`
"帮我 benchmark 性能" → `erics-ability-benchmark`
"帮我保存当前进度" → `erics-ability-context-save`

### Rule 3: Doc/Prose 场景路由到 erics-process

"帮我写文档" → `erics-process-doc-standards`
"优化这段 prose" → `erics-process-prose-standard`
"trim 一下这段文字" → `erics-process-trim-cot-leakage`
"帮我对齐中英双语文档" → `erics-process-translate-docs`

### Rule 4: 当不确定时，给出两个选项

"这个设计合理吗？" → 推荐 `erics-ability-plan-design-review`（评分视角）+ `erics-ability-plan-eng-review`（工程视角）

## Routing Table

| Request pattern | Routes to | Reason |
|---|---|---|
| "review this pr" / "code review" | `erics-process-code-review` | Coverage + prose + invariant discipline |
| "debug this" / "fix this bug" | `erics-ability-investigate` | Four-phase discipline: investigate/analyze/hypothesize/implement |
| "arch review" / "eng plan" / "lock in plan" | `erics-ability-plan-eng-review` | Architecture + data flow + edge cases |
| "design review" / "rate design" | `erics-ability-plan-design-review` | Design dimension scoring (0-10) |
| "ceo review" / "10-star" / "product" | `erics-ability-plan-ceo-review` | CEO-level product framing |
| "devex review" / "TTHW" / "dx" | `erics-ability-plan-devex-review` | Developer experience audit |
| "improve docs" / "audit docs" | `erics-process-doc-standards` | Documentation placement + corpus discipline |
| "trim prose" / "edit text" | `erics-process-prose-standard` | Prose completeness + editorial discipline |
| "trim cot" / "remove reasoning" | `erics-process-trim-cot-leakage` | Chain-of-thought leakage detection |
| "security audit" / "owasp" / "vulnerability" | `erics-ability-cso` | OWASP Top 10 + STRIDE threat modeling |
| "ship it" / "run tests and push" | `erics-ability-ship` | Test + review + PR + push |
| "canary" / "monitor deploy" | `erics-ability-canary` | Post-deploy monitoring loop |
| "retro" / "retrospective" | `erics-ability-retro` | Weekly retro + shipping streaks |
| "save context" / "checkpoint" | `erics-ability-context-save` | Git state + decisions + remaining work |
| "restore context" / "resume session" | `erics-ability-context-restore` | Cross-workspace context restoration |
| "brain init" / "init brain" / "setup project brain" | `erics-ability-brain-init` | Project-level persistent memory scaffold |
| "read brain page" / "create brain page" / "update truth" | `erics-ability-brain-page` | Read/write brain pages through CLI |
| "brain bootstrap" / "seed project brain" | `erics-ability-brain-bootstrap` | Brownfield/greenfield brain seeding |
| "brain ingest" / "digest to brain" / "capture this conversation" | `erics-ability-brain-ingest` | Decompose input into atomic knowledge points |
| "brainstorm" / "office hours" / "is this worth building" | `erics-ability-office-hours` | YC Office Hours six forcing questions |
| "spec this out" / "file an issue" | `erics-ability-spec` | Vague intent → executable spec |
| "benchmark" / "performance regression" | `erics-ability-benchmark` | Performance regression detection |
| "model benchmark" / "compare models" | `erics-ability-benchmark-models` | Cross-model skill comparison |
| "simplify" / "find dead code" | `erics-process-find-simplifications` | Simplification candidate discovery |
| "archive notes" / "prune decisions" | `erics-process-archive-notes` | Agent Note lifecycle management |
| "land stack" / "merge stacked prs" | `erics-process-merging-stacked-prs` | GitHub official PR stack landing |
| "pre-push checks" | `erics-process-pre-push-checks` | Pre-push minimal evidence selection |
| "generate docs" / "diataxis" | `erics-ability-document-generate` | Diataxis doc generation from code |
| "update docs for release" | `erics-ability-document-release` | Docs sync to shipped behavior |
| "setup deploy" | `erics-ability-setup-deploy` | Deploy config detection |
| "upgrade" / "sync skills" | `erics-ability-upgrade` | Check & sync upstream skill updates |
| "health check" | `erics-ability-health` | Code quality dashboard |
| "learn" / "record learnings" | `erics-ability-learn` | Cross-session memory management |

## Output Format

When routing, output exactly:

```
→ [Skill Name] — [One-line reason]
```

Example:
> "帮我 review 这个 PR"
→ `erics-process-code-review` —纪律优先：coverage、prose、invariant 全面审查

## Cross-cutting cases

If the request spans multiple categories, pick the **most specific** (narrowest scope) skill. If equal specificity, prefer `erics-process-*` over `erics-ability-*` for writing/review tasks, and `erics-ability-*` over `erics-process-*` for action/execution tasks.

## Skills Index

Full trigger词 index: `.loopx/erics-skills-index.md`
Path anchor mapping: `.loopx/erics-mapping.md`
Integration docs: `INTEGRATION.md`
