#!/bin/bash

main() {
  local docs="${1:?Missing param docs at index 1.}"
  echo "Applying transformations..."
  # mark trusted-activities summary fields with "v1" and "v2" accordingly
  jq '.paths[][].summary |= "v1 - \(.)"' < ${docs}/trusted-activities > ${docs}/transform.tmp && mv ${docs}/transform.tmp ${docs}/trusted-activities
  jq '.paths[][].summary |= "v2 - \(.)"' < ${docs}/trusted-activities.json > ${docs}/transform.tmp && mv ${docs}/transform.tmp ${docs}/trusted-activities.json
  # mark trusted-activities v1 endpoints as deprecated
  jq '.paths[][].deprecated = true' < ${docs}/trusted-activities > ${docs}/transform.tmp && mv ${docs}/transform.tmp ${docs}/trusted-activities
}

main "$@"
