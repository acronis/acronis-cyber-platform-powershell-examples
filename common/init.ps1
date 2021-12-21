#**************************************************************************************************************
# Copyright © 2019-2021 Acronis International GmbH. This source code is distributed under MIT software license.
#**************************************************************************************************************

# Read execution directory to correctly map all files
$scriptDir = $MyInvocation.MyCommand.Path | Split-Path -Parent

# include common functions
. "${scriptDir}\..\common/basis-functions.ps1"

# include base configuration
. "${scriptDir}\..\common/basis-configuration.ps1"

# include basis API checks
. "${scriptDir}\..\common/basis-api-check.ps1"