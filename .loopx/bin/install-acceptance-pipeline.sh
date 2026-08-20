#!/usr/bin/env bash
# Install Acceptance Pipeline Specification (APS) tools into the project.
# Aligned with docs/APS_INTEGRATION.md v1.1.
#
# Usage:
#   bash .loopx/bin/install-acceptance-pipeline.sh           # install (default)
#   bash .loopx/bin/install-acceptance-pipeline.sh --check   # check current state
#   bash .loopx/bin/install-acceptance-pipeline.sh --upgrade # re-fetch v1.1 config
#   bash .loopx/bin/install-acceptance-pipeline.sh --help

set -euo pipefail

APS_DIR="$PWD/.loopx/acceptance-pipeline"
BIN_DIR="$APS_DIR/bin"
CACHE_DIR="$APS_DIR/../cache/aps"
CONFIG_FILE="$APS_DIR/acceptance.env"

# Parse args
MODE="install"
for arg in "$@"; do
  case "$arg" in
    --check)  MODE="check" ;;
    --upgrade) MODE="upgrade" ;;
    --help|-h)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

echo "=========================================="
echo "  APS Installer  (EricStack v1.1)"
echo "=========================================="
echo "  Project: $PWD"
echo "  Mode:    $MODE"
echo ""

# Detect Babashka
TOOL_MODE="go"
if command -v bb &> /dev/null; then
  TOOL_MODE="babashka"
fi
echo "[APS] Detected tool mode: $TOOL_MODE"

# Create directory structure
create_dirs() {
  mkdir -p "$BIN_DIR/bb" "$BIN_DIR/go"
  mkdir -p "$APS_DIR/features"
  mkdir -p "$APS_DIR/ir"
  mkdir -p "$APS_DIR/generated/metadata"
  mkdir -p "$APS_DIR/reports/dry-check"
  mkdir -p "$APS_DIR/reports/run"
  mkdir -p "$APS_DIR/reports/mutation"
  mkdir -p "$APS_DIR/reports/diagnose"
  mkdir -p "$CACHE_DIR/ir" "$CACHE_DIR/dry" "$CACHE_DIR/mutation" "$CACHE_DIR/lint"
}

write_config() {
  # Write a v1.1-compatible acceptance.env. Idempotent: only writes if missing,
  # or always in upgrade mode.
  if [ -f "$CONFIG_FILE" ] && [ "$MODE" != "upgrade" ]; then
    echo "[APS] acceptance.env exists, leaving untouched (use --upgrade to refresh)"
    return 0
  fi
  cat > "$CONFIG_FILE" << 'ENVEOF'
# Acceptance Pipeline Specification (APS) — EricStack v1.1
APS_TOOL_AVAILABLE=false
APS_VERSION=v1.2.0
APS_TOOL_MODE=babashka
APS_VERIFY_CHECKSUMS=true
APS_FEATURE_DIR=.loopx/acceptance-pipeline/features
APS_IR_DIR=.loopx/acceptance-pipeline/ir
APS_GENERATED_DIR=.loopx/acceptance-pipeline/generated
APS_REPORTS_DIR=.loopx/acceptance-pipeline/reports
APS_CACHE_DIR=.loopx/cache/aps
APS_HOOKS_FILE=.loopx/acceptance-pipeline/hooks.yaml
APS_FRAMEWORK=auto
APS_LINT_ENABLED=true
APS_LINT_MIN_SCENARIOS=1
APS_LINT_MAX_STEPS=15
APS_LINT_REQUIRE_BACKGROUND=true
APS_LINT_ALLOWED_TAGS=@smoke,@regression,@auth,@api,@ui,@integration,@slow,@quarantine
APS_DRY_CHECK_THRESHOLD=0
APS_PLACEHOLDER_VARIANT_THRESHOLD=3
APS_NEAR_DUPLICATE_THRESHOLD=0.85
APS_FAIL_ON_MISSING_HANDLERS=true
APS_WARN_ON_ORPHAN_HANDLERS=true
APS_SANDBOX=auto
APS_SANDBOX_DETECT_SIDE_EFFECTS=true
APS_SANDBOX_REQUIRE_DISPOSE=true
APS_MUTATION_EXCELLENT_THRESHOLD=3
APS_MUTATION_WARN_THRESHOLD=8
APS_MUTATION_TODO_THRESHOLD=15
APS_MUTATION_WHITELIST=.loopx/acceptance-pipeline/mutation-whitelist.txt
APS_MUTATION_INCREMENTAL=true
APS_MUTATION_TIMEOUT_SECONDS=300
APS_CACHE_ENABLED=true
APS_CACHE_TTL_DAYS=7
APS_CACHE_LRU_MAX_ENTRIES=1000
APS_PROGRESS=auto
APS_VERBOSITY=normal
APS_OUTPUT_FORMAT=junit
APS_DIAGNOSE_ON_FAILURE=true
APS_DIAGNOSE_FORMAT=markdown
APS_DIAGNOSE_DIR=.loopx/acceptance-pipeline/reports/diagnose
APS_HOOKS_ENABLED=true
APS_CUSTOM_STAGES_FILE=.loopx/acceptance-pipeline/custom-stages.yaml
APS_MUTATION_SURVIVAL_RATE_MAX=15
ENVEOF
  # -i.bak works with both GNU sed and macOS/BSD sed.
  sed -i.bak "s/^APS_TOOL_MODE=babashka/APS_TOOL_MODE=$TOOL_MODE/" "$CONFIG_FILE"
  rm -f "$CONFIG_FILE.bak"
  echo "[APS] Wrote v1.1 acceptance.env"
}

write_gitkeeps() {
  find "$APS_DIR" "$CACHE_DIR" -type d -exec touch {}/.gitkeep \; 2>/dev/null || true
}

case "$MODE" in
  check)
    echo ""
    echo "=========================================="
    echo "  APS Check  (v1.1)"
    echo "=========================================="
    ok=0; fail=0; tools_unavailable=0
    if [ -d "$BIN_DIR/bb" ] && [ -d "$BIN_DIR/go" ]; then
      echo "  [OK] bin/ structure present"
    else
      echo "  [FAIL] bin/ structure missing — run without --check"; fail=$((fail+1))
    fi
    if [ -f "$CONFIG_FILE" ]; then
      echo "  [OK] acceptance.env present"
      # Check for v1.1 markers
      if grep -q 'APS_MUTATION_TODO_THRESHOLD' "$CONFIG_FILE"; then
        echo "  [OK] v1.1 config (tiered mutation thresholds)"
      else
        echo "  [WARN] v1.0 config — run with --upgrade"
      fi
    else
      echo "  [FAIL] acceptance.env missing — run without --check"; fail=$((fail+1))
    fi
    # Check tool binaries
    if [ -x "$BIN_DIR/bb/gherkin-parser" ] || [ -x "$BIN_DIR/go/gherkin-parser" ]; then
      echo "  [OK] gherkin-parser binary present"
    else
      echo "  [WARN] gherkin-parser NOT installed (APS_TOOL_AVAILABLE should be false)"
      tools_unavailable=1
      if [ -f "$CONFIG_FILE" ] && grep -q '^APS_TOOL_AVAILABLE=true' "$CONFIG_FILE"; then
        echo "  [FAIL] config enables APS tools, but gherkin-parser is missing"
        fail=$((fail+1))
      fi
    fi
    echo ""
    if [ $fail -gt 0 ]; then
      echo "Status: NEEDS INSTALL"
    elif [ $tools_unavailable -gt 0 ]; then
      echo "Status: CONFIGURED (TOOLS UNAVAILABLE)"
    else
      echo "Status: HEALTHY"
    fi
    exit $fail
    ;;
  install|upgrade)
    create_dirs
    if [ -f "$CONFIG_FILE" ] && [ "$MODE" != "upgrade" ]; then
      echo "[APS] acceptance.env exists, leaving untouched (use --upgrade to refresh)"
    else
      write_config
    fi
    write_gitkeeps
    echo ""
    echo "=========================================="
    echo "  Installation complete"
    echo "=========================================="
    echo "  Tool mode:    $TOOL_MODE"
    echo "  Config:       $CONFIG_FILE"
    echo "  Bin dir:      $BIN_DIR"
    echo "  Cache dir:    $CACHE_DIR"
    echo ""
    echo "  Next steps:"
    echo "    1. Add .feature files to $APS_DIR/features/"
    echo "    2. Set APS_TOOL_AVAILABLE=true after installing gherkin-* tools"
    echo "    3. Run: loopx acceptance-pipeline run features/**/*.feature"
    echo ""
    echo "  Note: Binaries (gherkin-parser/dry-checker/mutator) are NOT auto-downloaded."
    echo "        See docs/APS_INTEGRATION.md §4 for installation instructions."
    ;;
esac
