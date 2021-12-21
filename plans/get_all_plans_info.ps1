#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get all plans info
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $4 - POST data
$allPlans = Acronis-Get -Uri "api/policy_management/v4/policies"

# Save the JSON info into a file
$allPlans | ConvertTo-Json -Depth 100 | Out-File "${scriptDir}\..\all_plans.json"