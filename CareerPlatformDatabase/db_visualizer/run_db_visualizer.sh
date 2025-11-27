#!/usr/bin/env bash
set -euo pipefail

# Guard: disable running inside DB container unless explicitly allowed.
if [[ "${DB_CONTAINER_MODE:-}" == "1" && "${ALLOW_DB_VISUALIZER_IN_CONTAINER:-}" != "1" ]]; then
  echo "Database visualizer is disabled in database container mode."
  echo "To run it manually inside this container, set ALLOW_DB_VISUALIZER_IN_CONTAINER=1 and re-run."
  exit 2
fi

# Optional helper to run the local DB visualizer.
# This script installs dependencies (if missing) and starts the server.

# When explicitly allowed inside container, allow lifecycle scripts for native deps.
if [[ "${ALLOW_DB_VISUALIZER_IN_CONTAINER:-}" == "1" ]]; then
  unset NPM_CONFIG_IGNORE_SCRIPTS || true
  export NPM_CONFIG_IGNORE_SCRIPTS=false
  unset YARN_IGNORE_SCRIPTS || true
  export YARN_IGNORE_SCRIPTS=false
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# Ensure Node is available
if ! command -v node >/dev/null 2>&1; then
  echo "Error: Node.js is not installed or not in PATH." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "Error: npm is not installed or not in PATH." >&2
  exit 1
fi

# Install dependencies if node_modules is missing or empty
if [ ! -d "node_modules" ] || [ -z "$(ls -A node_modules 2>/dev/null || true)" ]; then
  echo "Installing npm dependencies for db_visualizer..."
  npm ci || npm install
else
  echo "Dependencies already present. Skipping install."
fi

# Load postgres.env if present
if [ -f "./postgres.env" ]; then
  # shellcheck disable=SC1091
  source ./postgres.env
fi

echo "Starting database visualizer on http://localhost:3000 ..."
npm start
