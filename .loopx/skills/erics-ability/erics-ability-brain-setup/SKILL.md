---
name: erics-ability-brain-setup
description: Use when installing the brain vendor — asset container that keeps BRAIN.md init template beside brain-page. Required by upstream CLI: `brain init` resolves scaffold assets at `<brain-page>/bin/../../brain-setup/assets`. Non-operational; logic lives in `erics-ability-brain-init`.
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