#!/bin/bash

# Ensure the script stops on the first error
set -e

# Define your output directory and JSON file list
OUTPUT_DIR="dns_output"
HOSTED_ZONES_JSON="hosted_zones.json"

# Fetch all hosted zones and save to a file
aws route53 list-hosted-zones --output json > $HOSTED_ZONES_JSON

# Check if the JSON file was created successfully
if [[ ! -f $HOSTED_ZONES_JSON ]]; then
    echo "Error: Could not fetch hosted zones."
    exit 1
fi

# Create the output directory
mkdir -p "$OUTPUT_DIR"

# Extract the domain names and IDs
while IFS= read -r row; do
    DOMAIN=$(echo $row | jq -r '(.Name // "") | rtrimstr(".")') # Remove trailing dot
    HOSTED_ZONE_ID=$(echo $row | jq -r '.Id')
    
    if [[ -z "$DOMAIN" || -z "$HOSTED_ZONE_ID" ]]; then
        echo "Warning: Missing data for row: $row"
        continue
    fi

    echo "Processing domain: $DOMAIN"

    # List all DNS records and save to JSON
    aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --output json > "$OUTPUT_DIR/$DOMAIN.json"

    echo "JSON file for domain $DOMAIN generated: $OUTPUT_DIR/$DOMAIN.json"
done < <(jq -c '.HostedZones[]' $HOSTED_ZONES_JSON)

# Run the Node.js script to generate the Excel file
node generate-excel.js

# Clean up
rm -rf "$OUTPUT_DIR"

echo "All steps completed successfully. Excel file generated: all_domains.xlsx"

