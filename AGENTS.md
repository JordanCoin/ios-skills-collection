# iOS Skills Collection

202 iOS/Swift/Xcode agent skills from 28 authors with phase-aware routing.

## Structure

```
.claude-plugin/plugin.json    — Claude Code plugin manifest
.codex-plugin/plugin.json     — Codex CLI plugin manifest
hooks/
  hooks.json                  — SessionStart + PreToolUse hook config
  inject-router.mjs           — Injects router skill at session start
  route-skills.mjs            — Pattern-matches files/commands → skills
skills/
  _router/SKILL.md            — Meta-skill: phase map, knowledge corrections, decision matrix
  {author}--{name}/SKILL.md   — Individual skills (210 total)
  {author}--{name}/references/ — Detailed docs loaded on demand
skills-index.json             — Routing rules + phase assignments
sources.json                  — Upstream repo mapping for sync
sync.sh                       — Pull latest from all upstream repos
install.sh                    — Install for Claude Code + Codex CLI
```

## How Skills Load

1. **Session start**: Router injects with knowledge corrections table + decision matrix
2. **File edit/read**: Hook matches file patterns → injects 1-3 relevant skills
3. **Bash command**: Hook matches command patterns → injects relevant skills
4. **Import detection**: Writing `import HealthKit` → injects dpearson2699--healthkit
5. **Manual**: Agent reads any skill from `skills/{id}/SKILL.md`

Max 3 skills per injection. 24KB byte budget. Each skill fires once per session (dedup).

## Priority

Paul Hudson (twostraws) skills are primary for all overlapping domains.
When multiple skills cover the same topic, use the one with highest priority in skills-index.json.

## Skill Format

```yaml
---
name: skill-name
description: When to use this skill (1-1024 chars)
---

# Skill content (markdown)
```

## Contributing

Each skill directory is prefixed with the source author. To add a skill from a new upstream repo:
1. Add the repo to `sources.json`
2. Run `./sync.sh` to pull the SKILL.md files
3. Add routing rules to `skills-index.json` if needed
4. Add to the appropriate phase in `skills-index.json`
