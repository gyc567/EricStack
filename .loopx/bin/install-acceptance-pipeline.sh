#!/bin/bash
set -e
APS_DIR="$PWD/.loopx/acceptance-pipeline"
BIN_DIR="$APS_DIR/bin"
CACHE_DIR="$APS_DIR/../cache/aps"

echo "Installing Acceptance Pipeline Specification tools..."

# Detect Babashka
if command -v bb &> /dev/null; then
  echo "[APS] Babashka detected, using BB scripts"
  mkdir -p "$BIN_DIR/bb"
  TOOL_MODE="babashka"
else
  echo "[APS] No Babashka, checking for Go binaries..."
  TOOL_MODE="go"
fi

# Create all required directories
mkdir -p "$BIN_DIR"/{bb,go}
mkdir -p "$APS_DIR"/{features,ir,generated/metadata,reports/{dry-check,run,mutation,diagnose}}
mkdir -p "$CACHE_DIR"/{ir,dry,mutation,lint}

# Write acceptance.env if not exists
if [ ! -f "$APS_DIR/acceptance.env" ]; then
  cp /dev/stdin "$APS_DIR/acceptance.env" << 'ENVEOF'
APS_VERSION=latest
APS_TOOL_MODE=TOOL_MODE_PLACEHOLDER
APS_FEATURE_DIR=.loopx/acceptance-pipeline/features
APS_IR_DIR=.loopx/acceptance-pipeline/ir
APS_GENERATED_DIR=.loopx/acceptance-pipeline/generated
APS_REPORTS_DIR=.loopx/acceptance-pipeline/reports
APS_CACHE_DIR=.loopx/cache/aps
APS_DRY_CHECK_THRESHOLD=0
APS_PLACEHOLDER_VARIANT_THRESHOLD=3
APS_MUTATION_SURVIVAL_RATE_MAX=5
APS_FRAMEWORK=auto
ENVEOF
  sed -i "s/TOOL_MODE_PLACEHOLDER/$TOOL_MODE/" "$APS_DIR/acceptance.env"
fi

# Write .gitkeep files
find "$APS_DIR" "$CACHE_DIR" -type d -exec touch {}/.gitkeep \;

echo "[APS] Installation complete"
echo "[APS] Tool mode: $TOOL_MODE"
echo "[APS] Run: loopx acceptance-pipeline run features/**/*.feature"
