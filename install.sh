#!/bin/bash
set -e

# iOS Skills Collection — Auto-install for Claude Code, Codex, and Xcode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="$SCRIPT_DIR"

G='\033[0;32m'  Y='\033[1;33m'  B='\033[0;34m'  D='\033[0;90m'  R='\033[0;31m'  N='\033[0m'

SKILL_COUNT=$(find "$PLUGIN_PATH/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "${B}iOS Skills Collection${N} — ${SKILL_COUNT} skills"
echo -e "${D}ideation → design → develop → test → deploy → iterate${N}"
echo ""

# ── Shared ───────────────────────────────────────────────────────
symlink_skills_to() {
  local dest="$1" label="$2"
  mkdir -p "$dest"
  local count=0
  for skill_dir in "$PLUGIN_PATH/skills"/*/; do
    local name=$(basename "$skill_dir")
    [ "$name" = "_router" ] && continue
    [ ! -f "$skill_dir/SKILL.md" ] && continue
    local target="$dest/$name"
    if [ -L "$target" ]; then
      readlink "$target" 2>/dev/null | grep -q "$PLUGIN_PATH" && continue
      ln -sfn "$skill_dir" "$target"; count=$((count + 1))
    elif [ ! -e "$target" ]; then
      ln -sfn "$skill_dir" "$target"; count=$((count + 1))
    fi
  done
  [ ! -e "$dest/_ios-router" ] && ln -sfn "$PLUGIN_PATH/skills/_router" "$dest/_ios-router"
  local total=$(find "$dest" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  echo -e "  ${G}✓${N} $label — $total skills"
}

# ── Claude Code ──────────────────────────────────────────────────
install_claude() {
  command -v claude >/dev/null 2>&1 || return 0
  echo -e "${B}Claude Code:${N}"

  # Marketplace + plugin install
  if ! claude plugins marketplace list 2>/dev/null | grep -q "ios-skills-collection" 2>/dev/null; then
    claude plugins marketplace add "https://github.com/JordanCoin/ios-skills-collection" 2>/dev/null && \
      echo -e "  ${G}✓${N} Marketplace added" || \
      echo -e "  ${Y}!${N} Marketplace failed — try manually"
  fi
  if ! claude plugins list 2>/dev/null | grep -q "ios-skills" 2>/dev/null; then
    claude plugins install "ios-skills@ios-skills-collection" 2>/dev/null && \
      echo -e "  ${G}✓${N} Plugin installed" || \
      echo -e "  ${Y}!${N} Plugin install failed — try manually"
  else
    echo -e "  ${G}✓${N} Plugin installed"
  fi

  # Register hooks in settings.json (reliable — same as codemap)
  local SETTINGS="$HOME/.claude/settings.json"
  mkdir -p "$HOME/.claude"
  if [ ! -f "$SETTINGS" ]; then
    echo '{}' > "$SETTINGS"
  fi
  if ! grep -q "ios-skills" "$SETTINGS" 2>/dev/null; then
    python3 -c "
import json
with open('$SETTINGS') as f: s = json.load(f)
hooks = s.setdefault('hooks', {})
ss = hooks.setdefault('SessionStart', [])
if not any('ios-skills' in str(e) for e in ss):
    ss.append({'matcher':'startup|resume|clear|compact','hooks':[{'type':'command','command':'node \"$PLUGIN_PATH/hooks/inject-router.mjs\"'}]})
ptu = hooks.setdefault('PreToolUse', [])
if not any('ios-skills' in str(e) for e in ptu):
    ptu.append({'matcher':'Read|Edit|MultiEdit|Write|Bash','hooks':[{'type':'command','command':'node \"$PLUGIN_PATH/hooks/route-skills.mjs\"'}]})
with open('$SETTINGS', 'w') as f: json.dump(s, f, indent=2)
" && echo -e "  ${G}✓${N} Hooks registered" || echo -e "  ${Y}!${N} Hook registration failed"
  else
    echo -e "  ${G}✓${N} Hooks registered"
  fi
  echo ""
}

# ── Codex ────────────────────────────────────────────────────────
install_codex() {
  echo -e "${B}Codex:${N}"
  symlink_skills_to "$HOME/.agents/skills" "CLI (~/.agents/skills)"

  # Mac App plugin bundle
  if [ -d "/Applications/Codex.app" ] || command -v codex >/dev/null 2>&1; then
    local PLUGINS_DIR="$HOME/plugins"
    local MARKETPLACE="$HOME/.agents/plugins/marketplace.json"
    mkdir -p "$PLUGINS_DIR" "$(dirname "$MARKETPLACE")"
    local target="$PLUGINS_DIR/ios-skills"
    if [ ! -L "$target" ] || ! readlink "$target" 2>/dev/null | grep -q "$PLUGIN_PATH"; then
      ln -sfn "$PLUGIN_PATH" "$target"
    fi
    if [ ! -f "$MARKETPLACE" ] || ! grep -q '"ios-skills"' "$MARKETPLACE" 2>/dev/null; then
      python3 -c "
import json, os
mp = '$MARKETPLACE'
m = json.load(open(mp)) if os.path.exists(mp) else {'name':'local-plugins','interface':{'displayName':'Local Plugins'},'plugins':[]}
if not any(p.get('name')=='ios-skills' for p in m.get('plugins',[])):
    m.setdefault('plugins',[]).append({'name':'ios-skills','source':{'source':'local','path':'./plugins/ios-skills'},'policy':{'installation':'INSTALLED_BY_DEFAULT','authentication':'ON_INSTALL'},'category':'Coding'})
with open(mp,'w') as f: json.dump(m,f,indent=2)
" 2>/dev/null
    fi
    echo -e "  ${G}✓${N} Mac App (~/plugins/ios-skills)"
  fi
  echo ""
}

# ── Xcode ────────────────────────────────────────────────────────
install_xcode() {
  [ -d "/Applications/Xcode.app" ] || return 0
  echo -e "${B}Xcode:${N}"
  symlink_skills_to "$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/skills" "Claude Agent"
  symlink_skills_to "$HOME/Library/Developer/Xcode/CodingAssistant/codex/skills" "Codex"
  echo -e "  ${D}Restart Xcode to pick up skills${N}"
  echo ""
}

# ── Uninstall ────────────────────────────────────────────────────
uninstall() {
  echo -e "${Y}Uninstalling...${N}"
  for dir in "$HOME/.agents/skills" \
    "$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/skills" \
    "$HOME/Library/Developer/Xcode/CodingAssistant/codex/skills"; do
    if [ -d "$dir" ]; then
      local count=0
      for link in "$dir"/*; do
        [ -L "$link" ] && readlink "$link" | grep -q "$PLUGIN_PATH" && rm "$link" && count=$((count + 1))
      done
      [ $count -gt 0 ] && echo -e "  ${G}✓${N} Removed $count symlinks from $dir"
    fi
  done
  [ -L "$HOME/plugins/ios-skills" ] && rm "$HOME/plugins/ios-skills" && echo -e "  ${G}✓${N} Removed ~/plugins/ios-skills"
  local MP="$HOME/.agents/plugins/marketplace.json"
  if [ -f "$MP" ] && grep -q '"ios-skills"' "$MP" 2>/dev/null; then
    python3 -c "
import json
with open('$MP') as f: m=json.load(f)
m['plugins']=[p for p in m.get('plugins',[]) if p.get('name')!='ios-skills']
with open('$MP','w') as f: json.dump(m,f,indent=2)
" && echo -e "  ${G}✓${N} Removed from marketplace.json"
  fi
  local SETTINGS="$HOME/.claude/settings.json"
  if [ -f "$SETTINGS" ] && grep -q "ios-skills" "$SETTINGS" 2>/dev/null; then
    python3 -c "
import json
with open('$SETTINGS') as f: s=json.load(f)
for event in ['SessionStart','PreToolUse']:
    if event in s.get('hooks',{}):
        s['hooks'][event]=[e for e in s['hooks'][event] if 'ios-skills' not in str(e)]
        if not s['hooks'][event]: del s['hooks'][event]
with open('$SETTINGS','w') as f: json.dump(s,f,indent=2)
" && echo -e "  ${G}✓${N} Removed hooks from settings.json"
  fi
  rm -rf "$HOME/.ios-skills" 2>/dev/null
  echo -e "  ${D}Claude plugin: claude plugins remove ios-skills${N}"
  echo -e "${G}Done.${N}"
}

# ── Status ───────────────────────────────────────────────────────
status() {
  echo -e "${B}Status:${N}"
  command -v claude >/dev/null 2>&1 && {
    claude plugins list 2>/dev/null | grep -q "ios-skills" && echo -e "  Claude Code:     ${G}installed${N}" || echo -e "  Claude Code:     ${Y}plugin not found${N}"
    grep -q "ios-skills" "$HOME/.claude/settings.json" 2>/dev/null && echo -e "  Hooks:           ${G}registered${N}" || echo -e "  Hooks:           ${R}not registered${N}"
  } || echo -e "  Claude Code:     ${D}not found${N}"
  local cc=$(find "$HOME/.agents/skills" -maxdepth 1 -type l 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  [ "$cc" -gt 0 ] && echo -e "  Codex CLI:       ${G}installed${N} ($cc)" || echo -e "  Codex CLI:       ${Y}not installed${N}"
  [ -L "$HOME/plugins/ios-skills" ] && echo -e "  Codex Mac App:   ${G}installed${N}" || echo -e "  Codex Mac App:   ${Y}not installed${N}"
  local xc=$(find "$HOME/Library/Developer/Xcode/CodingAssistant" -maxdepth 3 -type l -name "*--*" 2>/dev/null | xargs -I{} readlink {} 2>/dev/null | grep -c "$PLUGIN_PATH" || true)
  [ "$xc" -gt 0 ] && echo -e "  Xcode:           ${G}installed${N} ($xc)" || echo -e "  Xcode:           ${Y}not installed${N}"
  echo ""
  echo -e "  ${D}$SKILL_COUNT skills / 28 authors / 6 phases${N}"
}

# ── Main ─────────────────────────────────────────────────────────
case "${1:-}" in
  --uninstall|-u) uninstall ;;
  --status|-s)    status ;;
  --help|-h)
    echo "Usage: ./install.sh           # install for all detected agents"
    echo "       ./install.sh --status  # show what's installed"
    echo "       ./install.sh --uninstall"
    ;;
  *)
    install_claude
    install_codex
    install_xcode
    echo -e "${D}Restart Claude Code / Xcode to pick up new skills.${N}"
    ;;
esac
