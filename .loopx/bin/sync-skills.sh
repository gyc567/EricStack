#!/usr/bin/env bash
# EricStack Skill Sync — checks and syncs erics-* skills from upstream repos.
# Honors `protected_skills` in sync-state.json — local skills are NEVER overwritten.
#
# Usage:
#   sync-skills.sh --check      # Check for upstream updates (no changes)
#   sync-skills.sh --dry-run    # Show what would change
#   sync-skills.sh --execute    # Apply sync (with confirmation, respects protection)
#   sync-skills.sh --execute --yes  # Apply sync non-interactively

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOPX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
STATE_FILE="$LOOPX_DIR/sync-state.json"
STATE_FILE="${SYNC_STATE_FILE:-$STATE_FILE}"
SKILLS_DIR="$LOOPX_DIR/skills"
SKILLS_DIR="${SYNC_SKILLS_DIR:-$SKILLS_DIR}"

# Colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source repos
DSH_URL="https://github.com/deepseek-ai/deepseek-harness.git"
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

# Fetch remote HEAD commits (lightweight, no clone)
get_remote_commit() {
  local url=$1
  git ls-remote --quiet "$url" HEAD 2>/dev/null | cut -f1
}

get_local_commit() {
  local source=$1
  jq -r ".sources[\"$source\"].commit // empty" "$STATE_FILE"
}

# Load protected skills (NEVER overwrite) into a global array.
PROTECTED_SKILLS=()
ASSUME_YES=false
ACTIVE_TMP=""
DEEP_SEEK_NEW_REMOTE=""
DEEP_SEEK_TREE_SHA=""
GSTACK_NEW_REMOTE=""
GSTACK_TREE_SHA=""

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
  find "$1" -type f -name 'SKILL.md' -print0 2>/dev/null \
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
  [ -n "$DEEP_SEEK_NEW_REMOTE" ] && expr="$expr | (.sources[\"deepseek-harness\"].commit = \"$DEEP_SEEK_NEW_REMOTE\") | (.sources[\"deepseek-harness\"].last_sync = \"$ts\") | (.sources[\"deepseek-harness\"].tree_sha256 = \"$DEEP_SEEK_TREE_SHA\")"
  [ -n "$GSTACK_NEW_REMOTE" ] && expr="$expr | (.sources[\"gstack\"].commit = \"$GSTACK_NEW_REMOTE\") | (.sources[\"gstack\"].last_sync = \"$ts\") | (.sources[\"gstack\"].tree_sha256 = \"$GSTACK_TREE_SHA\")"
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

load_protected_skills() {
  PROTECTED_SKILLS=()
  if [ -f "$STATE_FILE" ] && jq -e '.protected_skills' "$STATE_FILE" >/dev/null 2>&1; then
    while IFS= read -r s; do
      [ -n "$s" ] && PROTECTED_SKILLS+=("$s")
    done < <(jq -r '.protected_skills[]' "$STATE_FILE" 2>/dev/null)
  fi
}

require_remote_commits() {
  local dsh_remote=$1 gstack_remote=$2
  if [ -z "$dsh_remote" ] || [ -z "$gstack_remote" ]; then
    fail "Could not resolve both upstream HEAD commits. Check network access and repository URLs."
    return 1
  fi
}

is_protected() {
  local name=$1
  [ ${#PROTECTED_SKILLS[@]} -gt 0 ] || return 1
  for p in "${PROTECTED_SKILLS[@]}"; do
    [ "$p" = "$name" ] && return 0
  done
  return 1
}

# Build rsync --exclude args
protected_rsync_args() {
  local args=()
  [ ${#PROTECTED_SKILLS[@]} -gt 0 ] || return 0
  for p in "${PROTECTED_SKILLS[@]}"; do
    args+=(--exclude="$p")
  done
  printf '%s\n' "${args[@]}"
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
  load_protected_skills

  local dsh_local=$(get_local_commit deepseek-harness)
  local gstack_local=$(get_local_commit gstack)

  log "  Fetching upstream commits..."
  local dsh_remote=$(get_remote_commit "$DSH_URL")
  local gstack_remote=$(get_remote_commit "$GSTACK_URL")
  require_remote_commits "$dsh_remote" "$gstack_remote" || return 1

  echo ""
  printf "  %-20s  %-15s  %s\n" "SOURCE" "STATUS" "LOCAL → REMOTE"
  printf "  %-20s  %-15s  %s\n" "──────" "──────" "──────────────"
  print_status "deepseek-harness" "$dsh_local" "$dsh_remote" "$(jq -r '.sources["deepseek-harness"].last_sync' "$STATE_FILE")"
  print_status "gstack" "$gstack_local" "$gstack_remote" "$(jq -r '.sources["gstack"].last_sync' "$STATE_FILE")"
  echo ""

  if [ ${#PROTECTED_SKILLS[@]} -gt 0 ]; then
    log "  Protected local skills (${#PROTECTED_SKILLS[@]}):"
    printf '    - %s\n' "${PROTECTED_SKILLS[@]}"
    echo ""
  fi

  # Sanity check: totals
  local claimed
  claimed=$(jq -r '.totals.total_skills // "n/a"' "$STATE_FILE")
  local actual
  actual=$(find "$SKILLS_DIR" -name SKILL.md -not -path '*/.omc/*' | wc -l | tr -d ' ')
  if [ "$claimed" != "n/a" ] && [ "$claimed" != "$actual" ]; then
    warn "Totals drift: sync-state claims $claimed skills, but $actual SKILL.md files exist."
  else
    ok "Totals OK: $actual SKILL.md files match state."
  fi

  local updates=0
  [ "$dsh_local" != "$dsh_remote" ] && ((updates++)) || true
  [ "$gstack_local" != "$gstack_remote" ] && ((updates++)) || true

  echo ""
  if [ $updates -eq 0 ]; then
    ok "All upstream skills are up to date."
  else
    warn "$updates source(s) have updates available."
    log ""
    log "  Run with --execute to sync (destructive — but respects protected_skills):"
    log "    bash .loopx/bin/sync-skills.sh --execute"
  fi
}

cmd_dry_run() {
  log "\n${BOLD}EricStack Skill Sync — Dry Run${NC}\n"
  load_protected_skills

  local dsh_local=$(get_local_commit deepseek-harness)
  local gstack_local=$(get_local_commit gstack)
  local dsh_remote=$(get_remote_commit "$DSH_URL")
  local gstack_remote=$(get_remote_commit "$GSTACK_URL")
  require_remote_commits "$dsh_remote" "$gstack_remote" || return 1

  if [ "$dsh_local" = "$dsh_remote" ]; then
    ok "deepseek-harness: no changes"
  else
    warn "deepseek-harness: would sync $dsh_local → $dsh_remote"
  fi
  if [ "$gstack_local" = "$gstack_remote" ]; then
    ok "gstack: no changes"
  else
    warn "gstack: would sync $gstack_local → $gstack_remote"
  fi

  echo ""
  if [ ${#PROTECTED_SKILLS[@]} -gt 0 ]; then
    log "  Protected skills (skipped from overwrite):"
    printf '    - %s\n' "${PROTECTED_SKILLS[@]}"
    echo ""
  fi

  log "Skill files affected:"
  log "  deepseek-harness → erics-process/* (11 skills, minus protected)"
  log "  gstack           → erics-ability/* (15 skills, minus protected)"
  echo ""
  warn "No files have been modified. Use --execute to apply changes."
}

cmd_execute() {
  log "\n${BOLD}EricStack Skill Sync — Execute${NC}\n"
  load_protected_skills

  if ! $ASSUME_YES; then
    if [ ! -t 0 ]; then
      fail "Refusing destructive sync without confirmation. Re-run interactively or pass --yes."
      return 2
    fi
    read -r -p "Sync the latest upstream skills into this checkout? [y/N] " response
    case "$response" in
      [yY]|[yY][eE][sS]) ;;
      *) warn "Sync cancelled."; return 0 ;;
    esac
  fi

  if [ ${#PROTECTED_SKILLS[@]} -gt 0 ]; then
    log "  Protected skills (NEVER overwritten):"
    printf '    - %s\n' "${PROTECTED_SKILLS[@]}"
    echo ""
  fi

  # Build rsync exclude args once
  local rsync_excludes=()
  while IFS= read -r arg; do
    [ -n "$arg" ] && rsync_excludes+=("$arg")
  done < <(protected_rsync_args)

  local dsh_local=$(get_local_commit deepseek-harness)
  local gstack_local=$(get_local_commit gstack)
  local dsh_remote=$(get_remote_commit "$DSH_URL")
  local gstack_remote=$(get_remote_commit "$GSTACK_URL")
  require_remote_commits "$dsh_remote" "$gstack_remote" || return 1

  local updated=0

  if [ "$dsh_local" != "$dsh_remote" ]; then
    warn "Syncing deepseek-harness ($dsh_local → $dsh_remote)..."
    local tmp
    tmp=$(mktemp -d)
    ACTIVE_TMP="$tmp"
    if ! git clone --depth 1 "$DSH_URL" "$tmp" 2>/dev/null; then
      fail "Failed to clone deepseek-harness."
      return 1
    fi

    # Apply brand rewrites to all skill markdown files
    find "$tmp/.agents/skills" -name "*.md" 2>/dev/null | while read -r f; do
      sed -i.bak \
        -e 's/deepseek-harness/EricStack/g' \
        -e 's/DeepSeek Harness/EricStack/g' \
        -e 's|../../../||g' \
        -e 's|../../||g' \
        -e '/^\[.*\](.*\.\.\/.*)$/d' \
        "$f"
      rm -f "${f}.bak"
    done

    # Copy process skills (erics-process-*) — protected skills are excluded
    if [ -d "$tmp/.agents/skills/erics-process" ]; then
      if [ ${#rsync_excludes[@]} -gt 0 ]; then
        rsync -av --quiet "${rsync_excludes[@]}" "$tmp/.agents/skills/erics-process/" \
          "$SKILLS_DIR/erics-process/"
      else
        rsync -av --quiet "$tmp/.agents/skills/erics-process/" \
          "$SKILLS_DIR/erics-process/"
      fi
      ok "Synced process skills from deepseek-harness"
    fi

    # Copy ability skills that don't already exist in EricStack
    if [ -d "$tmp/.agents/skills/erics-ability" ]; then
      for skill in "$tmp/.agents/skills/erics-ability"/*/; do
        [ -d "$skill" ] || continue
        local skill_name
        skill_name=$(basename "$skill")
        if is_protected "$skill_name"; then
          log "  [SKIP] $skill_name (protected)"
          continue
        fi
        if [ ! -d "$SKILLS_DIR/erics-ability/$skill_name" ]; then
          rsync -av --quiet "$skill" "$SKILLS_DIR/erics-ability/"
          ok "Added new ability skill: $skill_name"
        fi
      done
    fi

    local tmp_head
    tmp_head=$(git -C "$tmp" rev-parse HEAD 2>/dev/null || echo "")
    if [ -z "$tmp_head" ]; then
      fail "Failed to read HEAD from cloned deepseek-harness repo."
      rm -rf "$tmp"; ACTIVE_TMP=""; return 1
    fi
    # Re-fetch the remote's current HEAD SHA from within the clone to detect
    # a concurrent push that happened during the clone window. A mismatch here
    # means upstream force-pushed and the pre-clone $dsh_remote is stale.
    local remote_current
    remote_current=$(git ls-remote --quiet "$DSH_URL" HEAD 2>/dev/null | cut -f1 || echo "")
    if [ -n "$remote_current" ] && [ "$tmp_head" != "$remote_current" ]; then
      warn "Upstream deepseek-harness advanced during clone (concurrent push detected)."
      warn "  Pre-clone SHA:  ${dsh_remote:0:8}"
      warn "  Post-clone HEAD: ${tmp_head:0:8}"
      warn "  Current remote:  ${remote_current:0:8}"
      warn "  Treating as up-to-date — rerun to sync to the newer commit."
      rm -rf "$tmp"; ACTIVE_TMP=""
      ok "deepseek-harness: synced to $tmp_head (concurrent push detected)"
    elif [ "$tmp_head" != "$dsh_remote" ]; then
      # Same SHA but not matching stored local — local was already behind; sync happened.
      DEEP_SEEK_NEW_REMOTE="$tmp_head"
    fi
    ACTIVE_TMP=""
    DEEP_SEEK_TREE_SHA=$(skills_tree_sha "$tmp/.agents/skills")
    DEEP_SEEK_NEW_REMOTE="$dsh_remote"
    updated=$((updated + 1))
  else
    ok "deepseek-harness: already up to date"
  fi

  if [ "$gstack_local" != "$gstack_remote" ]; then
    warn "Syncing gstack ($gstack_local → $gstack_remote)..."
    local tmp
    tmp=$(mktemp -d)
    ACTIVE_TMP="$tmp"
    if ! git clone --depth 1 "$GSTACK_URL" "$tmp" 2>/dev/null; then
      fail "Failed to clone gstack."
      return 1
    fi

    # Apply brand rewrites
    find "$tmp/.agents/skills" -name "*.md" 2>/dev/null | while read -r f; do
      sed -i.bak \
        -e 's/gstack/EricStack/g' \
        -e 's/GStack/EricStack/g' \
        -e 's/Garry Tan/EricStack/g' \
        -e 's|~/.gstack/|~/.loopx/|g' \
        -e '/^_gstack_/d' \
        "$f"
      rm -f "${f}.bak"
    done

    # Copy new ability skills (protected ones are skipped)
    if [ -d "$tmp/.agents/skills/erics-ability" ]; then
      for skill in "$tmp/.agents/skills/erics-ability"/*/; do
        [ -d "$skill" ] || continue
        local skill_name
        skill_name=$(basename "$skill")
        if is_protected "$skill_name"; then
          log "  [SKIP] $skill_name (protected)"
          continue
        fi
        if [ ! -d "$SKILLS_DIR/erics-ability/$skill_name" ]; then
          rsync -av --quiet "$skill" "$SKILLS_DIR/erics-ability/"
          ok "Added new ability skill: $skill_name"
        fi
      done
    fi

    local tmp_head
    tmp_head=$(git -C "$tmp" rev-parse HEAD 2>/dev/null || echo "")
    if [ -z "$tmp_head" ]; then
      fail "Failed to read HEAD from cloned gstack repo."
      rm -rf "$tmp"; ACTIVE_TMP=""; return 1
    fi
    local remote_current
    remote_current=$(git ls-remote --quiet "$GSTACK_URL" HEAD 2>/dev/null | cut -f1 || echo "")
    if [ -n "$remote_current" ] && [ "$tmp_head" != "$remote_current" ]; then
      warn "Upstream gstack advanced during clone (concurrent push detected)."
      warn "  Pre-clone SHA:  ${gstack_remote:0:8}"
      warn "  Post-clone HEAD: ${tmp_head:0:8}"
      warn "  Current remote:  ${remote_current:0:8}"
      warn "  Treating as up-to-date — rerun to sync to the newer commit."
      rm -rf "$tmp"; ACTIVE_TMP=""
      ok "gstack: synced to $tmp_head (concurrent push detected)"
    elif [ "$tmp_head" != "$gstack_remote" ]; then
      GSTACK_NEW_REMOTE="$tmp_head"
    fi
    ACTIVE_TMP=""
    GSTACK_TREE_SHA=$(skills_tree_sha "$tmp/.agents/skills")
    updated=$((updated + 1))
  else
    ok "gstack: already up to date"
  fi

  echo ""
  if [ $updated -gt 0 ]; then
    if ! write_state_atomically "$STATE_FILE"; then
      fail "State writeback failed; rerun to retry without re-cloning."
      return 1
    fi
    ok "Sync complete. $updated source(s) updated."
    log "Run \`git status\` to see changed files."
  else
    ok "Nothing to do — all skills are up to date."
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
    need_tool jq
    need_tool git
    cmd_check
    ;;
  --dry-run)
    need_tool jq
    need_tool git
    cmd_dry_run
    ;;
  --execute)
    need_tool jq
    need_tool git
    cmd_execute
    ;;
  -h|--help)
    sed -n '2,11p' "$0"
    exit 0
    ;;
  *)
    echo "Usage: sync-skills.sh [--check|--dry-run|--execute [--yes]]"
    echo ""
    echo "  --check      Check for upstream updates (no changes)"
    echo "  --dry-run    Show what would change"
    echo "  --execute    Apply sync after confirmation (respects protected_skills)"
    echo "  --yes        Confirm --execute non-interactively"
    exit 1
    ;;
esac
