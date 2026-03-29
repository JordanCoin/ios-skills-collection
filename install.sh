#!/bin/bash
set -e

# iOS Skills Collection — Install for Claude Code + Codex CLI
# 169 skills from 11 authors, phase-aware routing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="$SCRIPT_DIR"

G='\033[0;32m'  Y='\033[1;33m'  B='\033[0;34m'  D='\033[0;90m'  R='\033[0;31m'  N='\033[0m'

SKILL_COUNT=$(find "$PLUGIN_PATH/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${B}iOS Skills Collection${N} — ${SKILL_COUNT} skills"
echo -e "${D}ideation → design → develop → test → deploy → iterate${N}"
echo ""

# ── Detect what's installed ──────────────────────────────────────
HAS_CLAUDE=0; HAS_CODEX=0
command -v claude >/dev/null 2>&1 && HAS_CLAUDE=1
command -v codex  >/dev/null 2>&1 && HAS_CODEX=1

# ── Install functions ────────────────────────────────────────────
install_claude() {
  echo -e "${B}Claude Code:${N}"

  # Use --plugin-dir for dev, tell user how to register permanently
  if [ $HAS_CLAUDE -eq 1 ]; then
    echo -e "  ${G}✓${N} Plugin ready at: $PLUGIN_PATH"
    echo -e ""
    echo -e "  ${Y}To use:${N}"
    echo -e "    ${D}Dev/test (one session):${N}  claude --plugin-dir \"$PLUGIN_PATH\""
    echo -e "    ${D}Permanent:${N}              claude plugins add \"$PLUGIN_PATH\""
    echo ""
  else
    echo -e "  ${D}Claude Code not found. Install from https://claude.ai/code${N}"
  fi
}

install_codex() {
  # Codex discovers raw skills from ~/.agents/skills/
  local AGENTS_SKILLS="$HOME/.agents/skills"
  mkdir -p "$AGENTS_SKILLS"

  local count=0
  for skill_dir in "$PLUGIN_PATH/skills"/*/; do
    local name=$(basename "$skill_dir")
    [ "$name" = "_router" ] && continue
    local target="$AGENTS_SKILLS/$name"
    if [ -L "$target" ]; then
      # Already symlinked, check if pointing to us
      if readlink "$target" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
        continue
      fi
    fi
    if [ ! -e "$target" ]; then
      ln -sfn "$skill_dir" "$target"
      count=$((count + 1))
    fi
  done

  # Also install router as a discoverable skill
  if [ ! -e "$AGENTS_SKILLS/_ios-router" ]; then
    ln -sfn "$PLUGIN_PATH/skills/_router" "$AGENTS_SKILLS/_ios-router"
  fi

  local total=$(find "$AGENTS_SKILLS" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  echo -e "  ${G}✓${N} Codex CLI — $total skills symlinked to ~/.agents/skills/"
}

uninstall() {
  echo -e "${Y}Uninstalling...${N}"

  # Remove symlinks from ~/.agents/skills/ pointing to our plugin
  local AGENTS_SKILLS="$HOME/.agents/skills"
  if [ -d "$AGENTS_SKILLS" ]; then
    local count=0
    for link in "$AGENTS_SKILLS"/*/; do
      link="${link%/}"
      if [ -L "$link" ] && readlink "$link" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
        rm "$link"
        count=$((count + 1))
      fi
    done
    # Also check non-directory symlinks
    for link in "$AGENTS_SKILLS"/*; do
      if [ -L "$link" ] && readlink "$link" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
        rm "$link"
        count=$((count + 1))
      fi
    done
    [ $count -gt 0 ] && echo -e "  ${G}✓${N} Removed $count symlinks from ~/.agents/skills/"
  fi

  # Clean up state dir
  rm -rf "$HOME/.ios-skills" 2>/dev/null && echo -e "  ${G}✓${N} Removed ~/.ios-skills state"

  echo ""
  echo -e "  ${D}If installed as Claude plugin, also run: claude plugins remove ios-skills${N}"
  echo -e "${G}Done.${N}"
}

status() {
  echo -e "${B}Status:${N}"

  # Claude
  if [ $HAS_CLAUDE -eq 1 ]; then
    if claude plugins list 2>/dev/null | grep -q "ios-skills" 2>/dev/null; then
      echo -e "  Claude Code:  ${G}installed (plugin)${N}"
    else
      echo -e "  Claude Code:  ${Y}available${N} — run: claude plugins add \"$PLUGIN_PATH\""
    fi
  else
    echo -e "  Claude Code:  ${D}not found${N}"
  fi

  # Codex (via ~/.agents/skills/)
  local codex_count=$(find "$HOME/.agents/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  if [ "$codex_count" -gt 0 ]; then
    echo -e "  Codex CLI:    ${G}installed${N} ($codex_count skills in ~/.agents/skills/)"
  else
    echo -e "  Codex CLI:    ${Y}not installed${N}"
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
  --all|-a)
    [ $HAS_CLAUDE -eq 1 ] && install_claude
    [ $HAS_CODEX -eq 1 ]  && install_codex
    ;;
  --uninstall|-u)
    uninstall ;;
  --status)
    status ;;
  --help|-h)
    echo "Usage: ./install.sh [option]"
    echo ""
    echo "  --all, -a         Install for all detected agents (recommended)"
    echo "  --claude, -c      Show Claude Code install instructions"
    echo "  --codex, -x       Install skills for Codex CLI (~/.agents/skills/)"
    echo "  --uninstall, -u   Remove from all agents"
    echo "  --status          Show installation status"
    echo "  (no args)         Interactive mode"
    ;;
  *)
    echo -e "Detected:"
    [ $HAS_CLAUDE -eq 1 ] && echo -e "  ${G}✓${N} Claude Code" || echo -e "  ${D}✗ Claude Code${N}"
    [ $HAS_CODEX -eq 1 ]  && echo -e "  ${G}✓${N} Codex CLI"   || echo -e "  ${D}✗ Codex CLI${N}"
    echo ""
    echo "  1) Install for all detected agents (recommended)"
    echo "  2) Claude Code only"
    echo "  3) Codex CLI only"
    echo "  4) Show status"
    echo "  5) Uninstall"
    echo ""
    read -p "Choice [1-5]: " choice
    case $choice in
      1) [ $HAS_CLAUDE -eq 1 ] && install_claude; [ $HAS_CODEX -eq 1 ] && install_codex ;;
      2) install_claude ;;
      3) install_codex ;;
      4) status ;;
      5) uninstall ;;
      *) echo -e "${R}Invalid choice${N}"; exit 1 ;;
    esac
    ;;
esac

echo ""
echo -e "${D}Claude: skills auto-inject via hooks when editing .swift or running xcodebuild.${N}"
echo -e "${D}Codex:  skills auto-activate based on SKILL.md description matching.${N}"
