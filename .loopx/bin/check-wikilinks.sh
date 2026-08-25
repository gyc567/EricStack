#!/usr/bin/env bash
# check-wikilinks.sh — Validate that all [[wikilink]] references resolve.
# POSIX-compatible: no associative arrays.
#
# Usage:
#   bash .loopx/bin/check-wikilinks.sh           # check (default)
#   bash .loopx/bin/check-wikilinks.sh --strict  # warnings become errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOPX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WIKI_DIR="$LOOPX_DIR/wiki"

STRICT=false
for arg in "$@"; do
  case "$arg" in
    --strict) STRICT=true ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

[ -d "$WIKI_DIR" ] || { echo "Wiki dir missing: $WIKI_DIR"; exit 2; }

# Build a list of "name dir" pairs in a temp file (POSIX-portable).
PAGES_FILE=$(mktemp)
trap 'rm -f "$PAGES_FILE"' EXIT
> "$PAGES_FILE"

while IFS= read -r -d '' f; do
  base=$(basename "$f" .md)
  dir=$(dirname "$f")
  echo "${base}|${dir}" >> "$PAGES_FILE"
done < <(find "$WIKI_DIR" -name "*.md" -print0 2>/dev/null)

errors=0
warnings=0
error_links=""
warning_links=""

# Check if a page name exists
page_exists() {
  local target=$1
  if awk -F'|' -v target="$target" '$1 == target { found=1 } END { exit !found }' "$PAGES_FILE"; then
    # Count how many entries (ambiguity check)
    local count
    count=$(awk -F'|' -v target="$target" '$1 == target { count++ } END { print count+0 }' "$PAGES_FILE")
    echo "$count"
    return 0
  fi
  # Explicit Wiki paths such as [[concepts/page-name]].
  if [ -f "$WIKI_DIR/$target.md" ]; then
    echo "1"
    return 0
  fi
  # Try common subdirs
  for sub in "" "concepts/" "entities/" "comparisons/" "queries/" "sources/"; do
    if [ -f "$WIKI_DIR/${sub}${target}.md" ]; then
      echo "1"
      return 0
    fi
  done
  # Wiki pages may link directly to installed skill names or use the short
  # process/ability suffix (for example [[code-review]]).
  case "$target" in
    erics-process-*)
      [ -f "$LOOPX_DIR/skills/erics-process/$target/SKILL.md" ] && { echo "1"; return 0; }
      ;;
    erics-ability-*)
      local short="${target#erics-ability-}"
      if [ -f "$LOOPX_DIR/skills/erics-ability/$target/SKILL.md" ] || \
         [ -f "$LOOPX_DIR/skills/erics-ability/$short/SKILL.md" ]; then
        echo "1"
        return 0
      fi
      ;;
    erics-loop-router)
      [ -f "$LOOPX_DIR/skills/erics-loop-router/SKILL.md" ] && { echo "1"; return 0; }
      ;;
    *)
      if [ -f "$LOOPX_DIR/skills/erics-process/erics-process-$target/SKILL.md" ] || \
         [ -f "$LOOPX_DIR/skills/erics-ability/$target/SKILL.md" ] || \
         [ -f "$LOOPX_DIR/skills/erics-ability/erics-ability-$target/SKILL.md" ]; then
        echo "1"
        return 0
      fi
      ;;
  esac
  return 1
}

check_wikilink() {
  local file=$1
  local lineno=$2
  local target=$3
  target="${target%%#*}"
  target="${target%%|*}"

  case "$target" in
    ""|http*|file*|/*) return 0 ;;
  esac
  case "$target" in
    *.*|README*|LICENSE|CHANGELOG|CONTRIBUTING) return 0 ;;
  esac

  local count
  if count=$(page_exists "$target"); then
    if [ "$count" -gt 1 ]; then
      warning_links="${warning_links}${file}:${lineno}: ambiguous wikilink [[${target}]]\n"
      warnings=$((warnings + 1))
    fi
  else
    error_links="${error_links}${file}:${lineno}: broken wikilink [[${target}]]\n"
    errors=$((errors + 1))
  fi
}

total_links=0
while IFS= read -r md; do
  # rg for [[...]] patterns; iterate line by line
  while IFS=: read -r lineno rest; do
    [ -z "$lineno" ] && continue
    while [[ "$rest" =~ \[\[([^\]]+)\]\] ]]; do
      target="${BASH_REMATCH[1]}"
      rest="${rest#*\]\]}"
      check_wikilink "$md" "$lineno" "$target"
      total_links=$((total_links + 1))
    done
  # Preserve original line numbers while ignoring fenced code examples.
  done < <(awk '
    /^```/ { fenced = !fenced; next }
    !fenced {
      line = $0
      gsub(/`[^`]*`/, "", line)
      if (line ~ /\[\[[^]]+\]\]/) print NR ":" line
    }
  ' "$md")
done < <(find "$WIKI_DIR" -name "*.md" 2>/dev/null)

echo "=========================================="
echo "  EricStack Wiki Link Check"
echo "=========================================="
echo ""
echo "Wiki pages:  $(wc -l < "$PAGES_FILE")"
echo "Wikilinks:   $total_links"
echo "Errors:      $errors"
echo "Warnings:    $warnings"
echo ""

if [ -n "$error_links" ]; then
  echo "BROKEN LINKS (showing up to 20):"
  echo -e "$error_links" | head -20 | while IFS= read -r line; do
    rel="${line#$LOOPX_DIR/}"
    echo "  ✗ $rel"
  done
  if [ "$errors" -gt 20 ]; then
    echo "  ... and $((errors - 20)) more"
  fi
  echo ""
fi

if [ -n "$warning_links" ]; then
  echo "AMBIGUOUS LINKS (showing up to 10):"
  echo -e "$warning_links" | head -10 | while IFS= read -r line; do
    rel="${line#$LOOPX_DIR/}"
    echo "  ⚠ $rel"
  done
  if [ "$warnings" -gt 10 ]; then
    echo "  ... and $((warnings - 10)) more"
  fi
  echo ""
fi

if $STRICT && [ $warnings -gt 0 ]; then
  echo "STRICT mode: $warnings warnings treated as errors"
  exit 1
fi

if [ $errors -gt 0 ]; then
  echo "FAIL: $errors broken wikilinks"
  exit 1
fi
echo "PASS: All wikilinks resolve"
exit 0
