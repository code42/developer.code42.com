#!/bin/bash
BUILD=build
DOCS=$BUILD/docs
OUT=$DOCS/out

DOCS_SERVER="http://localhost:5000"

rm -rf $BUILD
mkdir -p $OUT

DOCS_ENDPOINTS=$(curl $DOCS_SERVER/api/docs-index | jq -r .services[].location)
printf "%s\n" "$DOCS_ENDPOINTS" > $BUILD/docs_endpoints.txt
sed -i -e "s~^~$DOCS_SERVER~" $BUILD/docs_endpoints.txt
wget -i $BUILD/docs_endpoints.txt -P $DOCS

jq -s '.[].paths' $DOCS/* | jq -s add > $BUILD/paths.json
jq -s '.[].definitions' $DOCS/* | jq -s add > $BUILD/defs.json

jq '.paths |= $paths' --argfile paths $BUILD/paths.json template.json > $BUILD/merged_paths.json
jq '.definitions |= $defs' --argfile defs $BUILD/defs.json $BUILD/merged_paths.json > $OUT/code42api.json