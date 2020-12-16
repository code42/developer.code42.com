#!/bin/bash

set -euo pipefail

main () {
  local docs_server="${1:?Missing param docs_server at index 1.}"
  local docs_src="${2:?Missing param docs_src at index 2.}"
  local docs_endpoints=$(curl ${docs_server}/api/docs-index/v1 | jq -r .services[].location)
  printf "%s\n" "${docs_endpoints}" > ${docs_src}/docs_endpoints.txt
  sed -i -e "s~^~${docs_server}~" ${docs_src}/docs_endpoints.txt
}

main "$@"
