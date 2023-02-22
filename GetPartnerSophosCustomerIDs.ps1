<#
    Script Changelog
    1.0     [Feb 2023]    Ben Weinberg      - Script developed
#>
<# 
    .SYNOPSIS
    Connects to Sophos Central Partner 
    .DESCRIPTION
    This PowerShell script prompts the user to enter their Sophos client ID and secret, and a file path to save the results. 
    It then uses the client ID and secret to authenticate with the Sophos API and retrieve an access token. 
    The script then uses the access token to retrieve information about all tenants associated with the authenticated account and saves this information in a CSV file. 
    The script retrieves the tenant information in batches, as there may be many tenants, and appends each batch to the same CSV file.
    .NOTES
#>


$clientId = Read-Host -Prompt 'Enter your Client ID'
if ($clientId -eq "" ){
    write-host "A client ID must be specified"
    exit
}
$clientSecret = Read-Host -Prompt 'Enter your Client Secret' -AsSecureString
if ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)) -eq "") {
    Write-Host "A client secret must be specified."
    exit
}
$defaultPath = "c:\temp\Sophos.csv"
$csvFilePath = Read-Host -Prompt "Enter the location to save the results, please include the file name ending in .csv (default: $defaultPath)"
if ($csvFilePath -eq "") {
    $csvFilePath = $defaultPath
}

$authParams = @{
    Uri         = 'https://id.sophos.com/api/v2/oauth2/token'
    Method      = 'Post'
    Body        = @{
        grant_type    = 'client_credentials'
        client_id     = $clientId
        client_secret = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret))
        scope         = 'token'
    }
    ContentType = 'application/x-www-form-urlencoded'
}

$authResponse = Invoke-RestMethod @authParams

$accessToken = $authResponse.access_token

$headers = @{
    Authorization = "Bearer $accessToken"
}

$whoamiUrl = 'https://api.central.sophos.com/whoami/v1'
$whoamiResponse = Invoke-RestMethod -Uri $whoamiUrl -Headers $headers

$partnerId = $whoamiResponse.id

#Write-Host "Your Partner ID is: $partnerId"

# list all tenants
$headers = @{
    "Authorization" = "Bearer $($authResponse.access_token)"
    "X-Partner-ID" = $partnerId
    "Content-Type" = "application/json"
    "User-Agent" = "PowerShell"
}

$firstPageUrl = "https://api.central.sophos.com/partner/v1/tenants?pageTotal=true"

$firstPageResponse = Invoke-RestMethod -Uri $firstPageUrl -Headers $headers -Method Get
$totalPages = $firstPageResponse.pages.total

for ($page = 1; $page -le $totalPages; $page++) {
    $tenantsUrl = "https://api.central.sophos.com/partner/v1/tenants?pageTotal=true&page=$page"
    $tenantsResponse = Invoke-RestMethod -Uri $tenantsUrl -Headers $headers -Method Get

    # display the tenant information
    #foreach ($tenant in $tenantsResponse.items) {
    #    Write-Output "Tenant ID: $($tenant.id)"
    #    Write-Output "Tenant Name: $($tenant.name)"
    #    Write-Output "Data Geography: $($tenant.dataGeography)"
    #    Write-Output "Data Region: $($tenant.dataRegion)"
    #    Write-Output "Billing Type: $($tenant.billingType)"
    #    Write-Output "API Host: $($tenant.apiHost)"
    #    Write-Output ""
    #}

    # append the tenant information to the CSV file
    $tenantsResponse.items | Select-Object id, name, dataGeography, dataRegion, billingType, apiHost | Export-Csv -Path $csvFilePath -NoTypeInformation -Append
}

Write-Host "Tenant information has been exported to $csvFilePath."
