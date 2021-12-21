#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Get personal_tenant_id for user.json
$tokenInfo = Get-Content "${scriptDir}\..\agent_installation_token.json" | ConvertFrom-Json
$token = $tokenInfo.token

.\Cyber_Protection_Agent_for_Windows_x64.exe --quiet --registration by-token --reg-token $token --reg-address $baseUrl