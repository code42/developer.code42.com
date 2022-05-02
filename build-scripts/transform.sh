#!/bin/bash

main() {
  local docs="${1:?Missing param docs at index 1.}"
  TMP=.transform.tmp
  TRUSTED_ACTIVITIES_V1="${docs}/trusted-activities"
  TRUSTED_ACTIVITIES_V2="${docs}/trusted-activities.json"
  WATCHLISTS="${docs}/watchlists.json"

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

  ### Watchlists
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/watchlists.yaml > $WATCHLISTS
  # rename UserRiskProfileService tags
  jq '(.paths[][] | select(.tags == ["UserRiskProfileService"]) | .tags) |= ["User Risk Profiles"]' < $WATCHLISTS > $TMP && mv $TMP $WATCHLISTS
  # rename WatchlistsService tags
  jq '(.paths[][] | select(.tags == ["WatchlistService"]) | .tags) |= ["Watchlists"]' < $WATCHLISTS > $TMP && mv $TMP $WATCHLISTS

}

main "$@"
