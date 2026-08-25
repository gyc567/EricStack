#!/usr/bin/env bash
# Shared path-safety helpers for EricStack install/uninstall scripts.
# Sourced, not executed.

if ! command -v realpath >/dev/null 2>&1; then
  echo "Error: realpath is required but not installed." >&2
  exit 1
fi

# Portable canonicalization shim.
#
# `realpath --canonicalize-missing` is a GNU coreutils extension. macOS BSD
# `realpath` rejects the flag and errors on missing paths without it. Rather
# than require `brew install coreutils`, replicate the semantics in pure shell:
#   - Existing path  -> `realpath` (works on both BSD and GNU).
#   - Missing path   -> walk up parents until one exists, resolve that, then
#                       append the missing tail verbatim.
canonicalize_path() {
  local p="${1-}"
  [ -z "$p" ] && return 0
  if [ -e "$p" ]; then
    realpath "$p"
    return 0
  fi
  local missing="" probe="$p"
  while [ ! -e "$probe" ]; do
    local base="${probe##*/}"
    probe="${probe%"$base"}"
    probe="${probe%/}"
    missing="/${base}${missing}"
    if [ "$probe" = "/" ] || [ -z "$probe" ]; then
      [ -z "$probe" ] && probe="."
      break
    fi
  done
  if [ -e "$probe" ]; then
    printf '%s%s\n' "$(realpath "$probe")" "$missing"
  else
    printf '%s\n' "$p"
  fi
}

# Refuse destinations that are empty, "/", or $HOME itself, and require the
# resolved path to live under ~/.claude/skills.
assert_safe_skills_dest() {
  local dest=$1
  local canon_dest canon_home allowed_prefix
  canon_dest=$(canonicalize_path "$dest")
  canon_home=$(canonicalize_path "$HOME")

  case "$canon_dest" in
    ""|"/"|"$canon_home")
      echo "Error: unsafe SKILLS_DEST: ${dest:-<empty>}" >&2
      exit 2
      ;;
  esac

  allowed_prefix="$canon_home/.claude/skills"
  case "$canon_dest" in
    "$allowed_prefix"|"$allowed_prefix"/*) ;;
    *)
      echo "Error: SKILLS_DEST must be under ~/.claude/skills" >&2
      echo "  Got: $canon_dest" >&2
      exit 2
      ;;
  esac
}
