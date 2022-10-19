#!/bin/sh

# check required tools
if !hash newman 2>/dev/null; then
    echo  '`newman` not installed.'
    exit 1
fi
if !hash jq 2>/dev/null; then
    echo  '`jq` not installed. Needed for parsing JSON.'
    exit 1
fi
if !hash curl 2>/dev/null; then
    echo  '`curl` not installed. Needed for syncing with Postman.'
    exit 1
fi

# check parameter input
if [ -z "$1" ]; then
    echo 'No api key found. => ./run-testing.sh [API_KEY] [COLLECTION_ID] [ENVIRONMENT_ID] [BUILD_NUMBER]'
    exit 1
fi
if [ -z "$2" ]; then
    echo 'No collection ID. => ./run-testing.sh [API_KEY] [COLLECTION_ID] [ENVIRONMENT_ID] [BUILD_NUMBER]'
    exit 1
fi
if [ -z "$3" ]; then
    echo 'No environment ID. => ./run-testing.sh [API_KEY] [COLLECTION_ID] [ENVIRONMENT_ID] [BUILD_NUMBER]'
    exit 1
fi

# set url
collection_url="https://api.getpostman.com/collections/$2?apikey=$1"
environment_url="https://api.getpostman.com/environments/$3?apikey=$1"
newman run $collection_url --environment $environment_url --export-environment newenv.json -r htmlextra --reporter-htmlextra-export report-"$4".html --reporter-htmlextra-logs

# convert newenv for update env in postman
cat newenv.json | jq -r '{ "environment": { "name": .name|tostring,
    "values": [
    .values[] | {
        "key": .key,
        "value": .value|tostring,
        "type": .value|type
    }
] } }' > updatedenv.json

# sync variable to postman
curl --location --request PUT $environment_url --header 'Content-Type: application/json' -d @updatedenv.json
