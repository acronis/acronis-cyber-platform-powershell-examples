#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Request all resources available for the current authorization scope protection statuses
$allResources = Acronis-Get -Uri "api/resource_management/v4/resource_statuses"

# Save the JSON activities info into a file
$allResources | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\all_resources_protection_statuses.json"