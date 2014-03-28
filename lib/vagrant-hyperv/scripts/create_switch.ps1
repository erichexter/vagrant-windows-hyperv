#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
param (
    [string]$type = $(throw "-type is required."),
    [string]$name = $(throw "-name is required."),
    [string]$vm_id = $(throw "-vm_id is required."),
    [string]$adapter = ""
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
forEach ($module in $modules) { . $module }

try {
  $switch_exist = $false
  Get-VMSwitch -SwitchType  "$type" | ForEach-Object {
    if ( $_.name -eq $name ) {
      $switch_exist = $true
    }
  }

  try {
    Get-NetAdapter -Name $adapter
  } catch {

  }

  $count = 0
  $operation_pass = $false
  if (-not $switch_exist ) {
    do {
      try {
        if ($type -ne "External") {
          New-VMSwitch -Name "$name" -SwitchType "$type" -ErrorAction "stop"
        } else {
          New-VMSwitch -Name "$name" -NetAdapterName $adapter -ErrorAction "stop"
        }
        $operation_pass = $true
      } catch {
        sleep 5
      }
    }
    while (!$operation_pass -and $count -lt 5)
  }

  $resultHash = @{
  message = "OK"
  }
  $result = ConvertTo-Json $resultHash
  Write-Output-Message $result
  } catch {
    Write-Error-Message $_
  }
