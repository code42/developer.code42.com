#!/bin/bash

set -euo pipefail

main() {
  local docs_src="${1:?Missing parameter docs_src at index 1.}"
  local build="${2:?Missing parameter build at index 2.}"
  local docs="${3:?Missing parameter docs at index 3}"
  local docs_out="${4:?Missing parameter docs_out at index 4}"
  rm -rf ${docs_src}
  rm -f ${build}/code42api.json
  mkdir -p ${docs} ${docs_out}
}

main "$@"
