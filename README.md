# Generate Subdomains

![image](https://github.com/user-attachments/assets/21dab747-9569-4b02-9fa3-9a80473b56a8)


Bash + JS to get a list of all subdomains from AWS Route53 in a spreadsheet

## Dependencies
Node
AWS CLI

## Steps

1. Login to AWS via CLI
   
2. Change bash script to executable
   
   ```chmod +x generate-all-domains.sh```
   
3. Install npm and dependiencies
   
   ```npm init -y```
   
   ```npm instal xlsx```
4. Run bash script
   
   ```./generate-all-domains.sh```

## For only one domain

You can use the ```generate-subdomain-data.sh``` script instead and simple change the ```DOMAIN``` variable.
