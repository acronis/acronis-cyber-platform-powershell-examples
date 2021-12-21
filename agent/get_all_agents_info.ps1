#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get list of all Acronis Agents for tenants subtree
# where the root tenant is
# defined by used API Client tenant, the same as
# $agents = Invoke-RestMethod -Uri "${baseUrl}api/agent_manager/v2/agents" -Headers $headers
$agents = Acronis-Get -Uri "api/agent_manager/v2/agents"

# Save the JSON agents info into a file
$agents | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\all_agents.json"