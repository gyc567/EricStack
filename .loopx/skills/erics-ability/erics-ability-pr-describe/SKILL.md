---
name: erics-ability-pr-describe
description: Use when a pull request is complete and needs an accurate title, summary, walkthrough, labels, and breaking-change notes.
triggers:
  - pr describe
  - describe this pr
  - 生成 PR 描述
  - PR 描述
  - generate pr description
  - summarize this pr
---

# PR Description Generator

**Input:** PR diff, commit messages, file list
**Output:** PR title, type, summary, walkthrough, labels, breaking changes

---

## Step 1 — Gather context

```bash
# Get commit messages
git log --oneline base..head

# Get changed files
git diff base..head --stat

# Get full diff (for summary generation)
git diff base..head

# Read AGENTS.md if it exists
cat AGENTS.md 2>/dev/null || echo "No AGENTS.md found"

# Read repo label conventions (if .github/labels exists)
cat .github/labels 2>/dev/null | head -30 || echo "No labels file"
```

---

## Step 2 — Generate PR description

### PR Title

Format: `<type>: <imperative-short-description>`

Types: `feat` / `fix` / `docs` / `refactor` / `test` / `perf` / `chore` / `revert`

Rules:
- Imperative mood: "add login" not "added login" or "adding login"
- Max 72 characters
- No period at end
- Reference ticket if present: `feat: add OAuth login (PROJ-123)`

### PR Type

From conventional commits spec:
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only
- `style` — formatting, no code change
- `refactor` — code change that neither fixes a bug nor adds a feature
- `test` — adding or correcting tests
- `perf` — performance improvement
- `chore` — build process, auxiliary tools, deps
- `revert` — reverts a previous commit

### PR Summary

3 parts:
1. **What** — one sentence describing the change itself
2. **Why** — one sentence on the motivation or problem being solved
3. **How** — optional one sentence on approach if non-obvious

### PR Walkthrough

Group files by module/feature. For each module:
- One line: `<file>: <what changed and why>`
- Prioritize files that touch public APIs or user-facing behavior

### PR Labels

Generate 2-5 labels from this set (match repo conventions if `.github/labels` exists):
- `type:feat` / `type:fix` / `type:docs` / `type:refactor` / `type:test` / `type:perf`
- `scope:auth` / `scope:api` / `scope:ui` / `scope:db` / `scope:infra`
- `security` / `breaking` / `deprecation` / `needs-tests`

### Breaking Changes

Check for:
- Removing or renaming a public API
- Changing function signatures
- Changing behavior of existing endpoints
- Removing configuration options
- Database schema migrations

If found: append `⚠️ Breaking Change:` with specific API/behavior that breaks.

---

## Step 3 — Self-Reflection

After generating the description, ask:
1. "Does this description let someone who didn't write the PR understand what changed?"
2. "Are the labels accurate and complete?"
3. "Did I miss any important files or changes?"
4. "Is the walkthrough organized by feature, not by file listing order?"

If any answer is no, revise.

---

## Output Template

```
## PR Title
<type>: <imperative-short-description>

## PR Type
`<type>`

## Summary
**What:** <one sentence>
**Why:** <one sentence>
**How:** <optional one sentence>

## Walkthrough
- `<module>/<file>.ext`: <one-line change summary>
- ...

## Labels
`label1` `label2` `label3`

## Breaking Changes
⚠️ Breaking Change: <description> (if any)
```

---

## Self-Reflection Checklist

Before presenting the final description to the user, verify:
- [ ] Title is under 72 chars and uses imperative mood
- [ ] Type matches conventional commits spec
- [ ] Summary explains both what changed and why
- [ ] Walkthrough is organized by feature, not file order
- [ ] Labels match repo conventions (if available)
- [ ] Breaking changes are accurately detected
- [ ] No jargon or acronyms unexplained
