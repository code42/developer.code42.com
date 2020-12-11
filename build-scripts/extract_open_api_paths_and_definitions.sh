#!/bin/bash

set -e

main() {
  local docs="${1:?Missing param docs at index 1.}"
  local docs_src="${2:?Missing param docs_src at index 2.}"
  jq -s '.[].paths' ${docs}/* | jq -s add > ${docs_src}/paths.json
  jq -s '.[].definitions' ${docs}/* | jq -s add > ${docs_src}/defs.json
}

main "$@"
