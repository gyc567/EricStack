#!/bin/bash
set -e

SKILLS_DEST="${SKILLS_DEST:-$HOME/.claude/skills}"
LOOPX_STATE="$HOME/.codex/loopx"
ERICSTACK_LOOPX_LINK="$LOOPX_STATE"

echo "Uninstalling EricStack..."
echo "  Skills: $SKILLS_DEST"

# 1. Remove all erics-* skills
echo ""
echo "[1/2] Removing EricStack skills..."
erics_count=0
for skill in "$SKILLS_DEST"/erics-* "$SKILLS_DEST"/estack "$SKILLS_DEST"/estack-upgrade; do
  if [ -e "$skill" ]; then
    rm -rf "$skill"
    basename "$skill" | xargs echo "  [RM]"
    erics_count=$((erics_count + 1))
  fi
done
echo "  Removed $erics_count items"

# 2. Unlink .loopx from LoopX runtime
echo ""
echo "[2/2] Unlinking LoopX runtime..."
if [ -L "$ERICSTACK_LOOPX_LINK" ]; then
  # Check if it points to an EricStack .loopx
  target=$(readlink "$ERICSTACK_LOOPX_LINK")
  if [[ "$target" == *"/EricStack/.loopx" ]] || [[ "$target" == *"/.loopx" ]]; then
    rm "$ERICSTACK_LOOPX_LINK"
    echo "  ✓ Unlinked: $LOOPX_STATE"
  else
    echo "  [SKIP] $LOOPX_STATE points elsewhere: $target"
  fi
else
  echo "  [SKIP] No EricStack link found at $LOOPX_STATE"
fi

echo ""
echo "========================================"
echo "Uninstall complete!"
echo ""
echo "To reinstall: bash ~/EricStack/.loopx/bin/install-ericsstack.sh"
