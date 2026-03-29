#!/usr/bin/env node
/**
 * SessionStart hook — injects the router skill at session start.
 * Outputs the ROUTER SKILL.md content so the agent always knows
 * about the skill collection and how to navigate it.
 */
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = process.env.CLAUDE_PLUGIN_ROOT || join(__dirname, '..');

try {
  const routerPath = join(PLUGIN_ROOT, 'skills', '_router', 'SKILL.md');
  const content = readFileSync(routerPath, 'utf8');

  // Strip frontmatter for cleaner injection
  const body = content.replace(/^---[\s\S]*?---\n*/, '');

  // Count skills
  const skillsDir = join(PLUGIN_ROOT, 'skills');
  let count = 0;
  try {
    const { readdirSync, statSync } = await import('fs');
    for (const d of readdirSync(skillsDir)) {
      if (d.startsWith('_')) continue;
      const skillMd = join(skillsDir, d, 'SKILL.md');
      try { statSync(skillMd); count++; } catch {}
    }
  } catch {}

  const header = `# iOS Skills Router — ${count || 169} skills loaded\n\n`;
  process.stdout.write(header + body);
} catch (err) {
  // Fail silently — don't break the session
  process.stderr.write(`[ios-skills] Router injection failed: ${err.message}\n`);
}
