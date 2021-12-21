#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get a customer info
$customer = Get-Content "${scriptDir}\..\customer.json" | ConvertFrom-Json
$customerId = $customer.id

# Retrieve int tenant id by uuid tenant id, the same as
# $customerGroup = Invoke-RestMethod -Uri "${baseUrl}api/1/groups/${customerId}" -Headers $headers
$customerGroup = Acronis-Get -Uri "api/1/groups/${customerId}"
$customerIntId = $customerGroup.id

# Get list of all Acronis Agents for tenants subtree
# where the root tenant is a previously created customer, the same as
# $agents = Invoke-RestMethod -Uri "${baseUrl}api/agent_manager/v2/agents?tenant_id=${customerIntId}" -Headers $headers
$agents = Acronis-Get -Uri "api/agent_manager/v2/agents?tenant_id=${customerIntId}"

# Save the JSON agents info into a file
$agents | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\all_agents_for_customer.json"