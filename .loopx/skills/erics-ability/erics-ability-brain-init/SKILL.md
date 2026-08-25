---
name: erics-ability-brain-init
description: |
  Initialize a project's brain — scaffolds BRAIN.md, brain/ directory, and wires
  CLAUDE.md/AGENTS.md into the current project. Brain is the project-level
  persistent memory (decisions, constraints, context that survives sessions).
  Use when the user says "init brain", "brain init", "setup project brain",
  "初始化项目记忆", or "启动 brain" and the project's BRAIN.md does not yet exist.
triggers:
  - brain init
  - init brain
  - setup project brain
  - 初始化项目记忆
  - 启动 brain
---

# /brain-init — Initialize a Project Brain

You are a **calm setup operator**. The user wants durable project memory;
your job is to make the brain install cleanly, verify it works, and point at
the next step.

## Detect command

Parse the user's input:

- `/brain init` / `/init brain` → run the init flow
- `/brain init --no-wire` → skip CLAUDE.md / AGENTS.md wire
- `/brain init --agent <claude-code|codex|opencode|cursor|pi|all>` → wire
  only that agent's config (default: `all`)

If the project already has a `BRAIN.md`, tell the user "Brain is already
initialized; run `/brain-bootstrap` to seed it or `/brain-page` to add
pages" and exit.

## Pre-flight checks (idempotent)

### 1. Locate the CLI

The CLI ships inside the `brain-page` skill. After EricStack install it
lives at `~/.claude/skills/brain-page/bin/brain.mjs`. Verify:

```bash
CLI="$HOME/.claude/skills/brain-page/bin/brain.mjs"
[ -x "$CLI" ] || fail "brain CLI not found at $CLI — re-run install-ericsstack.sh"
node "$CLI" --help >/dev/null || fail "brain CLI is broken (exit $?)"
```

If `node` is missing, fail with: "brain requires Node.js ≥18 on PATH."

### 2. Verify the sibling skill is installed

The CLI resolves scaffold assets at `<bin>/../../brain-setup/assets`, so
`~/.claude/skills/brain-setup/` MUST exist alongside `brain-page`:

```bash
[ -f "$HOME/.claude/skills/brain-setup/assets/BRAIN.md" ] || \
  fail "brain-setup assets missing — re-run install-ericsstack.sh"
```

### 3. Confirm we're in a project

`brain init` must run from the project root (the directory where you want
`BRAIN.md` and `brain/` to live). If the user is in a subdirectory, ask
which directory is the project root before proceeding.

### 4. Refuse on DeepSeek Harness projects

If the project contains `notes/implemented/` or `notes/archived/`, fail
with:

> This project uses the DeepSeek Harness Agent Notes system. Brain and
> archive-agent-notes would create two competing decision corpora; do not
> run `brain init` here. Use `/erics-process-archive-agent-notes` instead.

## Init flow

### Step 1: Run the CLI

```bash
cd "<project-root>"
node "$HOME/.claude/skills/brain-page/bin/brain.mjs" init [<flags from detect>]
```

The CLI will:
1. Copy `BRAIN.md` (from sibling `brain-setup/assets/`) into the project
   root. **Never overwrites** an existing `BRAIN.md` — if one exists, it
   exits with an error.
2. Create `brain/` with `pages/` subdirectory + initial root pages +
   `index.md`.
3. Wire the marked brain block into `CLAUDE.md` / `AGENTS.md` (or the
   single `--agent` flag's config). The marked block is delimited by
   `<!-- brain:begin -->` / `<!-- brain:end -->`; the CLI only edits
   inside that block, never the whole file.

### Step 2: Verify

```bash
cd "<project-root>"
[ -f BRAIN.md ]              || fail "BRAIN.md not created"
[ -d brain ]                  || fail "brain/ not created"
node "$CLI" brain-dir         # should print brain dir + source + exists=true, populated=true
node "$CLI" list-pages        # should list root pages (architecture, stack, ...)
grep -q '<!-- brain:begin -->' CLAUDE.md 2>/dev/null && echo "wire OK" || \
  ( [ -f AGENTS.md ] && grep -q '<!-- brain:begin -->' AGENTS.md && echo "wire OK" )
```

### Step 3: Offer next steps

Use AskUserQuestion (max 4 options):

- A) **Bootstrap from code / git log** — runs `/brain-bootstrap` (brownfield)
- B) **Interview me first** — runs `/brain-bootstrap` (greenfield interview mode)
- C) **Skip, I'll write pages myself** — points at `/brain-page`

If A or B, route to `erics-ability-brain-bootstrap`. If C, stop here.

## After init: light contract for the project

Once `BRAIN.md` exists, every EricStack skill should respect it:

- **Before** starting a task: `node "$CLI" list-pages` and `read-page` the
  relevant ones.
- **When a decision crystallizes**: write it through the CLI — never hand-edit
  `brain/`.
- **When overturning a prior conclusion**: `update-truth` (rewrite the
  `compiled_truth` block) and `append-timeline --kind reversal`.

## Important Rules

- This skill does **not** edit code in the user's project — only `BRAIN.md`,
  `brain/`, and the marked wire block in `CLAUDE.md` / `AGENTS.md`.
- **Never overwrite** an existing `BRAIN.md`. If one exists, route the
  user to `/brain-page` instead.
- The CLI must be invoked through `node`, not the symlink alone, because
  the CLI uses ESM `import "../lib/brain.mjs"` which fails if the working
  directory is wrong.
- Do not write user secrets into brain pages. Pages are checked into git
  unless the user has explicitly gitignored `brain/`.