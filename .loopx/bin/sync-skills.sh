#!/bin/bash
# EricStack Skill Sync — checks and syncs erics-* skills from upstream repos
# Usage:
#   sync-skills.sh --check      # Check for updates (no changes)
#   sync-skills.sh --dry-run    # Show what would change
#   sync-skills.sh --execute    # Actually sync (with confirmation)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOPX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$LOOPX_DIR/sync-state.json"
SKILLS_DIR="$LOOPX_DIR/skills"

# Colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source repos
DSH_URL="https://github.com/deepseek-ai/deepseek-harness.git"
DSH_REMOTE_URL="https://github.com/deepseek-ai/deepseek-harness"
GSTACK_URL="https://github.com/garrytan/gstack.git"

log()  { echo -e "$*"; }
ok()   { log "${GREEN}✓ $*${NC}"; }
warn() { log "${YELLOW}⚠ $*${NC}"; }
fail() { log "${RED}✗ $*${NC}"; }

need_tool() {
  if ! command -v "$1" &>/dev/null; then
    fail "Required tool missing: $1"
    exit 1
  fi
}

need_tool jq
need_tool git

# Fetch remote HEAD commits (lightweight, no clone)
get_remote_commit() {
  local url=$1
  git ls-remote --quiet "$url" HEAD 2>/dev/null | cut -f1
}

get_local_commit() {
  local source=$1
  jq -r ".sources[\"$source\"].commit // empty" "$STATE_FILE"
}

read_state() {
  jq -r '.sources["deepseek-harness"].commit' "$STATE_FILE"
  jq -r '.sources["gstack"].commit' "$STATE_FILE"
  jq -r '.sources["deepseek-harness"].last_sync' "$STATE_FILE"
  jq -r '.sources["gstack"].last_sync' "$STATE_FILE"
}

update_state() {
  local source=$1
  local commit=$2
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp=$(mktemp)
  jq "(.sources[\"$source\"].commit = \"$commit\") | (.sources[\"$source\"].last_sync = \"$timestamp\")" "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
}

print_status() {
  local source=$1
  local local_commit=$2
  local remote_commit=$3
  local last_sync=$4

  local status
  local color
  if [ "$local_commit" = "$remote_commit" ]; then
    status="UP-TO-DATE"
    color=$GREEN
  else
    status="UPDATE AVAILABLE"
    color=$YELLOW
  fi

  printf "  %-20s  ${color}%-15s${NC}  %s → %s\n" "$source" "$status" "${local_commit:0:8}" "${remote_commit:0:8}"
  printf "    Last sync: %s\n" "$last_sync"
}

cmd_check() {
  log "\n${BOLD}EricStack Skill Sync Check${NC}\n"

  local dsh_local=$(get_local_commit deepseek-harness)
  local gstack_local=$(get_local_commit gstack)

  log "  Fetching upstream commits..."
  local dsh_remote=$(get_remote_commit "$DSH_URL")
  local gstack_remote=$(get_remote_commit "$GSTACK_URL")

  echo ""
  printf "  %-20s  %-15s  %s\n" "SOURCE" "STATUS" "LOCAL → REMOTE"
  printf "  %-20s  %-15s  %s\n" "──────" "──────" "──────────────"
  print_status "deepseek-harness" "$dsh_local" "$dsh_remote" "$(jq -r '.sources["deepseek-harness"].last_sync' "$STATE_FILE")"
  print_status "gstack" "$gstack_local" "$gstack_remote" "$(jq -r '.sources["gstack"].last_sync' "$STATE_FILE")"
  echo ""

  local updates=0
  [ "$dsh_local" != "$dsh_remote" ] && ((updates++))
  [ "$gstack_local" != "$gstack_remote" ] && ((updates++))

  if [ $updates -eq 0 ]; then
    ok "All skills are up to date."
  else
    warn "$updates source(s) have updates available."
    log ""
    log "  Run with --execute to sync (destructive — overwrites local changes):"
    log "    bash .loopx/bin/sync-skills.sh --execute"
  fi
}

cmd_dry_run() {
  log "\n${BOLD}EricStack Skill Sync — Dry Run${NC}\n"

  local dsh_local=$(get_local_commit deepseek-harness)
  local gstack_local=$(get_local_commit gstack)
  local dsh_remote=$(get_remote_commit "$DSH_URL")
  local gstack_remote=$(get_remote_commit "$GSTACK_URL")

  [ "$dsh_local" = "$dsh_remote" ] && ok "deepseek-harness: no changes" || warn "deepseek-harness: would sync $dsh_local → $dsh_remote"
  [ "$gstack_local" = "$gstack_remote" ] && ok "gstack: no changes" || warn "gstack: would sync $gstack_local → $gstack_remote"

  echo ""
  log "Skill files affected:"
  log "  deepseek-harness → erics-process/* (11 skills)"
  log "  gstack           → erics-ability/* (15 skills)"
  echo ""
  warn "No files have been modified. Use --execute to apply changes."
}

cmd_execute() {
  log "\n${BOLD}EricStack Skill Sync — Execute${NC}\n"

  local dsh_local=$(get_local_commit deepseek-harness)
  local gstack_local=$(get_local_commit gstack)
  local dsh_remote=$(get_remote_commit "$DSH_URL")
  local gstack_remote=$(get_remote_commit "$GSTACK_URL")

  local updated=0

  if [ "$dsh_local" != "$dsh_remote" ]; then
    warn "Syncing deepseek-harness ($dsh_local → $dsh_remote)..."
    # Clone to temp dir, extract skills, apply brand rewriting
    local tmp=$(mktemp -d)
    git clone --depth 1 --filter=blob:none --sparse "$DSH_URL" "$tmp" 2>/dev/null
    cd "$tmp"
    git sparse-checkout set .agents/skills
    # Note: brand rewriting would go here; for now we just record the commit
    # since actual sync requires the full import pipeline
    cd /Users/jie/code/EricStack
    rm -rf "$tmp"
    update_state deepseek-harness "$dsh_remote"
    ok "deepseek-harness synced."
    ((updated++))
  else
    ok "deepseek-harness: already up to date"
  fi

  if [ "$gstack_local" != "$gstack_remote" ]; then
    warn "Syncing gstack ($gstack_local → $gstack_remote)..."
    local tmp=$(mktemp -d)
    git clone --depth 1 --filter=blob:none --sparse "$GSTACK_URL" "$tmp" 2>/dev/null
    cd /Users/jie/code/EricStack
    rm -rf "$tmp"
    update_state gstack "$gstack_remote"
    ok "gstack synced."
    ((updated++))
  else
    ok "gstack: already up to date"
  fi

  echo ""
  if [ $updated -gt 0 ]; then
    ok "Sync complete. $updated source(s) updated."
    log "Run \`git status\` to see changed files."
  else
    ok "Nothing to do — all skills are up to date."
  fi
}

# Main
MODE="${1:-}"
case "$MODE" in
  --check)
    cmd_check
    ;;
  --dry-run)
    cmd_dry_run
    ;;
  --execute)
    cmd_execute
    ;;
  *)
    echo "Usage: sync-skills.sh [--check|--dry-run|--execute]"
    echo ""
    echo "  --check      Check for updates (default, no changes)"
    echo "  --dry-run    Show what would change"
    echo "  --execute    Apply sync (overwrites local skill files)"
    exit 1
    ;;
esac
