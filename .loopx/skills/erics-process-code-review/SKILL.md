---
name: erics-process-code-review
description: Use when reviewing a pull request — enforces coverage, prose, and invariant discipline. Supports incremental review for large PRs.
triggers:
  - code review
  - review this pr
  - review pr
  - pr review
  - review only new commits
  - incremental review
  - 大PR审查
---

# Code Review — EricStack Process Discipline

**Coverage + Prose + Invariant — three dimensions, every PR, every time.**

## Modes

This skill supports three modes, selected by PR size and context:

| Mode | Trigger | When |
|---|---|---|
| **Full Review** | Default (diff < 600 lines) | Small-to-medium PRs |
| **Incremental Review** | "incremental" / "只审查新改动" / 3+ new commits | PR builds on existing code |
| **Large PR Compression** | "large pr" / diff ≥ 600 lines | Large refactors, wide changes |

---

## Mode 1: Full Review

### Step 1 — Establish base and head

```bash
# Verify the PR's base (target branch) and head (latest commit)
git log --oneline -1          # confirm current HEAD
git log --oneline origin/main # confirm base ref
```

### Step 2 — Get the diff

```bash
git diff base..head --stat    # changed files summary
git diff base..head           # full diff
```

### Step 3 — Three-dimensional review

#### Coverage

- Every new public API has at least one test
- Every bug fix has a regression test
- Error paths have test coverage
- No code paths that are "obviously untested"

#### Prose

- PR description explains **what** changed and **why**
- Commit messages follow conventional commits (`feat:`, `fix:`, `docs:`)
- Comments explain **why**, not **what** (the code shows what)
- No implementation narration, no commented-out review history
- Run [erics-process-prose-standard](../erics-process-prose-standard/SKILL.md) on all visible text

#### Invariant

- Critical assertions are present and correct
- No dropped errors (missing `?` on Result-returning calls)
- Ownership and disposal are properly tracked
- Concurrency patterns are sound (no races in async code)

### Step 4 — Report findings

```
## Review Report: [PR Title]

### Blockers
- [file:line] — description of blocking issue

### Suggestions
- [file:line] — actionable improvement

### Coverage
- [file:function] — untested path

### Prose
- PR description: needs clarification on why this change was made

### Invariant
- [file:line] — missing error handling
```

---

## Mode 2: Incremental Review

**Triggered when:** PR has 3+ commits beyond base, or user says "incremental review"

### Logic

1. Find the diff between base and head
2. Identify only the files changed in new commits
3. Run full review only on changed files
4. For unchanged files: reference prior review state if available

```bash
# Find changed files since base
git diff base..head --name-only

# Find commits beyond the last reviewed state
git log base..head --oneline

# Diff only the changed files
git diff base..head -- <list-of-changed-files>
```

### Output

```
## Incremental Review: [PR Title]
Base: [base SHA]  Head: [head SHA]
Changed files: N  New commits: N

### New Code (full review)
... findings on new/changed code ...

### Unchanged Files (no review)
[List of files skipped — assuming prior review is valid]
```

---

## Mode 3: Large PR Compression

**Triggered when:** diff > 600 lines, or user says "large pr"

### Logic

1. Split diff by module/directory
2. Each chunk gets its own focused review
3. High-priority chunks (security, error handling) reviewed first
4. Results merged and deduplicated

```bash
# Split by directory
git diff base..head --stat | awk '{print $NF}' | cut -d/ -f1 | sort -u
```

### Chunk Priority

| Priority | Directory/Pattern | Reason |
|---|---|---|
| P0 | `auth/`, `security/`, `payment/` | High risk |
| P0 | `**/*test*` | Coverage validation |
| P1 | `api/`, `routes/`, `handlers/` | Interface contracts |
| P1 | `**/*invariant*` | Critical logic |
| P2 | `utils/`, `lib/` | Supporting code |
| P2 | `docs/` | Prose only |

### Output

```
## Large PR Review: [PR Title]
Total changes: N files, M lines
Compression: N chunks

### Chunk 1: auth/ (P0 — security)
... findings ...

### Chunk 2: api/ (P1 — interface)
... findings ...

---
Total findings: N blockers, M suggestions
High-priority changes require extra scrutiny.
```

---

## Blocking requirements

1. **New prose receives semantic review.** Run [erics-process-prose-standard](../erics-process-prose-standard/SKILL.md) on every added Markdown passage, comment, prompt, and visible string.
2. **Docs match the code.** Config, defaults, errors, and public behavior update docs in the same diff.
3. **Core type docs match.** Changes to public types update the appropriate type documentation.
4. **Required evidence exists.** Verify tests cover the exhaustive matrix; review the gaps neither tests nor linters can detect.
5. **Invariant companions are semantic.** For every touched invariant file, require a meaningful owner relationship.

## Reporting findings

State the defect, location, impact, and evidence. Place findings inline on the tightest relevant diff range. Separate blockers from suggestions. Use GitHub review threads for replies. When receiving review, verify each claim and fix or rebut on technical grounds.

## Sources of truth

- [AGENTS.md](../../AGENTS.md) — project conventions (if exists)
- [erics-process-prose-standard](../erics-process-prose-standard/SKILL.md) — prose quality
- [erics-process-pre-push-checks](../erics-process-pre-push-checks/SKILL.md) — pre-push gates
