#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Read an API Client info from a file and store client_id and client_secret in variables
$customer = Get-Content "${scriptDir}\..\customer.json" | ConvertFrom-Json
$customerId = $customer.id

# Read an token info from file
# As if api_token_customer_scope.json file exists the token is overwritten in init scripts
$token = Get-Content "${scriptDir}\..\api_token.json" | ConvertFrom-Json
$accessToken = $token.access_token

# Use param to tell type of credentials we request
$postParams = @{ grant_type = "urn:ietf:params:oauth:grant-type:jwt-bearer"; assertion = "${accessToken}"; scope = "urn:acronis.com:tenant-id:${customerId}" }

# Overwrite header set in the init scripts
$headers["Content-Type"] = "application/x-www-form-urlencoded"

# Exchange tokens
$token = Acronis-Post -Uri "bc/idp/token" -Body $postParams

# Save the Token info to file for further usage
# YOU MUST STORE YOUR CREDENTIALS IN SECURE PLACE
# A FILE USES FOR CODE SIMPLICITY
# PLEASE CHECK TOKEN VALIDITY AND REFRESH IT IF NEEDED
$token | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\api_token_customer_scope.json"