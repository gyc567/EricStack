#!/bin/bash
set -e

ERICSTACK_DIR="${ERICSTACK_DIR:-$HOME/EricStack}"
SKILLS_DEST="${SKILLS_DEST:-$HOME/.claude/skills}"

echo "Installing EricStack skills..."
echo "  Source: $ERICSTACK_DIR/.loopx/skills/"
echo "  Dest:   $SKILLS_DEST/"

if [ ! -d "$ERICSTACK_DIR/.loopx/skills" ]; then
  echo "Error: EricStack not found at $ERICSTACK_DIR"
  echo "Run: git clone https://github.com/gyc567/EricStack.git ~/EricStack"
  exit 1
fi

# Clean old installs
rm -f "$SKILLS_DEST"/erics-*
rm -f "$SKILLS_DEST"/erics-*

install_from_dir() {
  local src_dir="$1"
  local expected_prefix="$2"  # "erics-process-" or "erics-ability-"
  
  if [ ! -d "$src_dir" ]; then
    echo "  [SKIP] $src_dir not found"
    return
  fi
  
  for skill_dir in "$src_dir"/*/; do
    if [ -d "$skill_dir" ] && [ -f "${skill_dir}SKILL.md" ]; then
      local basename=$(basename "$skill_dir")
      
      # Determine final skill name
      local final_name
      if [[ "$basename" == erics-process-* ]] || [[ "$basename" == erics-ability-* ]] || [[ "$basename" == erics-loop-router ]]; then
        final_name="$basename"
      else
        final_name="${expected_prefix}${basename}"
      fi
      
      local dest="$SKILLS_DEST/$final_name"
      rm -rf "$dest"
      ln -sf "$skill_dir" "$dest"
      echo "  [OK] $final_name"
    fi
  done
}

echo ""
echo "Installing erics-process-* skills..."
install_from_dir "$ERICSTACK_DIR/.loopx/skills/erics-process" "erics-process-"

echo ""
echo "Installing erics-ability-* skills..."
install_from_dir "$ERICSTACK_DIR/.loopx/skills/erics-ability" "erics-ability-"

echo ""
echo "Installing erics-loop-router..."
if [ -d "$ERICSTACK_DIR/.loopx/skills/erics-loop-router" ]; then
  rm -rf "$SKILLS_DEST/erics-loop-router"
  ln -sf "$ERICSTACK_DIR/.loopx/skills/erics-loop-router" "$SKILLS_DEST/erics-loop-router"
  echo "  [OK] erics-loop-router"
fi

echo ""
count=$(ls -d "$SKILLS_DEST"/erics-* 2>/dev/null | wc -l | tr -d ' ')
echo "Installed $count EricStack skills"
echo "Done! Run /estack to verify."
