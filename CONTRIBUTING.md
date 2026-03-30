# Contributing

## Adding a new skill from an upstream repo

1. **Find the repo** with SKILL.md files you want to add

2. **Add to sources.json**:
```json
{
  "repo": "author/repo-name",
  "author": "Author Name",
  "url": "https://github.com/author/repo-name",
  "license": "MIT",
  "skills": {
    "author--skill-name": "path/to/skill/in/repo"
  }
}
```

For repos with many skills under a `skills/` directory:
```json
{
  "repo": "author/repo-name",
  "author": "Author Name",
  "url": "https://github.com/author/repo-name",
  "license": "MIT",
  "prefix": "author--",
  "skillsDir": "skills"
}
```

3. **Run sync** to pull the files:
```bash
./sync.sh
```

4. **Verify** the skill has valid frontmatter:
```bash
head -5 skills/author--skill-name/SKILL.md
```
Must have `---` frontmatter with `name:` and `description:` fields.

5. **(Optional) Add routing** in `skills-index.json` if the skill should auto-inject
on specific file patterns or bash commands.

6. **Add to a phase** in `skills-index.json` under the appropriate phase
(ideation/design/develop/test/deploy/iterate) and tier (primary/secondary/frameworks).

7. **Open a PR** using the template.

## Adding a skill you wrote

Same as above, but host it in its own repo first so sync.sh can track updates.
Or add it directly under `skills/yourname--skill-name/` if it's unique to this collection.

## Skill format

```yaml
---
name: skill-name          # lowercase, hyphens, 1-64 chars
description: >            # 1-1024 chars, describes WHEN to use
  Use when the user is doing X. Also use when Y.
---

# Skill Title

Content here. Markdown.
```

The `description` is the primary signal for agent discovery — include trigger phrases
and scope boundaries.

## Naming convention

`{github-username}--{skill-name}/SKILL.md`

The `--` separator distinguishes author from skill name. This prevents collisions
when multiple authors have skills covering the same topic.

## License

- Most skills should be MIT
- If the upstream uses a different license (e.g., PolyForm Perimeter), note it in the
  README sources section and include any required notices in the LICENSE file
- Don't add skills with licenses that prohibit redistribution
