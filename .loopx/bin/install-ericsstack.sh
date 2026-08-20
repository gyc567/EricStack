#!/usr/bin/env bash
# EricStack Installer — installs 38 SKILL.md files + 2 entry points.
# Idempotent: re-running is safe. Honors --dry-run / --check / --force modes.
#
# Usage:
#   bash .loopx/bin/install-ericsstack.sh              # install (default, idempotent)
#   bash .loopx/bin/install-ericsstack.sh --check      # show current state, no changes
#   bash .loopx/bin/install-ericsstack.sh --dry-run    # show what would happen
#   bash .loopx/bin/install-ericsstack.sh --force      # overwrite without prompt
#   SKILLS_DEST=~/.claude/skills bash ...              # override target

set -euo pipefail

# ============================================================
# 1. Argument parsing
# ============================================================
MODE="install"   # install | check | dry-run
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --check)   MODE="check" ;;
    --dry-run) MODE="dry-run" ;;
    --force)   FORCE=true ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $arg"; exit 1 ;;
  esac
done

# ============================================================
# 2. Locate EricStack
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERICSTACK_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
if [ ! -d "$ERICSTACK_DIR/.loopx/skills" ]; then
  echo "Error: EricStack not found."
  echo "Expected skills next to this installer: $ERICSTACK_DIR/.loopx/skills"
  exit 1
fi

SKILLS_DEST="${SKILLS_DEST:-$HOME/.claude/skills}"
SKILLS_SRC="$ERICSTACK_DIR/.loopx/skills"

# Canonicalize and validate SKILLS_DEST to prevent path-traversal rm -rf accidents.
if ! command -v realpath &>/dev/null; then
  echo "Error: realpath is required but not installed." >&2
  exit 1
fi
CANON_DEST=$(realpath --canonicalize-missing "$SKILLS_DEST")
CANON_HOME=$(realpath --canonicalize-missing "$HOME")

case "$CANON_DEST" in
  ""|/|"$CANON_HOME")
    echo "Error: unsafe SKILLS_DEST: ${SKILLS_DEST:-<empty>}" >&2
    exit 2
    ;;
esac

# Further restrict to under $HOME/.claude/skills (realpath-resolved).
ALLOWED_PREFIX="$CANON_HOME/.claude/skills"
case "$CANON_DEST" in
  "$ALLOWED_PREFIX"|"$ALLOWED_PREFIX"/*) ;;
  *)
    echo "Error: SKILLS_DEST must be under ~/.claude/skills" >&2
    echo "  Got: $CANON_DEST" >&2
    exit 2
    ;;
esac

# ============================================================
# 3. Compute actual skill counts
# ============================================================
ACTUAL_PROCESS=$(find "$SKILLS_SRC/erics-process" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_ABILITY=$(find "$SKILLS_SRC/erics-ability" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
ACTUAL_ROUTER=$([ -f "$SKILLS_SRC/erics-loop-router/SKILL.md" ] && echo 1 || echo 0)
ACTUAL_SKILL_MD=$((ACTUAL_PROCESS + ACTUAL_ABILITY + ACTUAL_ROUTER))
ACTUAL_ENTRYPOINTS=2  # estack, estack-upgrade
ACTUAL_INSTALLED=$((ACTUAL_SKILL_MD + ACTUAL_ENTRYPOINTS))

skill_install_name() {
  local basename=$1 expected_prefix=$2
  case "$basename" in
    erics-process-*|erics-ability-*|erics-loop-router) printf '%s\n' "$basename" ;;
    *) printf '%s%s\n' "$expected_prefix" "$basename" ;;
  esac
}

for_each_managed_skill() {
  local callback=$1 src_dir=$2 expected_prefix=$3
  local skill_dir basename final_name
  [ -d "$src_dir" ] || return 0
  for skill_dir in "$src_dir"/*/; do
    [ -f "${skill_dir}SKILL.md" ] || continue
    basename=$(basename "$skill_dir")
    final_name=$(skill_install_name "$basename" "$expected_prefix")
    "$callback" "$final_name" "$skill_dir"
  done
}

count_installed() {
  local count=0 name
  count_one() {
    if [ -e "$SKILLS_DEST/$1" ] || [ -L "$SKILLS_DEST/$1" ]; then
      count=$((count + 1))
    fi
    return 0
  }
  for_each_managed_skill count_one "$SKILLS_SRC/erics-process" "erics-process-"
  for_each_managed_skill count_one "$SKILLS_SRC/erics-ability" "erics-ability-"
  if [ -e "$SKILLS_DEST/erics-loop-router" ] || [ -L "$SKILLS_DEST/erics-loop-router" ]; then
    count=$((count + 1))
  fi
  for name in estack estack-upgrade; do
    if [ -e "$SKILLS_DEST/$name" ] || [ -L "$SKILLS_DEST/$name" ]; then
      count=$((count + 1))
    fi
  done
  printf '%s\n' "$count"
}

# Banner
echo "=========================================="
echo "  EricStack Installer  (mode: $MODE)"
echo "=========================================="
echo ""
echo "  EricStack:    $ERICSTACK_DIR"
echo "  Skills dest:  $SKILLS_DEST"
echo "  Found:        $ACTUAL_SKILL_MD SKILL.md + $ACTUAL_ENTRYPOINTS entry = $ACTUAL_INSTALLED total"
echo ""

# Pre-check: LoopX
if command -v loopx >/dev/null 2>&1; then
  echo "  [OK] LoopX: $(loopx --version 2>/dev/null)"
else
  echo "  [WARN] LoopX not installed"
  echo "         Install: curl -fsSL https://huangruiteng.github.io/loopx/install.sh | bash"
  echo ""
fi

# ============================================================
# 4. Mode-specific body
# ============================================================
case "$MODE" in
  check)
    echo "=========================================="
    echo "  Install Check"
    echo "=========================================="
    ok=0; fail=0
    [ -d "$SKILLS_DEST" ] && { echo "  [OK] Dest exists: $SKILLS_DEST"; ok=$((ok+1)); } || { echo "  [FAIL] Dest missing"; fail=$((fail+1)); }
    installed=$(count_installed)
    if [ "$installed" -eq "$ACTUAL_INSTALLED" ]; then
      echo "  [OK] $installed/$ACTUAL_INSTALLED skills installed"
    else
      echo "  [FAIL] $installed/$ACTUAL_INSTALLED skills installed — run without --check to install"
      fail=$((fail+1))
    fi
    if command -v loopx >/dev/null 2>&1; then
      echo "  [OK] LoopX is installed"
    else
      echo "  [WARN] LoopX is NOT installed"
    fi
    echo ""
    [ $fail -eq 0 ] && echo "Status: HEALTHY" || echo "Status: NEEDS SETUP"
    exit $fail
    ;;

  dry-run)
    echo "=========================================="
    echo "  Dry Run"
    echo "=========================================="
    echo "  Will perform:"
    echo "    1. Connect to LoopX (if installed)"
    echo "    2. Clean old skills in $SKILLS_DEST"
    echo "    3. Symlink $ACTUAL_PROCESS erics-process-* skills"
    echo "    4. Symlink $ACTUAL_ABILITY erics-ability-* skills"
    echo "    5. Symlink erics-loop-router"
    echo "    6. Create /estack entry point"
    echo "    7. Create /estack-upgrade entry point"
    echo ""
    echo "  No files have been modified. Run without --dry-run to apply."
    exit 0
    ;;

  install)
    # Step 1: Connect to LoopX (project-level)
    echo "[1/4] Connecting to LoopX..."
    cd "$ERICSTACK_DIR"
    if command -v loopx >/dev/null 2>&1; then
      if loopx status >/dev/null 2>&1; then
        echo "  [OK] Already connected"
      else
        loopx bootstrap --project "$ERICSTACK_DIR" \
          --goal-id ericstack-goal \
          --objective "EricStack engineering loop" \
          --adapter-kind read_only_project_map_v0 \
          --adapter-status connected-read-only \
          --no-onboarding-scan \
          --codex-app-heartbeat ask >/dev/null 2>&1 \
          && echo "  [OK] Connected" \
          || echo "  [SKIP] LoopX connect skipped"
      fi
    else
      echo "  [SKIP] LoopX not installed"
    fi

    # Step 2: Clean old skills (idempotent)
    echo ""
    echo "[2/4] Cleaning old skills..."
    mkdir -p "$SKILLS_DEST"
    remove_one() { rm -rf "$SKILLS_DEST/$1"; }
    for_each_managed_skill remove_one "$SKILLS_SRC/erics-process" "erics-process-"
    for_each_managed_skill remove_one "$SKILLS_SRC/erics-ability" "erics-ability-"
    rm -rf "$SKILLS_DEST/erics-loop-router" "$SKILLS_DEST/estack" "$SKILLS_DEST/estack-upgrade"

    # Step 3: Install skills via symlinks (NOT copies — easier to update)
    echo ""
    echo "[3/4] Installing $ACTUAL_SKILL_MD skills + $ACTUAL_ENTRYPOINTS entry points..."

    install_one() {
      ln -sf "$2" "$SKILLS_DEST/$1"
      echo "  [OK] $1"
    }

    for_each_managed_skill install_one "$SKILLS_SRC/erics-process" "erics-process-"
    for_each_managed_skill install_one "$SKILLS_SRC/erics-ability" "erics-ability-"

    if [ -d "$SKILLS_SRC/erics-loop-router" ]; then
      ln -sf "$SKILLS_SRC/erics-loop-router" "$SKILLS_DEST/erics-loop-router"
      echo "  [OK] erics-loop-router"
    fi

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
UPGRADE
    printf 'cd %q && git pull origin main && bash .loopx/bin/install-ericsstack.sh\n' "$ERICSTACK_DIR" \
      >> "$SKILLS_DEST/estack-upgrade/SKILL.md"
    cat >> "$SKILLS_DEST/estack-upgrade/SKILL.md" << 'UPGRADE'
```
UPGRADE
    echo "  [OK] estack-upgrade"

    # Step 4: Summary
    echo ""
    echo "[4/4] Summary..."
    count=$(count_installed)
    echo "  Installed: $count skills (expected: $ACTUAL_INSTALLED)"
    if [ "$count" -eq "$ACTUAL_INSTALLED" ]; then
      echo "  [OK] count matches"
    else
      echo "  [FAIL] count mismatch" >&2
      exit 1
    fi

    if command -v loopx >/dev/null 2>&1; then
      echo "  LoopX: $(loopx --version 2>/dev/null)"
    else
      echo "  LoopX: NOT installed (install separately)"
    fi

    echo ""
    echo "=========================================="
    echo "Done! Run /estack to verify."
    echo ""
    echo "To upgrade: /estack-upgrade"
    echo "To uninstall: bash $ERICSTACK_DIR/.loopx/bin/uninstall-ericsstack.sh"
    ;;
esac
