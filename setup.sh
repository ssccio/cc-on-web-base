#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Ensure ~/.claude exists
mkdir -p "${HOME}/.claude"

# 2. Initialize settings.json with {} if it doesn't exist
if [ ! -f "${HOME}/.claude/settings.json" ]; then
  echo '{}' > "${HOME}/.claude/settings.json"
fi

# 3. System update + install dependencies
apt-get update
apt-get upgrade -y
apt-get install -y jq curl unzip tar

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp/awscliv2
/tmp/awscliv2/aws/install
rm -rf /tmp/awscliv2.zip /tmp/awscliv2

# Install oc (OpenShift client)
curl -L "https://github.com/okd-project/okd/releases/download/4.21.0-okd-scos.6/openshift-client-linux-amd64-rhel9-4.21.0-okd-scos.6.tar.gz" \
#curl -L "https://github.com/okd-project/okd/releases/download/4.21.0-okd-scos.6/openshift-client-linux-arm64-rhel9-4.21.0-okd-scos.6.tar.gz" \
  -o /tmp/oc.tar.gz
tar -xzf /tmp/oc.tar.gz -C /usr/local/bin oc
rm /tmp/oc.tar.gz

# 4. Merge hooks, env, attribution, and permissions into settings.json
jq -s '.[0] * {"hooks": .[1].hooks} * {env: .[2].env, attribution: .[2].attribution, permissions: .[2].permissions}' \
  "${HOME}/.claude/settings.json" \
  "${SCRIPT_DIR}/hooks/hooks.json" \
  "${SCRIPT_DIR}/settings.json" \
  > "${HOME}/.claude/settings.json.tmp" \
  && mv "${HOME}/.claude/settings.json.tmp" "${HOME}/.claude/settings.json"

# 5. Copy content directories into ~/.claude/
cp -r "${SCRIPT_DIR}/skills" "${HOME}/.claude/skills"
cp -r "${SCRIPT_DIR}/scripts" "${HOME}/.claude/scripts"
cp -r "${SCRIPT_DIR}/agents" "${HOME}/.claude/agents"
cp -r "${SCRIPT_DIR}/templates" "${HOME}/.claude/templates"

# 6. Copy MCP server configuration
cp "${SCRIPT_DIR}/mcp.json" "${HOME}/.mcp.json"
