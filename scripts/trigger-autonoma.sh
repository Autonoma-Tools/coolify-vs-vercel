#!/usr/bin/env bash
# trigger-autonoma.sh
#
# Triggers an Autonoma E2E test suite run against a preview URL, polls for
# completion, and exits 0 on pass / 1 on fail so GitHub Actions can propagate
# the status to the PR check.
#
# Usage:
#   ./scripts/trigger-autonoma.sh "https://pr-123.preview.example.com"
#
# Required env vars:
#   AUTONOMA_API_KEY   API key for the Autonoma REST API
#   AUTONOMA_SUITE_ID  ID of the test suite to execute
#
# Optional env vars:
#   AUTONOMA_API_URL   Base URL for the Autonoma API (default: https://api.getautonoma.com)
#   POLL_INTERVAL      Seconds between status polls (default: 15)
#   POLL_TIMEOUT       Total seconds before giving up (default: 1800 = 30 min)

set -euo pipefail

PREVIEW_URL="${1:-}"

if [[ -z "${PREVIEW_URL}" ]]; then
  echo "Error: PREVIEW_URL is required as the first argument." >&2
  echo "Usage: $0 <preview-url>" >&2
  exit 2
fi

if [[ -z "${AUTONOMA_API_KEY:-}" ]]; then
  echo "Error: AUTONOMA_API_KEY env var is required." >&2
  exit 2
fi

if [[ -z "${AUTONOMA_SUITE_ID:-}" ]]; then
  echo "Error: AUTONOMA_SUITE_ID env var is required." >&2
  exit 2
fi

AUTONOMA_API_URL="${AUTONOMA_API_URL:-https://api.getautonoma.com}"
POLL_INTERVAL="${POLL_INTERVAL:-15}"
POLL_TIMEOUT="${POLL_TIMEOUT:-1800}"

echo "Triggering Autonoma suite ${AUTONOMA_SUITE_ID} against ${PREVIEW_URL}..."

TRIGGER_RESPONSE="$(
  curl --silent --show-error --fail \
    --request POST \
    --url "${AUTONOMA_API_URL}/v1/suites/${AUTONOMA_SUITE_ID}/runs" \
    --header "Authorization: Bearer ${AUTONOMA_API_KEY}" \
    --header "Content-Type: application/json" \
    --data "$(printf '{"target_url":"%s"}' "${PREVIEW_URL}")"
)"

RUN_ID="$(printf '%s' "${TRIGGER_RESPONSE}" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"

if [[ -z "${RUN_ID}" ]]; then
  echo "Error: could not parse run ID from Autonoma response." >&2
  echo "Response was:" >&2
  echo "${TRIGGER_RESPONSE}" >&2
  exit 1
fi

echo "Autonoma run started: ${RUN_ID}"
echo "Polling for completion (every ${POLL_INTERVAL}s, timeout ${POLL_TIMEOUT}s)..."

ELAPSED=0
while (( ELAPSED < POLL_TIMEOUT )); do
  STATUS_RESPONSE="$(
    curl --silent --show-error --fail \
      --request GET \
      --url "${AUTONOMA_API_URL}/v1/runs/${RUN_ID}" \
      --header "Authorization: Bearer ${AUTONOMA_API_KEY}"
  )"

  STATUS="$(printf '%s' "${STATUS_RESPONSE}" | sed -n 's/.*"status"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1)"

  echo "[$(date -u +%H:%M:%SZ)] run ${RUN_ID} status=${STATUS}"

  case "${STATUS}" in
    passed|success)
      echo "Autonoma tests passed."
      exit 0
      ;;
    failed|error|timed_out)
      echo "Autonoma tests failed (status=${STATUS})."
      echo "Full response:"
      echo "${STATUS_RESPONSE}"
      exit 1
      ;;
    queued|running|pending|"")
      sleep "${POLL_INTERVAL}"
      ELAPSED=$(( ELAPSED + POLL_INTERVAL ))
      ;;
    *)
      echo "Unknown status '${STATUS}' — treating as transient and continuing to poll."
      sleep "${POLL_INTERVAL}"
      ELAPSED=$(( ELAPSED + POLL_INTERVAL ))
      ;;
  esac
done

echo "Timed out after ${POLL_TIMEOUT}s waiting for Autonoma run ${RUN_ID} to complete." >&2
exit 1
