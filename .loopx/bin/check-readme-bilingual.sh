#!/usr/bin/env bash
# check-readme-bilingual.sh — Verify that README.md (EN) and README_CN.md (ZH)
# have consistent structure and skill counts.
#
# Checks:
#   1. Both files exist
#   2. Both reference the same skill count (38)
#   3. Both have a "Project Positioning" section
#   4. Both mention the same install command
#   5. Markdown section structure (## headers) is roughly equivalent
#
# Usage:
#   bash .loopx/bin/check-readme-bilingual.sh           # check
#   bash .loopx/bin/check-readme-bilingual.sh --strict  # warnings become errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOPX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$LOOPX_DIR/.." && pwd)"
EN="$ROOT_DIR/README.md"
ZH="$ROOT_DIR/README_CN.md"
EXPECTED_SKILLS=$(find "$LOOPX_DIR/skills" -name SKILL.md -not -path '*/.omc/*' | wc -l | tr -d ' ')

STRICT=false
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=true ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

errors=0
warnings=0
error_msgs=""
warning_msgs=""

# 1. Both files exist
for f in "$EN" "$ZH"; do
  if [ ! -f "$f" ]; then
    error_msgs="${error_msgs}MISSING: $f\n"
    errors=$((errors + 1))
  fi
done

if [ $errors -gt 0 ]; then
  echo "FAIL: missing README files"
  echo -e "$error_msgs"
  exit 1
fi

# 2. Skill count consistency (expected count computed from the skills tree)
for f in "$EN" "$ZH"; do
  rel="${f#$ROOT_DIR/}"
  if ! rg -q "provides \*\*$EXPECTED_SKILLS skills" "$f" 2>/dev/null; then
    error_msgs="${error_msgs}$rel: missing 'provides **$EXPECTED_SKILLS skills' in description\n"
    errors=$((errors + 1))
  fi
  if ! rg -q "all $EXPECTED_SKILLS skills" "$f" 2>/dev/null && \
     ! rg -q "全部 $EXPECTED_SKILLS 个 skills" "$f" 2>/dev/null; then
    error_msgs="${error_msgs}$rel: install step doesn't claim $EXPECTED_SKILLS skills\n"
    errors=$((errors + 1))
  fi
done
en_count=$(rg -o 'provides \*\*[0-9]+ skills' -r '$0' "$EN" 2>/dev/null | head -1 || true)
zh_count=$(rg -o 'provides \*\*[0-9]+ skills' -r '$0' "$ZH" 2>/dev/null | head -1 || true)
if [ -n "$en_count" ] && [ -n "$zh_count" ] && [ "$en_count" != "$zh_count" ]; then
  error_msgs="${error_msgs}EN/ZH disagree on skill count: '$en_count' vs '$zh_count'\n"
  errors=$((errors + 1))
fi

# 3. Project Positioning section
for f in "$EN" "$ZH"; do
  rel="${f#$ROOT_DIR/}"
  if ! rg -q '^## (Project Positioning|项目定位)' "$f" 2>/dev/null; then
    warning_msgs="${warning_msgs}$rel: missing 'Project Positioning' / '项目定位' section\n"
    warnings=$((warnings + 1))
  fi
done

# 4. Install command consistency
en_cmd=$(rg -o 'bash ~/EricStack/.loopx/bin/install-ericsstack.sh' "$EN" 2>/dev/null | head -1)
zh_cmd=$(rg -o 'bash ~/EricStack/.loopx/bin/install-ericsstack.sh' "$ZH" 2>/dev/null | head -1)
if [ "$en_cmd" != "$zh_cmd" ]; then
  warning_msgs="${warning_msgs}install-ericsstack.sh command differs between EN/ZH\n"
  warnings=$((warnings + 1))
fi

# 5. Section structure comparison
en_sections=$(rg -c '^## ' "$EN" 2>/dev/null)
zh_sections=$(rg -c '^## ' "$ZH" 2>/dev/null)
echo "EN sections: $en_sections"
echo "ZH sections: $zh_sections"
if [ "$en_sections" != "$zh_sections" ]; then
  diff=$((en_sections - zh_sections))
  if [ "${diff#-}" -gt 2 ]; then
    warning_msgs="${warning_msgs}section count differs: EN=$en_sections vs ZH=$zh_sections\n"
    warnings=$((warnings + 1))
  fi
fi

# 6. Specific anchor links present
for f in "$EN" "$ZH"; do
  rel="${f#$ROOT_DIR/}"
  if ! rg -q 'docs/TUTORIAL.md' "$f" 2>/dev/null; then
    warning_msgs="${warning_msgs}$rel: no link to docs/TUTORIAL.md\n"
    warnings=$((warnings + 1))
  fi
done

# Output
echo "=========================================="
echo "  Bilingual README Check"
echo "=========================================="
echo ""
echo "EN: README.md ($(wc -l < "$EN") lines)"
echo "ZH: README_CN.md ($(wc -l < "$ZH") lines)"
echo ""

if [ -n "$error_msgs" ]; then
  echo "ERRORS:"
  echo -e "$error_msgs"
fi
if [ -n "$warning_msgs" ]; then
  echo "WARNINGS:"
  echo -e "$warning_msgs"
fi

echo "=========================================="
echo "  Summary"
echo "=========================================="
echo "  Errors:   $errors"
echo "  Warnings: $warnings"
echo ""

if $STRICT && [ $warnings -gt 0 ]; then
  echo "STRICT mode: $warnings warnings treated as errors"
  exit 1
fi

if [ $errors -gt 0 ]; then
  echo "FAIL: $errors errors"
  exit 1
fi
echo "PASS: Bilingual READMEs are consistent"
exit 0
