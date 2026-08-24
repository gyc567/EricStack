#!/usr/bin/env bash
# EricStack Skill Count Consistency Check
# Validates that documented skill counts match the actual SKILL.md files.
# The actual count is computed from the filesystem — no hardcoded numbers here.
#
# Policy:
#   - Living docs (README, tutorials, index) may only claim the real skill
#     total or the real installed count (total + 2 estack entry points).
#   - Historical audit reports (docs/AUDIT*.md) are exempt.
#
# Usage:
#   bash .loopx/bin/check-skill-counts.sh           # check
#   bash .loopx/bin/check-skill-counts.sh --fix     # auto-fix legacy sentinel counts
#   bash .loopx/bin/check-skill-counts.sh --verbose # show every located claim

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOPX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$LOOPX_DIR/.." && pwd)"
SKILLS_DIR="$LOOPX_DIR/skills"

ACTUAL_TOTAL=$(find "$SKILLS_DIR" -name SKILL.md -not -path '*/.omc/*' | wc -l | tr -d ' ')
ACTUAL_PROCESS=$(find "$SKILLS_DIR/erics-process" -name SKILL.md | wc -l | tr -d ' ')
ACTUAL_ABILITY=$(find "$SKILLS_DIR/erics-ability" -name SKILL.md | wc -l | tr -d ' ')
ACTUAL_ROUTER=$(find "$SKILLS_DIR/erics-loop-router" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_ENTRYPOINTS=2
ACTUAL_INSTALLED=$((ACTUAL_TOTAL + ACTUAL_ENTRYPOINTS))

# Former catalog sizes — extend this list whenever the total grows.
# (Only include values that were PREVIOUS but no longer current.)
STALE_COUNTS="36 38 40"

# Docs whose headline must state the current total.
MUST_STATE_TOTAL=(
  "$ROOT_DIR/README.md"
  "$ROOT_DIR/README_CN.md"
  "$LOOPX_DIR/erics-skills-index.md"
)

LIVING_FILES=(
  "$ROOT_DIR/README.md"
  "$ROOT_DIR/README_CN.md"
  "$ROOT_DIR/INTEGRATION.md"
  "$ROOT_DIR/CLAUDE.md"
  "$ROOT_DIR/docs/TUTORIAL.md"
  "$ROOT_DIR/docs/LLM_WIKI_TUTORIAL.md"
  "$ROOT_DIR/docs/APS_INTEGRATION.md"
  "$LOOPX_DIR/erics-skills-index.md"
)

VERBOSE=false
FIX_MODE=false
for arg in "$@"; do
  case "$arg" in
    --verbose) VERBOSE=true ;;
    --fix)     FIX_MODE=true ;;
    --help|-h)
      sed -n '2,15p' "$0"
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

CLAIMS_TMP=$(mktemp)
trap 'rm -f "$CLAIMS_TMP"' EXIT

echo "=========================================="
echo "  EricStack Skill Count Consistency Check"
echo "=========================================="
echo ""
echo "Actual skills in .loopx/skills/:"
echo "  - erics-process-*:   $ACTUAL_PROCESS"
echo "  - erics-ability-*:   $ACTUAL_ABILITY"
echo "  - erics-loop-router: $ACTUAL_ROUTER"
echo "  - Total:             $ACTUAL_TOTAL (+$ACTUAL_ENTRYPOINTS entry points = $ACTUAL_INSTALLED installed)"
echo ""

for f in "${LIVING_FILES[@]}"; do
  [ -f "$f" ] || continue
  rel="${f#$ROOT_DIR/}"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    lineno="${line%%:*}"
    rest="${line#*:}"
    count="${rest%% *}"
    echo "$rel|$count|$lineno" >> "$CLAIMS_TMP"
    $VERBOSE && echo "  [$rel L$lineno] claims $count skills"
  done < <(rg -n -o '\b([0-9]{1,3})\s*(skills?|个\s*skills?)\b' "$f" 2>/dev/null || true)
done

echo "=========================================="
echo "  Verdicts (living docs)"
echo "=========================================="
echo ""

errors=0
seen=""
while IFS='|' read -r rel count lineno; do
  key="$rel|$count"
  case "|$seen|" in
    *"|$key|"*) continue ;;
  esac
  seen="$seen$key|"
  lines=$(awk -F'|' -v k="$key" '$1 "|" $2 == k {printf "%s%s", sep, $3; sep=","}' "$CLAIMS_TMP")
  if echo " $STALE_COUNTS " | grep -q " $count "; then
    echo "  FAIL $rel: stale total '${count} skills' (lines $lines) — current total is $ACTUAL_TOTAL"
    errors=$((errors + 1))
  else
    $VERBOSE && echo "  OK   $rel: ${count} skills (lines $lines)"
  fi
done < "$CLAIMS_TMP"

for f in "${MUST_STATE_TOTAL[@]}"; do
  [ -f "$f" ] || continue
  rel="${f#$ROOT_DIR/}"
  if ! rg -q "\b$ACTUAL_TOTAL\s*(skills|个 skills|个技能)" "$f" 2>/dev/null; then
    echo "  FAIL $rel: does not state the current total ($ACTUAL_TOTAL)"
    errors=$((errors + 1))
  else
    $VERBOSE && echo "  OK   $rel states current total $ACTUAL_TOTAL"
  fi
done

[ -s "$CLAIMS_TMP" ] || [ ${#MUST_STATE_TOTAL[@]} -eq 0 ] || echo "  (no numeric skills claims found)"

if $FIX_MODE; then
  echo ""
  echo "=========================================="
  echo "  Auto-fix (--fix)"
  echo "=========================================="
  for f in "${LIVING_FILES[@]}"; do
    [ -f "$f" ] || continue
    rel="${f#$ROOT_DIR/}"
    changed=false
    if rg -q '\b(36|38|40|41)\s*(skills|个 skills)\b' "$f" 2>/dev/null; then
      sed -i.bak -E "s/\b(36|38|40|41)(skills|个 skills)/${ACTUAL_TOTAL}\2/g" "$f"
      rm -f "${f}.bak"
      changed=true
    fi
    $changed && echo "  [FIX] $rel: legacy 36/38/40/41 → $ACTUAL_TOTAL"
  done
fi

echo ""
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo "  Errors:   $errors"
echo "  Actual:   $ACTUAL_TOTAL skills ($ACTUAL_PROCESS process + $ACTUAL_ABILITY ability + $ACTUAL_ROUTER router)"
echo ""

if [ $errors -gt 0 ]; then
  echo "FAIL: $errors stale or missing skill-count claim(s)"
  echo "Update the flagged docs to the current total ($ACTUAL_TOTAL), then rerun."
  exit 1
fi
echo "PASS: No stale counts; headline docs state current total ($ACTUAL_TOTAL)"
exit 0
