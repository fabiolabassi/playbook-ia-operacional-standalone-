#!/usr/bin/env bash
set -euo pipefail

: "${OPENAI_API_KEY:?Configure OPENAI_API_KEY no ambiente.}"
: "${GOOGLE_API_KEY:?Configure GOOGLE_API_KEY no ambiente.}"

mkdir -p results
for config in devops/*/promptfooconfig.yaml; do
  name="$(basename "$(dirname "$config")")"
  echo "Avaliando $name"
  npx --yes promptfoo@0.125.1 eval \
    -c "$config" \
    --no-cache \
    --no-progress-bar \
    -o "results/$name.json"
done
