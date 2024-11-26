#!/bin/bash

main() {
  local docs="${1:?Missing param docs at index 1.}"
  TMP=.transform.tmp
  ALERTS="${docs}/alerts"
  AUTHORITY="${docs}/authority.json"
  RULES_V1="${docs}/alert-rules"
  RULES_V2="${docs}/alert-rules-v2"
  TRUSTED_ACTIVITIES_V2="${docs}/trusted-activities.json"
  FILE_EVENTS="${docs}/file-events.json"
  CASES="${docs}/cases.json"
  ACTORS="${docs}/actors.json"

  echo "Applying transformations..."

  ### Audit log
  echo "Transforming Audit Log docs..."
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/audit > ${docs}/audit.json
  rm ${docs}/audit

  ### Authority
  echo "Transforming Authority docs..."
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/authority > $AUTHORITY
  # The authority's File component schema overwrites FFS', rename it
  ### SWAGGER 2 ###
  jq '.definitions |= with_entries( if .key == "File" then .key |= "AuthorityFile" else . end)' < $AUTHORITY > $TMP && mv $TMP $AUTHORITY
  jq '.definitions.RestoreGroup.properties.files.items."$ref" |= "#/definitions/AuthorityFile"' < $AUTHORITY > $TMP && mv $TMP $AUTHORITY

  ### OPENAPI 3 ###
#  jq '.components.schemas |= with_entries( if .key == "File" then .key |= "AuthorityFile" else . end)' < ${docs}/authority > $AUTHORITY
#  jq '.components.schemas.RestoreGroup.properties.files.items."$ref" |= "#/components/schemas/AuthorityFile"' < $AUTHORITY > $TMP && mv $TMP $AUTHORITY

  rm ${docs}/authority

  ### Trusted Activities v2
  echo "Transforming Trusted Activities docs..."
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/trusted-activities > $TRUSTED_ACTIVITIES_V2
  rm "${docs}/trusted-activities"

  ### File Events
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/file-events > $FILE_EVENTS
  echo "Transforming File Events docs..."
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
  echo "Transforming Alert Rule v1 docs..."
  # prefix summary fields with "v1"
  jq '.paths[][].summary |= "v1 - \(.)"' < $RULES_V1 > $TMP && mv $TMP $RULES_V1
  # mark v1 endpoints as deprecated
  jq '.paths[][].deprecated = true'< $RULES_V1 > $TMP && mv $TMP $RULES_V1
  # deprecate alert API query rules endpoint
  jq '.paths[][] |= if .tags == [ "Rules" ] then .deprecated = true else . end' < $ALERTS > $TMP && mv $TMP $ALERTS
  jq '.paths[][].tags[] |= if . == "Rules" then "Alerts" else . end' < $ALERTS > $TMP && mv $TMP $ALERTS

  ### Alert Rules v2
  echo "Transforming Alert Rule v2 docs..."
  # mark rules summary fields with "v2"
  jq '.paths[][].summary |= "v2 - \(.)"' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
  # hide add-users
  jq 'del(.paths."/v2/alert-rules/{id}/users".post)' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
  # hide remove-users
  jq 'del(.paths."/v2/alert-rules/{id}/remove-users")' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
  # hide remove-user-aliases
  jq 'del(.paths."/v2/alert-rules/{id}/remove-user-aliases")' < $RULES_V2 > $TMP && mv $TMP $RULES_V2

  ## Sessions
  echo "Transforming Sessions docs..."
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/sessions > "${docs}/sessions.json"
  rm ${docs}/sessions

  ### Watchlists
  echo "Transforming Department docs..."
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/departments > "${docs}/departments.json"
  rm ${docs}/departments
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/directory-groups > "${docs}/directory-groups.json"
  rm ${docs}/directory-groups
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/watchlists > "${docs}/watchlists.json"
  rm ${docs}/watchlists
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/risk-profiles > "${docs}/risk-profiles.json"
  rm ${docs}/risk-profiles

  # set update-risk-profile PATCH description
  echo "Transforming Risk Profile docs..."
  jq '.paths."/v2/actor-risk-profiles/{actor_id}".patch.description |= {"$ref": "./api-descriptions/user_risk_profile_patch.rmd"}' < "${docs}/risk-profiles.json" > $TMP && mv $TMP "${docs}/risk-profiles.json"

  ### Cases
  echo "Transforming Cases docs..."
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/cases > $CASES
  rm ${docs}/cases
  mv $CASES ${docs}/cases

  ### Actors
  echo "Transforming Actor docs..."
  # convert openapi 3 yaml to swagger 2 json
  api-spec-converter -f openapi_3 -t swagger_2 -c ${docs}/actor-enrichment-service > $ACTORS
  rm ${docs}/actor-enrichment-service
  # rename tags
  jq '.paths[][].tags[] |=
  if . == "actor-api-controller" then "Actors"  else .
  end' < $ACTORS > $TMP && mv $TMP $ACTORS
  mv $ACTORS ${docs}/actors
}

main "$@"
