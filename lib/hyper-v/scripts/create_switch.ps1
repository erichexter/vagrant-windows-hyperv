#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
param (
    [string]$type = $(throw "-type is required."),
    [string]$name = $(throw "-name is required."),
    [string]$vm_id = $(throw "-vm_id is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
forEach ($module in $modules) { . $module }

Write-Host "$name"
try {
  $switch_exist = $false
  Get-VMSwitch -SwitchType  "$type" | ForEach-Object {
    Write-Host $_.name
    Write-Host $name
    if ( $_.name -eq $name ) {
      $switch_exist = $true
    }
  }
  Write-Host $switch_exist
  $count = 0
  $operation_pass = $false
  if (-not $switch_exist ) {
    do {
      try {
        if ($type -ne "External") {
          New-VMSwitch –Name "$name" –SwitchType "$type" -ErrorAction "stop"
        } else {
          $adapter_name = "Ethernet"
          New-VMSwitch -Name "$name" -NetAdapterName $adapter_name -ErrorAction "stop"
        }
        $operation_pass = $true
      } catch {
        sleep 5
        Write-Host "Failed--"
        Write-Error-Message $_
      }
    }
    while (!$operation_pass -and $count -lt 5)
  }

  $vm = Get-Vm -Id $vm_id
  try {
    Write-Host $name
    Get-VMNetworkAdapter -VM $vm | Connect-VMNetworkAdapter -SwitchName "$name"
  } catch {
    Write-Error-Message $_
  }

  $resultHash = @{
  message = "OK"
  }
  $result = ConvertTo-Json $resultHash
  Write-Output-Message $result
  } catch {
    Write-Error-Message $_
  }
