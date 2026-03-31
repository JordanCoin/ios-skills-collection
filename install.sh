#!/bin/bash
set -e

# iOS Skills Collection — Install for Claude Code, Codex, and Xcode
# 200+ skills from 28 authors, phase-aware routing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="$SCRIPT_DIR"

G='\033[0;32m'  Y='\033[1;33m'  B='\033[0;34m'  D='\033[0;90m'  R='\033[0;31m'  N='\033[0m'

SKILL_COUNT=$(find "$PLUGIN_PATH/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${B}iOS Skills Collection${N} — ${SKILL_COUNT} skills"
echo -e "${D}ideation → design → develop → test → deploy → iterate${N}"
echo ""

# ── Shared helper ────────────────────────────────────────────────
symlink_skills_to() {
  local dest="$1"
  local label="$2"
  mkdir -p "$dest"

  local count=0
  for skill_dir in "$PLUGIN_PATH/skills"/*/; do
    local name=$(basename "$skill_dir")
    [ "$name" = "_router" ] && continue
    [ ! -f "$skill_dir/SKILL.md" ] && continue

    local target="$dest/$name"
    if [ -L "$target" ]; then
      local existing=$(readlink "$target" 2>/dev/null || true)
      echo "$existing" | grep -q "$PLUGIN_PATH" 2>/dev/null && continue
      ln -sfn "$skill_dir" "$target"
      count=$((count + 1))
    elif [ ! -e "$target" ]; then
      ln -sfn "$skill_dir" "$target"
      count=$((count + 1))
    fi
  done

  # Router skill
  [ ! -e "$dest/_ios-router" ] && ln -sfn "$PLUGIN_PATH/skills/_router" "$dest/_ios-router"

  local total=$(find "$dest" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  echo -e "  ${G}✓${N} $label — $total skills symlinked to $dest"
}

# ── Install functions ────────────────────────────────────────────
install_claude() {
  local HAS_CLAUDE=0
  command -v claude >/dev/null 2>&1 && HAS_CLAUDE=1

  echo -e "${B}Claude Code:${N}"
  if [ $HAS_CLAUDE -eq 1 ]; then
    if claude plugins marketplace list 2>/dev/null | grep -q "ios-skills-collection" 2>/dev/null; then
      echo -e "  ${D}Marketplace already added${N}"
    else
      echo -e "  Adding marketplace..."
      claude plugins marketplace add "https://github.com/JordanCoin/ios-skills-collection" 2>/dev/null && \
        echo -e "  ${G}✓${N} Marketplace added" || \
        echo -e "  ${Y}!${N} Failed — try: claude plugins marketplace add https://github.com/JordanCoin/ios-skills-collection"
    fi

    if claude plugins list 2>/dev/null | grep -q "ios-skills" 2>/dev/null; then
      echo -e "  ${G}✓${N} Plugin already installed"
    else
      echo -e "  Installing plugin..."
      claude plugins install "ios-skills@ios-skills-collection" 2>/dev/null && \
        echo -e "  ${G}✓${N} Plugin installed" || \
        echo -e "  ${Y}!${N} Failed — try: claude plugins install ios-skills@ios-skills-collection"
    fi

    # Symlink router skill into ~/.claude/skills/ so Claude always discovers it
    local CLAUDE_SKILLS="$HOME/.claude/skills"
    mkdir -p "$CLAUDE_SKILLS"
    local router_target="$CLAUDE_SKILLS/ios-skills-router"
    if [ -L "$router_target" ]; then
      local existing=$(readlink "$router_target" 2>/dev/null || true)
      echo "$existing" | grep -q "ios-skills" 2>/dev/null || ln -sfn "$PLUGIN_PATH/skills/_router" "$router_target"
    elif [ ! -e "$router_target" ]; then
      ln -sfn "$PLUGIN_PATH/skills/_router" "$router_target"
    fi
    echo -e "  ${G}✓${N} Router skill linked to ~/.claude/skills/ios-skills-router"
    echo ""
  else
    echo -e "  ${D}Claude Code not found${N}"
  fi
}

install_codex_skills() {
  symlink_skills_to "$HOME/.agents/skills" "Codex CLI"
}

install_codex_plugin() {
  local PLUGINS_DIR="$HOME/plugins"
  local MARKETPLACE="$HOME/.agents/plugins/marketplace.json"

  mkdir -p "$PLUGINS_DIR"
  mkdir -p "$(dirname "$MARKETPLACE")"

  local target="$PLUGINS_DIR/ios-skills"
  if [ -L "$target" ]; then
    local existing=$(readlink "$target" 2>/dev/null || true)
    if echo "$existing" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
      echo -e "  ${D}Codex Mac App: already linked${N}"
    else
      ln -sfn "$PLUGIN_PATH" "$target"
      echo -e "  ${G}✓${N} Codex Mac App — updated symlink"
    fi
  elif [ ! -e "$target" ]; then
    ln -sfn "$PLUGIN_PATH" "$target"
    echo -e "  ${G}✓${N} Codex Mac App — symlinked to ~/plugins/ios-skills"
  fi

  if [ -f "$MARKETPLACE" ]; then
    if grep -q '"ios-skills"' "$MARKETPLACE" 2>/dev/null; then
      echo -e "  ${D}Marketplace: already registered${N}"
      return 0
    fi
    python3 -c "
import json
with open('$MARKETPLACE') as f: m = json.load(f)
m.setdefault('plugins', [])
m['plugins'].append({'name':'ios-skills','source':{'source':'local','path':'./plugins/ios-skills'},'policy':{'installation':'INSTALLED_BY_DEFAULT','authentication':'ON_INSTALL'},'category':'Coding'})
with open('$MARKETPLACE', 'w') as f: json.dump(m, f, indent=2)
"
  else
    python3 -c "
import json
m={'name':'local-plugins','interface':{'displayName':'Local Plugins'},'plugins':[{'name':'ios-skills','source':{'source':'local','path':'./plugins/ios-skills'},'policy':{'installation':'INSTALLED_BY_DEFAULT','authentication':'ON_INSTALL'},'category':'Coding'}]}
with open('$MARKETPLACE', 'w') as f: json.dump(m, f, indent=2)
"
  fi
  echo -e "  ${G}✓${N} Marketplace — registered"
}

install_xcode() {
  echo -e "${B}Xcode:${N}"
  local XCODE_CLAUDE="$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/skills"
  local XCODE_CODEX="$HOME/Library/Developer/Xcode/CodingAssistant/codex/skills"

  symlink_skills_to "$XCODE_CLAUDE" "Xcode (Claude Agent)"
  symlink_skills_to "$XCODE_CODEX" "Xcode (Codex)"

  echo -e "  ${D}Restart Xcode to pick up new skills${N}"
}

uninstall() {
  echo -e "${Y}Uninstalling...${N}"

  # Remove symlinks from all known locations
  for dir in \
    "$HOME/.agents/skills" \
    "$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/skills" \
    "$HOME/Library/Developer/Xcode/CodingAssistant/codex/skills"; do
    if [ -d "$dir" ]; then
      local count=0
      for link in "$dir"/*; do
        if [ -L "$link" ] && readlink "$link" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
          rm "$link"
          count=$((count + 1))
        fi
      done
      [ $count -gt 0 ] && echo -e "  ${G}✓${N} Removed $count symlinks from $dir"
    fi
  done

  # Plugin bundle
  local plugin_link="$HOME/plugins/ios-skills"
  if [ -L "$plugin_link" ] && readlink "$plugin_link" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
    rm "$plugin_link"
    echo -e "  ${G}✓${N} Removed ~/plugins/ios-skills"
  fi

  # Marketplace
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

  rm -rf "$HOME/.ios-skills" 2>/dev/null && echo -e "  ${G}✓${N} Removed ~/.ios-skills state"

  echo ""
  echo -e "  ${D}If installed as Claude plugin: claude plugins remove ios-skills${N}"
  echo -e "${G}Done.${N}"
}

status() {
  echo -e "${B}Status:${N}"

  # Claude Code
  if command -v claude >/dev/null 2>&1; then
    if claude plugins list 2>/dev/null | grep -q "ios-skills" 2>/dev/null; then
      echo -e "  Claude Code:       ${G}installed${N}"
    else
      echo -e "  Claude Code:       ${Y}not installed${N}"
    fi
  else
    echo -e "  Claude Code:       ${D}not found${N}"
  fi

  # Codex CLI
  local codex_count=$(find "$HOME/.agents/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  [ "$codex_count" -gt 0 ] && echo -e "  Codex CLI:         ${G}installed${N} ($codex_count skills)" || echo -e "  Codex CLI:         ${Y}not installed${N}"

  # Codex Mac App
  if [ -L "$HOME/plugins/ios-skills" ] && readlink "$HOME/plugins/ios-skills" | grep -q "$PLUGIN_PATH" 2>/dev/null; then
    echo -e "  Codex Mac App:     ${G}installed${N}"
  else
    echo -e "  Codex Mac App:     ${Y}not installed${N}"
  fi

  # Xcode
  local xc_claude=$(find "$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  local xc_codex=$(find "$HOME/Library/Developer/Xcode/CodingAssistant/codex/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  if [ "$xc_claude" -gt 0 ] || [ "$xc_codex" -gt 0 ]; then
    echo -e "  Xcode:             ${G}installed${N} (Claude: $xc_claude, Codex: $xc_codex skills)"
  else
    echo -e "  Xcode:             ${Y}not installed${N}"
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
  --xcode)
    install_xcode ;;
  --all|-a)
    install_claude
    install_codex_skills
    install_codex_plugin
    install_xcode ;;
  --uninstall|-u)
    uninstall ;;
  --status)
    status ;;
  --help|-h)
    echo "Usage: ./install.sh [option]"
    echo ""
    echo "  --all, -a           Install for all agents (recommended)"
    echo "  --claude, -c        Install for Claude Code"
    echo "  --codex, -x         Install for Codex (CLI + Mac App)"
    echo "  --xcode             Install for Xcode (Claude Agent + Codex)"
    echo "  --uninstall, -u     Remove from all agents"
    echo "  --status            Show installation status"
    echo "  (no args)           Interactive mode"
    ;;
  *)
    echo -e "Detected:"
    command -v claude >/dev/null 2>&1 && echo -e "  ${G}✓${N} Claude Code" || echo -e "  ${D}✗ Claude Code${N}"
    command -v codex  >/dev/null 2>&1 && echo -e "  ${G}✓${N} Codex CLI"   || echo -e "  ${D}✗ Codex CLI${N}"
    [ -d "/Applications/Codex.app" ] && echo -e "  ${G}✓${N} Codex Mac App" || echo -e "  ${D}✗ Codex Mac App${N}"
    [ -d "/Applications/Xcode.app" ] && echo -e "  ${G}✓${N} Xcode"        || echo -e "  ${D}✗ Xcode${N}"
    echo ""
    echo "  1) Install for all detected agents (recommended)"
    echo "  2) Claude Code only"
    echo "  3) Codex (CLI + Mac App)"
    echo "  4) Xcode only"
    echo "  5) Show status"
    echo "  6) Uninstall"
    echo ""
    read -p "Choice [1-6]: " choice
    case $choice in
      1) install_claude; install_codex_skills; install_codex_plugin; install_xcode ;;
      2) install_claude ;;
      3) install_codex_skills; install_codex_plugin ;;
      4) install_xcode ;;
      5) status ;;
      6) uninstall ;;
      *) echo -e "${R}Invalid choice${N}"; exit 1 ;;
    esac
    ;;
esac

echo ""
echo -e "${D}Claude: skills auto-inject via hooks when editing .swift or running xcodebuild.${N}"
echo -e "${D}Codex/Xcode: skills auto-activate based on SKILL.md description matching.${N}"
