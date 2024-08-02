const fs = require('fs');
const XLSX = require('xlsx');

// Function to get alias target or resource record value
function getAliasOrResourceValue(entry) {
    if (entry.AliasTarget) {
        return entry.AliasTarget.DNSName || '';
    } else if (entry.ResourceRecords && entry.ResourceRecords.length > 0) {
        return entry.ResourceRecords.map(record => record.Value).join('; ') || '';
    }
    return '';
}

// Function to convert JSON to worksheet
function jsonToSheet(jsonData) {
    const data = jsonData.map(entry => ({
        name: entry.Name || '',
        type: entry.Type || '',
        aliasTargetOrRecordResource: entry.AliasTarget ? 'DNS' : 'ResourceRecord',
        resourceRecordValue: getAliasOrResourceValue(entry),
    }));
    return XLSX.utils.json_to_sheet(data, { header: ['name', 'type', 'aliasTargetOrRecordResource', 'resourceRecordValue'] });
}

// Create a new workbook
const workbook = XLSX.utils.book_new();

// Define the path to the JSON files
const outputDir = 'dns_output';

// Read all JSON files from the output directory
fs.readdirSync(outputDir).forEach(file => {
    if (file.endsWith('.json')) {
        const domain = file.replace('.json', ''); // Get domain name from file name
        const jsonData = JSON.parse(fs.readFileSync(`${outputDir}/${file}`, 'utf-8')).ResourceRecordSets;
        
        // Convert JSON to worksheet
        const sheetName = domain.length > 31 ? domain.substring(0, 31) : domain; // Limit sheet name length
        const worksheet = jsonToSheet(jsonData);
        
        // Add worksheet to workbook
        XLSX.utils.book_append_sheet(workbook, worksheet, sheetName);
    }
});

// Write workbook to file
const outputFileName = 'all_domains.xlsx';
XLSX.writeFile(workbook, outputFileName);

console.log(`Excel file generated: ${outputFileName}`);

