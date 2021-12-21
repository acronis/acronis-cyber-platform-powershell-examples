#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# includes common functions, base configuration and basis API checks
. "${scriptDir}\..\common\init.ps1"

# Construct JSON to request
# 301d1574-849e-4714-859f-3a2ec12a218b is predefined id for "Machines with agents" static group
# Thus this Static group is expected to contain machines with agents
# We need to have at least 1 machine w/agent to see that groups
# ****************************************************
# NOTICE. You can't add a sub-group to a dynamic group
# ****************************************************
$json = @"
{
	"type": "resource.group.computers",
	  "parent_group_ids": [
		"301d1574-849e-4714-859f-3a2ec12a218b"
	],
	"group_condition": "test*",
	"allowed_member_types": [
		"resource.machine"
	],
	"name": "My Dynamic Group",
	"user_defined_name": "My Dynamic Group"
}
"@

Acronis-Post -Uri "api/resource_management/v4/resources"  -Body $json