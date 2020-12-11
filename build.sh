#!/bin/bash
set -eu

BUILD=source
if [[ $# -eq 1 && "${1}" == "prod" ]]
then
    BUILD=build
    bundle exec middleman build
fi

DOCS_SRC=docs-src
DOCS=${DOCS_SRC}/docs
DOCS_OUT=${DOCS_SRC}/out

SANDBOX=${BUILD}/sandbox
API_DOCS=${SANDBOX}/api

DOCS_SERVER="https://default-api.core-int.cloud.code42.com"

clean() {
  rm -rf ${DOCS_SRC}
  rm -f ${SANDBOX}/code42api.json
  mkdir -p ${DOCS} ${DOCS_OUT}
}

get_swagger_file_locations() {
  DOCS_ENDPOINTS=$(curl ${DOCS_SERVER}/api/docs-index/v1 | jq -r .services[].location)
  printf "%s\n" "${DOCS_ENDPOINTS}" > $DOCS_SRC/docs_endpoints.txt
  sed -i -e "s~^~${DOCS_SERVER}~" ${DOCS_SRC}/docs_endpoints.txt
}

download_swagger_files() {
  echo "fetching swagger documents..."
  wget -i ${DOCS_SRC}/docs_endpoints.txt -P ${DOCS}
}

extract_swagger_paths_and_definitions() {
  echo "building unified swagger document..."
  jq -s '.[].paths' ${DOCS}/* | jq -s add > ${DOCS_SRC}/paths.json
  jq -s '.[].definitions' ${DOCS}/* | jq -s add > ${DOCS_SRC}/defs.json
}

make_joined_swagger_file() {
  jq '.paths |= $paths' --argfile paths ${DOCS_SRC}/paths.json swagger_template.json > ${DOCS_SRC}/merged_paths.json
  jq '.definitions |= $defs' --argfile defs ${DOCS_SRC}/defs.json ${DOCS_SRC}/merged_paths.json > ${DOCS_OUT}/code42api.json

  # put the merged file into the directory for publishing
  cp ${DOCS_OUT}/code42api.json ${API_DOCS}
  echo "Done."
}

main() {
  clean
  get_swagger_file_locations
  download_swagger_files
  extract_swagger_paths_and_definitions
  make_joined_swagger_file
}

main "$@"
