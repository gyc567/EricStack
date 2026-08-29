# Anti-Slop Integration

EricStack integrates [dmmulroy/anti-slop](https://github.com/dmmulroy/anti-slop) as a vendored oxlint plugin with 15 rules that reject low-evidence and low-signal TypeScript/JavaScript patterns in AI-generated code.

## What is anti-slop?

Anti-slop is an opinionated oxlint plugin that catches 15 specific code patterns that are common in AI-generated code but are incorrect, unmaintainable, or unsafe:

| Category | Rules |
|----------|-------|
| **Type Safety** | no-chained-type-assertions, no-widen-then-assert, require-safety-comment-for-type-assertion, no-known-value-widening |
| **Reflection** | no-reflect-apply, no-reflect-get, no-runtime-typeof |
| **Generic Safety** | no-object-parameters, no-unknown-parameters, no-unknown-returns, no-unknown-type-aliases, no-unsafe-dictionary-type |
| **Code Structure** | no-conditional-empty-object-spread, no-shape-in-symbol-names |
| **Testing** | no-module-mocking |

| **Effect** | no-service-constructor-imports |



## Why vendored?

Anti-slop is **vendored** (copied into this repo) rather than added as a fixed npm dependency. This is the [official recommendation](https://github.com/dmmulroy/anti-slop#installation) — it allows teams to read, adapt, and own the rules without being tied to an upstream version.

EricStack syncs from upstream with a custom script that preserves EricStack-specific configuration files.

## File Structure

```
tools/oxlint/anti-slop/          ← Vendored plugin (synced from upstream)
├── oxlintrc.ts                  ← EricStack config (protected)
├── package.json                  ← EricStack package (protected)
├── SKILL.md                     ← Plugin overview (protected)
├── tsconfig.json
└── src/                         ← Upstream source (synced)
    ├── index.ts
    ├── rules/                   ×15
    ├── shared/
    └── effect/

.loopx/skills/erics-process-anti-slop/
└── SKILL.md                     ← Canonical rule reference for AI

.loopx/bin/sync-anti-slop.sh   ← Upstream sync script
```

## Syncing from Upstream

```bash
# Check for updates
bash .loopx/bin/sync-anti-slop.sh --check

# Apply sync
bash .loopx/bin/sync-anti-slop.sh --execute
```

The sync script:
- Shallow clones the upstream repo (`--depth 1`)
- Copies only the `src/` directory
- Tracks state in `sync-state.json` with commit SHA and tree hash
- Detects concurrent upstream pushes during clone
- **Never** overwrites protected files: `oxlintrc.ts`, `package.json`, `SKILL.md`, `tsconfig.json`

### Adding new protected files

If you add EricStack-specific files to the plugin directory that should never be overwritten, add them to the `PROTECTED_PATTERNS` array in `sync-anti-slop.sh`.

## Enabling in APS

By default, the oxlint anti-slop check is **disabled** (`APS_OXLINT_ENABLED=false`) because EricStack is primarily a Rust/Skill project without TypeScript source files.

To enable:

```bash
# Edit .loopx/acceptance-pipeline/acceptance.env
APS_OXLINT_ENABLED=true
```

When enabled, Stage 0 (Lint) runs `oxlint` with the anti-slop plugin against all `src/**/*.ts` files. Violations are reported as lint errors and block the pipeline.

### Ignored paths

Agent asset directories are excluded from linting:
```
.agent/**  .agents/**  .claude/**  .codex/**  .continue/**
.cursor/**  .gemini/**  .opencode/**  .pi/**  .roo/**  .windsurf/**
```

## Relationship with erics-process-anti-slop Skill

The `erics-process-anti-slop` skill (`.loopx/skills/erics-process-anti-slop/SKILL.md`) is the **human-readable canonical reference** for the 15 rules. It provides:
- Rule descriptions with before/after examples
- AI generation guidance
- Documentation standards (from ai-slop-cleaner)
-协同 relationship with ai-slop-cleaner

The oxlint plugin is the **machine-checkable enforcement** used by APS. The skill is used at code review / generation time; the plugin is used in the automated pipeline.

## Upgrade Process

When upstream anti-slop releases a new version:

1. Run `bash .loopx/bin/sync-anti-slop.sh --check` to see if updates are available
2. Review the diff in `tools/oxlint/anti-slop/src/` after sync
3. If there are breaking changes to rule behavior, update `oxlintrc.ts` accordingly
4. Verify `bash .loopx/bin/lint-skills.sh` still passes (skill examples must not violate rules)
5. If APS_OXLINT_ENABLED=true, run the pipeline to verify no regressions

## Adding New Rules

To add a new rule to the EricStack anti-slop plugin:

1. Implement the rule in `tools/oxlint/anti-slop/src/rules/`
2. Export it from `tools/oxlint/anti-slop/src/index.ts`
3. Enable it in `tools/oxlint/anti-slop/oxlintrc.ts`
4. Document it in `erics-process-anti-slop/SKILL.md`
5. Add it to the rule index table in this file
6. Sync: `bash .loopx/bin/sync-anti-slop.sh --execute --yes` (to preserve your changes)

## Dependencies

- `oxlint` ^0.14.0
- `@oxlint/plugins` ^0.7.0

Install with:
```bash
npm install -g pnpm
cd tools/oxlint/anti-slop && pnpm install
```

Or via the installer: `bash .loopx/bin/install-ericsstack.sh` (Step 4b).
