# SophosPartnerCustomerIDs
Connects to Sophos Central Partner to get Tenant IDs

This PowerShell script prompts the user to enter their Sophos client ID and secret, and a file path to save the results. 
It then uses the client ID and secret to authenticate with the Sophos API and retrieve an access token. 
The script then uses the access token to retrieve information about all tenants associated with the authenticated account and saves this information in a CSV file. 
The script retrieves the tenant information in batches, as there may be many tenants, and appends each batch to the same CSV file.

You will need to create a new Sophos Partner API credential to run this script. You will need a "Client ID" and a "Client Secret". More info on how to get this here: https://developer.sophos.com/getting-started
