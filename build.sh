#!/bin/bash
rm -rf build
mkdir -p build/docs/final

DOCS_ENDPOINTS=$(curl http://localhost:5000/api/discovery | jq -r .services[].location)
printf "%s\n" "$DOCS_ENDPOINTS" > build/docs_endpoints.txt
sed -i -e 's/^/http\:\/\/localhost\:5000/' build/docs_endpoints.txt
wget -i build/docs_endpoints.txt -P build/docs

jq -s '.[].paths' build/docs/* | jq -s add > build/docs/final/paths.json
jq -s '.[].definitions' build/docs/* | jq -s add > build/docs/final/definitions.json

jq '.paths |= $paths' --argfile paths build/docs/final/paths.json template.json > build/docs/final/paths_only.json
jq '.definitions |= $schemas' --argfile schemas build/docs/final/definitions.json build/docs/final/paths_only.json > build/docs/final/code42api.json