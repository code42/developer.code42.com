#!/bin/bash
set -eu

BUILD=build
DOCS=$BUILD/docs
OUT=$DOCS/out
PUBLISH=publish
SANDBOX=$PUBLISH/sandbox

DOCS_SERVER="https://default-api.core-int.cloud.code42.com"

rm -rf $BUILD
rm -f $SANDBOX/code42api.json
mkdir -p $OUT

# get the list of all swagger file locations
DOCS_ENDPOINTS=$(curl $DOCS_SERVER/api/docs-index/v1 | jq -r .services[].location)
printf "%s\n" "$DOCS_ENDPOINTS" > $BUILD/docs_endpoints.txt
sed -i -e "s~^~$DOCS_SERVER~" $BUILD/docs_endpoints.txt

# download all of the swagger files into the $DOCS directory
wget -i $BUILD/docs_endpoints.txt -P $DOCS

# grab all the paths and definitions from every swagger file that was found
jq -s '.[].paths' $DOCS/* | jq -s add > $BUILD/paths.json
jq -s '.[].definitions' $DOCS/* | jq -s add > $BUILD/defs.json

# append all of the found paths and definitions into a single swagger file
jq '.paths |= $paths' --argfile paths $BUILD/paths.json swagger_template.json > $BUILD/merged_paths.json
jq '.definitions |= $defs' --argfile defs $BUILD/defs.json $BUILD/merged_paths.json > $OUT/code42api.json

# put the merged file into the directory for publising
cp $OUT/code42api.json $SANDBOX