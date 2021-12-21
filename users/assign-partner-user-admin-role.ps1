#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get a user info
$user = Get-Content "${scriptDir}\..\partner_user.json" | ConvertFrom-Json
$userId = $user.id

# Get a partner info
$partner = Get-Content "${scriptDir}\..\partner.json" | ConvertFrom-Json
$partnerId = $partner.id


$json = @"
{"items": [
     {"id": "00000000-0000-0000-0000-000000000000",
     "issuer_id": "00000000-0000-0000-0000-000000000000",
     "role_id": "partner_admin",
     "tenant_id": "${partnerId}",
     "trustee_id": "${userId}",
     "trustee_type": "user",
     "version": 0}
     ]}
"@

# Invoke-RestMethod -Method Put -Uri "${baseUrl}api/2/users/${userId}/access_policies" -Headers $headers -Body $json
Acronis-Put -Uri "api/2/users/${userId}/access_policies" -Body $json