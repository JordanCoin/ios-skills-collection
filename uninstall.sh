#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="$SCRIPT_DIR"
G='\033[0;32m' Y='\033[1;33m' D='\033[0;90m' N='\033[0m'

echo ""
echo -e "${Y}Uninstalling iOS Skills Collection...${N}"
echo ""

for dir in "$HOME/.agents/skills" \
  "$HOME/Library/Developer/Xcode/CodingAssistant/ClaudeAgentConfig/skills" \
  "$HOME/Library/Developer/Xcode/CodingAssistant/codex/skills"; do
  if [ -d "$dir" ]; then
    count=0
    for link in "$dir"/*; do
      [ -L "$link" ] && readlink "$link" | grep -q "$PLUGIN_PATH" && rm "$link" && count=$((count + 1))
    done
    [ $count -gt 0 ] && echo -e "  ${G}✓${N} Removed $count symlinks from $dir"
  fi
done

[ -L "$HOME/plugins/ios-skills" ] && rm "$HOME/plugins/ios-skills" && echo -e "  ${G}✓${N} Removed ~/plugins/ios-skills"

MP="$HOME/.agents/plugins/marketplace.json"
if [ -f "$MP" ] && grep -q '"ios-skills"' "$MP" 2>/dev/null; then
  python3 -c "
import json
with open('$MP') as f: m=json.load(f)
m['plugins']=[p for p in m.get('plugins',[]) if p.get('name')!='ios-skills']
with open('$MP','w') as f: json.dump(m,f,indent=2)
" && echo -e "  ${G}✓${N} Removed from marketplace.json"
fi

SETTINGS="$HOME/.claude/settings.json"
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

echo ""
echo -e "  ${D}If installed as Claude plugin: claude plugins remove ios-skills${N}"
echo -e "${G}Done.${N}"
