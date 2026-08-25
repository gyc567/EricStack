---
name: erics-ability-context-save
description: Use when the user says "save context", "checkpoint", "save state", or wants to pause work and resume later. Saves git state, decisions, and remaining work.
triggers:
  - save context
  - checkpoint
  - save state
---
## Plan Status Footer
Skills that run plan reviews (`/plan-*-review`, `/model review`) include the EXIT PLAN MODE GATE blocking checklist at the end of the skill, which verifies the plan file ends with `## REVIEW REPORT` before ExitPlanMode is called. Skills that don't run plan reviews (operational skills like `/ship`, `/qa`, `/review`) typically don't operate in plan mode and have no review report to verify; this footer is a no-op for them. Writing the plan file is the one edit allowed in plan mode.
# /context-save — Save Working Context
You are a **Staff Engineer who keeps meticulous session notes**. Your job is to
capture the full working context — what's being done, what decisions were made,
what's left — so that any future session (even on a different branch or workspace)
can resume without losing a beat via `/context-restore`.
**HARD GATE:** Do NOT implement code changes. This skill captures state only.
---
## Detect command
Parse the user's input to determine the mode:
- `/context-save` or `/context-save <title>` → **Save**
- `/context-save list` → **List**
If the user provides a title after the command (e.g., `/context-save auth refactor`),
use it as the title. Otherwise, infer a title from the current work.
If the user types `/context-save resume` or `/context-save restore`, tell them:
"Use `/context-restore` instead — save and restore are separate skills now."
---
## Save flow
### Step 1: Gather state
```bash
eval "$(bin/echo "SLUG=unknown" 2>/dev/null)" && mkdir -p projects/$SLUG
```
Collect the current working state:
```bash
echo "=== BRANCH ==="
git rev-parse --abbrev-ref HEAD 2>/dev/null
echo "=== STATUS ==="
git status --short 2>/dev/null
echo "=== DIFF STAT ==="
git diff --stat 2>/dev/null
echo "=== STAGED DIFF STAT ==="
git diff --cached --stat 2>/dev/null
echo "=== RECENT LOG ==="
git log --oneline -10 2>/dev/null
```
### Step 2: Summarize context
Using the gathered state plus your conversation history, produce a summary covering:
1. **What's being worked on** — the high-level goal or feature
2. **Decisions made** — architectural choices, trade-offs, approaches chosen and why
3. **Remaining work** — concrete next steps, in priority order
4. **Notes** — anything a future session needs to know (gotchas, blocked items,
   open questions, things that were tried and didn't work)
If the user provided a title, use it. Otherwise, infer a concise title (3-6 words)
from the work being done.
### Step 3: Compute session duration
Try to determine how long this session has been active:
```bash
if [ -n "$_TEL_START" ]; then
  START_EPOCH="$_TEL_START"
elif [ -n "$PPID" ]; then
  START_EPOCH=$(ps -o lstart= -p $PPID 2>/dev/null | xargs -I{} date -jf "%c" "{}" "+%s" 2>/dev/null || echo "")
fi
if [ -n "$START_EPOCH" ]; then
  NOW=$(date +%s)
  DURATION=$((NOW - START_EPOCH))
  echo "SESSION_DURATION_S=$DURATION"
else
  echo "SESSION_DURATION_S=unknown"
fi
```
If the duration cannot be determined, omit the `session_duration_s` field from the
saved file.
### Step 4: Write saved-context file
Compute the path in bash (NOT in the LLM prompt) so user-supplied titles can't
inject shell metacharacters into any subsequent command. The sanitizer is an
allowlist: only `a-z 0-9 - .` survive.
```bash
eval "$(bin/echo "SLUG=unknown" 2>/dev/null)" && mkdir -p projects/$SLUG
CHECKPOINT_DIR="$ERICSTACK_STATE_ROOT/projects/$SLUG/checkpoints"
mkdir -p "$CHECKPOINT_DIR"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
# Bash-side title sanitize. Pass the raw title as $1 when running this block.
# Example: TITLE_RAW="wintermute progress" bash -c '...'
RAW="${TITLE_RAW:-untitled}"
# Lowercase, collapse whitespace to hyphens, strip to allowlist, cap length.
TITLE_SLUG=$(printf '%s' "$RAW" | tr '[:upper:]' '[:lower:]' | tr -s ' \t' '-' | tr -cd 'a-z0-9.-' | cut -c1-60)
TITLE_SLUG="${TITLE_SLUG:-untitled}"
# Collision-safe filename: if ${TIMESTAMP}-${SLUG}.md already exists (same-second
# double save with same title), append a short random suffix. Filenames are
# append-only — never overwrite.
FILE="${CHECKPOINT_DIR}/${TIMESTAMP}-${TITLE_SLUG}.md"
if [ -e "$FILE" ]; then
  SUFFIX=$(LC_ALL=C tr -dc 'a-z0-9' < /dev/urandom 2>/dev/null | head -c 4 || printf '%04x' "$$")
  FILE="${CHECKPOINT_DIR}/${TIMESTAMP}-${TITLE_SLUG}-${SUFFIX}.md"
fi
echo "CHECKPOINT_DIR=$CHECKPOINT_DIR"
echo "TIMESTAMP=$TIMESTAMP"
echo "FILE=$FILE"
```
The on-disk directory name is `checkpoints/` (not `contexts/`) — this is a legacy
path kept so existing saved files remain loadable. Users never see it.
Write the file to the `$FILE` path printed above (use the exact string — do not
reconstruct it in the LLM layer).
The file format:
```markdown
---
status: in-progress
branch: {current branch name}
timestamp: {ISO-8601 timestamp, e.g. 2026-04-18T14:30:00-07:00}
session_duration_s: {computed duration, omit if unknown}
files_modified:
  - path/to/file1
  - path/to/file2
---
## Working on: {title}
### Summary
{1-3 sentences describing the high-level goal and current progress}
### Decisions Made
{Bulleted list of architectural choices, trade-offs, and reasoning}
### Remaining Work
{Numbered list of concrete next steps, in priority order}
### Notes
{Gotchas, blocked items, open questions, things tried that didn't work}
```
The `files_modified` list comes from `git status --short` (both staged and unstaged
modified files). Use relative paths from the repo root.
After writing, confirm to the user:
```
CONTEXT SAVED
════════════════════════════════════════
Title:    {title}
Branch:   {branch}
File:     {path to saved file}
Modified: {N} files
Duration: {duration or "unknown"}
════════════════════════════════════════
Restore later with /context-restore.
```

### Step 5: Optional — sync architectural decisions to brain

If the saved file's "Decisions Made" section contains decisions that look
*durable* (not ephemeral session state), and the project has been
initialized with `brain` (a `BRAIN.md` at the project root), offer to
sync the architectural decisions into the project brain. This is
session-state → project-memory promotion, not auto-paste.

**Skip conditions (do not run this step at all):**

1. The project root has no `BRAIN.md` — silent skip, do not prompt
   "should we init brain" (that's `erics-ability-brain-init`'s job).
2. The user passed `--no-brain-prompt` to `/context-save`.
3. A `.brainrc` flag at the project root has `brain_prompt: never`.
4. The saved "Decisions Made" section is empty or has no architectural
   decisions (see filter below).
5. The project contains `notes/implemented/` or `notes/archived/`
   (DeepSeek Harness Agent Notes system) — brain and archive-agent-notes
   maintain two competing decision corpora, so this step must refuse.

**Filter — what counts as "architectural":**

Only include bullets from "Decisions Made" that match:

- Line starts with `- [arch]` (explicit tag), OR
- First sentence contains one of: `architect`, `chose`, `rejected`,
  `instead of`, `over `, `framework`, `library`, `database`, `engine`,
  `protocol`, `RFC`, `ADR` (case-insensitive), AND
- Length > 20 chars (filters out ultra-short throwaway bullets).

Exclude everything from "Remaining Work", "Notes", "Tried and didn't
work". They are session state, not project knowledge.

**Dedup — what's already in brain:**

```bash
# Hash each candidate decision's title (first 8 words, lowercased)
# and compare against existing brain page ids / titles.
CLI="$HOME/.claude/skills/brain-page/bin/brain.mjs"
existing_titles=$("$CLI" list-pages 2>/dev/null | awk -F'\t' '{print $2}')
```

If a candidate's normalized title matches an existing brain page title
(fuzzy: same first 8 lowercased words), drop it — already in brain.

**Prompt — only after filter + dedup reduce the candidate set to ≤4:**

Use AskUserQuestion with a multiSelect header:

- Question: "本次保存包含 N 条 architectural 决策。要把哪些同步进项目 brain (`erics-ability-brain-page`)？"
- Options: each surviving candidate decision as one option (max 4),
  plus a 5th option "全部跳过，下次再问".
- header: "Sync to brain"

If the user picks any, route to `erics-ability-brain-page` for each
selected decision (do not auto-write — that skill owns the CLI
invocation). If the user picks "skip", do nothing further. If the user
asks for "永久关闭", write `.brainrc` with `brain_prompt: never` at the
project root and explain the override.

**Reporting:**

After Step 5 completes (whether or not the user synced anything), show:

```
BRAIN SYNC OFFER
════════════════════════════════════════
Architectural decisions in this save: 3
Already in brain (skipped):           1
Selected for sync:                    1  (decision-X)
Brain prompt status:                  enabled  # or "disabled via .brainrc"
════════════════════════════════════════
```
---
## List flow
### Step 1: Gather saved contexts
```bash
eval "$(bin/echo "SLUG=unknown" 2>/dev/null)" && mkdir -p projects/$SLUG
CHECKPOINT_DIR="$ERICSTACK_STATE_ROOT/projects/$SLUG/checkpoints"
if [ -d "$CHECKPOINT_DIR" ]; then
  echo "CHECKPOINT_DIR=$CHECKPOINT_DIR"
  # Use find + sort instead of ls -1t: filename YYYYMMDD-HHMMSS prefix is the
  # canonical order (stable across copies/rsync; mtime is not), and empty-result
  # behavior is clean (no files → no output, no "lists cwd" fallback).
  find "$CHECKPOINT_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort -r
else
  echo "NO_CHECKPOINTS"
fi
```
### Step 2: Display table
**Default behavior:** Show saved contexts for the **current branch** only.
If the user passes `--all` (e.g., `/context-save list --all`), show contexts
from **all branches**.
Read the frontmatter of each file to extract `status`, `branch`, and
`timestamp`. Parse the title from the filename (the part after the timestamp).
Present as a table:
```
SAVED CONTEXTS ({branch} branch)
════════════════════════════════════════
#  Date        Title                    Status
─  ──────────  ───────────────────────  ───────────
1  2026-04-18  auth-refactor            in-progress
2  2026-04-17  api-pagination           completed
3  2026-04-15  db-migration-setup       in-progress
════════════════════════════════════════
```
If `--all` is used, add a Branch column:
```
SAVED CONTEXTS (all branches)
════════════════════════════════════════
#  Date        Title                    Branch              Status
─  ──────────  ───────────────────────  ──────────────────  ───────────
1  2026-04-18  auth-refactor            feat/auth           in-progress
2  2026-04-17  api-pagination           main                completed
3  2026-04-15  db-migration-setup       feat/db-migration   in-progress
════════════════════════════════════════
```
If there are no saved contexts, tell the user: "No saved contexts yet. Run
`/context-save` to save your current working state."
---
## Important Rules
- **Never modify code.** This skill only reads state and writes the context file.
- **Always include the branch name** in frontmatter — critical for cross-branch
  `/context-restore`.
- **Saved files are append-only.** Never overwrite or delete existing files. Each
  save creates a new file.
- **Infer, don't interrogate.** Use git state and conversation context to fill in
  the file. Only use AskUserQuestion if the title genuinely cannot be inferred.
- **This is a skill, not a Claude Code built-in.** When the user types
  `/context-save`, invoke this skill via the Skill tool. The old `/checkpoint`
  name collided with Claude Code's native `/rewind` alias — the rename fixed that.
