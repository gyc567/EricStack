#!/usr/bin/env bash
# EricStack Anti-Slop Sync — syncs vendored oxlint plugin from upstream anti-slop repo.
# Honors protected patterns — local EricStack customizations are NEVER overwritten.
#
# Usage:
#   sync-anti-slop.sh --check      # Check for upstream updates (no changes)
#   sync-anti-slop.sh --dry-run    # Show what would change
#   sync-anti-slop.sh --execute    # Apply sync (with confirmation, respects protection)
#   sync-anti-slop.sh --execute --yes  # Apply sync non-interactively

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOPX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$LOOPX_DIR/sync-state.json"
SRC_DIR="$LOOPX_DIR/../tools/oxlint/anti-slop/src"

# Colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

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

# Upstream
UPSTREAM_URL="https://github.com/dmmulroy/anti-slop.git"
UPSTREAM_KEY="anti-slop"

get_remote_commit() {
  git ls-remote --quiet "$UPSTREAM_URL" HEAD 2>/dev/null | cut -f1
}

get_local_commit() {
  jq -r ".sources[\"$UPSTREAM_KEY\"].commit // empty" "$STATE_FILE"
}

ASSUME_YES=false
ACTIVE_TMP=""
UPSTREAM_NEW_REMOTE=""
UPSTREAM_TREE_SHA=""

# Protected files/dirs that sync must never overwrite
PROTECTED_PATTERNS=(
  "oxlintrc.ts"
  "SKILL.md"
  "package.json"
  "tsconfig.json"
)

is_protected() {
  local file=$1
  for p in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$file" == *"$p" ]]; then
      return 0
    fi
  done
  return 1
}

skills_tree_sha() {
  [ -d "$1" ] || { echo ""; return; }
  local hash_cmd
  if command -v sha256sum &>/dev/null; then
    hash_cmd=(sha256sum)
  elif command -v shasum &>/dev/null; then
    hash_cmd=(shasum -a 256)
  else
    fail "No hash tool found: need sha256sum (Linux) or shasum -a 256 (macOS/BSD)"
    return 1
  fi
  find "$1" -type f -print0 2>/dev/null \
    | LC_ALL=C sort -z \
    | xargs -0 "${hash_cmd[@]}" 2>/dev/null \
    | "${hash_cmd[@]}" | awk '{print $1}'
}

write_state_atomically() {
  local state_file=$1
  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local new_state
  new_state=$(mktemp)
  local expr=""
  [ -n "$UPSTREAM_NEW_REMOTE" ] && expr="$expr | (.sources[\"$UPSTREAM_KEY\"].commit = \"$UPSTREAM_NEW_REMOTE\") | (.sources[\"$UPSTREAM_KEY\"].last_sync = \"$ts\") | (.sources[\"$UPSTREAM_KEY\"].tree_sha256 = \"$UPSTREAM_TREE_SHA\")"
  expr="${expr# | }"
  [ -z "$expr" ] && return 0
  if ! jq "$expr" "$state_file" > "$new_state"; then
    rm -f "$new_state"
    fail "jq failed to compose new state"
    return 1
  fi
  mv "$new_state" "$state_file"
}

cleanup_tmp() {
  if [ -n "${ACTIVE_TMP:-}" ] && [ -d "$ACTIVE_TMP" ]; then
    rm -rf "$ACTIVE_TMP"
  fi
}
trap cleanup_tmp EXIT INT TERM

# Copy src/ from upstream clone, skipping protected files
copy_src() {
  local src=$1
  local dest=$2
  mkdir -p "$dest"
  local file
  while IFS= read -r -d '' file; do
    local rel="${file#$src/}"
    if is_protected "$rel"; then
      log "  [SKIP] $rel (protected)"
      continue
    fi
    local dest_file="$dest/$rel"
    mkdir -p "$(dirname "$dest_file")"
    cp "$file" "$dest_file"
    log "  [SYNC] $rel"
  done < <(find "$src" -type f -print0 2>/dev/null)
}

sync_source() {
  local tmp tmp_head tree_sha remote_current
  tmp=$(mktemp -d)
  ACTIVE_TMP="$tmp"
  if ! git clone --depth 1 "$UPSTREAM_URL" "$tmp" 2>/dev/null; then
    fail "Failed to clone $UPSTREAM_KEY."
    rm -rf "$tmp"; ACTIVE_TMP=""
    return 1
  fi

  copy_src "$tmp/src" "$SRC_DIR"

  tmp_head=$(git -C "$tmp" rev-parse HEAD 2>/dev/null || echo "")
  if [ -z "$tmp_head" ]; then
    fail "Failed to read HEAD from cloned $UPSTREAM_KEY repo."
    rm -rf "$tmp"; ACTIVE_TMP=""
    return 1
  fi

  tree_sha=$(skills_tree_sha "$tmp/src")
  rm -rf "$tmp"; ACTIVE_TMP=""

  remote_current=$(git ls-remote --quiet "$UPSTREAM_URL" HEAD 2>/dev/null | cut -f1 || echo "")
  if [ -n "$remote_current" ] && [ "$tmp_head" != "$remote_current" ]; then
    warn "$UPSTREAM_KEY advanced upstream during clone (concurrent push detected)."
    warn "  Synced content is ${tmp_head:0:8}; rerun later to pick up ${remote_current:0:8}."
  fi

  UPSTREAM_NEW_REMOTE="$tmp_head"
  UPSTREAM_TREE_SHA="$tree_sha"
}

print_status() {
  local source=$1
  local local_commit=$2
  local remote_commit=$3
  local last_sync=$4

  local status color
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
  log "\n${BOLD}EricStack Anti-Slop Sync Check${NC}\n"
  need_tool jq
  need_tool git

  local local_commit=$(get_local_commit)
  log "  Fetching upstream commits..."
  local remote_commit=$(get_remote_commit)

  if [ -z "$remote_commit" ]; then
    fail "Could not resolve upstream HEAD commit. Check network access and repository URL."
    return 1
  fi

  echo ""
  printf "  %-20s  %-15s  %s\n" "SOURCE" "STATUS" "LOCAL → REMOTE"
  printf "  %-20s  %-15s  %s\n" "──────" "──────" "──────────────"
  local last_sync=$(jq -r ".sources[\"$UPSTREAM_KEY\"].last_sync // \"never\"" "$STATE_FILE")
  print_status "$UPSTREAM_KEY" "$local_commit" "$remote_commit" "$last_sync"
  echo ""

  log "  Protected files (never overwritten):"
  for p in "${PROTECTED_PATTERNS[@]}"; do
    printf "    - %s\n" "$p"
  done
  echo ""

  if [ "$local_commit" = "$remote_commit" ]; then
    ok "anti-slop is up to date."
  else
    warn "anti-slop has updates available."
    log ""
    log "  Run with --execute to sync:"
    log "    bash .loopx/bin/sync-anti-slop.sh --execute"
  fi
}

cmd_dry_run() {
  log "\n${BOLD}EricStack Anti-Slop Sync — Dry Run${NC}\n"
  need_tool jq
  need_tool git

  local local_commit=$(get_local_commit)
  local remote_commit=$(get_remote_commit)

  if [ "$local_commit" = "$remote_commit" ]; then
    ok "anti-slop: no changes"
  else
    warn "anti-slop: would sync ${local_commit:0:8} → ${remote_commit:0:8}"
  fi

  echo ""
  log "  Protected files (would be preserved):"
  for p in "${PROTECTED_PATTERNS[@]}"; do
    printf "    - %s\n" "$p"
  done
  echo ""
  warn "No files have been modified. Use --execute to apply changes."
}

cmd_execute() {
  log "\n${BOLD}EricStack Anti-Slop Sync — Execute${NC}\n"
  need_tool jq
  need_tool git

  if ! $ASSUME_YES; then
    if [ ! -t 0 ]; then
      fail "Refusing destructive sync without confirmation. Re-run interactively or pass --yes."
      return 2
    fi
    read -r -p "Sync vendored anti-slop src/ from upstream? [y/N] " response
    case "$response" in
      [yY]|[yY][eE][sS]) ;;
      *) warn "Sync cancelled."; return 0 ;;
    esac
  fi

  log "  Protected files (never overwritten):"
  for p in "${PROTECTED_PATTERNS[@]}"; do
    printf "    - %s\n" "$p"
  done
  echo ""

  local local_commit=$(get_local_commit)
  local remote_commit=$(get_remote_commit)

  if [ "$local_commit" = "$remote_commit" ]; then
    ok "anti-slop: already up to date"
  else
    warn "Syncing anti-slop (${local_commit:0:8} → ${remote_commit:0:8})..."
    sync_source || return 1
    if ! write_state_atomically "$STATE_FILE"; then
      fail "State writeback failed; rerun to retry without re-cloning."
      return 1
    fi
    ok "Sync complete."
    log "Run \`git status\` to see changed files."

    # Offer to run pnpm install if package.json changed
    if [ -f "$LOOPX_DIR/../tools/oxlint/anti-slop/package.json" ]; then
      log ""
      log "  Run pnpm install to update dependencies:"
      log "    (cd tools/oxlint/anti-slop && pnpm install)"
    fi
  fi
}

# Main
MODE="${1:-}"
[ "${2:-}" = "--yes" ] && ASSUME_YES=true
if [ -n "${2:-}" ] && [ "${2:-}" != "--yes" ]; then
  echo "Unknown argument: ${2}" >&2
  exit 2
fi
if [ -n "${3:-}" ]; then
  echo "Unknown argument: ${3}" >&2
  exit 2
fi
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
  -h|--help)
    sed -n '2,11p' "$0"
    exit 0
    ;;
  *)
    echo "Usage: sync-anti-slop.sh [--check|--dry-run|--execute [--yes]]"
    echo ""
    echo "  --check      Check for upstream updates (no changes)"
    echo "  --dry-run    Show what would change"
    echo "  --execute    Apply sync after confirmation (respects protected files)"
    echo "  --yes        Confirm --execute non-interactively"
    exit 1
    ;;
esac
