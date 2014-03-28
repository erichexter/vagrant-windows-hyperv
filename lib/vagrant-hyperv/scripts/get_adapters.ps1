#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
# Include the following modules
$Dir = Split-Path $script:MyInvocation.MyCommand.Path
. ([System.IO.Path]::Combine($Dir, "utils\write_messages.ps1"))

$adapters = @(Get-NetAdapter `
    | Select-Object Name,InterfaceDescription,Status) `
    | Where-Object {$_.Status-eq "up"}
Write-Output-Message $(ConvertTo-JSON $adapters)
