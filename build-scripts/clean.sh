#!/bin/bash

set -e

main() {
  local docs_src="${1:?Missing parameter docs_src at index 1.}"
  local sandbox="${2:?Missing parameter sandbox at index 2.}"
  local docs="${3:?Missing parameter docs at index 3}"
  local docs_out="${4:?Missing parameter docs_out at index 4}"
  rm -rf ${docs_src}
  rm -f ${sandbox}/code42api.json
  mkdir -p ${docs} ${docs_out}
}

main "$@"
