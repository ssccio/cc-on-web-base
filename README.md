# cc-on-web-base

Bootstrap repository for **Claude on Web** — sets up a capable, opinionated Claude Code environment from scratch.

## What This Does

When Claude on Web provisions a fresh environment, it clones this repo and runs `setup.sh` to install the [oh-my-claudecode](https://github.com/oh-my-claudecode/oh-my-claudecode) plugin along with supporting CLI tools.

After setup, the Claude agent has access to:

- **Multi-agent orchestration** via oh-my-claudecode skills and agents
- **37+ skills** (autopilot, ultrawork, ralph, plan, swarm, pipeline, and more)
- **Tiered specialist agents** (executor, architect, designer, researcher, etc.)
- **Claude Code hooks** for automation (keyword detection, skill injection, post-tool checks)
- **AWS CLI v2** for cloud operations
- **`oc` (OpenShift client)** for Kubernetes/OpenShift cluster interaction
- **MCP server configuration** (Context7, Atlassian, grep.app)
- **Pre-configured permissions** for common read-only and operational commands

## Repository Structure

```
.
├── setup.sh          # Bootstrap script — run this to initialize ~/.claude/
├── settings.json     # Claude Code settings (env, permissions, attribution)
├── mcp.json          # MCP server definitions
├── hooks/
│   └── hooks.json    # Claude Code lifecycle hook registry
├── scripts/          # Node.js hook scripts (ESM/CJS, no build step)
├── skills/           # Skill definitions (one SKILL.md per skill)
├── agents/           # Agent prompt definitions (tiered: low/medium/high)
└── templates/        # Rule templates for project .claude/rules/
```

## Bootstrap

```bash
git clone <this-repo>
cd cc-on-web-base
bash setup.sh
```

`setup.sh` will:

1. Create `~/.claude/` if it doesn't exist
2. Initialize `~/.claude/settings.json` (if missing)
3. Install system dependencies: `jq`, `curl`, `unzip`, `tar`
4. Install **AWS CLI v2**
5. Install **`oc`** (OpenShift client binary)
6. Merge hooks, env, permissions, and attribution into `~/.claude/settings.json`
7. Copy skills, scripts, agents, and templates into `~/.claude/`
8. Copy MCP server config to `~/.mcp.json`

## Requirements

- Debian/Ubuntu-based Linux (uses `apt-get`)
- Run as root or with `sudo` (required for `apt-get` and `/usr/local/bin` writes)
