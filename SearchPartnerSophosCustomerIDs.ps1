<#
    Script Changelog
    1.0     [Feb 2023]    Ben Weinberg      - Script developed
    1.1     [Feb 2023]    Ben Weinberg      - Modified script to include search for tenant ID
#>
<# 
    .SYNOPSIS
    Connects to Sophos Central Partner 
    .DESCRIPTION
    This PowerShell script prompts the user to enter their Sophos client ID, secret and TenantID which can be found in the registry of the effected machine. 
    It then uses the client ID and secret to authenticate with the Sophos API and retrieve an access token. 
    The script then uses the access token to retrieve information about all tenants associated with the authenticated account searches for the tenant ID and returns the company its associated with. 
    .NOTES
#>


$clientId = Read-Host -Prompt 'Enter your Client ID, ask Ben if unsure'
if ($clientId -eq "" ){
    write-host "A client ID must be specified"
    return
}
$clientSecret = Read-Host -Prompt 'Enter your Client Secret, ask Ben if unsure' -AsSecureString
if ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret)) -eq "") {
    Write-Host "A client secret must be specified."
    return
}

$tenantId = Read-Host -Prompt "Enter a tenant ID"
if ([string]::IsNullOrEmpty($tenantId)) {
    write-host "A Tenant ID must be specified"
    return
} elseif (-not [Guid]::TryParse($tenantId, [ref][Guid]::Empty)) {
    write-host "The Tenant ID must be in the GUID format"
    return
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

try {
$authResponse = Invoke-RestMethod @authParams
} catch {
    write-host "Authentication failed. Error message: $($_.Exception.Message)" -ForegroundColor Red
    return
}

$accessToken = $authResponse.access_token

$headers = @{
    Authorization = "Bearer $accessToken"
}

$whoamiUrl = 'https://api.central.sophos.com/whoami/v1'
$whoamiResponse = Invoke-RestMethod -Uri $whoamiUrl -Headers $headers

$partnerId = $whoamiResponse.id

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
$matchedTenant = $null
for ($page = 1; $page -le $totalPages; $page++) {
    $tenantsUrl = "https://api.central.sophos.com/partner/v1/tenants?pageTotal=true&page=$page"
    $tenantsResponse = Invoke-RestMethod -Uri $tenantsUrl -Headers $headers -Method Get
    foreach ($tenant in $tenantsResponse.items) {
        if ($tenant.id -eq $tenantId) {
            $matchedTenant = $tenant
            break
        }
    }
    if ($matchedTenant) {
        break
    }
}

if ($matchedTenant) {
    Write-Host "Tenant name for ID $tenantId is $($matchedTenant.name)" -ForegroundColor Green
} else {
    Write-Host "No tenant found with ID $tenantId" -ForegroundColor Red
}
