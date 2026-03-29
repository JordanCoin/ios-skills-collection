#!/bin/bash
set -e

# iOS Skills Collection — Install for Claude Code + Codex
# 169 skills from 11 authors, phase-aware routing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="$SCRIPT_DIR"

G='\033[0;32m'  # green
Y='\033[1;33m'  # yellow
B='\033[0;34m'  # blue
D='\033[0;90m'  # dim
R='\033[0;31m'  # red
N='\033[0m'     # reset

SKILL_COUNT=$(find "$PLUGIN_PATH/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${B}iOS Skills Collection${N} — ${SKILL_COUNT} skills"
echo -e "${D}ideation → design → develop → test → deploy → iterate${N}"
echo ""

# ── Detect what's installed ──────────────────────────────────────
HAS_CLAUDE=0; HAS_CODEX=0; HAS_SKILLS=0
command -v claude >/dev/null 2>&1 && HAS_CLAUDE=1
command -v codex  >/dev/null 2>&1 && HAS_CODEX=1
command -v npx    >/dev/null 2>&1 && HAS_SKILLS=1

# ── Install functions ────────────────────────────────────────────
install_claude() {
  local CLAUDE_DIR="$HOME/.claude"
  local SETTINGS="$CLAUDE_DIR/settings.json"

  mkdir -p "$CLAUDE_DIR"

  if [ -f "$SETTINGS" ] && grep -q "$PLUGIN_PATH" "$SETTINGS" 2>/dev/null; then
    echo -e "  ${D}Claude Code: already installed${N}"
    return 0
  fi

  if [ -f "$SETTINGS" ]; then
    cp "$SETTINGS" "$SETTINGS.backup"
    python3 -c "
import json
with open('$SETTINGS') as f: s = json.load(f)
s.setdefault('plugins', [])
if '$PLUGIN_PATH' not in s['plugins']: s['plugins'].append('$PLUGIN_PATH')
with open('$SETTINGS', 'w') as f: json.dump(s, f, indent=2)
"
  else
    echo '{"plugins":["'"$PLUGIN_PATH"'"]}' | python3 -c "
import json, sys; print(json.dumps(json.load(sys.stdin), indent=2))
" > "$SETTINGS"
  fi

  echo -e "  ${G}✓${N} Claude Code — plugin registered"
}

install_codex() {
  local CODEX_SKILLS="$HOME/.codex/skills"
  mkdir -p "$CODEX_SKILLS"

  # Symlink each skill dir into Codex's skill directory
  local count=0
  for skill_dir in "$PLUGIN_PATH/skills"/*/; do
    local name=$(basename "$skill_dir")
    [ "$name" = "_router" ] && continue
    local target="$CODEX_SKILLS/$name"
    if [ ! -e "$target" ]; then
      ln -sf "$skill_dir" "$target"
      count=$((count + 1))
    fi
  done

  # Also install the router as a skill
  if [ -d "$PLUGIN_PATH/skills/_router" ] && [ ! -e "$CODEX_SKILLS/_ios-router" ]; then
    ln -sf "$PLUGIN_PATH/skills/_router" "$CODEX_SKILLS/_ios-router"
  fi

  echo -e "  ${G}✓${N} Codex CLI — $count skills symlinked to ~/.codex/skills/"
}

install_shared() {
  # ~/.agents/skills/ is the cross-agent convention (works for both + npx skills)
  local SHARED_SKILLS="$HOME/.agents/skills"
  mkdir -p "$SHARED_SKILLS"

  local count=0
  for skill_dir in "$PLUGIN_PATH/skills"/*/; do
    local name=$(basename "$skill_dir")
    [ "$name" = "_router" ] && continue
    local target="$SHARED_SKILLS/$name"
    if [ ! -e "$target" ]; then
      ln -sf "$skill_dir" "$target"
      count=$((count + 1))
    fi
  done

  echo -e "  ${G}✓${N} Shared — $count skills symlinked to ~/.agents/skills/"
}

uninstall() {
  echo -e "${Y}Uninstalling...${N}"

  # Claude Code
  local SETTINGS="$HOME/.claude/settings.json"
  if [ -f "$SETTINGS" ] && grep -q "$PLUGIN_PATH" "$SETTINGS" 2>/dev/null; then
    python3 -c "
import json
with open('$SETTINGS') as f: s = json.load(f)
s.get('plugins', [])
if '$PLUGIN_PATH' in s.get('plugins', []): s['plugins'].remove('$PLUGIN_PATH')
with open('$SETTINGS', 'w') as f: json.dump(s, f, indent=2)
"
    echo -e "  ${G}✓${N} Removed from Claude Code settings"
  fi

  # Codex + shared: remove symlinks pointing to our plugin
  for dir in "$HOME/.codex/skills" "$HOME/.agents/skills"; do
    if [ -d "$dir" ]; then
      local count=0
      for link in "$dir"/*/; do
        if [ -L "${link%/}" ] && readlink "${link%/}" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
          rm "${link%/}"
          count=$((count + 1))
        fi
      done
      [ $count -gt 0 ] && echo -e "  ${G}✓${N} Removed $count symlinks from $dir"
    fi
  done

  echo -e "${G}Done.${N}"
}

status() {
  echo -e "${B}Status:${N}"

  # Claude
  local SETTINGS="$HOME/.claude/settings.json"
  if [ -f "$SETTINGS" ] && grep -q "$PLUGIN_PATH" "$SETTINGS" 2>/dev/null; then
    echo -e "  Claude Code:  ${G}installed${N}"
  else
    echo -e "  Claude Code:  ${D}not installed${N}"
  fi

  # Codex
  local codex_count=$(find "$HOME/.codex/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  if [ "$codex_count" -gt 0 ]; then
    echo -e "  Codex CLI:    ${G}installed${N} ($codex_count skills)"
  else
    echo -e "  Codex CLI:    ${D}not installed${N}"
  fi

  # Shared
  local shared_count=$(find "$HOME/.agents/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  if [ "$shared_count" -gt 0 ]; then
    echo -e "  Shared:       ${G}installed${N} ($shared_count skills)"
  else
    echo -e "  Shared:       ${D}not installed${N}"
  fi

  echo ""
  echo -e "  ${D}$SKILL_COUNT skills across 6 phases from 11 authors${N}"
}

# ── Parse args ───────────────────────────────────────────────────
case "${1:-}" in
  --claude|-c)
    install_claude ;;
  --codex|-x)
    install_codex ;;
  --shared|-s)
    install_shared ;;
  --all|-a)
    [ $HAS_CLAUDE -eq 1 ] && install_claude
    [ $HAS_CODEX -eq 1 ]  && install_codex
    install_shared
    ;;
  --uninstall|-u)
    uninstall ;;
  --status)
    status ;;
  --help|-h)
    echo "Usage: ./install.sh [option]"
    echo ""
    echo "  --all, -a         Install for all detected agents (recommended)"
    echo "  --claude, -c      Install for Claude Code only"
    echo "  --codex, -x       Install for Codex CLI only"
    echo "  --shared, -s      Install to ~/.agents/skills/ (cross-agent)"
    echo "  --uninstall, -u   Remove from all agents"
    echo "  --status          Show installation status"
    echo "  (no args)         Interactive mode"
    ;;
  *)
    # Interactive
    echo -e "Detected:"
    [ $HAS_CLAUDE -eq 1 ] && echo -e "  ${G}✓${N} Claude Code" || echo -e "  ${D}✗ Claude Code${N}"
    [ $HAS_CODEX -eq 1 ]  && echo -e "  ${G}✓${N} Codex CLI"   || echo -e "  ${D}✗ Codex CLI${N}"
    echo ""
    echo "  1) Install for all detected agents (recommended)"
    echo "  2) Claude Code only"
    echo "  3) Codex CLI only"
    echo "  4) Shared skills only (~/.agents/skills/)"
    echo "  5) Show status"
    echo "  6) Uninstall"
    echo ""
    read -p "Choice [1-6]: " choice
    case $choice in
      1) [ $HAS_CLAUDE -eq 1 ] && install_claude; [ $HAS_CODEX -eq 1 ] && install_codex; install_shared ;;
      2) install_claude ;;
      3) install_codex ;;
      4) install_shared ;;
      5) status ;;
      6) uninstall ;;
      *) echo -e "${R}Invalid choice${N}"; exit 1 ;;
    esac
    ;;
esac

echo ""
echo -e "${D}Skills load automatically when you edit .swift files or run Xcode commands.${N}"
echo -e "${D}The router skill injects at session start with the full phase map.${N}"
