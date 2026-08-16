#!/bin/bash
set -e

# Resolve EricStack location
if [ -d "/Users/jie/code/EricStack/.loopx" ]; then
  ERICSTACK_DIR="/Users/jie/code/EricStack"
elif [ -d "$HOME/EricStack/.loopx" ]; then
  ERICSTACK_DIR="$HOME/EricStack"
elif [ -d "$HOME/code/EricStack/.loopx" ]; then
  ERICSTACK_DIR="$HOME/code/EricStack"
else
  echo "Error: EricStack not found."
  echo "Run: git clone https://github.com/gyc567/EricStack.git ~/EricStack"
  exit 1
fi

SKILLS_DEST="${SKILLS_DEST:-$HOME/.claude/skills}"

echo "========================================"
echo "  EricStack Installer"
echo "========================================"
echo ""
echo "  EricStack: $ERICSTACK_DIR"
echo "  Skills:   $SKILLS_DEST"
echo ""

# Pre-check: LoopX
if command -v loopx >/dev/null 2>&1; then
  echo "[OK] LoopX is installed: $(loopx --version 2>/dev/null)"
else
  echo "[WARN] LoopX not found. To install:"
  echo "       curl -fsSL https://huangruiteng.github.io/loopx/install.sh | bash"
  echo ""
fi

# Step 1: Connect to LoopX (project-level, NOT global ~/.codex/loopx)
echo "[1/4] Connecting to LoopX (project-level)..."
cd "$ERICSTACK_DIR"
if command -v loopx >/dev/null 2>&1; then
  if loopx status >/dev/null 2>&1; then
    echo "  [OK] Already connected"
  else
    # Use read-only project map adapter — doesn't touch ~/.codex/loopx
    loopx bootstrap --project "$ERICSTACK_DIR" \
      --goal-id ericstack-goal \
      --objective "EricStack engineering loop" \
      --adapter-kind read_only_project_map_v0 \
      --adapter-status connected-read-only \
      --no-onboarding-scan \
      --codex-app-heartbeat ask >/dev/null 2>&1 && \
      echo "  [OK] Connected to LoopX" || \
      echo "  [SKIP] LoopX connect skipped (non-fatal)"
  fi
else
  echo "  [SKIP] LoopX not installed"
fi

# Step 2: Clean old installs
echo ""
echo "[2/4] Cleaning old skills..."
rm -rf "$SKILLS_DEST"/erics-*
rm -rf "$SKILLS_DEST"/estack
rm -rf "$SKILLS_DEST"/estack-upgrade

# Step 3: Install skills
echo ""
echo "[3/4] Installing skills..."

install_from_dir() {
  local src_dir="$1"
  local expected_prefix="$2"
  
  for skill_dir in "$src_dir"/*/; do
    [ -d "$skill_dir" ] && [ -f "${skill_dir}SKILL.md" ] || continue
    local basename=$(basename "$skill_dir")
    
    local final_name
    if [[ "$basename" == erics-process-* ]] || \
       [[ "$basename" == erics-ability-* ]] || \
       [[ "$basename" == erics-loop-router ]]; then
      final_name="$basename"
    else
      final_name="${expected_prefix}${basename}"
    fi
    
    ln -sf "$skill_dir" "$SKILLS_DEST/$final_name"
    echo "  [OK] $final_name"
  done
}

install_from_dir "$ERICSTACK_DIR/.loopx/skills/erics-process" "erics-process-"
install_from_dir "$ERICSTACK_DIR/.loopx/skills/erics-ability" "erics-ability-"

[ -d "$ERICSTACK_DIR/.loopx/skills/erics-loop-router" ] && \
  ln -sf "$ERICSTACK_DIR/.loopx/skills/erics-loop-router" "$SKILLS_DEST/erics-loop-router" && \
  echo "  [OK] erics-loop-router"

# /estack — slash command entry point
mkdir -p "$SKILLS_DEST/estack"
cat > "$SKILLS_DEST/estack/SKILL.md" << 'ESTACK'
---
name: estack
description: EricStack main entry point.
triggers:
  - estack
  - /estack
  - 主入口
  - 工程助手
---

# EricStack — AI-Native Engineering Loop

```
╔══════════════════════════════════════════════════════╗
║  EricStack  v0.1.0  |  40 skills  |  AI-Native Loop  ║
╚══════════════════════════════════════════════════════╝
```

Tell me what you want to do:
- "review this PR" → `/erics-process-code-review`
- "debug this error" → `/erics-ability-investigate`
- "plan this feature" → `/erics-ability-plan-eng-review`
- "run APS pipeline" → `/erics-process-acceptance-pipeline`
- "upgrade" → `/estack-upgrade`

Run `/erics-loop-router` to see all 40 skills.
ESTACK
echo "  [OK] estack (entry point)"

# /estack-upgrade
mkdir -p "$SKILLS_DEST/estack-upgrade"
cat > "$SKILLS_DEST/estack-upgrade/SKILL.md" << 'UPGRADE'
---
name: estack-upgrade
description: Upgrade all EricStack skills to latest.
triggers:
  - estack-upgrade
  - /estack-upgrade
  - upgrade ericstack
  - 升级 ericstack
---

# /estack-upgrade

```bash
cd ~/EricStack && git pull origin main && bash .loopx/bin/install-ericsstack.sh
```
UPGRADE
echo "  [OK] estack-upgrade"

# Step 4: Summary
echo ""
echo "[4/4] Summary..."
count=$(ls -d "$SKILLS_DEST"/erics-* "$SKILLS_DEST"/estack "$SKILLS_DEST"/estack-upgrade 2>/dev/null | wc -l | tr -d ' ')
echo "  Installed: $count skills"
echo ""

if command -v loopx >/dev/null 2>&1; then
  echo "  LoopX: $(loopx --version 2>/dev/null)"
else
  echo "  LoopX: NOT installed (install separately)"
fi

echo ""
echo "========================================"
echo "Done! Run /estack to verify."
echo ""
echo "To upgrade: /estack-upgrade"
echo "To uninstall: bash ~/.claude/skills/../.loopx/bin/uninstall-ericsstack.sh"
