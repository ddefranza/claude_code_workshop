#!/bin/bash
set -e

# Install system packages (skip if pandoc already installed)
if ! command -v pandoc &> /dev/null; then
  echo "Installing pandoc..."
  sudo apt-get update
  sudo apt-get install -y pandoc
else
  echo "pandoc already installed, skipping."
fi

# Register Semantic Scholar MCP server (skip if already registered)
if ! claude mcp get semantic-scholar &> /dev/null; then
  echo "Registering Semantic Scholar MCP server..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  claude mcp add semantic-scholar -s project -- uvx --from git+https://github.com/akapet00/semantic-scholar-mcp semantic-scholar-mcp
else
  echo "Semantic Scholar MCP already registered, skipping."
fi

echo "✅ Setup complete. Open a terminal and run 'claude' to get started."