---
name: erics-ability-brain-setup
description: |
  Asset-only skill required as a runtime sibling of `erics-ability-brain-page`.
  Carries the BRAIN.md init template and optional pre-commit / SessionStart
  hooks from mindmux/brain.md. This is a vendor constraint of the upstream
  CLI — `brain init` resolves scaffold assets at
  `<brain-page>/bin/../../brain-setup/assets`, so both skills MUST be
  installed side-by-side. Body is non-operational; init logic lives in
  `erics-ability-brain-init`.
triggers:
  - brain setup assets
  - brain scaffold assets
---

# /brain-setup — Vendor Asset Container (PR-1)

> **This skill is asset-only.** It exists in EricStack because the upstream
> `brain` CLI resolves scaffold assets at a fixed sibling path
> (`<brain-page>/bin/../../brain-setup/assets`). Without it installed next to
> `erics-ability-brain-page`, `brain init` fails. There is no operational body
> for this skill — agents should invoke `erics-ability-brain-init` instead.

## What this skill carries (PR-1)

```
.loopx/skills/erics-ability-brain-setup/
├── SKILL.md                 # this file (non-operational)
├── assets/
│   └── BRAIN.md             # init template (vendored from mindmux/brain.md @ dafdde9d)
└── hooks/                   # vendored, NOT installed by default
    ├── pre-commit
    └── session-start
```

## Install behavior

- `assets/BRAIN.md` — **always installed** by PR-3 install script (copied to
  `~/.claude/skills/erics-ability-brain-setup/assets/`).
- `hooks/pre-commit`, `hooks/session-start` — **opt-in only**; PR-3 install
  script copies them only when the user opts in (PR-3 default is **off** to
  avoid surprising existing workflows).

## Upstream references

- Asset source: `https://github.com/mindmuxai/brain.md/tree/main/skills/brain-setup`
- License: Apache-2.0 (see `THIRD_PARTY_LICENSES.md`)
- Pin: commit `dafdde9d9981895b149d6285ef19fa2ea9092747` (recorded in
  `.loopx/sync-state.json#sources.mindmux-brain-md`)