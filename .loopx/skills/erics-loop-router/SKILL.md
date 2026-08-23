---
name: erics-loop-router
description: Use when routing an engineering task to the most specific EricStack process or ability skill.
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

"这个设计合理吗？" → 推荐 `erics-ability-design-consultation`（设计视角）+ `erics-ability-plan-eng-review`（工程视角）

## Routing Table

| Request pattern | Routes to | Reason |
|---|---|---|
| "review this pr" / "code review" | `erics-process-code-review` | Coverage + prose + invariant discipline |
| "debug this" / "fix this bug" | `erics-ability-investigate` | Four-phase discipline: investigate/analyze/hypothesize/implement |
| "arch review" / "eng plan" / "lock in plan" | `erics-ability-plan-eng-review` | Architecture + data flow + edge cases |
| "design review" / "rate design" | `erics-ability-design-consultation` | Design-system consultation and review |
| "ceo review" / "10-star" / "product" | `erics-ability-plan-ceo-review` | CEO-level product framing |
| "devex review" / "TTHW" / "dx" | `erics-ability-devex-review` | Developer experience audit |
| "improve docs" / "audit docs" | `erics-process-doc-standards` | Documentation placement + corpus discipline |
| "trim prose" / "edit text" | `erics-process-prose-standard` | Prose completeness + editorial discipline |
| "trim cot" / "remove reasoning" | `erics-process-trim-cot-leakage` | Chain-of-thought leakage detection |
| "security audit" / "owasp" / "vulnerability" | `erics-ability-cso` | OWASP Top 10 + STRIDE threat modeling |
| "ship it" / "run tests and push" | `erics-process-pre-push-checks` | Select and run evidence before a push |
| "canary" / "monitor deploy" | `erics-ability-health` | Run the available project health checks |
| "retro" / "retrospective" | `erics-ability-retro` | Weekly retro + shipping streaks |
| "save context" / "checkpoint" | `erics-ability-context-save` | Git state + decisions + remaining work |
| "restore context" / "resume session" | `erics-ability-context-restore` | Cross-workspace context restoration |
| "brainstorm" / "office hours" / "is this worth building" | `erics-ability-office-hours` | YC Office Hours six forcing questions |
| "grill me" / "sharpen my idea" / "拷问想法" / "压力测试想法" | `erics-ability-grill-me` | Stateless interview, loose idea → committable decisions |
| "grill with docs" / "codebase-aligned interview" / "代码库对齐质询" | `erics-ability-grill-with-docs` | Stateful grilling, reads code, writes CONTEXT.md + ADRs |
| "wayfinder" / "too big for one session" / "chart this effort" / "大工作量分拆" | `erics-ability-wayfinder` | Multi-session map, grilling inside decision tickets |
| "spec this out" / "file an issue" | `erics-ability-spec` | Vague intent → executable spec |
| "benchmark" / "performance regression" | `erics-ability-benchmark` | Performance regression detection |
| "model benchmark" / "compare models" | `erics-ability-benchmark-models` | Cross-model skill comparison |
| "simplify" / "find dead code" | `erics-process-find-simplifications` | Simplification candidate discovery |
| "archive notes" / "prune decisions" | `erics-process-archive-agent-notes` | Agent Note lifecycle management |
| "land stack" / "merge stacked prs" | `erics-process-merging-stacked-prs` | GitHub official PR stack landing |
| "pre-push checks" | `erics-process-pre-push-checks` | Pre-push minimal evidence selection |
| "generate docs" / "diataxis" | `erics-process-doc-standards` | Documentation structure and quality rules |
| "update docs for release" | `erics-process-doc-site-sync` | Sync documentation navigation and pages |
| "upgrade" / "sync skills" | `erics-ability-upgrade` | Check & sync upstream skill updates |
| "health check" | `erics-ability-health` | Code quality dashboard |
| "learn" / "record learnings" | `erics-ability-context-save` | Preserve decisions and remaining work |

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
