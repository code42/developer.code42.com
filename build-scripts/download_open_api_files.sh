#!/bin/bash

set -e

main() {
  local docs_src="${1:?Missing param docs_src at index 1.}"
  local docs="${2:?Missing param docs at index 2.}"
  echo "fetching OpenAPI documents..."
  wget -i ${docs_src}/docs_endpoints.txt -P ${docs}
}

main "$@"
