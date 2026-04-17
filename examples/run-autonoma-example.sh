#!/usr/bin/env bash
# examples/run-autonoma-example.sh
#
# End-to-end demo of scripts/trigger-autonoma.sh against a URL of your choice.
# Mirrors what the GitHub Actions workflow does in its final step, so you can
# iterate on the Autonoma integration locally before wiring it into CI.
#
# Usage:
#   export AUTONOMA_API_KEY=sk_live_xxx
#   export AUTONOMA_SUITE_ID=suite_abc123
#   ./examples/run-autonoma-example.sh https://pr-123.preview.example.com
#
# Optional:
#   export AUTONOMA_API_URL=https://api.getautonoma.com
#   export POLL_INTERVAL=15
#   export POLL_TIMEOUT=1800

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TRIGGER="${REPO_ROOT}/scripts/trigger-autonoma.sh"

PREVIEW_URL="${1:-}"

if [[ -z "${PREVIEW_URL}" ]]; then
  echo "Usage: $0 <preview-url>" >&2
  echo "Example: $0 https://pr-123.preview.example.com" >&2
  exit 2
fi

if [[ ! -x "${TRIGGER}" ]]; then
  echo "Making ${TRIGGER} executable..."
  chmod +x "${TRIGGER}"
fi

echo "Running Autonoma suite against ${PREVIEW_URL}..."
echo "  AUTONOMA_API_URL=${AUTONOMA_API_URL:-https://api.getautonoma.com}"
echo "  AUTONOMA_SUITE_ID=${AUTONOMA_SUITE_ID:-<unset>}"
echo

if "${TRIGGER}" "${PREVIEW_URL}"; then
  echo
  echo "Autonoma run passed — in CI this would leave the PR check green."
  exit 0
else
  status=$?
  echo
  echo "Autonoma run failed with exit code ${status} — in CI this would block the PR merge."
  exit "${status}"
fi
