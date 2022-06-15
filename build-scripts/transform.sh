#!/bin/bash

main() {
  local docs="${1:?Missing param docs at index 1.}"
  TMP=.transform.tmp
  TRUSTED_ACTIVITIES_V1="${docs}/trusted-activities"
  TRUSTED_ACTIVITIES_V2="${docs}/trusted-activities.json"
  WATCHLISTS="${docs}/watchlists.json"
  FILE_EVENTS="${docs}/file-events"

  echo "Applying transformations..."

  ### Trusted Activities v1
  # prefix summary fields with "v1"
  jq '.paths[][].summary |= "v1 - \(.)"' < $TRUSTED_ACTIVITIES_V1 > $TMP && mv $TMP $TRUSTED_ACTIVITIES_V1
  # mark v1 endpoints as deprecated
  jq '.paths[][].deprecated = true'< $TRUSTED_ACTIVITIES_V1 > $TMP && mv $TMP $TRUSTED_ACTIVITIES_V1

  ### Trusted Activities v2
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/trusted-activities.yaml > $TRUSTED_ACTIVITIES_V2
  # rename tags
  jq '.paths[][].tags |= [ "Trusted Activities" ]' < $TRUSTED_ACTIVITIES_V2 > $TMP && mv $TMP $TRUSTED_ACTIVITIES_V2
  # mark trusted-activities summary fields with "v1" and "v2" accordingly
  jq '.paths[][].summary |= "v2 - \(.)"' < $TRUSTED_ACTIVITIES_V2 > $TMP && mv $TMP $TRUSTED_ACTIVITIES_V2

  ### File Events
  # prefix v1 summary fields with "v1" and mark as deprecated
  jq '.paths |= with_entries( if .key | contains("v1") then .value[].summary  |= "v1 - \(.)" else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
  jq '.paths |= with_entries( if .key | contains("v1") then .value[].deprecated |= true else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS

   # prefix v2 summary fields with "v2"
  jq '.paths |= with_entries( if .key | contains("v2") then (if .value.post? then .value.post.summary |= "v2 - \(.)" else .value.get.summary |= "v2 - \(.)" end) else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS

  # order v2 events before v1
  jq '.paths |= (to_entries | [_nwise(.; 5)] | reverse | flatten | from_entries)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS

  ### Watchlists
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/watchlists.yaml > $WATCHLISTS
  # rename UserRiskProfileService tags
  jq '(.paths[][] | select(.tags == ["UserRiskProfileService"]) | .tags) |= ["User Risk Profiles"]' < $WATCHLISTS > $TMP && mv $TMP $WATCHLISTS
  # rename WatchlistsService tags
  jq '(.paths[][] | select(.tags == ["WatchlistService"]) | .tags) |= ["Watchlists"]' < $WATCHLISTS > $TMP && mv $TMP $WATCHLISTS

}

main "$@"
