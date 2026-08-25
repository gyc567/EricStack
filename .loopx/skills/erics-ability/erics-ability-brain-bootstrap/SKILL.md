---
name: erics-ability-brain-bootstrap
description: Use when the user says "brain bootstrap", "seed project brain", "播种 brain", "bootstrap project memory", or right after `/brain init` on an existing project. Drafts root pages from code, docs, and git log (brownfield), or interviews the user (greenfield).
triggers:
  - brain bootstrap
  - seed project brain
  - 播种 brain
  - bootstrap project memory
---

# /brain-bootstrap — Seed a Project Brain

You are a **synthesizing historian**. The brain is empty; you fill it from
what already exists in the project (code, docs, git log) or from what the
user knows (interview). Never fabricate; mark uncertainty explicitly.

## Detect mode

```bash
[ -d .git ] && MODE=brownfield || MODE=greenfield
[ -f package.json ] || [ -f Cargo.toml ] || [ -f pyproject.toml ] || \
  [ -f go.mod ] || [ -f pom.xml ] || MODE=greenfield
```

Default `brownfield` if any of: `.git/`, dependency manifest, `README.md`,
`docs/` directory exists. Default `greenfield` otherwise. Always ask to
override before treating it as the other mode.

If the user says "interview me first" or the project is brand-new, force
`greenfield`.

## HARD GATE — DeepSeek Harness projects

```bash
if [ -d notes/implemented ] || [ -d notes/archived ]; then
  echo "REFUSE: project uses DeepSeek Harness Agent Notes."
  echo "Use /erics-process-archive-agent-notes for decision tracking."
  exit 1
fi
```

Brain and `archive-agent-notes` maintain two competing decision corpora;
running both creates contradictions. **Never run brain-bootstrap on a
DeepSeek Harness project.**

## Pre-flight

```bash
[ -f BRAIN.md ] || fail "Brain not initialized — run /brain init first"
CLI="$HOME/.claude/skills/brain-page/bin/brain.mjs"
[ -x "$CLI" ] || fail "brain CLI not installed — re-run install-ericsstack.sh"
node "$CLI" brain-dir | grep -q "populated: true" || \
  fail "brain/ is empty — init must have failed silently"
node "$CLI" list-pages >/dev/null || fail "list-pages failed"
```

## Brownfield flow

### Step 1: Inventory the project

```bash
echo "=== stack ===" && cat package.json Cargo.toml pyproject.toml go.mod pom.xml 2>/dev/null | head -100
echo "=== README ===" && head -50 README.md 2>/dev/null
echo "=== docs tree ===" && find docs -maxdepth 2 -type f 2>/dev/null | head -30
echo "=== git log (50 most recent) ===" && git log --oneline -50 2>/dev/null
echo "=== top-level dirs ===" && ls -la
```

### Step 2: Draft the six root pages

The CLI ships six fixed root pages (`background`, `architecture`, `flow`,
`mindmap`, `stack`, `roadmap`). For each, write `update-root <slug>` with
content derived from the inventory:

- `background` — what the project is, who it's for, problem it solves
- `architecture` — major subsystems and their relationships (use a tree,
  not prose)
- `flow` — 2–5 critical user/system flows end-to-end
- `mindmap` — feature surface, grouped by capability
- `stack` — languages, frameworks, infra; with the **why** for each choice
- `roadmap` — current quarter goals + known constraints

```bash
cat <<'EOF' | node "$CLI" update-root stack
# Stack

- TypeScript + Node 22 — chosen for ...
- PostgreSQL — chosen for concurrent writers, JSONB
- ...
EOF
```

**Synthesize, don't copy-paste.** Each root page should be ~30–80 lines.
Mark anything uncertain with `<!-- uncertain: reason -->` inline so the
user can correct it.

### Step 3: Surface key decisions from git log

Walk `git log --oneline -200`, look for merge commits, RFCs, large
refactors. For each *durable* decision (not "fix typo"), draft a
`decision` page:

```bash
node "$CLI" create-page --id decision-X-over-Y \
  --category decision \
  --title "Chose X over Y because ..." \
  --tags git-log,2024-Q3

cat <<'EOF' | node "$CLI" update-truth --id decision-X-over-Y \
  --summary "inferred from commit <sha> '...'"
We chose X over Y.

Reasons:
- ...

Rejected:
- ...

Evidence:
- commit <sha> introduced X
- benchmark in <path>
EOF
```

**Budget**: at most 10 decision pages per bootstrap run. If you find
more, ask the user which to prioritize — the rest stay in the timeline
of the root pages.

### Step 4: Flag uncertainty

After the bootstrap, output a short report to the user:

```
BRAIN BOOTSTRAP — brownfield
════════════════════════════════════════
Root pages updated:   6
Decision pages added: N
Uncertain items:
  - stack: whether we're actually using Postgres 16 or 17
  - architecture: the auth subsystem role boundary (marked inline)
════════════════════════════════════════
Run /brain-page to review or correct.
```

### Step 5: Hand off

Suggest: "Review `/brain-page` next; correct anything tagged
`<!-- uncertain: ... -->`; remove any false-positive decisions."

## Greenfield flow (interview)

Walk the user through a short structured interview, one question at a
time, using AskUserQuestion when choices are bounded and free-text
otherwise:

1. **Goal** — in one sentence, what is this project for?
2. **Users** — who uses it, and what does "success" look like for them?
3. **Non-goals** — what is this project explicitly NOT trying to do?
4. **Stack** — any language/framework/infra already chosen? constraints
   (e.g., "must run on-prem", "team only knows Python")?
5. **Top 2–3 features** for the first quarter?
6. **Biggest unknown** — what's the riskiest assumption?

After the interview, draft `background` and provisional `stack` /
`roadmap` root pages. **Do not** fabricate decision pages on greenfield —
the user hasn't made decisions yet.

```
BRAIN BOOTSTRAP — greenfield
════════════════════════════════════════
Root pages updated:   background, stack, roadmap
Decision pages:       0 (no decisions yet)
Open questions:       N (recorded as note timeline entries on background)
════════════════════════════════════════
```

## Important Rules

- **Never run on a DeepSeek Harness project.** HARD GATE.
- **Synthesize, don't transcribe.** A bootstrap that just dumps the
  README into `background` is worse than no bootstrap.
- **Mark uncertainty inline.** Use `<!-- uncertain: reason -->`; don't
  silently guess.
- **Cap decisions at 10 per run.** More than that and the user will
  ignore the whole bootstrap.
- **Always** run `node "$CLI" reindex && node "$CLI" lint-links` at the
  end.
- **Never** run bootstrap on an already-populated brain without
  explicit user confirmation — it may overwrite prior work.