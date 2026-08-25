---
name: erics-ability-investigate
description: Use when debugging through investigation, analysis, hypothesis, and implementation without guessing at fixes.
triggers:
  - debug this
  - fix this bug
  - root cause
  - investigate this error
---
# Investigation Iron Law
**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**
Fixing symptoms creates whack-a-mole debugging. Every fix that doesn't address root cause makes the next bug harder to find. Find the root cause, then fix it.
---
## Phase 1: Root Cause Investigation
Gather context before forming any hypothesis.
1. **Collect symptoms:** Read the error messages, stack traces, and reproduction steps. If the user hasn't provided enough context, ask ONE question at a time via AskUserQuestion.
2. **Read the code:** Trace the code path from the symptom back to potential causes. Use Grep to find all references, Read to understand the logic.
3. **Check recent changes:**
   ```bash
   git log --oneline -20 -- <affected-files>
   ```
   Was this working before? What changed? A regression means the root cause is in the diff.
4. **Reproduce:** Can you trigger the bug deterministically? If not, gather more evidence before proceeding.
5. **Check investigation history:** Search prior learnings for investigations on the same files. Recurring bugs in the same area are an architectural smell. If prior investigations exist, note patterns and check if the root cause was structural.
## Prior Learnings
Search for relevant learnings from previous sessions:
```bash
_CROSS_PROJ=$(bin/ 2>/dev/null || echo "unset")
echo "CROSS_PROJECT: $_CROSS_PROJ"
if [ "$_CROSS_PROJ" = "true" ]; then
  bin/true --limit 10 --query "debug investigation root cause hypothesis bug fix" --cross-project 2>/dev/null || true
else
  bin/true --limit 10 --query "debug investigation root cause hypothesis bug fix" 2>/dev/null || true
fi
```
If `CROSS_PROJECT` is `unset` (first time): Use AskUserQuestion:
> EricStack can search learnings from your other projects on this machine to find
> patterns that might apply here. This stays local (no data leaves your machine).
> Recommended for solo developers. Skip if you work on multiple client codebases
> where cross-contamination would be a concern.
Options:
- A) Enable cross-project learnings (recommended)
- B) Keep learnings project-scoped only
