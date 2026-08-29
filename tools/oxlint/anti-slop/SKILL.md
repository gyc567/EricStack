---
name: oxlint-anti-slop
description: "OXLINT plugin for anti-slop rules — auto-generated, managed by sync-anti-slop.sh"
user-invocable: false
---

# Anti-Slop OXLINT Plugin

This directory contains the vendored [anti-slop](https://github.com/dmmulroy/anti-slop) oxlint plugin source, synced from upstream.

## Overview

The plugin implements 15 ESLint-compatible lint rules that reject low-evidence and low-signal TypeScript/JavaScript patterns. Rules are defined in `src/rules/` and exposed via `src/index.ts`.

## File Structure

```
tools/oxlint/anti-slop/
├── oxlintrc.ts          ← EricStack configuration (protected — never overwritten by sync)
├── package.json         ← EricStack package name (protected)
├── tsconfig.json
├── SKILL.md             ← This file (protected)
└── src/
    ├── index.ts         ← Plugin entry point
    ├── shared/          ← Shared utilities
    ├── rules/           ← 15 rule implementations
    └── effect/          ← Effect-specific rules
```

## Syncing from Upstream

```bash
# Check for updates
bash .loopx/bin/sync-anti-slop.sh --check

# Apply sync
bash .loopx/bin/sync-anti-slop.sh --execute
```

**Protected files** — these are never overwritten by sync:
- `oxlintrc.ts` — EricStack-specific ignore patterns and rule config
- `package.json` — EricStack package name and devDeps
- `tsconfig.json`
- `SKILL.md`

## Enabling in APS

In `.loopx/acceptance-pipeline/acceptance.env`:

```env
APS_OXLINT_ENABLED=true
APS_OXLINT_PLUGIN=./tools/oxlint/anti-slop/src/index.ts
APS_OXLINT_SEVERITY=error
```

When enabled, Stage 0 (Lint) runs `oxlint` with the anti-slop plugin against all `src/**/*.ts` files.

## Quick Reference

| Rule | Description |
|------|-------------|
| no-chained-type-assertions | Rejects `as A as B` without validation |
| no-widen-then-assert | Rejects widening then asserting back |
| require-safety-comment-for-type-assertion | Requires SAFETY comment on non-const assertions |
| no-known-value-widening | Rejects discarding known literal values |
| no-reflect-apply | Rejects Reflect.apply |
| no-reflect-get | Rejects Reflect.get |
| no-runtime-typeof | Rejects ad-hoc typeof narrowing |
| no-object-parameters | Rejects `object` as function parameter |
| no-unknown-parameters | Rejects `unknown` parameters (except `cause`) |
| no-unknown-returns | Rejects `unknown` return types |
| no-unknown-type-aliases | Rejects aliases that hide `unknown` |
| no-unsafe-dictionary-type | Rejects `Record<string, unknown>` |
| no-conditional-empty-object-spread | Rejects `...{}` conditional spreads |
| no-shape-in-symbol-names | Rejects `Shape` in symbol names |
| no-module-mocking | Rejects `vi.mock` / `jest.mock` |
| no-service-constructor-imports | (Effect) Rejects direct capability constructor imports |

## Relationship with erics-process-anti-slop Skill

This plugin is the **automated enforcement** layer for the rules defined in `erics-process-anti-slop`. The skill (`erics-process-anti-slop`) provides the human-readable rule descriptions and is used at code review / generation time; this plugin provides the machine-checkable enforcement in the APS pipeline.

The skill file at `.loopx/skills/erics-process-anti-slop/SKILL.md` is the **canonical source** for the rule descriptions and examples.
