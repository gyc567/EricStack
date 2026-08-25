#!/usr/bin/env bash
# EricStack Uninstaller — removes all erics-* skills + estack entry points.
# Honors --dry-run / --check / --force modes.
#
# Usage:
#   bash .loopx/bin/uninstall-ericsstack.sh                       # uninstall (default)
#   bash .loopx/bin/uninstall-ericsstack.sh --check               # show what would be removed
#   bash .loopx/bin/uninstall-ericsstack.sh --dry-run             # same, no changes
#   bash .loopx/bin/uninstall-ericsstack.sh --force               # remove without prompt
#   bash .loopx/bin/uninstall-ericsstack.sh --purge-loop-engineering  # ALSO remove loop-engineering state (opt-in)

set -euo pipefail

MODE="uninstall"
FORCE=false
PURGE_LOOP_ENG=false
for arg in "$@"; do
  case "$arg" in
    --check)   MODE="check" ;;
    --dry-run) MODE="check" ;;
    --force)   FORCE=true ;;
    --purge-loop-engineering) PURGE_LOOP_ENG=true ;;
    -h|--help)
      sed -n '2,11p' "$0"
      exit 0
      ;;
    *) echo "Unknown argument: $arg" >&2; exit 2 ;;
  esac
done

SKILLS_DEST="${SKILLS_DEST:-$HOME/.claude/skills}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERICSTACK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_SRC="$ERICSTACK_DIR/.loopx/skills"

source "$SCRIPT_DIR/lib-pathsafe.sh"
assert_safe_skills_dest "$SKILLS_DEST"

echo "=========================================="
echo "  EricStack Uninstaller  (mode: $MODE)"
echo "=========================================="
echo ""
echo "  Skills:                 $SKILLS_DEST"
echo "  Purge loop-engineering: $PURGE_LOOP_ENG"
echo ""

# Detect what would be removed (DYNAMIC count)
declare -a to_remove=()
for skill_file in "$SKILLS_SRC"/erics-process/*/SKILL.md "$SKILLS_SRC"/erics-ability/*/SKILL.md; do
  [ -f "$skill_file" ] || continue
  name=$(basename "$(dirname "$skill_file")")
  case "$name" in
    erics-process-*|erics-ability-*) ;;
    *)
      case "$skill_file" in
        */erics-process/*) name="erics-process-$name" ;;
        */erics-ability/*) name="erics-ability-$name" ;;
      esac
      ;;
  esac
  item="$SKILLS_DEST/$name"
  if [ -e "$item" ] || [ -L "$item" ]; then
    to_remove+=("$item")
  fi
done
for name in erics-loop-router estack estack-upgrade; do
  item="$SKILLS_DEST/$name"
  if [ -e "$item" ] || [ -L "$item" ]; then
    to_remove+=("$item")
  fi
done
# Loop Engineering shell wrappers (user-side runtime artifacts)
for name in loop-doctor loop-status loop-mode loop-init; do
  item="$SKILLS_DEST/$name"
  if [ -e "$item" ] || [ -L "$item" ]; then
    to_remove+=("$item")
  fi
done

if [ ${#to_remove[@]} -eq 0 ]; then
  echo "  [OK] Nothing to remove — EricStack is not installed."
  exit 0
fi

echo "  Found ${#to_remove[@]} items:"
for item in "${to_remove[@]}"; do
  echo "    - $(basename "$item")"
done
echo ""

# Loop Engineering opt-in purge targets (NEVER touch by default — preserves existing
# "don't modify .loopx/..." contract from the original uninstaller).
declare -a loop_eng_purge=()
if $PURGE_LOOP_ENG; then
  if [ -f "$ERICSTACK_DIR/loop/STATE.md" ]; then
    loop_eng_purge+=("$ERICSTACK_DIR/loop/STATE.md")
  fi
  if [ -f "$ERICSTACK_DIR/.loopx/loop-engineering-state.json" ]; then
    loop_eng_purge+=("$ERICSTACK_DIR/.loopx/loop-engineering-state.json")
  fi
  if [ -d "$HOME/.loop-engineering" ]; then
    loop_eng_purge+=("$HOME/.loop-engineering")
  fi
  if [ ${#loop_eng_purge[@]} -gt 0 ]; then
    echo "  Loop-engineering purge targets (--purge-loop-engineering):"
    for item in "${loop_eng_purge[@]}"; do
      echo "    - ${item#$ERICSTACK_DIR/}"
    done
    echo ""
  fi
fi

if [ "$MODE" = "check" ]; then
  echo "  [DRY-RUN] No changes made. Use --force to remove."
  exit 0
fi

# Confirm unless --force
if ! $FORCE; then
  if [ ! -t 0 ]; then
    echo "Refusing destructive uninstall without confirmation. Re-run interactively or pass --force." >&2
    exit 2
  fi
  read -r -p "  Remove these ${#to_remove[@]} items? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY]) ;;
    *) echo "  Aborted."; exit 0 ;;
  esac
fi

# Remove
echo ""
echo "[1/2] Removing EricStack skills..."
removed=0
for item in "${to_remove[@]}"; do
  rm -rf "$item"
  echo "  [RM] $(basename "$item")"
  removed=$((removed + 1))
done

echo ""
echo "  Removed $removed items"
echo ""

# Step 2: opt-in loop-engineering purge + registry goal removal
if $PURGE_LOOP_ENG; then
  echo "[2/2] Purging loop-engineering state..."
  for item in "${loop_eng_purge[@]}"; do
    rm -rf "$item"
    echo "  [RM] ${item#$ERICSTACK_DIR/}"
  done

  # Remove ericstack-loop-engineering-goal from .loopx/registry.json
  reg="$ERICSTACK_DIR/.loopx/registry.json"
  if [ -f "$reg" ] && command -v jq >/dev/null 2>&1; then
    if jq -e '.goals | map(.id) | index("ericstack-loop-engineering-goal")' "$reg" >/dev/null 2>&1; then
      tmp=$(mktemp)
      if jq '.goals |= map(select(.id != "ericstack-loop-engineering-goal"))' "$reg" > "$tmp" && mv "$tmp" "$reg"; then
        echo "  [RM] .loopx/registry.json: ericstack-loop-engineering-goal"
      else
        echo "  [WARN] failed to strip ericstack-loop-engineering-goal from registry.json"
        rm -f "$tmp"
      fi
    fi
  fi
else
  echo "[2/2] Skipped loop-engineering purge (use --purge-loop-engineering to enable)"
fi

echo ""
echo "  NOTE: ~/.codex/loopx is LoopX global state and was NOT modified."
echo "  To fully remove LoopX: rm -rf ~/.codex/loopx ~/.local/bin/loopx"
echo ""
echo "=========================================="
echo "Uninstall complete!"
echo ""
echo "To reinstall: bash $ERICSTACK_DIR/.loopx/bin/install-ericsstack.sh"
