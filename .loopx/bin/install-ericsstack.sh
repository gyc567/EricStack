#!/bin/bash
set -e

if [ -d "/Users/jie/code/EricStack/.loopx" ]; then
  ERICSTACK_DIR="/Users/jie/code/EricStack"
elif [ -d "$HOME/EricStack/.loopx" ]; then
  ERICSTACK_DIR="$HOME/EricStack"
elif [ -d "$HOME/code/EricStack/.loopx" ]; then
  ERICSTACK_DIR="$HOME/code/EricStack"
else
  echo "Error: EricStack .loopx/ not found."
  exit 1
fi

SKILLS_DEST="${SKILLS_DEST:-$HOME/.claude/skills}"
LOOPX_STATE="$HOME/.codex/loopx"

echo "Installing EricStack..."
echo "  EricStack: $ERICSTACK_DIR"
echo "  Skills:   $SKILLS_DEST"

# 1. Link .loopx/ to LoopX runtime
if [ ! -e "$LOOPX_STATE" ]; then
  echo ""
  echo "[1/3] Linking .loopx/ to LoopX runtime..."
  mkdir -p "$(dirname "$LOOPX_STATE")"
  ln -sf "$ERICSTACK_DIR/.loopx" "$LOOPX_STATE"
  echo "  ✓ Linked: $LOOPX_STATE → $ERICSTACK_DIR/.loopx"
else
  echo ""
  echo "[1/3] LoopX runtime already exists (skipping)"
fi

# 2. Clean old installs
rm -rf "$SKILLS_DEST"/erics-*
rm -rf "$SKILLS_DEST"/estack

# 3. Install skills
echo ""
echo "[2/3] Installing skills..."

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

if [ -d "$ERICSTACK_DIR/.loopx/skills/erics-loop-router" ]; then
  ln -sf "$ERICSTACK_DIR/.loopx/skills/erics-loop-router" "$SKILLS_DEST/erics-loop-router"
  echo "  [OK] erics-loop-router"
fi

# /estack top-level slash command
mkdir -p "$SKILLS_DEST/estack"
cat > "$SKILLS_DEST/estack/SKILL.md" << 'ESTACK'
---
name: estack
description: EricStack main entry point — displays interactive banner and routes to the correct skill.
triggers:
  - estack
  - /estack
  - 主入口
  - 工程助手
---

# EricStack — AI-Native Engineering Loop

```
╔══════════════════════════════════════════════════════╗
║  EricStack  v0.1.0  |  38 skills  |  AI-Native Loop  ║
╚══════════════════════════════════════════════════════╝
```

## Quick Start

Tell me what you want to do and I'll route to the right skill:

- "review this PR" → `/erics-process-code-review`
- "debug this error" → `/erics-ability-investigate`
- "plan this feature" → `/erics-ability-plan-eng-review`
- "run acceptance pipeline" → `/erics-process-acceptance-pipeline`

Run `/erics-loop-router` to see all 38 skills.
ESTACK
echo "  [OK] estack (slash command entry)"

# /estack-upgrade top-level slash command
mkdir -p "$SKILLS_DEST/estack-upgrade"
cat > "$SKILLS_DEST/estack-upgrade/SKILL.md" << 'UPGRADE'
---
name: estack-upgrade
description: Upgrade all EricStack skills, scripts, and docs to the latest version from GitHub.
triggers:
  - estack-upgrade
  - /estack-upgrade
  - upgrade ericstack
  - update ericstack
  - 升级 ericstack
---

# /estack-upgrade — Upgrade EricStack

## One-Command Upgrade

```bash
cd ~/EricStack && git pull origin main && bash .loopx/bin/install-ericsstack.sh
```

## What Gets Upgraded

- All 39 skills (linked from latest `.loopx/skills/`)
- `install-ericsstack.sh` script
- APS infrastructure (`.loopx/acceptance-pipeline/`)
- Wiki knowledge base (`.loopx/wiki/`)
- All docs (`README.md`, `docs/*.md`)

## Before Upgrading

- Commit or stash local changes to `.loopx/` or `docs/`
- Upstream changes will overwrite local `.loopx/`
UPGRADE
echo "  [OK] estack-upgrade (slash command entry)"

# 4. LoopX registration
echo ""
echo "[3/3] LoopX registration..."
if ! loopx status >/dev/null 2>&1; then
  echo "  [SKIP] LoopX not available"
else
  echo "  ✓ LoopX running"
fi

echo ""
count=$(ls -d "$SKILLS_DEST"/erics-* "$SKILLS_DEST"/estack "$SKILLS_DEST"/estack-upgrade 2>/dev/null | wc -l | tr -d ' ')
echo "Installed $count skills"
echo ""
echo "Run /estack to verify!"
