---
name: erics-ability-upgrade
description: Use when checking the EricStack version or whether configured upstream skill sources have updates.
triggers:
  - upgrade
  - sync skills
  - check for updates
  - erics update
  - new version
---

# /erics-ability-upgrade — EricStack Upgrade Check

Check two things:
1. **EricStack version** — is the installed version current vs GitHub latest?
2. **Upstream skill sync** — have upstream repos (deepseek-harness, gstack) updated since last sync?

## When

- User types `/upgrade` or `/sync-skills`
- Any LoopX goal start (via erics-loop-router auto-check)

## How

### Phase 1: EricStack Version Check

```bash
LOCAL_VERSION=$(cat .loopx/VERSION)
REMOTE_TAG=$(git ls-remote --tags https://github.com/gyc567/EricStack.git \
  | awk -F/ '{print $NF}' | grep '^v' | sort -V | tail -1 | sed 's/v//')
```

Compare `LOCAL_VERSION` vs `REMOTE_TAG`.

- If equal → EricStack is current.
- If `REMOTE_TAG` > `LOCAL_VERSION` → NEW VERSION AVAILABLE.

### Phase 2: Upstream Skill Sync Check

```bash
bash .loopx/bin/sync-skills.sh --check
```

Parse the output for "UPDATE AVAILABLE" vs "UP-TO-DATE" per source.

## Output Format

```
EricStack Upgrade Check
═══════════════════════════════════════

📦 EricStack version
   Installed:  v0.1.0
   Latest:     v0.1.0  ✓  (up to date)

🔄 Upstream skills
   deepseek-harness  ✓  UP-TO-DATE  (47f9438 → 47f9438)
   gstack            ✓  UP-TO-DATE  (008dd65b → 008dd65b)
```

If updates available:

```
📦 EricStack version
   Installed:  v0.1.0
   Latest:     v0.2.0  ← NEW
   Run: git pull origin main

🔄 Upstream skills
   deepseek-harness  ⚠  UPDATE AVAILABLE  (47f9438 → abc1234)
   gstack            ✓  UP-TO-DATE  (008dd65b → 008dd65b)

   To sync upstream skills:
   bash .loopx/bin/sync-skills.sh --execute
```

## Error Handling

If GitHub is unreachable:
- Report BLOCKED with "Network error — could not reach GitHub."
- Do not crash on malformed tag output.
- Treat empty remote tag as "could not determine."

## Completion

- All current → DONE
- EricStack update available → DONE with recommendation to `git pull`
- Upstream update available → DONE with recommendation to run sync
- Both → DONE with both recommendations
- Network error → BLOCKED
