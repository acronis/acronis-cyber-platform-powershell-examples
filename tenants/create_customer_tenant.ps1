#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get a partner info
$partner = Get-Content "${scriptDir}\..\partner.json" | ConvertFrom-Json
$partnerId = $partner.id

$tenantName  = Read-Host  -Prompt "Enter expected a partners tenant name"

# Body JSON, to create a customer tenant
$json = @"
{
    "name": "${tenantName}",
    "parent_id": "${partnerId}",
    "kind": "${customerTenant}"
  }
"@

# Create a customer in a trial mode, the same as
# $customer = Invoke-RestMethod -Method Post -Uri "${baseUrl}api/2/tenants" -Headers $headers -Body $json
$customer = Acronis-Post -Uri "api/2/tenants" -Body $json
$customerId = $customer.id

# Save the JSON customer info into a file
$customer | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\customer.json"

Enable-AllOfferingItems -BaseUrl $baseUrl -ParentTenantID $partnerId -TenantID $customerId -AuthHeader $headers -Edition $edition

# Switching customer tenant to production mode, the same as
# $customerPricing = Invoke-RestMethod  -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers
$customerPricing = Acronis-Get -Uri "api/2/tenants/${customerId}/pricing"
$customerPricing.mode = "production"

$customerPricingJson = $customerPricing | ConvertTo-Json

# Set production mode, the same as
# Invoke-RestMethod -Method Put -Uri "${baseUrl}api/2/tenants/${customerId}/pricing" -Headers $headers -Body $customerPricingJson
Acronis-Put -Uri "api/2/tenants/${customerId}/pricing" -Body $customerPricingJson