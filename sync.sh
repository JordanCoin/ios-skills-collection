#!/bin/bash
set -e

# iOS Skills Collection — Sync upstream SKILL.md files
# Reads sources.json, checks for updates, pulls changed files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCES="$SCRIPT_DIR/sources.json"
SKILLS_DIR="$SCRIPT_DIR/skills"
STATE_FILE="$SCRIPT_DIR/.sync-state.json"
LAST_SYNC_FILE="$SCRIPT_DIR/.last-sync"

G='\033[0;32m' Y='\033[1;33m' B='\033[0;34m' D='\033[0;90m' R='\033[0;31m' N='\033[0m'

# ── Helpers ──────────────────────────────────────────────────────
check_deps() {
  for cmd in gh jq node; do
    command -v "$cmd" >/dev/null 2>&1 || { echo -e "${R}Missing: $cmd${N}"; exit 1; }
  done
}

get_sha() {
  local repo="$1"
  gh api "repos/$repo/commits/HEAD" --jq '.sha' 2>/dev/null || echo "unknown"
}

get_stored_sha() {
  local repo="$1"
  if [ -f "$STATE_FILE" ]; then
    jq -r --arg r "$repo" '.[$r] // "none"' "$STATE_FILE" 2>/dev/null || echo "none"
  else
    echo "none"
  fi
}

set_stored_sha() {
  local repo="$1" sha="$2"
  if [ -f "$STATE_FILE" ]; then
    local tmp=$(mktemp)
    jq --arg r "$repo" --arg s "$sha" '.[$r] = $s' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
  else
    echo "{\"$repo\": \"$sha\"}" | jq '.' > "$STATE_FILE"
  fi
}

download_file() {
  local repo="$1" path="$2" dest="$3"
  local content
  content=$(gh api "repos/$repo/contents/$path" --jq '.content' 2>/dev/null) || return 1
  echo "$content" | base64 -d > "$dest"
}

download_tree() {
  local repo="$1" prefix="$2" dest_prefix="$3"
  local tree
  tree=$(gh api "repos/$repo/git/trees/main?recursive=1" --jq ".tree[] | select(.path | startswith(\"$prefix\")) | .path" 2>/dev/null) || {
    tree=$(gh api "repos/$repo/git/trees/master?recursive=1" --jq ".tree[] | select(.path | startswith(\"$prefix\")) | .path" 2>/dev/null) || return 1
  }

  local count=0
  while IFS= read -r path; do
    [ -z "$path" ] && continue
    # Only download .md files and scripts
    case "$path" in
      *.md|*.py|*.sh|*.json|*.yaml|*.yml|*.swift) ;;
      *) continue ;;
    esac

    local relative="${path#$prefix/}"
    local skill_name=$(echo "$relative" | cut -d/ -f1)
    local file_path="${relative#$skill_name/}"

    # Skip if no SKILL.md in this skill dir
    if [ -z "$file_path" ]; then
      # This is the skill dir itself or a file at root of prefix
      if [[ "$path" == */SKILL.md ]]; then
        local dest_dir="$SKILLS_DIR/${dest_prefix}${skill_name}"
        mkdir -p "$dest_dir"
        download_file "$repo" "$path" "$dest_dir/SKILL.md" && count=$((count + 1))
      fi
      continue
    fi

    local dest_dir="$SKILLS_DIR/${dest_prefix}${skill_name}"
    local dest_file="$dest_dir/$file_path"
    mkdir -p "$(dirname "$dest_file")"
    download_file "$repo" "$path" "$dest_file" && count=$((count + 1))
  done <<< "$tree"
  echo "$count"
}

# ── Sync a single source ────────────────────────────────────────
sync_source() {
  local repo="$1" check_only="$2"

  local current_sha=$(get_sha "$repo")
  local stored_sha=$(get_stored_sha "$repo")

  if [ "$current_sha" = "$stored_sha" ]; then
    echo -e "  ${D}$repo — up to date${N}"
    return 0
  fi

  local short_old="${stored_sha:0:7}"
  local short_new="${current_sha:0:7}"
  [ "$stored_sha" = "none" ] && short_old="(first sync)"

  if [ "$check_only" = "true" ]; then
    echo -e "  ${Y}$repo — changed${N} ($short_old → $short_new)"
    return 1  # signal that updates are available
  fi

  echo -e "  ${B}$repo${N} ($short_old → $short_new)"

  # Read source config from sources.json
  local source_json
  source_json=$(jq --arg r "$repo" '.sources[] | select(.repo == $r)' "$SOURCES")

  local prefix=$(echo "$source_json" | jq -r '.prefix // empty')
  local skills_dir_name=$(echo "$source_json" | jq -r '.skillsDir // empty')
  local explicit_skills=$(echo "$source_json" | jq -r '.skills // empty')

  local file_count=0

  if [ -n "$skills_dir_name" ] && [ -n "$prefix" ]; then
    # Bulk download: repo has skills/ dir with multiple skills, use prefix
    file_count=$(download_tree "$repo" "$skills_dir_name" "$prefix")
  elif [ -n "$explicit_skills" ] && [ "$explicit_skills" != "null" ]; then
    # Explicit mapping: download specific skills
    for local_name in $(echo "$explicit_skills" | jq -r 'keys[]'); do
      local remote_path=$(echo "$explicit_skills" | jq -r --arg k "$local_name" '.[$k]')
      local dest="$SKILLS_DIR/$local_name"
      mkdir -p "$dest"

      # Download SKILL.md
      if [ "$remote_path" = "." ]; then
        download_file "$repo" "SKILL.md" "$dest/SKILL.md" 2>/dev/null && file_count=$((file_count + 1))
      else
        download_file "$repo" "$remote_path/SKILL.md" "$dest/SKILL.md" 2>/dev/null && file_count=$((file_count + 1))
      fi

      # Download references/ if they exist
      local refs
      if [ "$remote_path" = "." ]; then
        refs=$(gh api "repos/$repo/contents/references" --jq '.[].name' 2>/dev/null) || true
        for ref in $refs; do
          mkdir -p "$dest/references"
          download_file "$repo" "references/$ref" "$dest/references/$ref" 2>/dev/null && file_count=$((file_count + 1))
        done
      else
        refs=$(gh api "repos/$repo/contents/$remote_path/references" --jq '.[].name' 2>/dev/null) || true
        for ref in $refs; do
          mkdir -p "$dest/references"
          download_file "$repo" "$remote_path/references/$ref" "$dest/references/$ref" 2>/dev/null && file_count=$((file_count + 1))
        done
      fi
    done
  fi

  set_stored_sha "$repo" "$current_sha"
  echo -e "    ${G}✓${N} $file_count files updated"
}

# ── Commands ─────────────────────────────────────────────────────
do_sync() {
  echo -e "${B}Syncing iOS skills from upstream repos...${N}"
  echo ""

  local repos
  repos=$(jq -r '.sources[].repo' "$SOURCES")
  local has_updates=0

  while IFS= read -r repo; do
    sync_source "$repo" "false" || true
  done <<< "$repos"

  date -u +%Y-%m-%dT%H:%M:%SZ > "$LAST_SYNC_FILE"
  local count=$(find "$SKILLS_DIR" -name "SKILL.md" | wc -l | tr -d ' ')
  echo ""
  echo -e "${G}Done.${N} $count skills total."
}

do_check() {
  echo -e "${B}Checking for upstream changes...${N}"
  echo ""

  local repos
  repos=$(jq -r '.sources[].repo' "$SOURCES")
  local updates=0

  while IFS= read -r repo; do
    sync_source "$repo" "true" || updates=$((updates + 1))
  done <<< "$repos"

  echo ""
  if [ $updates -gt 0 ]; then
    echo -e "${Y}$updates repo(s) have updates.${N} Run ${B}./sync.sh${N} to pull them."
  else
    echo -e "${G}All skills are up to date.${N}"
  fi
}

do_status() {
  echo -e "${B}Sync status:${N}"

  if [ -f "$LAST_SYNC_FILE" ]; then
    local last=$(cat "$LAST_SYNC_FILE")
    echo -e "  Last sync: ${G}$last${N}"
  else
    echo -e "  Last sync: ${Y}never${N}"
  fi

  local count=$(find "$SKILLS_DIR" -name "SKILL.md" | wc -l | tr -d ' ')
  local sources=$(jq '.sources | length' "$SOURCES")
  echo -e "  Skills: $count"
  echo -e "  Sources: $sources repos"
  echo ""

  if [ -f "$STATE_FILE" ]; then
    echo -e "  ${D}Tracked SHAs:${N}"
    jq -r 'to_entries[] | "    \(.key): \(.value[0:7])"' "$STATE_FILE"
  fi
}

# ── Quick check for session start hook ───────────────────────────
# Called by inject-router.mjs — just prints a one-liner if stale
do_quick_check() {
  if [ ! -f "$LAST_SYNC_FILE" ]; then
    echo "NEEDS_SYNC"
    return
  fi

  local last_epoch
  local last_ts=$(cat "$LAST_SYNC_FILE")
  if command -v gdate >/dev/null 2>&1; then
    last_epoch=$(gdate -d "$last_ts" +%s 2>/dev/null || echo 0)
  elif date -d "2000-01-01" +%s >/dev/null 2>&1; then
    # GNU date
    last_epoch=$(date -d "$last_ts" +%s 2>/dev/null || echo 0)
  else
    # BSD date (macOS)
    last_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_ts" +%s 2>/dev/null || echo 0)
  fi

  local now_epoch=$(date +%s)
  local age=$(( (now_epoch - last_epoch) / 86400 ))

  if [ $age -ge 7 ]; then
    echo "STALE_${age}d"
  else
    echo "OK"
  fi
}

# ── Parse args ───────────────────────────────────────────────────
case "${1:-}" in
  --check|-c)     check_deps; do_check ;;
  --status|-s)    check_deps; do_status ;;
  --quick-check)  do_quick_check ;;
  --help|-h)
    echo "Usage: ./sync.sh [option]"
    echo ""
    echo "  (no args)       Pull latest from all upstream repos"
    echo "  --check, -c     Check what's changed without updating"
    echo "  --status, -s    Show last sync time and tracked SHAs"
    echo "  --quick-check   One-word status for hook scripts (OK/STALE/NEEDS_SYNC)"
    echo "  --help, -h      Show this help"
    ;;
  *)              check_deps; do_sync ;;
esac
