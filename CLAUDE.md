# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

This is the **oh-my-claudecode (OMC)** base content repository — a Claude Code plugin providing multi-agent orchestration, skill definitions, hook scripts, and agent templates. It is deployed as a plugin installed at `~/.claude/` on user machines.

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `skills/` | 37+ skill definitions (`SKILL.md` per skill), each with YAML frontmatter defining triggers and behavior |
| `agents/` | Agent prompt definitions (one `.md` per agent, tiered: low/medium/high) |
| `agents/templates/` | Base template and tier instructions for authoring new agents |
| `hooks/hooks.json` | Hook registry — maps Claude Code lifecycle events to scripts |
| `scripts/` | Node.js hook scripts executed at runtime by Claude Code hooks |
| `templates/rules/` | Rule templates users copy to their project's `.claude/rules/` |

## Scripts (Hook Execution)

All hook scripts are Node.js ESM (`.mjs`) or CJS (`.cjs`), no build step required at runtime:

| Script | Hook | Purpose |
|--------|------|---------|
| `session-start.mjs` | `SessionStart` | Restores persistent mode, counts pending todos, checks HUD |
| `keyword-detector.mjs` | `UserPromptSubmit` | Detects magic keywords (ulw, ralph, eco, etc.) |
| `skill-injector.mjs` | `UserPromptSubmit` | Injects skill content into context |
| `pre-tool-enforcer.mjs` | `PreToolUse` | Enforces path-based write delegation rules |
| `permission-handler.mjs` | `PermissionRequest` | Handles Bash permission requests |
| `post-tool-verifier.mjs` | `PostToolUse` | Post-tool checks |
| `subagent-tracker.mjs` | `SubagentStart`/`SubagentStop` | Tracks active subagents |
| `pre-compact.mjs` | `PreCompact` | Captures state before context compaction |
| `persistent-mode.cjs` | `Stop` | Persists active mode across sessions |
| `session-end.mjs` | `SessionEnd` | Session cleanup |

## Skill Authoring

Each skill lives at `skills/<name>/SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name
description: Brief description
triggers:
  - "keyword1"
agent: executor   # optional
model: sonnet     # optional
---
```

When adding a new skill, also:
1. Create a corresponding `commands/<name>.md` mirror (if applicable)
2. Update `docs/REFERENCE.md` skill count
3. If an execution mode skill, add a hook in `src/hooks/<name>/`

## Agent Authoring

Agents use the template system in `agents/templates/`:
- `base-agent.md` — standard structure with `{{PLACEHOLDER}}` injection points
- `tier-instructions.md` — LOW (haiku), MEDIUM (sonnet), HIGH (opus) behavioral rules

Three tiers per agent type: `<name>-low.md`, `<name>.md` (medium), `<name>-high.md`.

## Build Step (Skill Bridge Only)

The learner skill requires a compiled bundle:

```bash
node scripts/build-skill-bridge.mjs
# Output: dist/hooks/skill-bridge.cjs
```

Uses `esbuild` to bundle `src/hooks/learner/bridge.ts` → CJS for use by `skill-injector.mjs`.

## Documentation Composition

Docs are composed from partials using `{{INCLUDE:path}}` template syntax:

```bash
node scripts/compose-docs.mjs
# Input:  docs/templates/*.template.md + docs/partials/
# Output: docs/*.md and docs/shared/
```

## Testing Scripts

Ad-hoc integration tests (run directly with `node`):

```bash
node scripts/test-session-injection.ts
node scripts/test-notepad-integration.ts
node scripts/test-mutual-exclusion.ts
node scripts/test-remember-tags.ts
node scripts/test-max-attempts.ts
node scripts/sync-metadata.ts
```

## Mode Hierarchy

```
autopilot
└── ralph (persistence + verification loop)
    └── ultrawork (parallel execution)
        └── ecomode (token-efficient model routing, modifier only)
```

`ecomode` is a modifier — it changes model selection, not execution behavior. When both `ecomode` and another explicit mode keyword appear, `ecomode` wins.
