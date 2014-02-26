#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

param (
    [string]$vm_id = $(throw "-vm_id is required."),
    [string]$path = $(throw "-path is required.")
)

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
forEach ($module in $modules) { . $module }


# Export the Virtual Machine
try {
  $vm = Get-Vm -Id $vm_id
  $vm  | Export-VM -Path $path -ErrorAction "stop"
  $name = $vm.name
  $resultHash = @{
    name = "$name"
  }
  $result = ConvertTo-Json $resultHash
  Write-Output-Message $result
  } catch {
    Write-Error-Message "Failed to export a  VM $_"
  }
