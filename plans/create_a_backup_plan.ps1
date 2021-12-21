#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

$basePlan = Get-Content "base_plan.json"

# Replace protection.total policy id with new UUID and replace backup.policy id with another new UUID
$basePlan = $basePlan.Replace("{{parent_plan_uuid}}", [guid]::NewGuid().Guid).Replace("{{plan_uuid}}", [guid]::NewGuid().Guid)

# To create a backup only plan (as stated in the used template file)
# POST API call using function defined in basis_functions.sh
# with following parameters
# $1 - an API endpoint to call
# $2 - Content-Type
# $4 - POST data
Acronis-Post -Uri "api/policy_management/v4/policies" -Body $basePlan
