#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
param (
    [string]$ram_memory = $(throw "-ram_memory is required."),
    [string]$vm_id = $(throw "-vm_id is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
forEach ($module in $modules) { . $module }

$vm = Get-Vm -Id $vm_id
try {
  Set-vm -vm $vm -MemoryStartupBytes (($ram_memory -as [int]) * 1MB) -ErrorAction "stop"
}
catch {
  Write-Error-Message "Failed to configure memory $_"
}
