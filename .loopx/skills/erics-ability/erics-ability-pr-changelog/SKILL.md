---
name: erics-ability-pr-changelog
description: Use when preparing a release — generates or updates CHANGELOG.md entries based on PR changes and conventional commits.
triggers:
  - update changelog
  - changelog
  - release notes
  - 更新日志
  - generate changelog
  - PR 发版
---

# CHANGELOG Generator

**Reads PR commits and diff, generates keep-a-changelog 1.0.0 compliant entries.**

---

## Gather context

```bash
# Get commit messages (these carry the conventional commit type)
git log --oneline base..head

# Get diff summary
git diff base..head --stat

# Check if CHANGELOG.md exists
cat CHANGELOG.md 2>/dev/null | head -50 || echo "No CHANGELOG.md found"

# Read AGENTS.md for changelog conventions
cat AGENTS.md 2>/dev/null | grep -i changelog || echo "No changelog conventions in AGENTS.md"
```

---

## Determine SemVer级别

From conventional commits since last release:

| Type | SemVer Impact |
|---|---|
| `feat` | Minor (+1) |
| `fix` | Patch (+1) |
| `feat:` with `BREAKING CHANGE` | Major (+1) |
| `fix:` with `BREAKING CHANGE` | Major (+1) |
| `docs` | Patch (if anything) |
| `refactor` | Patch |
| `test` | None |
| `chore` | None |
| `perf` | Minor |
| `revert` | Patch |

**Output:** `Recommended version bump: patch | minor | major`

---

## Generate entries

### Categorize commits

Group each commit into one of:
- **Added** — new features (`feat:`)
- **Changed** — changes to existing functionality
- **Deprecated** — soon-to-be-removed features
- **Removed** — removed features
- **Fixed** — bug fixes (`fix:`)
- **Security** — security improvements
- **Breaking** — any `BREAKING CHANGE` in footer or `!` in type

### Entry format (keep-a-changelog 1.0.0)

```markdown
## [<version>] — <YYYY-MM-DD>

### Added
- [<commit short hash>](commit URL) <description> (@author)

### Changed
- ...

### Fixed
- ...

### Security
- ...

### Breaking
- ...
```

---

## Update CHANGELOG.md

If CHANGELOG.md exists:
1. Prepend new entries to the top (after the header)
2. Preserve existing entries
3. Do not modify existing version blocks

If CHANGELOG.md does not exist:
1. Create from template
2. Include all commits in this release

---

## Generate release notes

Separate from CHANGELOG.md, generate a draft for GitHub release:

```
## <version> (<YYYY-MM-DD>)

<one paragraph summary of this release>

### Highlights
- <top 3 most important changes>

### Breaking Changes
- <list any breaking changes>

### Full Changelog
<list of all commits>
```

---

## Output

```
## SemVer Recommendation
<patch | minor | major>

## CHANGELOG Entries
<generated entries in keep-a-changelog format>

## Release Notes Draft
<draft suitable for GitHub release>

## CHANGELOG.md Status
- Updated: <path to updated file>
- Created: <path if newly created>
```

---

## Relationship to other skills

| Related Skill | Distinction |
|---|---|
| `erics-process-pre-push-checks` | Pre-push-checks runs before push. `pr-changelog` runs before release. |
| `erics-ability-pr-describe` | `pr-describe` generates PR-level description. `pr-changelog` generates release-level changelog. |
