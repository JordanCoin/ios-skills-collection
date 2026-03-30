#!/bin/bash
set -e

# iOS Skills Collection — Install for Claude Code + Codex (CLI + Mac App)
# 210 skills from 28 authors, phase-aware routing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="$SCRIPT_DIR"

G='\033[0;32m'  Y='\033[1;33m'  B='\033[0;34m'  D='\033[0;90m'  R='\033[0;31m'  N='\033[0m'

SKILL_COUNT=$(find "$PLUGIN_PATH/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${B}iOS Skills Collection${N} — ${SKILL_COUNT} skills"
echo -e "${D}ideation → design → develop → test → deploy → iterate${N}"
echo ""

# ── Install functions ────────────────────────────────────────────
install_claude() {
  local HAS_CLAUDE=0
  command -v claude >/dev/null 2>&1 && HAS_CLAUDE=1

  echo -e "${B}Claude Code:${N}"
  if [ $HAS_CLAUDE -eq 1 ]; then
    echo -e "  ${G}✓${N} Plugin ready at: $PLUGIN_PATH"
    echo ""
    echo -e "  ${Y}To use:${N}"
    echo -e "    ${D}Dev/test (one session):${N}  claude --plugin-dir \"$PLUGIN_PATH\""
    echo -e "    ${D}Permanent:${N}              claude plugins add \"$PLUGIN_PATH\""
    echo ""
  else
    echo -e "  ${D}Claude Code not found. Install from https://claude.ai/code${N}"
  fi
}

install_codex_skills() {
  # Raw skills for Codex CLI discovery via ~/.agents/skills/
  local AGENTS_SKILLS="$HOME/.agents/skills"
  mkdir -p "$AGENTS_SKILLS"

  local count=0
  for skill_dir in "$PLUGIN_PATH/skills"/*/; do
    local name=$(basename "$skill_dir")
    [ "$name" = "_router" ] && continue
    # P1 fix: only link if SKILL.md exists
    [ ! -f "$skill_dir/SKILL.md" ] && continue

    local target="$AGENTS_SKILLS/$name"
    if [ -L "$target" ]; then
      # P1 fix: replace stale symlinks from different paths
      local existing=$(readlink "$target" 2>/dev/null || true)
      if echo "$existing" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
        continue
      else
        ln -sfn "$skill_dir" "$target"
        count=$((count + 1))
        continue
      fi
    fi
    if [ ! -e "$target" ]; then
      ln -sfn "$skill_dir" "$target"
      count=$((count + 1))
    fi
  done

  # Also install router
  if [ ! -e "$AGENTS_SKILLS/_ios-router" ]; then
    ln -sfn "$PLUGIN_PATH/skills/_router" "$AGENTS_SKILLS/_ios-router"
  fi

  local total=$(find "$AGENTS_SKILLS" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  echo -e "  ${G}✓${N} Codex CLI — $total skills symlinked to ~/.agents/skills/"
}

install_codex_plugin() {
  # Full plugin bundle for Codex Mac App
  local PLUGINS_DIR="$HOME/plugins"
  local MARKETPLACE="$HOME/.agents/plugins/marketplace.json"

  mkdir -p "$PLUGINS_DIR"
  mkdir -p "$(dirname "$MARKETPLACE")"

  # Symlink repo as plugin bundle
  local target="$PLUGINS_DIR/ios-skills"
  if [ -L "$target" ]; then
    local existing=$(readlink "$target" 2>/dev/null || true)
    if echo "$existing" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
      echo -e "  ${D}Codex Mac App: already linked${N}"
    else
      ln -sfn "$PLUGIN_PATH" "$target"
      echo -e "  ${G}✓${N} Codex Mac App — updated symlink at ~/plugins/ios-skills"
    fi
  elif [ ! -e "$target" ]; then
    ln -sfn "$PLUGIN_PATH" "$target"
    echo -e "  ${G}✓${N} Codex Mac App — symlinked to ~/plugins/ios-skills"
  fi

  # Register in marketplace.json
  if [ -f "$MARKETPLACE" ]; then
    if grep -q '"ios-skills"' "$MARKETPLACE" 2>/dev/null; then
      echo -e "  ${D}Marketplace: already registered${N}"
      return 0
    fi
    # Add to existing marketplace
    python3 -c "
import json
with open('$MARKETPLACE') as f: m = json.load(f)
m.setdefault('plugins', [])
m['plugins'].append({
    'name': 'ios-skills',
    'source': {'source': 'local', 'path': './plugins/ios-skills'},
    'policy': {'installation': 'INSTALLED_BY_DEFAULT', 'authentication': 'ON_INSTALL'},
    'category': 'Coding'
})
with open('$MARKETPLACE', 'w') as f: json.dump(m, f, indent=2)
"
  else
    # Create new marketplace
    python3 -c "
import json
m = {
    'name': 'local-plugins',
    'interface': {'displayName': 'Local Plugins'},
    'plugins': [{
        'name': 'ios-skills',
        'source': {'source': 'local', 'path': './plugins/ios-skills'},
        'policy': {'installation': 'INSTALLED_BY_DEFAULT', 'authentication': 'ON_INSTALL'},
        'category': 'Coding'
    }]
}
with open('$MARKETPLACE', 'w') as f: json.dump(m, f, indent=2)
"
  fi
  echo -e "  ${G}✓${N} Marketplace — registered in ~/.agents/plugins/marketplace.json"
}

uninstall() {
  echo -e "${Y}Uninstalling...${N}"

  # Remove raw skill symlinks
  local AGENTS_SKILLS="$HOME/.agents/skills"
  if [ -d "$AGENTS_SKILLS" ]; then
    local count=0
    for link in "$AGENTS_SKILLS"/*; do
      if [ -L "$link" ] && readlink "$link" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
        rm "$link"
        count=$((count + 1))
      fi
    done
    [ $count -gt 0 ] && echo -e "  ${G}✓${N} Removed $count symlinks from ~/.agents/skills/"
  fi

  # Remove plugin bundle symlink
  local plugin_link="$HOME/plugins/ios-skills"
  if [ -L "$plugin_link" ] && readlink "$plugin_link" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
    rm "$plugin_link"
    echo -e "  ${G}✓${N} Removed ~/plugins/ios-skills"
  fi

  # Remove from marketplace
  local MARKETPLACE="$HOME/.agents/plugins/marketplace.json"
  if [ -f "$MARKETPLACE" ] && grep -q '"ios-skills"' "$MARKETPLACE" 2>/dev/null; then
    python3 -c "
import json
with open('$MARKETPLACE') as f: m = json.load(f)
m['plugins'] = [p for p in m.get('plugins', []) if p.get('name') != 'ios-skills']
with open('$MARKETPLACE', 'w') as f: json.dump(m, f, indent=2)
"
    echo -e "  ${G}✓${N} Removed from marketplace.json"
  fi

  # Clean state
  rm -rf "$HOME/.ios-skills" 2>/dev/null && echo -e "  ${G}✓${N} Removed ~/.ios-skills state"

  echo ""
  echo -e "  ${D}If installed as Claude plugin, also run: claude plugins remove ios-skills${N}"
  echo -e "${G}Done.${N}"
}

status() {
  echo -e "${B}Status:${N}"

  # Claude
  if command -v claude >/dev/null 2>&1; then
    if claude plugins list 2>/dev/null | grep -q "ios-skills" 2>/dev/null; then
      echo -e "  Claude Code:     ${G}installed (plugin)${N}"
    else
      echo -e "  Claude Code:     ${Y}available${N} — run: claude plugins add \"$PLUGIN_PATH\""
    fi
  else
    echo -e "  Claude Code:     ${D}not found${N}"
  fi

  # Codex CLI
  local codex_count=$(find "$HOME/.agents/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  if [ "$codex_count" -gt 0 ]; then
    echo -e "  Codex CLI:       ${G}installed${N} ($codex_count skills)"
  else
    echo -e "  Codex CLI:       ${Y}not installed${N}"
  fi

  # Codex Mac App
  if [ -L "$HOME/plugins/ios-skills" ] && readlink "$HOME/plugins/ios-skills" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
    echo -e "  Codex Mac App:   ${G}installed${N} (~/plugins/ios-skills)"
  else
    echo -e "  Codex Mac App:   ${Y}not installed${N}"
  fi

  echo ""
  echo -e "  ${D}$SKILL_COUNT skills across 6 phases from 28 authors${N}"
}

# ── Parse args ───────────────────────────────────────────────────
case "${1:-}" in
  --claude|-c)
    install_claude ;;
  --codex|-x)
    install_codex_skills
    install_codex_plugin ;;
  --codex-skills)
    install_codex_skills ;;
  --codex-plugin)
    install_codex_plugin ;;
  --all|-a)
    install_claude
    install_codex_skills
    install_codex_plugin ;;
  --uninstall|-u)
    uninstall ;;
  --status)
    status ;;
  --help|-h)
    echo "Usage: ./install.sh [option]"
    echo ""
    echo "  --all, -a           Install for all agents (recommended)"
    echo "  --claude, -c        Show Claude Code install instructions"
    echo "  --codex, -x         Install for Codex (CLI skills + Mac App plugin)"
    echo "  --codex-skills      Codex CLI only (raw skills in ~/.agents/skills/)"
    echo "  --codex-plugin      Codex Mac App only (plugin bundle + marketplace)"
    echo "  --uninstall, -u     Remove from all agents"
    echo "  --status            Show installation status"
    echo "  (no args)           Interactive mode"
    ;;
  *)
    echo -e "Detected:"
    command -v claude >/dev/null 2>&1 && echo -e "  ${G}✓${N} Claude Code" || echo -e "  ${D}✗ Claude Code${N}"
    command -v codex  >/dev/null 2>&1 && echo -e "  ${G}✓${N} Codex CLI"   || echo -e "  ${D}✗ Codex CLI${N}"
    [ -d "/Applications/Codex.app" ] && echo -e "  ${G}✓${N} Codex Mac App" || echo -e "  ${D}✗ Codex Mac App${N}"
    echo ""
    echo "  1) Install for all detected agents (recommended)"
    echo "  2) Claude Code only"
    echo "  3) Codex (CLI + Mac App)"
    echo "  4) Show status"
    echo "  5) Uninstall"
    echo ""
    read -p "Choice [1-5]: " choice
    case $choice in
      1) install_claude; install_codex_skills; install_codex_plugin ;;
      2) install_claude ;;
      3) install_codex_skills; install_codex_plugin ;;
      4) status ;;
      5) uninstall ;;
      *) echo -e "${R}Invalid choice${N}"; exit 1 ;;
    esac
    ;;
esac

echo ""
echo -e "${D}Claude: skills auto-inject via hooks when editing .swift or running xcodebuild.${N}"
echo -e "${D}Codex:  skills auto-activate based on SKILL.md description matching.${N}"
