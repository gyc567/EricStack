#!/usr/bin/env bash
# EricStack Skill Frontmatter Lint
# Validates YAML frontmatter quality on all SKILL.md files.
#
# Rules enforced:
#   - Required fields: name, description, triggers
#   - name must match parent directory name
#   - description must contain "Use when" (LLM routing hint) — except for entry points
#   - description must be <= 280 chars
#   - description must not contain stale brand refs (gstack, garry, deepseek)
#   - triggers must have >= 1 English + 1 entry (or >= 2 entries)
#   - First H1 in body must not be empty
#   - H1 should reference the skill name (warning)
#
# Usage:
#   bash .loopx/bin/lint-skills.sh           # check (default)
#   bash .loopx/bin/lint-skills.sh --strict  # warnings become errors
#   bash .loopx/bin/lint-skills.sh --quiet   # summary only

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOPX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$LOOPX_DIR/skills"

STRICT=false
QUIET=false
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=true ;;
    --quiet)  QUIET=true ;;
    -h|--help)
      sed -n '2,15p' "$0"
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

# Stale brand refs that should not appear in description
STALE_BRANDS_REGEX='\b(gstack|GStack|garry|Garry|deepseek-harness|DeepSeek Harness|deepseek)\b'

errors=0
warnings=0
checked=0
declare -a error_files
declare -a warning_files

check_skill() {
  local file=$1
  local dir
  dir=$(dirname "$file")
  local expected_name
  expected_name=$(basename "$dir")
  checked=$((checked + 1))

  # Extract frontmatter (between first two ---)
  local fm
  fm=$(awk '/^---$/{c++; if(c==2) exit; next} c==1' "$file")
  if [ -z "$fm" ]; then
    error_files+=("$file: missing frontmatter (no ---...--- block)")
    errors=$((errors + 1))
    return
  fi

  # Required: name
  local name
  name=$(echo "$fm" | rg -o '^name:\s*"?([^"\n]+?)"?\s*$' -r '$1' | head -1)
  if [ -z "$name" ]; then
    error_files+=("$file: missing required field 'name'")
    errors=$((errors + 1))
  elif [ "$name" != "$expected_name" ]; then
    error_files+=("$file: name='$name' but directory is '$expected_name'")
    errors=$((errors + 1))
  fi

  # Required: description
  local desc
  desc=$(echo "$fm" | rg -o '^description:\s*"?(.+?)"?\s*$' -r '$1' | head -1)
  if [ -z "$desc" ]; then
    error_files+=("$file: missing required field 'description'")
    errors=$((errors + 1))
  else
    local desc_len=${#desc}
    if [ "$desc_len" -gt 280 ]; then
      warning_files+=("$file: description too long ($desc_len > 280 chars)")
      warnings=$((warnings + 1))
    fi

    # Stale brand refs (description should be clean for routing)
    if echo "$desc" | rg -q "$STALE_BRANDS_REGEX" 2>/dev/null; then
      error_files+=("$file: description contains stale brand reference (gstack/garry/deepseek)")
      errors=$((errors + 1))
    fi

    # Should contain "Use when" for LLM routing (skip entry points)
    if [[ "$expected_name" != "estack" && "$expected_name" != "estack-upgrade" ]]; then
      if ! echo "$desc" | rg -qi 'use when' 2>/dev/null; then
        warning_files+=("$file: description missing 'Use when' routing hint")
        warnings=$((warnings + 1))
      fi
    fi
  fi

  # Required: triggers (>= 2 entries)
  local triggers_count
  triggers_count=$(echo "$fm" | rg -c '^\s+-\s+' 2>/dev/null || echo 0)
  if [ "$triggers_count" -lt 2 ]; then
    warning_files+=("$file: triggers list has only $triggers_count entries (recommend >= 2)")
    warnings=$((warnings + 1))
  fi

  # Body checks: first H1 should not be empty
  local first_h1
  first_h1=$(awk '/^---$/{c++; next} c>=2 && /^# / {print; exit}' "$file")
  if [ -z "$first_h1" ]; then
    warning_files+=("$file: body has no H1 heading")
    warnings=$((warnings + 1))
  fi
}

# Main
[ -d "$SKILLS_DIR" ] || { echo "SKILLS_DIR missing: $SKILLS_DIR"; exit 2; }

while IFS= read -r -d '' skill_md; do
  check_skill "$skill_md"
done < <(find "$SKILLS_DIR" -name SKILL.md -not -path '*/.omc/*' -print0 2>/dev/null)

# Output
if ! $QUIET; then
  echo "=========================================="
  echo "  EricStack Skill Frontmatter Lint"
  echo "=========================================="
  echo ""

  if [ ${#error_files[@]} -gt 0 ]; then
    echo "ERRORS (${#error_files[@]}):"
    for e in "${error_files[@]}"; do
      rel="${e#$LOOPX_DIR/}"
      echo "  ✗ $rel"
      echo "      $e"
    done
    echo ""
  fi

  if [ ${#warning_files[@]} -gt 0 ]; then
    echo "WARNINGS (${#warning_files[@]}):"
    local_shown=0
    for w in "${warning_files[@]}"; do
      if [ $local_shown -lt 10 ]; then
        rel="${w#$LOOPX_DIR/}"
        echo "  ⚠ $rel"
        echo "      $w"
        local_shown=$((local_shown + 1))
      fi
    done
    if [ ${#warning_files[@]} -gt 10 ]; then
      echo "  ... and $((${#warning_files[@]} - 10)) more"
    fi
    echo ""
  fi
fi

echo "=========================================="
echo "  Summary"
echo "=========================================="
echo "  Checked:   $checked"
echo "  Errors:    $errors"
echo "  Warnings:  $warnings"
echo ""

# Strict mode: warnings become errors
if $STRICT && [ $warnings -gt 0 ]; then
  echo "  STRICT mode: $warnings warnings treated as errors"
  exit 1
fi

if [ $errors -gt 0 ]; then
  echo "FAIL: $errors errors"
  exit 1
fi
echo "PASS: All skill frontmatter valid"
exit 0
