---
name: erics-ability-brain-page
description: |
  Operating manual for reading and writing a project's brain — every read
  and write goes through the bundled `brain` CLI. Use when the user wants
  to capture a decision, constraint, or durable project knowledge, or read
  existing brain pages. Triggers: "brain page", "read brain page", "create
  brain page", "update truth", "记一条 brain 决策".
triggers:
  - brain page
  - read brain page
  - create brain page
  - update truth
  - 记一条 brain 决策
---

# /brain-page — Operating Manual for Brain Pages

You are a **meticulous librarian**. The brain is plain Markdown in git;
your job is to read and write it correctly through the CLI and never
hand-edit files under `brain/`.

## Hard rules (NEVER violate)

1. **All reads and writes go through the `brain` CLI.** The CLI is the
   sole writer. Frontmatter invariants and `update-truth` + `append-timeline`
   atomicity are guaranteed by construction — there is no validator, by
   design.
2. **NEVER hand-edit** any file under `brain/`. Even seemingly trivial
   edits (whitespace, a typo) will break frontmatter parsing on the next
   `read-page`.
3. **Five page categories** are valid: `project`, `concept`, `decision`,
   `person`, `reference`. The CLI will reject anything else.
4. **Three page statuses**: `active`, `draft`, `archived`. `archived`
   pages are kept as historical snapshots; do not delete them.
5. **Cross-references** use `[[page-id]]` syntax. After adding references,
   run `brain lint-links` and fix any broken links.
6. **DeepSeek Harness override**: if the project contains
   `notes/implemented/` or `notes/archived/`, prefer
   `/erics-process-archive-agent-notes` — brain is only a secondary
   cross-agent mirror in that case.

## Locate the CLI

```bash
CLI="$HOME/.claude/skills/brain-page/bin/brain.mjs"
[ -x "$CLI" ] || fail "brain CLI not installed — re-run install-ericsstack.sh"
```

## Detect command

Parse the user's input:

- `/read brain page <id-or-fragment>` → read one page
- `/create brain page <topic>` → start a new page
- `/update truth <id>` → rewrite compiled_truth on an existing page
- `/append timeline <id>` → add an evidence entry
- `/list pages` → list everything
- bare `/brain page` → show the index and ask what to do

For all variants, `cd` to the project root first (`brain` resolves
`./brain/` and `./BRAIN.md` from `process.cwd()`).

## Page taxonomy (cheat sheet)

| Category | When to use | Example ids |
|---|---|---|
| `project` | high-level facts about the project itself | `project-glossary`, `project-goals` |
| `concept` | reusable concept the team has agreed on | `concept-event-sourcing`, `concept-cqrs` |
| `decision` | a specific decision, dated and traceable | `decision-postgres-over-sqlite`, `decision-monorepo-over-polyrepo` |
| `person` | durable knowledge about a person on the team | `person-alice-architect`, `person-bob-oncall` |
| `reference` | pointer to an external artifact | `reference-incident-2026-04-12`, `reference-rfc-001` |

The test for whether something belongs in the brain:
**"Will this still matter in six months, and is it hard to reconstruct from
the code itself?"** If yes, write it. If no (pure implementation, in-code
comment, ephemeral task state), it doesn't belong.

## Read flow

### `list-pages`

```bash
node "$CLI" list-pages
```

Output: `id  title  category  status` rows. Use this before writing to
dedup — never create a page that already exists.

### `read-page <id>`

```bash
node "$CLI" read-page <id>
```

Prints the full page (frontmatter + `compiled_truth` + `## Timeline`).
Present it to the user as the canonical view of that knowledge.

### `read-root <slug>`

```bash
node "$CLI" read-root architecture
```

Prints one of the six root pages: `background`, `architecture`, `flow`,
`mindmap`, `stack`, `roadmap`. Use for high-level project context.

### `brain-dir`

Prints the resolved brain directory and its source (`default ./brain` or
`brainRoot` from `.mindmux/preferences.json`). Useful when debugging
"where did my brain go" — never assume a shadow brain exists.

## Write flow

### Create a new page

```bash
node "$CLI" create-page \
  --id <kebab-id> \
  --category <project|concept|decision|person|reference> \
  --title "Decision title — short noun phrase" \
  [--tags tag1,tag2] \
  [--status draft]   # default is active; use draft if uncertain
```

`--id` must be kebab-case and unique. The CLI generates frontmatter
(timestamps, slug) and writes the page to `brain/pages/<id>.md`.

### Update the compiled_truth

```bash
echo "<new compiled truth, multiline>" | \
  node "$CLI" update-truth --id <id> --summary "why the truth changed"
```

`update-truth` is **atomic**: in one write it rewrites the
`compiled_truth` block AND appends a `decision` timeline entry recording
the change. There is no way to rewrite the truth without leaving a trace.

Always provide `--summary` so the timeline entry is meaningful. If you
can't summarize why it changed, don't update the truth — leave a `note`
timeline entry instead.

### Append a timeline entry

```bash
node "$CLI" append-timeline --id <id> \
  --kind <decision|evidence|reversal|note> \
  --summary "what this evidence shows" \
  [--source "benchmark run, ticket #1234, PR #789, ..."]
```

Use `--kind`:

- `decision` — a new decision was made
- `evidence` — supporting data for an existing decision (benchmark,
  load test, postmortem)
- `reversal` — we changed our mind; the prior `compiled_truth` is now wrong
- `note` — observation that doesn't change the truth (exploration, idea)

### Archive a page

```bash
node "$CLI" archive-page --id <id> [--reversal-summary "..."]
```

Sets status to `archived`. The page file is preserved — never deleted —
so older `[[id]]` links remain resolvable. After archiving, the page
should not be updated; start a new page if needed.

### Reindex and lint

After any write:

```bash
node "$CLI" reindex        # rebuild brain/index.md
node "$CLI" lint-links     # verify [[page-id]] references resolve
```

`lint-links` is cheap and safe; run it routinely.

## When to write vs not write

**Write** when:
- A decision is being made *right now* and you can articulate the trade-offs
- A constraint just crystallized ("we can only use libraries from the
  approved list")
- A reversal occurred ("we used X, but after Y we switched to Z")
- An external reference needs a durable pointer (postmortem, RFC, ticket)

**Don't write** when:
- It's pure implementation detail visible in code
- It's a task in progress (use `erics-ability-context-save` instead)
- It's something that expires (a one-time deploy config, a temporary
  branch name)

## If no `BRAIN.md` exists

This skill assumes the project is already initialized. If `BRAIN.md`
doesn't exist at the project root, tell the user: "Brain is not
initialized in this project. Run `/brain init` first" and exit. Do not
auto-init here — that's `erics-ability-brain-init`'s job.

## Important Rules

- **Never** open `brain/` files in an editor. Always go through the CLI.
- **Always** `--summary` your `update-truth` and `append-timeline` calls —
  the timeline is the audit trail; unsummarized entries are noise.
- **Always** `lint-links` after adding cross-references.
- **Always** use kebab-case for `--id`.
- **Never** delete a page; use `archive-page`.