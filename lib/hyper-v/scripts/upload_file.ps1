#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

param (
    [string]$vm_id = $(throw "-vm_id is required."),
    [string]$guest_ip = $(throw "-guest_ip is required."),
    [string]$username = $(throw "-guest_username is required."),
    [string]$password = $(throw "-guest_password is required."),
    [string]$host_path = $(throw "-host_path is required."),
    [string]$guest_path = $(throw "-guest_path is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
$modules = @()
$modules += $presentDir + "\utils\write_messages.ps1"
$modules += $presentDir + "\utils\create_session.ps1"
forEach ($module in $modules) { . $module }

try {

  function Get-Remote-Temp-Path() {
    return $env:TEMP
  }

  $response = Create-Remote-Session $guest_ip $username $password
  if (!$response["session"] -and $response["error"]) {
      Write-Error-Message $response["error"]
      return
  }
  $temp_path = Invoke-Command -Session $response["session"] -ScriptBlock ${function:Get-Remote-Temp-Path} -ErrorAction "stop"
  $machine = Get-VM -Id $vm_id
  $guest_path = "$temp_path\$guest_path"
  Copy-VMFile  -VM $machine -SourcePath $host_path -DestinationPath $guest_path -CreateFullPath -FileSource Host -Force
  $resultHash = @{
    message = "OK"
    temp_path = "$guest_path"
  }
  $result = ConvertTo-Json $resultHash
  Write-Output-Message $result
  Remove-PSSession -Id $response["session"].Id
} catch {
  Write-Error-Message "Failed to copy file  $_"
  return
}
