# Changelog

All notable changes to EricStack are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Project Positioning section** in `README.md` and `README_CN.md` — clarifies that EricStack is a skill metadata project + engineering toolkit, not a runnable application. References new `src/README.md`.
- **`src/README.md`** — explains why `src/main.rs` is an intentional placeholder.
- **CONTRIBUTING.md** — contributor guide covering skill authoring, sync source addition, and coding standards.
- **CHANGELOG.md** (this file).
- **`.loopx/bin/check-skill-counts.sh`** — automated consistency checker for `38 skills` claims in all documentation. Supports `--fix` mode.
- **`.loopx/bin/lint-skills.sh`** — YAML frontmatter quality lint. Enforces name/description/triggers rules, brand cleanliness, and routing hints. Supports `--strict` and `--quiet` modes.
- **Acceptance Pipeline v1.1 config** — `acceptance.env` upgraded with tiered mutation thresholds (3% / 8% / 15%), incremental cache, sandboxing, failure diagnosis (Stage 6), plugin hooks, and 8 framework adapters.
- **`APS_TOOL_AVAILABLE=false`** default — prevents silent failure when APS binaries are not yet installed.
- **`install-acceptance-pipeline.sh`** — added `--check` and `--upgrade` modes; generates v1.1 config.
- **`install-ericsstack.sh`** — added `--check`, `--dry-run`, and `--force` modes; dynamic skill count instead of hardcoded `40`.
- **`uninstall-ericsstack.sh`** — added `--check`, `--dry-run`, and `--force` modes; explicit confirmation prompt.
- **`sync-skills.sh`** — honors `protected_skills` field in sync-state.json; reports totals drift.
- **`sync-state.json` v2.0** — added `local` source, `protected_skills` list, `totals` block, `sync_policy` block.
- **Grilling family** — `erics-ability-grill-me`, `erics-ability-grill-with-docs`, `erics-ability-wayfinder` (stateless / stateful / multi-session idea interrogation), plus `docs/GRILLING_SUITE.md` and a wiki concept page. Catalog now totals 41 SKILL.md (13 process + 27 ability + 1 router).
- **Loop Engineering integration** — install/uninstall scripts manage loop-engineering state and registry goals; `docs/LOOP_ENGINEERING_INTEGRATION.md`.
- **Markdown tooling** — `.loopx/bin/check-markdown-links.py`, `regenerate-wiki-index.py`, `check-readme-bilingual.sh`, `check-wikilinks.sh`, `lib-pathsafe.sh`.
- **Rust integration tests** — `tests/catalog.rs`: catalog contract, router reachability, CLI help/invalid-arg behavior.
- **CI workflows** — `.github/workflows/ci.yml` + `skill-validate.yml` (SHA-pinned actions, least privilege).
- **Audit reports** — `docs/AUDIT_2026-08-16.md`, `AUDIT_2026-08-18.md`, `AUDIT_2026-08-25.md`.

### Changed
- **Skill count claims**: 36 → 38 across `README.md`, `README_CN.md`. (Audit finding C3.)
- **Skill catalog**: 28 SKILL.md at `v0.1.0` → 41 now; installed items = 41 catalog + 2 entry points = 43.
- **`sync-state.json`**: schema version 1.0 → 2.0; `updated_at` refreshed to 2026-08-16.
- **`registry.json`**: schema version 0.1 → 0.2; adapter upgraded `read_only_project_map_v0` → `read_write_project_map_v0`; `spawn_policy.allowed` true; `write_scope` now lists allowed paths; `requires_parent_approval` narrowed to publish/production/external-write.
- **`erics-process-archive-agent-notes` SKILL.md**: removed duplicate `---` from frontmatter; renamed H1 from "Archive DeepSeek Harness Agent Notes" to "Archive EricStack Agent Notes".
- **`erics-process-translate-docs` SKILL.md**: description cleaned — removed "DeepSeek Harness" brand reference.

### Fixed
- LoopX contract error: `registry_tracked_but_not_push_allowed` resolved by moving the runtime registry out of Git tracking (see Security below) and providing `.loopx/registry.example.json`.
- Stale `36 skills` references in `README.md` (lines 104, 129) and `README_CN.md` (lines 5, 100) — replaced with 38.
- Hardcoded `40 skills` in `uninstall-ericsstack.sh` echo — replaced with dynamic `find` count.
- APS tool availability assumption — scripts no longer claim download success when binaries are absent.

### Security
- No new external dependencies; all new scripts use only POSIX `bash` + `jq` + `rg`.
- **`.loopx/registry.json` moved out of Git tracking** (LoopX runtime state with local paths); added de-privatized `.loopx/registry.example.json` fixture; installer bootstraps from the example on fresh clones.
- **uninstall confirmation is now fail-closed** for non-TTY stdin (piped input can no longer bypass the prompt without `--force`).

## [0.1.0] - 2026-08-15

### Added
- 28 SKILL.md files (11 process + 16 ability + 1 router), as tagged at `v0.1.0`.
- 4 install scripts: `install-ericsstack.sh`, `uninstall-ericsstack.sh`, `sync-skills.sh`, `install-acceptance-pipeline.sh`.
- `.loopx/acceptance-pipeline/` skeleton (config + directory structure).
- `.loopx/wiki/` (17 pages covering concepts, entities, comparisons).
- Initial `docs/`: `TUTORIAL.md`, `LLM_WIKI_TUTORIAL.md`, `INTEGRATION.md`, `AUDIT.md` (v2).
- LoopX integration via `registry.json` + `ACTIVE_GOAL_STATE.md`.

### Notes
- This was the first auditable version. Findings from `docs/AUDIT_2026-08-16.md` (v3) drove the [Unreleased] changes above.

---

## How to Read This Changelog

- **Added** — new features
- **Changed** — changes in existing functionality
- **Deprecated** — soon-to-be removed features
- **Removed** — removed features
- **Fixed** — bug fixes
- **Security** — vulnerability fixes

Versions follow [SemVer](https://semver.org/):
- **Major** (x.0.0) — incompatible API/contract changes
- **Minor** (0.x.0) — backwards-compatible feature additions
- **Patch** (0.0.x) — backwards-compatible bug fixes
