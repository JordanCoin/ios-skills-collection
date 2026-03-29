#!/usr/bin/env node
/**
 * PreToolUse hook — routes skills based on file patterns and bash commands.
 *
 * When the agent reads/edits a Swift file or runs a build command,
 * this hook matches against routing rules in skills-index.json and
 * injects the most relevant SKILL.md files as additionalContext.
 *
 * - Max 3 skills per injection (configurable in index)
 * - 18KB byte budget per injection
 * - Session dedup: each skill injects only once per session
 */
import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync, statSync } from 'fs';
import { join, basename, dirname } from 'path';
import { createHash } from 'crypto';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const PLUGIN_ROOT = process.env.CLAUDE_PLUGIN_ROOT || join(__dirname, '..');
const INDEX_PATH = join(PLUGIN_ROOT, 'skills-index.json');
const SKILLS_DIR = join(PLUGIN_ROOT, 'skills');
const DEDUP_DIR = join('/tmp', 'ios-skills-dedup');
const DEBUG = process.env.IOS_SKILLS_DEBUG === '1';

// ── Read stdin ──────────────────────────────────────────────────
let input = '';
try {
  input = readFileSync(0, 'utf8');
} catch {
  output({});
  process.exit(0);
}

let data;
try {
  data = JSON.parse(input);
} catch {
  output({});
  process.exit(0);
}

const toolName = data.tool_name || '';
const toolInput = data.tool_input || {};
const sessionId = data.session_id || 'default';

// ── Load index ──────────────────────────────────────────────────
let index;
try {
  index = JSON.parse(readFileSync(INDEX_PATH, 'utf8'));
} catch (err) {
  debug('index-load-failed', err.message);
  output({});
  process.exit(0);
}

const MAX_SKILLS = index.config?.maxSkillsPerInjection || 3;
const MAX_BYTES = index.config?.maxByteBudget || 18000;

// ── Session dedup ───────────────────────────────────────────────
if (!existsSync(DEDUP_DIR)) mkdirSync(DEDUP_DIR, { recursive: true });
const sessionHash = createHash('sha256').update(sessionId).digest('hex').slice(0, 16);
const dedupPath = join(DEDUP_DIR, `${sessionHash}.json`);

let injected = {};
try {
  if (existsSync(dedupPath)) {
    injected = JSON.parse(readFileSync(dedupPath, 'utf8'));
  }
} catch {}

// ── Match skills ────────────────────────────────────────────────
let candidates = []; // { skillId, priority }

if (['Read', 'Edit', 'Write'].includes(toolName) && toolInput.file_path) {
  const filePath = toolInput.file_path;
  const fileName = basename(filePath);

  for (const rule of (index.routing?.fileRules || [])) {
    const patterns = rule.pattern.split('|');
    let matched = false;

    for (const pat of patterns) {
      if (matchGlob(fileName, pat.trim()) || matchGlob(filePath, pat.trim())) {
        matched = true;
        break;
      }
    }

    if (matched) {
      for (const skillId of rule.skills) {
        if (!injected[skillId]) {
          candidates.push({ skillId, priority: rule.priority });
        }
      }
    }
  }

  // Framework import detection: scan file content for imports on Edit/Write
  const textToScan = toolInput.new_string || toolInput.content || '';
  if (textToScan) {
    const importMatch = textToScan.match(/import\s+(\w+)/g);
    if (importMatch) {
      for (const imp of importMatch) {
        const raw = imp.replace('import ', '');
        const framework = raw.toLowerCase();

        // Try direct match first, then kebab-case variants
        const variants = [
          framework,
          framework.replace(/^core(\w)/, 'core-$1'),           // CoreBluetooth → core-bluetooth
          framework.replace(/^(swift)(ui|data)/, '$1$2'),       // SwiftUI → swiftui
          framework.replace(/kit$/, 'kit'),                     // HealthKit → healthkit
          raw.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase() // CamelCase → kebab-case
        ];

        for (const v of variants) {
          const skillId = `dpearson2699--${v}`;
          const skillPath = join(SKILLS_DIR, skillId, 'SKILL.md');
          if (existsSync(skillPath) && !injected[skillId]) {
            candidates.push({ skillId, priority: 8 });
            break;
          }
        }
      }
    }
  }
} else if (toolName === 'Bash' && toolInput.command) {
  const command = toolInput.command;

  for (const rule of (index.routing?.bashRules || [])) {
    try {
      if (new RegExp(rule.pattern).test(command)) {
        for (const skillId of rule.skills) {
          if (!injected[skillId]) {
            candidates.push({ skillId, priority: rule.priority });
          }
        }
      }
    } catch (err) {
      debug('bash-regex-error', { pattern: rule.pattern, error: err.message });
    }
  }
}

// ── Dedup, sort, select ─────────────────────────────────────────
const seen = new Set();
candidates = candidates
  .filter(c => {
    if (seen.has(c.skillId)) return false;
    seen.add(c.skillId);
    return true;
  })
  .sort((a, b) => b.priority - a.priority);

debug('candidates', candidates.map(c => `${c.skillId} (p${c.priority})`));

// Load top N within byte budget
let totalBytes = 0;
const selected = [];

for (const candidate of candidates) {
  if (selected.length >= MAX_SKILLS) break;

  const skillPath = join(SKILLS_DIR, candidate.skillId, 'SKILL.md');
  if (!existsSync(skillPath)) {
    debug('skill-missing', candidate.skillId);
    continue;
  }

  let content;
  try {
    content = readFileSync(skillPath, 'utf8');
  } catch {
    continue;
  }

  if (totalBytes + Buffer.byteLength(content) > MAX_BYTES) {
    debug('byte-budget-exceeded', { skill: candidate.skillId, size: Buffer.byteLength(content), budget: MAX_BYTES - totalBytes });
    continue;
  }

  selected.push({ id: candidate.skillId, content, priority: candidate.priority });
  totalBytes += Buffer.byteLength(content);
}

// ── Output ──────────────────────────────────────────────────────
if (selected.length === 0) {
  output({});
} else {
  // Mark as injected for session dedup
  for (const s of selected) {
    injected[s.id] = Date.now();
  }
  try {
    writeFileSync(dedupPath, JSON.stringify(injected));
  } catch {}

  const parts = selected.map(s =>
    `<!-- ios-skill: ${s.id} (priority ${s.priority}) -->\n${s.content}`
  );

  const header = `[ios-skills] Injected ${selected.length} skill(s): ${selected.map(s => s.id).join(', ')}`;

  output({
    additionalContext: `${header}\n\n${parts.join('\n\n---\n\n')}`
  });

  debug('injected', selected.map(s => s.id));
}

// ── Helpers ─────────────────────────────────────────────────────

function output(obj) {
  process.stdout.write(JSON.stringify(obj));
}

function debug(event, data) {
  if (!DEBUG) return;
  process.stderr.write(JSON.stringify({ event, data, ts: new Date().toISOString() }) + '\n');
}

/**
 * Simple glob matcher.
 * Supports: * (any chars except /), ** (any chars including /), ? (single char)
 */
function matchGlob(str, pattern) {
  // First replace glob tokens with placeholders
  let re = pattern
    .replace(/\*\*/g, '\0GLOBSTAR\0')
    .replace(/\*/g, '\0STAR\0')
    .replace(/\?/g, '\0QUESTION\0');

  // Escape all regex special chars in the remaining literal text
  re = re.replace(/[.+^${}()|[\]\\]/g, '\\$&');

  // Restore glob tokens as regex equivalents
  re = re
    .replace(/\0GLOBSTAR\0/g, '.*')
    .replace(/\0STAR\0/g, '[^/]*')
    .replace(/\0QUESTION\0/g, '[^/]');

  try {
    return new RegExp(re + '$', 'i').test(str);
  } catch {
    return false;
  }
}
