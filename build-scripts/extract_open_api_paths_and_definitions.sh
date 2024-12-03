#!/bin/bash

set -euo pipefail

main() {
  local docs="${1:?Missing param docs at index 1.}"
  local docs_src="${2:?Missing param docs_src at index 2.}"
  json_docs=$(find ${docs} \! -name '*.yaml' -type f)
  jq -s '.[].paths' $json_docs | jq -s add > ${docs_src}/paths.json
  jq -s '.[].components.schemas' $json_docs | jq -s add > ${docs_src}/defs.json
}

main "$@"
