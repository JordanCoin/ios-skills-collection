#!/usr/bin/env node
/**
 * SessionStart hook — injects the router skill at session start.
 * Also checks if skills are stale and nudges the user to sync.
 */
import { readFileSync, readdirSync, statSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execFileSync } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = process.env.CLAUDE_PLUGIN_ROOT || join(__dirname, '..');

try {
  const routerPath = join(PLUGIN_ROOT, 'skills', '_router', 'SKILL.md');
  const content = readFileSync(routerPath, 'utf8');
  const body = content.replace(/^---[\s\S]*?---\n*/, '');

  // Count skills
  const skillsDir = join(PLUGIN_ROOT, 'skills');
  let count = 0;
  for (const d of readdirSync(skillsDir)) {
    if (d.startsWith('_')) continue;
    try { statSync(join(skillsDir, d, 'SKILL.md')); count++; } catch {}
  }

  // Quick freshness check
  let freshness = '';
  try {
    const syncScript = join(PLUGIN_ROOT, 'sync.sh');
    const result = execFileSync('bash', [syncScript, '--quick-check'], {
      timeout: 3000,
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    }).trim();

    if (result === 'NEEDS_SYNC') {
      freshness = '\n\n> **Skills have never been synced.** Run `./sync.sh` in the plugin directory to pull latest from upstream repos.\n';
    } else if (result.startsWith('STALE_')) {
      const days = result.replace('STALE_', '').replace('d', '');
      freshness = `\n\n> **Skills last synced ${days} days ago.** Run \`./sync.sh\` to check for updates.\n`;
    }
  } catch {
    // Don't block session start if check fails
  }

  const header = `# iOS Skills Router — ${count} skills loaded${freshness}\n\n`;
  process.stdout.write(header + body);
} catch (err) {
  process.stderr.write(`[ios-skills] Router injection failed: ${err.message}\n`);
}
