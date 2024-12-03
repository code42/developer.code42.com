#!/bin/bash

main() {
    local docs="${1:?Missing param docs at index 1.}"
    TMP=.transform.tmp

    echo "Applying transformations..."

    ### Alerts
    ALERTS="${docs}/alerts"
    echo "Transforming Alerts docs..."
    # deprecate alert API query rules endpoint
    jq '.paths[][] |= if .tags == [ "Rules" ] then .deprecated = true else . end' < $ALERTS > $TMP && mv $TMP $ALERTS
    jq '.paths[][].tags[] |= if . == "Rules" then "Alerts" else . end' < $ALERTS > $TMP && mv $TMP $ALERTS
    api-spec-converter -f swagger_2 -t openapi_3 -s json -c $ALERTS > ${docs}/alerts.json
    rm "$ALERTS"

    ### Authority
    AUTHORITY="${docs}/authority.json"
    echo "Transforming Authority docs..."
    ### OPENAPI 3 ###
    jq '.components.schemas |= with_entries( if .key == "File" then .key |= "AuthorityFile" else . end)' < ${docs}/authority > $AUTHORITY
    jq '.components.schemas.RestoreGroup.properties.files.items."$ref" |= "#/components/schemas/AuthorityFile"' < $AUTHORITY > $TMP && mv $TMP $AUTHORITY
    rm ${docs}/authority

    ### File Events
    FILE_EVENTS="${docs}/file-events.json"
    echo "Transforming File Events docs..."
    # prefix v1 summary fields with "v1" and mark as deprecated
    jq '.paths |= with_entries( if .key | contains("v1") then .value[].summary  |= "v1 - \(.)" else . end)' < ${docs}/file-events > $FILE_EVENTS
    jq '.paths |= with_entries( if .key | contains("v1") then .value[].deprecated |= true else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
    # prefix v2 summary fields with "v2"
    jq '.paths |= with_entries( if .key | contains("v2") then (if .value.post? then .value.post.summary |= "v2 - \(.)" else .value.get.summary |= "v2 - \(.)" end) else . end)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
    # order v2 events before v1
    jq '.paths |= (to_entries | [_nwise(.; 5)] | reverse | flatten | from_entries)' < $FILE_EVENTS > $TMP && mv $TMP $FILE_EVENTS
    rm ${docs}/file-events

    ### Alert Rules v1
    RULES_V1="${docs}/alert-rules"
    echo "Transforming Alert Rule v1 docs..."
    # prefix summary fields with "v1"
    jq '.paths[][].summary |= "v1 - \(.)"' < $RULES_V1 > $TMP && mv $TMP $RULES_V1
    # mark v1 endpoints as deprecated
    jq '.paths[][].deprecated = true'< $RULES_V1 > $TMP && mv $TMP $RULES_V1
    api-spec-converter -f swagger_2 -t openapi_3 -s json -c $RULES_V1 > ${docs}/alert-rules-v1.json
    rm "$RULES_V1"

    ### Alert Rules v2
    RULES_V2="${docs}/alert-rules-v2"
    echo "Transforming Alert Rule v2 docs..."
    # mark rules summary fields with "v2"
    jq '.paths[][].summary |= "v2 - \(.)"' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
    # hide add-users
    jq 'del(.paths."/v2/alert-rules/{id}/users".post)' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
    # hide remove-users
    jq 'del(.paths."/v2/alert-rules/{id}/remove-users")' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
    # hide remove-user-aliases
    jq 'del(.paths."/v2/alert-rules/{id}/remove-user-aliases")' < $RULES_V2 > $TMP && mv $TMP $RULES_V2
    api-spec-converter -f swagger_2 -t openapi_3 -s json -c $RULES_V2 > ${docs}/alert-rules-v2.json
    rm "$RULES_V2"

    ### Actors
    ACTORS="${docs}/actor-enrichment-service"
    echo "Transforming Actor docs..."
    # rename tags
    jq '.paths[][].tags[] |= if . == "actor-api-controller" then "Actors"  else . end' < $ACTORS > $TMP && mv $TMP $ACTORS
    mv $ACTORS ${docs}/actors.json
}

main "$@"
