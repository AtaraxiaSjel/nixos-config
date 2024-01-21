#!/usr/bin/env bash
set -euo pipefail

args=(
  "$@"
  --accept-flake-config
  --gc-roots-dir gcroot
  --max-memory-size "2048"
  --option allow-import-from-derivation true
  --show-trace
  --workers 4
)

if [[ -n "${GITHUB_STEP_SUMMARY-}" ]]; then
  log() {
    echo "$*" >> "$GITHUB_STEP_SUMMARY"
  }
else
  log() {
    echo "$*"
  }
fi

eval_error=0

for job in $(nix-eval-jobs "${args[@]}" | jq -r '. | @base64'); do
  job=$(echo "$job" | base64 -d)
  attr=$(echo "$job" | jq -r .attr)
  echo "### $attr"
  error=$(echo "$job" | jq -r .error)
  if [[ $error != null ]]; then
    log "### ❌ $attr"
    log
    log "<details><summary>Eval error:</summary><pre>"
    log "$error"
    log "</pre></details>"
    eval_error=1
  else
    log "### ✅ $attr"
  fi
done

exit $eval_error
