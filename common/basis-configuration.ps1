#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# Base URL for all requests -- replace with your own using config files
# Here we expected that you are in the sandbox available from Acronis Developer Network Portal
$config = Get-Content "${scriptDir}\..\cyber.platform.cfg.json" | ConvertFrom-Json
$default_config = Get-Content "${scriptDir}\..\cyber.platform.cfg.json" | ConvertFrom-Json

function Get-ConfigValue {

	[CmdletBinding()]
	Param(
		[parameter(Mandatory = $true)]
		[string]
		$Name)

	Set-Variable -Name $Name -Value $config.$Name

	$value = Get-Variable -Name $Name

	if ($null -eq $value.Value) {
		Set-Variable -Name $Name -Value $default_config.$Name

		$value = Get-Variable -Name $Name

		if ($null -eq $value.Value) {
			Throw "${Name}  doesn't set in config files."
		}
	}

	$value.Value
}

$baseUrl = Get-ConfigValue "baseUrl"
$partnerTenant = Get-ConfigValue "partnerTenant"
$customerTenant	= Get-ConfigValue "customerTenant"
$edition = Get-ConfigValue "edition"

