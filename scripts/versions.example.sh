# Version pin exports for CI/local runs
# Copy this file to scripts/versions.sh and adjust versions as needed.
# This file will be sourced by the workflow to export variables into the environment.

set -euo pipefail

# Node.js version pin. Prefer .nvmrc in the repo; if unset here, .nvmrc will be used.
# Keep in sync with .nvmrc if you set it here.
export NODE_VERSION_PIN="22.18.0"

# Package managers / runtimes (set as needed)
# export PNPM_VERSION="9.12.0"
# export YARN_VERSION="1.22.22"
# export BUN_VERSION="1.1.20"
# export DENO_VERSION="1.45.3"

# Tooling examples (uncomment and set as appropriate for your repo)
# export AZD_VERSION="1.9.3"
# export GH_VERSION="2.60.1"
# export JQ_VERSION="1.7.1"

# Add any additional version pins your setup script reads, e.g.:
# export PYTHON_VERSION_PIN="3.12.5"
# export GO_VERSION_PIN="1.22.5"
