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

# convert newenv for update env in postman
cat newenv.json | jq -r '{ "environment": { "name": .name|tostring,
    "values": [
    .values[] | {
        "key": .key,
        "value": .value|tostring,
        "type": .value|type
    }
] } }' > updatedenv.json
