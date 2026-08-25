#!/usr/bin/env bash
# EricStack Installer — installs $ACTUAL_SKILL_MD SKILL.md files + $ACTUAL_ENTRYPOINTS entry points (counts auto-computed below).
# Idempotent: re-running is safe. Honors --dry-run / --check modes.
#
# Usage:
#   bash .loopx/bin/install-ericsstack.sh                       # install (default, idempotent)
#   bash .loopx/bin/install-ericsstack.sh --check               # show current state, no changes
#   bash .loopx/bin/install-ericsstack.sh --dry-run             # show what would happen
#   bash .loopx/bin/install-ericsstack.sh --mode both           # enable Loop Engineering runtime
#   bash .loopx/bin/install-ericsstack.sh --with-loop-engineering-cli   # also npm install -g @cobusgreyling/loop-cli
#   SKILLS_DEST=~/.claude/skills bash ...                       # override target

set -euo pipefail

# ============================================================
# 1. Argument parsing
# ============================================================
MODE="install"            # install | check | dry-run
LOOP_ENG_MODE="loopx"     # loopx | loop-engineering | both
WITH_LOOP_DOCS="true"     # copy LOOP_ENGINEERING_INTEGRATION.md into runtime docs
WITH_LOOP_CLI="false"     # npm install -g @cobusgreyling/loop-cli
SKIP_LOOP_ENG="false"
args=("$@")
i=0
while [ $i -lt ${#args[@]} ]; do
  arg="${args[$i]}"
  case "$arg" in
    --check)   MODE="check" ;;
    --dry-run) MODE="dry-run" ;;
    --mode)
      i=$((i + 1))
      next="${args[$i]:-}"
      case "$next" in
        loopx|loop-engineering|both) LOOP_ENG_MODE="$next" ;;
        *) echo "Unknown --mode value: '$next' (expected loopx|loop-engineering|both)" >&2; exit 2 ;;
      esac
      ;;
    --mode=*)
      next="${arg#--mode=}"
      case "$next" in
        loopx|loop-engineering|both) LOOP_ENG_MODE="$next" ;;
        *) echo "Unknown --mode value: '$next' (expected loopx|loop-engineering|both)" >&2; exit 2 ;;
      esac
      ;;
    --with-loop-engineering-cli) WITH_LOOP_CLI="true" ;;
    --with-loop-docs)            WITH_LOOP_DOCS="true" ;;
    --skip-loop-docs)            WITH_LOOP_DOCS="false" ;;
    --skip-loop-engineering)     SKIP_LOOP_ENG="true" ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $arg" >&2; exit 2 ;;
  esac
  i=$((i + 1))
done

if [ "$SKIP_LOOP_ENG" = "true" ]; then
  LOOP_ENG_MODE="loopx"
fi

# Loop Engineering entry skills (proxies to @cobusgreyling/loop-cli)
LOOP_ENG_SKILLS=(
  "loop-doctor:doctor:Diagnose Loop Engineering readiness and print Loop Ready Score"
  "loop-status:status:Show current active loops and runtime state"
  "loop-mode:mode:Switch between loopx and loop-engineering runtimes"
  "loop-init:init:Scaffold loop patterns into the user's project"
)

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

# Path-traversal protection: shared helper validates SKILLS_DEST against
# symlink-resolved ~/.claude/skills before any rm -rf runs.
source "$SCRIPT_DIR/lib-pathsafe.sh"
assert_safe_skills_dest "$SKILLS_DEST"

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

# Loop Engineering wrappers are user-side runtime artifacts whose presence
# depends on npm availability at install time, so --check counts catalog
# items deterministically and reports wrappers informationally instead.
loop_eng_wrappers_present() {
  local present="" entry wname
  for entry in "${LOOP_ENG_SKILLS[@]}"; do
    wname=${entry%%:*}
    if [ -e "$SKILLS_DEST/$wname" ] || [ -L "$SKILLS_DEST/$wname" ]; then
      present="$present $wname"
    fi
  done
  printf '%s\n' "$present"
}

# Banner
echo "=========================================="
echo "  EricStack Installer  (mode: $MODE)"
echo "=========================================="
echo ""
echo "  EricStack:        $ERICSTACK_DIR"
echo "  Skills dest:      $SKILLS_DEST"
echo "  Found:            $ACTUAL_SKILL_MD SKILL.md + $ACTUAL_ENTRYPOINTS entry = $ACTUAL_INSTALLED total"
echo "  Loop Eng mode:    $LOOP_ENG_MODE"
echo "  Copy loop docs:   $WITH_LOOP_DOCS"
echo "  Install loop-cli: $WITH_LOOP_CLI"
echo ""

# Pre-check: LoopX
if command -v loopx >/dev/null 2>&1; then
  echo "  [OK] LoopX: $(loopx --version 2>/dev/null)"
else
  echo "  [WARN] LoopX not installed"
  echo "         Install: curl -fsSL https://huangruiteng.github.io/loopx/install.sh | bash"
  echo ""
fi

# Pre-check: Node.js (only matters when loop-engineering mode active)
if [ "$LOOP_ENG_MODE" != "loopx" ]; then
  if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo "  [OK] Node.js: $(node --version)"
  else
    echo "  [WARN] Node.js/npm not found — --mode $LOOP_ENG_MODE will skip loop-cli install"
    echo "         Install Node.js: https://nodejs.org/"
    echo ""
  fi
fi

# ============================================================
# 3a. Loop Engineering helpers
# ============================================================
LOOP_ENG_DOCS_DIR="$HOME/.loop-engineering/docs"
LOOP_ENG_DOC_SRC="$ERICSTACK_DIR/docs/LOOP_ENGINEERING_INTEGRATION.md"
LOOP_ENG_STATE_FILE="$ERICSTACK_DIR/loop/STATE.md"
LOOP_ENG_STATE_JSON="$ERICSTACK_DIR/.loopx/loop-engineering-state.json"
LOOP_ENG_REG_GOAL="ericstack-loop-engineering-goal"

# generate_loop_eng_skill <name> <subcmd> <desc> -> writes $SKILLS_DEST/<name>/SKILL.md
generate_loop_eng_skill() {
  local name=$1 subcmd=$2 desc=$3
  local dest="$SKILLS_DEST/$name"
  # Escape for safe interpolation into the double-quoted YAML description.
  desc=${desc//\\/\\\\}
  desc=${desc//\"/\\\"}
  mkdir -p "$dest"
  cat > "$dest/SKILL.md" <<EOF
---
name: $name
description: "$desc (proxies to @cobusgreyling/loop-cli)."
triggers:
  - $name
  - /$name
  - $subcmd
loop_pattern: tool-call
autonomy_level: L1
---

# /$name

Shell wrapper. Delegates to:

\`\`\`bash
npx --yes @cobusgreyling/loop-cli $subcmd
\`\`\`

If \`loop-cli\` is missing or Node.js is unavailable, run:

\`\`\`bash
npm install -g @cobusgreyling/loop-cli
\`\`\`

then re-invoke \`/$name\`.
EOF
}

# write_loop_eng_state -> writes loop/STATE.md + .loopx/loop-engineering-state.json
write_loop_eng_state() {
  mkdir -p "$(dirname "$LOOP_ENG_STATE_FILE")" "$(dirname "$LOOP_ENG_STATE_JSON")"
  local active_runtime
  case "$LOOP_ENG_MODE" in
    loopx)            active_runtime="loopx" ;;
    loop-engineering) active_runtime="loop-engineering" ;;
    both)             active_runtime="both" ;;
  esac

  cat > "$LOOP_ENG_STATE_FILE" <<EOF
---
active_runtime: $active_runtime
runtime_override: null
mode: $LOOP_ENG_MODE
last_audit_score: null
last_audit_at: null
generated_by: install-ericsstack.sh
generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

# Loop Engineering State

Generated by \`install-ericsstack.sh\`. Re-run the installer to refresh.

## Active runtime

\`$active_runtime\`

## Resolved mode

\`$LOOP_ENG_MODE\`

## Priority

session (\`loop/STATE.md\`) > project (\`.loopx/registry.json\`) > global (\`loop-mode\` SKILL.md frontmatter)
EOF

  cat > "$LOOP_ENG_STATE_JSON" <<EOF
{
  "schema_version": "0.1",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "mode": "$LOOP_ENG_MODE",
  "active_runtime": "$active_runtime",
  "loop_cli_installed": $(command -v loop-cli >/dev/null 2>&1 && echo true || echo false),
  "node_available": $(command -v node >/dev/null 2>&1 && echo true || echo false)
}
EOF
}

# add_loop_eng_goal_to_registry -> appends ericstack-loop-engineering-goal to .loopx/registry.json
add_loop_eng_goal_to_registry() {
  local reg="$ERICSTACK_DIR/.loopx/registry.json"
  # registry.json is untracked runtime state; fresh clones bootstrap from the
  # example fixture so Loop Engineering registration works on first install.
  if [ ! -f "$reg" ]; then
    local example="$ERICSTACK_DIR/.loopx/registry.example.json"
    if [ -f "$example" ]; then
      cp "$example" "$reg"
      echo "  [OK] bootstrapped .loopx/registry.json from example fixture"
    else
      echo "  [SKIP] registry goal: no registry.json and no example fixture"
      return 0
    fi
  fi
  command -v jq >/dev/null 2>&1 || { echo "  [SKIP] registry goal: jq not installed"; return 0; }

  # Idempotent: if goal already present, skip.
  if jq -e --arg id "$LOOP_ENG_REG_GOAL" '.goals | map(.id) | index($id)' "$reg" >/dev/null 2>&1; then
    echo "  [OK] registry goal already present: $LOOP_ENG_REG_GOAL"
    return 0
  fi

  local tmp goal_json updated_at
  tmp=$(mktemp)
  # bash 3.2 (macOS default) lacks the RETURN trap, so we cleanup explicitly
  # in both branches below instead of relying on a trap.

  updated_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  goal_json=$(jq -n --arg repo "$ERICSTACK_DIR" --arg updated "$updated_at" '{
    id: "ericstack-loop-engineering-goal",
    domain: "loop-engineering-runtime",
    status: "active",
    role: "loop-engineering-runtime",
    parent_goal_id: "ericstack-goal",
    repo: $repo,
    state_file: ".codex/goals/ericstack-loop-engineering-goal/ACTIVE_GOAL_STATE.md",
    authority_sources: ["docs/LOOP_ENGINEERING_INTEGRATION.md"],
    adapter: {
      kind: "read_only_loop_engineering_v0",
      status: "connected-read-only",
      previous_kind: null,
      upgraded_at: null,
      upgrade_reason: null
    },
    coordination: {
      write_scope: [".loopx/wiki/", "loop/STATE.md", ".loopx/loop-engineering-state.json"],
      requires_parent_approval: ["publish", "production-action", "external-write", "git-push"],
      registered_agents: [],
      agent_model: "peer_v1"
    },
    execution_profile: {
      cadence: "bounded_progress_segment",
      minimum_scale: "single_surface",
      must_include: ["coherent_artifact", "state_writeback"],
      spend_rule: "spend_only_after_artifact_validation_writeback",
      outcome_floor: {
        required_when: "after_surface_progress_streak",
        surface_streak_threshold: 3,
        outcome_markers: [],
        surface_only_hints: [],
        must_advance: ["primary_goal_outcome"],
        avoid: ["surface_only_progress_loop"],
        if_unavailable: "report_blocker_without_spend"
      },
      degradation_policy: {
        small_scale_streak_threshold: 2,
        on_degradation: "require_blocker_or_expand_next_batch"
      }
    },
    next_probe: "loop-cli doctor",
    guards: [
      "loop-engineering goal is read-only by default; upgrade to read-write requires explicit user approval",
      "do not modify ericstack-goal adapter from this goal"
    ]
  }')

  if jq --arg updated "$updated_at" --argjson goal "$goal_json" \
       '.updated_at = $updated | .goals += [$goal]' "$reg" > "$tmp"; then
    mv "$tmp" "$reg"
    echo "  [OK] registry goal added: $LOOP_ENG_REG_GOAL"
    return 0
  else
    echo "  [FAIL] registry goal add failed" >&2
    rm -f "$tmp"
    return 1
  fi
}

# install_loop_eng_cli -> npm install -g @cobusgreyling/loop-cli (optional, opt-in)
install_loop_eng_cli() {
  [ "$WITH_LOOP_CLI" = "true" ] || { echo "  [SKIP] loop-cli install: --with-loop-engineering-cli not set"; return 0; }
  [ "$LOOP_ENG_MODE" != "loopx" ] || { echo "  [SKIP] loop-cli install: --mode loopx"; return 0; }
  command -v npm >/dev/null 2>&1 || { echo "  [SKIP] loop-cli install: npm not available"; return 0; }
  echo "  Installing @cobusgreyling/loop-cli ..."
  if npm install -g @cobusgreyling/loop-cli 2>&1 | tail -5; then
    echo "  [OK] loop-cli installed"
  else
    echo "  [WARN] loop-cli install failed (continuing)"
  fi
}

# copy_loop_eng_docs -> copies LOOP_ENGINEERING_INTEGRATION.md into runtime docs dir
copy_loop_eng_docs() {
  [ "$WITH_LOOP_DOCS" = "true" ] || { echo "  [SKIP] loop docs copy: --skip-loop-docs"; return 0; }
  [ -f "$LOOP_ENG_DOC_SRC" ] || { echo "  [WARN] loop docs source missing: $LOOP_ENG_DOC_SRC"; return 0; }
  mkdir -p "$LOOP_ENG_DOCS_DIR"
  cp -f "$LOOP_ENG_DOC_SRC" "$LOOP_ENG_DOCS_DIR/LOOP_ENGINEERING_INTEGRATION.md"
  echo "  [OK] loop docs copied to $LOOP_ENG_DOCS_DIR/"
}

# install_loop_eng_wrappers -> writes 4 SKILL.md wrappers to $SKILLS_DEST/loop-{doctor,status,mode,init}
install_loop_eng_wrappers() {
  [ "$LOOP_ENG_MODE" != "loopx" ] || { echo "  [SKIP] loop wrappers: mode is loopx"; return 0; }
  local entry
  for entry in "${LOOP_ENG_SKILLS[@]}"; do
    IFS=':' read -r name subcmd desc <<< "$entry"
    generate_loop_eng_skill "$name" "$subcmd" "$desc"
    echo "  [OK] $name (wrapper -> loop-cli $subcmd)"
  done
}

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
    wrappers=$(loop_eng_wrappers_present)
    if [ -n "$wrappers" ]; then
      echo "  [INFO] Loop Engineering wrappers present:$wrappers"
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
    echo "    [1/7] Connect to LoopX (when mode=loopx or both)"
    echo "    [2/7] Install loop-cli (when --with-loop-engineering-cli + Node.js)"
    echo "    [3/7] Clean old skills in $SKILLS_DEST"
    echo "    [4/7] Symlink $ACTUAL_PROCESS erics-process-* + $ACTUAL_ABILITY erics-ability-* + 1 router + 2 entry points"
    if [ "$WITH_LOOP_DOCS" = "true" ] && [ "$LOOP_ENG_MODE" != "loopx" ]; then
      echo "    [5/7] Copy docs/LOOP_ENGINEERING_INTEGRATION.md -> $LOOP_ENG_DOCS_DIR/"
    fi
    if [ "$LOOP_ENG_MODE" != "loopx" ]; then
      echo "    [6/7] Write loop/STATE.md + .loopx/loop-engineering-state.json + append goal"
      echo "    [7/7] Generate 4 loop-* shell wrapper SKILL.md (loop-doctor, loop-status, loop-mode, loop-init)"
    fi
    echo ""
    echo "  No files have been modified. Run without --dry-run to apply."
    exit 0
    ;;

  install)
    # Step 1: Connect to LoopX (project-level) — only when mode includes loopx
    echo "[1/7] Connecting to LoopX..."
    cd "$ERICSTACK_DIR"
    if [ "$LOOP_ENG_MODE" = "loop-engineering" ]; then
      echo "  [SKIP] LoopX connect skipped (mode=loop-engineering)"
    elif command -v loopx >/dev/null 2>&1; then
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

    # Step 2: Install loop-cli (optional, opt-in via --with-loop-engineering-cli)
    echo ""
    echo "[2/7] Installing loop-cli (if requested)..."
    install_loop_eng_cli

    # Step 3: Clean old skills (idempotent)
    echo ""
    echo "[3/7] Cleaning old skills..."
    mkdir -p "$SKILLS_DEST"
    remove_one() { rm -rf "$SKILLS_DEST/$1"; }
    for_each_managed_skill remove_one "$SKILLS_SRC/erics-process" "erics-process-"
    for_each_managed_skill remove_one "$SKILLS_SRC/erics-ability" "erics-ability-"
    rm -rf "$SKILLS_DEST/erics-loop-router" "$SKILLS_DEST/estack" "$SKILLS_DEST/estack-upgrade"
    # Only remove loop-* wrappers when mode is not active (avoid clobbering on re-run with --mode loopx).
    if [ "$LOOP_ENG_MODE" = "loopx" ]; then
      for name in loop-doctor loop-status loop-mode loop-init; do
        rm -rf "$SKILLS_DEST/$name"
      done
    fi

    # Step 4: Install skills via symlinks (NOT copies — easier to update)
    echo ""
    echo "[4/7] Installing $ACTUAL_SKILL_MD skills + $ACTUAL_ENTRYPOINTS entry points..."

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
ESTACK
    printf '║  EricStack  v0.1.0  |  %d skills  |  AI-Native Loop  ║\n' "$ACTUAL_SKILL_MD" \
      >> "$SKILLS_DEST/estack/SKILL.md"
    cat >> "$SKILLS_DEST/estack/SKILL.md" << 'ESTACK'
╚══════════════════════════════════════════════════════╝
```

Tell me what you want to do:
- "review this PR" → `/erics-process-code-review`
- "debug this error" → `/erics-ability-investigate`
- "plan this feature" → `/erics-ability-plan-eng-review`
- "run APS pipeline" → `/erics-process-acceptance-pipeline`
- "upgrade" → `/estack-upgrade`

ESTACK
    printf 'Run `/erics-loop-router` to see all %d skills.\n' "$ACTUAL_SKILL_MD" \
      >> "$SKILLS_DEST/estack/SKILL.md"
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

    # Step 5: Copy LOOP_ENGINEERING_INTEGRATION.md into runtime docs dir
    echo ""
    if [ "$LOOP_ENG_MODE" != "loopx" ] && [ "$WITH_LOOP_DOCS" = "true" ]; then
      echo "[5/7] Copying LOOP_ENGINEERING_INTEGRATION.md..."
      copy_loop_eng_docs
    else
      echo "[5/7] Skipping loop docs copy"
    fi

    # Step 6: Write loop-engineering state + register independent goal
    echo ""
    if [ "$LOOP_ENG_MODE" != "loopx" ]; then
      echo "[6/7] Writing loop-engineering runtime state..."
      write_loop_eng_state
      echo "  [OK] $LOOP_ENG_STATE_FILE"
      echo "  [OK] $LOOP_ENG_STATE_JSON"
      add_loop_eng_goal_to_registry
    else
      echo "[6/7] Skipping loop-engineering runtime state (mode=loopx)"
    fi

    # Step 7: Generate 4 loop-* shell wrappers
    echo ""
    if [ "$LOOP_ENG_MODE" != "loopx" ]; then
      echo "[7/7] Generating loop-* entry skill wrappers..."
      install_loop_eng_wrappers
    else
      echo "[7/7] Skipping loop-* wrappers (mode=loopx)"
    fi

    # Summary
    echo ""
    echo "=========================================="
    echo "  Summary"
    echo "=========================================="
    count=$(count_installed)
    base_expected=$((ACTUAL_INSTALLED))
    loop_extra=0
    [ "$LOOP_ENG_MODE" != "loopx" ] && loop_extra=4
    expected=$((base_expected + loop_extra))
    echo "  Installed: $count skills (expected: $expected)"
    if [ "$count" -eq "$expected" ]; then
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
    echo "  Loop Engineering: $LOOP_ENG_MODE"
    if [ "$LOOP_ENG_MODE" != "loopx" ] && [ "$WITH_LOOP_CLI" = "true" ]; then
      if command -v loop-cli >/dev/null 2>&1; then
        echo "  loop-cli: $(loop-cli --version 2>/dev/null || echo 'installed')"
      else
        echo "  loop-cli: install attempted (may not be on PATH)"
      fi
    fi

    echo ""
    echo "=========================================="
    echo "Done! Run /estack to verify."
    echo ""
    echo "To upgrade: /estack-upgrade"
    echo "To uninstall: bash $ERICSTACK_DIR/.loopx/bin/uninstall-ericsstack.sh"
    if [ "$LOOP_ENG_MODE" != "loopx" ]; then
      echo "To purge loop-engineering: bash $ERICSTACK_DIR/.loopx/bin/uninstall-ericsstack.sh --purge-loop-engineering"
    fi
    ;;
esac
