#!/bin/bash

main() {
  local docs="${1:?Missing param docs at index 1.}"
  TMP=.transform.tmp
  ALERTS="${docs}/alerts"
  RULES_V1="${docs}/alert-rules"
  RULES_V2="${docs}/alert-rules-v2"
  TRUSTED_ACTIVITIES_V2="${docs}/trusted-activities.json"
  WATCHLISTS="${docs}/watchlists.json"
  FILE_EVENTS="${docs}/file-events.json"

  echo "Applying transformations..."

  ### Audit log
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/audit-log.yaml > ${docs}/audit
  jq '.paths |= with_entries( .key |= gsub("/rpc/search/"; "/v1/audit/") )' < ${docs}/audit > $TMP && mv $TMP ${docs}/audit
  jq '.paths[][].tags |= [ "Audit Log" ]' < ${docs}/audit > $TMP && mv $TMP ${docs}/audit

  ### Trusted Activities v2
  # Remove static TA v2 docs until we can swap over baldur
  rm "${docs}/trusted-activities.yaml"
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/trusted-activities > $TRUSTED_ACTIVITIES_V2
  # rename tags
  jq '.paths[][].tags |= [ "Trusted Activities" ]' < $TRUSTED_ACTIVITIES_V2 > $TMP && mv $TMP $TRUSTED_ACTIVITIES_V2
  # mark trusted-activities summary fields with "v1" and "v2" accordingly
  jq '.paths[][].summary |= "v2 - \(.)"' < $TRUSTED_ACTIVITIES_V2 > $TMP && mv $TMP $TRUSTED_ACTIVITIES_V2

  ### File Events
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/file-events > $FILE_EVENTS
  # prefix v1 summary fields with "v1" and mark as deprecated
  jq '.paths |= with_entries( if .key | contains("v1") then .value[].summary  |= "v1 - \(.)" else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
  jq '.paths |= with_entries( if .key | contains("v1") then .value[].deprecated |= true else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
   # prefix v2 summary fields with "v2"
  jq '.paths |= with_entries( if .key | contains("v2") then (if .value.post? then .value.post.summary |= "v2 - \(.)" else .value.get.summary |= "v2 - \(.)" end) else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
  # order v2 events before v1
  jq '.paths |= (to_entries | [_nwise(.; 5)] | reverse | flatten | from_entries)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
  rm ${docs}/file-events
  mv $FILE_EVENTS ${docs}/file-events

  ### Alert Rules v1
  # prefix summary fields with "v1"
  jq '.paths[][].summary |= "v1 - \(.)"' < $RULES_V1 > $TMP && mv $TMP $RULES_V1
  # mark v1 endpoints as deprecated
  jq '.paths[][].deprecated = true'< $RULES_V1 > $TMP && mv $TMP $RULES_V1
  # deprecate alert API query rules endpoint
  jq '.paths[][] |= if .tags == [ "Rules" ] then .deprecated = true else . end' < $ALERTS > $TMP && mv $TMP $ALERTS
  jq '.paths[][].tags[] |= if . == "Rules" then "Alerts" else . end' < $ALERTS > $TMP && mv $TMP $ALERTS

  ### Alert Rules v2
  # mark rules summary fields with "v2"
  jq '.paths[][].summary |= "v2 - \(.)"' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
  # hide add-users
  jq 'del(.paths."/v2/alert-rules/{id}/users".post)' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
  # hide remove-users
  jq 'del(.paths."/v2/alert-rules/{id}/remove-users")' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
  # hide remove-user-aliases
  jq 'del(.paths."/v2/alert-rules/{id}/remove-user-aliases")' < $RULES_V2 > $TMP && mv $TMP $RULES_V2

  ### Watchlists
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/watchlists.yaml > $WATCHLISTS
  # rename tags
  jq '.paths[][].tags[] |=
  if . == "WatchlistService" then "Watchlists"
  elif . == "UserRiskProfileService" then "User Risk Profiles"
  elif . == "DepartmentsService" then "Departments"
  elif . == "DirectoryGroupsService" then "Directory Groups"
  else .
  end' < $WATCHLISTS > $TMP && mv $TMP $WATCHLISTS
}

main "$@"
