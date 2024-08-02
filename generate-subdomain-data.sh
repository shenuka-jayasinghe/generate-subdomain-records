#!/bin/bash

# Ensure the script stops on the first error
set -e

# Define your domain name
DOMAIN="yourdomain.com"

# Step 1: Get the Hosted Zone ID
HOSTED_ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name==\`${DOMAIN}.\`].Id" --output text)

# Step 2: List all DNS records and save to JSON
aws route53 list-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --output json > dns.json

# Step 3: Generate CSV from JSON using Node.js
node - <<'EOF'
const fs = require('fs');

// Read JSON data from file
const jsonData = JSON.parse(fs.readFileSync('dns.json', 'utf-8')).ResourceRecordSets;

// Prepare CSV header
let csv = 'name,type,alias target or record resource,the resource record value (IP address)\n';

// Function to get alias target or resource record value
function getAliasOrResourceValue(entry) {
    if (entry.AliasTarget) {
        return entry.AliasTarget.DNSName || '';
    } else if (entry.ResourceRecords && entry.ResourceRecords.length > 0) {
        return entry.ResourceRecords.map(record => record.Value).join('; ') || '';
    }
    return '';
}

// Process each JSON entry
jsonData.forEach(entry => {
    let name = entry.Name || '';
    let type = entry.Type || '';
    let aliasTargetOrRecordResource = entry.AliasTarget ? 'DNS' : 'ResourceRecord';
    let resourceRecordValue = getAliasOrResourceValue(entry);

    // Append CSV line for this entry
    csv += `${name},${type},${aliasTargetOrRecordResource},${resourceRecordValue}\n`;
});

// Write CSV to file
fs.writeFileSync('output.csv', csv);

console.log('CSV output generated successfully.');
EOF

# Clean up
rm dns.json

echo "All steps completed successfully. CSV file generated: output.csv"

