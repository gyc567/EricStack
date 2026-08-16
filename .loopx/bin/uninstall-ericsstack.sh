#!/bin/bash
set -e

SKILLS_DEST="${SKILLS_DEST:-$HOME/.claude/skills}"

echo "========================================"
echo "  EricStack Uninstaller"
echo "========================================"
echo ""
echo "  Skills: $SKILLS_DEST"
echo ""

# Remove all EricStack skills
echo "[1/1] Removing EricStack skills..."
erics_count=0
for skill in "$SKILLS_DEST"/erics-* "$SKILLS_DEST"/estack "$SKILLS_DEST"/estack-upgrade; do
  if [ -e "$skill" ]; then
    rm -rf "$skill"
    basename "$skill" | xargs echo "  [RM]"
    erics_count=$((erics_count + 1))
  fi
done
echo "  Removed $erics_count items"
echo ""
echo "  NOTE: ~/.codex/loopx is LoopX global state and was NOT modified."
echo "  To fully remove LoopX: rm -rf ~/.codex/loopx ~/.local/bin/loopx"

echo ""
echo "========================================"
echo "Uninstall complete!"
echo ""
echo "To reinstall: bash ~/EricStack/.loopx/bin/install-ericsstack.sh"
