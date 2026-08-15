---
name: erics-ability-pr-improve
description: Use when you want actionable code improvement suggestions for a PR — analyzes the diff and produces prioritized, self-reviewed recommendations.
triggers:
  - pr improve
  - improve this pr
  - 代码改进建议
  - PR 改进
  - suggest improvements
  - code suggestions
---

# PR Code Improvement Suggestions

**Two-stage design: generate suggestions, then self-review to filter low-quality ones.**

---

## Stage 1 — Generate Suggestions

### Gather context

```bash
git diff base..head --stat
git diff base..head
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md"
```

### Generate per-file suggestions

For each changed file, identify:
- **Naming** — variables, functions, types that could be clearer
- **Comments** — missing explanations for non-obvious logic
- **Error handling** — missing `?`, unhandled error paths
- **Edge cases** — unchecked boundary conditions
- **Code style** — patterns that deviate from project style
- **Performance** — unnecessary allocations, redundant work

### Suggestion format

```markdown
### [file:line] — <category>

**Issue:** <description of the problem>
**Current:** <code snippet if applicable>
**Suggested:** <improved code snippet if applicable>
**Priority:** P0 / P1 / P2
**Effort:** low / medium / high
```

### Priority rules

| Priority | When |
|---|---|
| **P0** | Security issue, data corruption risk, unhandled error crash |
| **P1** | Logic error, missing edge case, unclear naming causing maintenance burden |
| **P2** | Style, minor readability, cosmetic improvements |

---

## Stage 2 — Self-Review

**Filter out low-quality suggestions before presenting to the user.**

For each suggestion from Stage 1, ask:

1. **Accuracy** — Is the issue real? Will the suggested fix actually improve the code?
2. **Cost/Benefit** — Is the improvement worth the change? (Don't suggest renaming a function used in 20 places for minor clarity gain)
3. **Style conflict** — Does the suggestion conflict with project conventions in AGENTS.md?
4. **Completeness** — Does the suggestion handle all related cases, or does it create new problems?

### Self-Review output format

```markdown
### After self-review:

✅ [file:line] — <kept suggestion, brief justification>
❌ [file:line] — <removed suggestion, reason>
```

Keep only suggestions that survive all four checks.

---

## Executable suggestions (low-effort only)

If a suggestion requires < 5 lines of diff and is clearly correct:

```
## Executable Patch

The following suggestion is small enough to apply directly:

\`\`\`diff
<file>
--- a/<file>
+++ b/<file>
@@ -line,count +line,count @@
-<old code>
+<new code>
\`\`\`

Apply? (yes/no)
```

Only suggest patches for P0/P1 issues. Never auto-apply.

---

## Relationship to other skills

| Related Skill | Distinction |
|---|---|
| `erics-process-find-simplifications` | Finds **architectural** simplification opportunities (dead code, over-abstraction, wrong data structures). `pr-improve` finds **local code** improvements (naming, error handling, comments). |
| `erics-ability-health` | Health is a **dashboard** of overall project quality. `pr-improve` is **PR-specific** and actionable. |
| `erics-process-prose-standard` | Prose standard handles **visible text quality**. `pr-improve` handles **code** quality. |

---

## Output template

```
## Stage 1: Code Improvement Suggestions

### [file:line] — <category>
**Issue:** ...
**Suggested:** ...
**Priority:** P0 | P1 | P2
**Effort:** low | medium | high

...

## Stage 2: Self-Review

✅ [file:line] — <kept>
❌ [file:line] — <removed because: ...>

## Summary
- P0 issues: N
- P1 issues: N
- P2 issues: N
- Executable patches: N (pending your confirmation)
```
