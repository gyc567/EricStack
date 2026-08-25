# Contributing to EricStack

> Thank you for your interest in EricStack! This document explains how to add, modify, or report issues for skills in the LoopX-powered engineering loop system.

---

## Project Overview

EricStack is a **skill metadata project + engineering toolkit**. It bundles:
- **41 SKILL.md files** (13 process discipline + 27 engineering ability + 1 router)
- **4 shell scripts** (install / uninstall / sync / aps installer)
- **APS framework config** (7-stage acceptance pipeline specification)
- **Docs + Wiki** (tutorials, audit, integration plans, references)

The `src/` directory is an **intentional placeholder** — EricStack does not ship a runnable application. All skills are designed to operate on **your** codebase after installation. See [`README.md`](README.md) → "Project Positioning" and [`src/README.md`](src/README.md) for the full rationale.

---

## How to Contribute

### 1. Improve an existing skill

Skills are plain Markdown files in `.loopx/skills/<kind>/<skill-name>/SKILL.md`. Each has a YAML frontmatter:

```yaml
---
name: erics-ability-investigate
description: Use when...  (must contain "Use when" routing hint)
triggers:
  - keyword1
  - keyword2
allowed-tools:  # optional
  - Read
  - Bash
---
```

**Before editing**, run:
```bash
bash .loopx/bin/lint-skills.sh           # check current quality
bash .loopx/bin/check-skill-counts.sh    # ensure doc counts match
```

**After editing**, re-run both to confirm zero errors. Warnings are acceptable but address them when reasonable.

### 2. Add a new skill

1. **Decide the kind:**
   - `erics-process-*` — discipline / enforcement (review, prose, simplify, docs)
   - `erics-ability-*` — execution / productivity (plan, debug, benchmark, retro)
2. **Pick a descriptive name** with a clear trigger word. Avoid generic names like `helper` or `utils`.
3. **Author the SKILL.md** following the frontmatter template above. The first H1 in the body should reference the skill name.
4. **Write a trigger-aware description** — describe WHEN to use it, not just WHAT it does. This drives LLM routing.
5. **Add 2-5 triggers** with at least one English keyword.
6. **Run validators** (see step 1 above).
7. **Update sync-state.json** — add the skill to `sources.local.skills_imported` and `protected_skills` (to prevent upstream sync from overwriting).

### 3. Add a new sync source (advanced)

If you're integrating skills from a new upstream:
1. Add the source to `.loopx/sync-state.json` under `sources.<name>` with `url`, `commit`, `skills_imported`, `last_sync`.
2. Update `bin/sync-skills.sh` to handle the new URL.
3. Add the brand-rewrite sed rules.
4. Run `bash .loopx/bin/sync-skills.sh --check` to verify.
5. Add a brand-cleanliness test in CI (see `.github/workflows/ci.yml`).

### 4. Fix documentation

- Docs are in `docs/` and `README*.md`.
- Run `bash .loopx/bin/check-skill-counts.sh` after any count change.
- Bilingual: update both `README.md` (English) and `README_CN.md` (Chinese).
- Cross-references should be Markdown-relative paths.

### 5. Report issues

Use GitHub Issues with one of these labels:
- `bug` — skill behavior is wrong
- `enhancement` — new skill or improvement
- `docs` — documentation error or gap
- `audit` — references `docs/AUDIT_2026-08-16.md` findings

Please include:
- Which skill (or path) is affected
- What you expected vs what happened
- Steps to reproduce (especially for skills that touch external systems)

---

## Development Workflow

```bash
# 1. Validate before commit
bash .loopx/bin/lint-skills.sh
bash .loopx/bin/check-skill-counts.sh
bash .loopx/bin/sync-skills.sh --check

# 2. Build & test
cargo build       # validates the placeholder src/main.rs
cargo test        # runs any Rust tests (none yet)

# 3. Install locally
bash .loopx/bin/install-ericsstack.sh --dry-run  # preview
bash .loopx/bin/install-ericsstack.sh           # apply
```

---

## Coding Standards

### YAML Frontmatter

- `name` must match the parent directory name.
- `description` should be ≤ 280 characters, contain "Use when", and never reference upstream brand names (gstack, garry, deepseek).
- `triggers` should have ≥ 2 entries with at least one English keyword.
- `allowed-tools` is optional; default is the host's full tool set.

### Body Markdown

- First H1 should be the skill's purpose or main concept.
- Use `##` for major sections, `###` for subsections.
- Avoid raw HTML except for `<details>` callouts.
- Code blocks should specify language: ```` ```bash ````, ```` ```yaml ````, etc.
- Wikilinks use `[[page-name]]` syntax in `.loopx/wiki/`, Markdown links elsewhere.

### Shell Scripts

- All scripts in `.loopx/bin/` MUST support `--check` and `--dry-run` modes.
- Use `set -euo pipefail`.
- Quote all variables.
- Use `jq` for JSON parsing, not grep.
- Color output only when stdout is a TTY: `[ -t 1 ] && ...`.

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat(skill): add erics-ability-x`
- `fix(skill): correct description in erics-process-y`
- `docs: update README with new skill count`
- `chore(sync): bump deepseek-harness commit`

---

## Architecture Decisions

- **Why a Rust crate?** — `src/main.rs` placeholder satisfies `Cargo.toml` so that Graft, loopx, and rust-analyzer can detect this as a Rust project. See [`src/README.md`](src/README.md).
- **Why symlinks instead of copies?** — `install-ericsstack.sh` symlinks from `~/.claude/skills/` back to `.loopx/skills/`, so local edits are immediately visible to the host. No sync step needed.
- **Why `protected_skills`?** — `sync-skills.sh` honors `sync-state.json`'s `protected_skills` list to prevent upstream sync from overwriting locally-authored skills. Always add new local skills to this list.
- **Why `aps-demo/` is empty?** — APS requires YOUR project to have features and step handlers. A demo would be misleading. See `docs/APS_INTEGRATION.md` for the full spec.

---

## Code of Conduct

Be kind, be precise, be useful. We're all here to make engineering loops more honest.

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License — see [`LICENSE`](LICENSE).
