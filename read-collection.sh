#!/bin/sh

cat newenv.json | jq -r '{ "environment": { "name": .name|tostring,
    "values": [
    .values[] | {
        "key": .key,
        "value": .value|tostring,
        "type": .value|type
    }
] } }' > updatedenv.json
