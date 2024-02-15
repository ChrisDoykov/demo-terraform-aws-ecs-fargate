#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Get the hosted zone name from inputs
eval "$(jq -r '@sh "hosted_zone_name=\(.zone_name)"')"

[ -z "$hoted_zone_name" ] && echo "Hosted Zone Name cannot be null but that's what got passed in!" >&2

# Check if the hosted zone exists
result=$(aws route53 list-hosted-zones-by-name --dns-name "$hosted_zone_name" --max-items 1)

# Extract the hosted zone ID
hosted_zone_id=$(echo "$result" | jq -r '.HostedZones[0]?.Id // empty')

if [ -n "$hosted_zone_id" ]; then
    # Get all the hosted zone info using the ID
    hosted_zone_info=$(aws route53 get-hosted-zone --id "$hosted_zone_id")

    # Extract the name servers
    name_servers=$(echo "$hosted_zone_info" | jq -r '.DelegationSet?.NameServers // empty' | tr -d '[:space:]')

    # Remove the '/hostedzone/' prefix to get the pure Zone ID
    hosted_zone_id=${hosted_zone_id#"/hostedzone/"}

    # Return the appropriate response
    jq -n --arg id "$hosted_zone_id" \
        --arg name_servers "$name_servers" \
        '{ "exists": "true", "id": $id, "name_servers": $name_servers }'
else
    # If the hosted zone doesn't exist - create it
    created_zone_info=$(aws route53 create-hosted-zone --name "$hosted_zone_name" --caller-reference "$(date +%s)")

    # Extract Zone ID of the newly created zone
    created_zone_id=$(echo "$created_zone_info" | jq -r '.HostedZone?.Id // empty')

    # To get the name_servers we need to fetch all of the zone's info using the ID
    created_zone_info=$(aws route53 get-hosted-zone --id "$created_zone_id")

    # Extract the name servers
    name_servers=$(echo "$created_zone_info" | jq -r '.DelegationSet?.NameServers // empty' | tr -d '[:space:]')

    # Remove the '/hostedzone/' prefix to get the pure Zone ID
    created_zone_id=${created_zone_id#"/hostedzone/"}

    # Return the appropriate response for the newly created zone
    jq -n --arg id "$created_zone_id" \
        --arg name_servers "$name_servers" \
        '{ "exists": "true", "id": $id, "name_servers": $name_servers }'
fi
