#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------


param (
    [string]$guest_path = $(throw "-guest_path is required."),
    [string]$hostpath = $(throw "-hostpath is required."),
    [string]$guest_ip = $(throw "-guest_ip is required."),
    [string]$username = $(throw "-username is required."),
    [string]$password = $(throw "-password is required.")
 )

# Include the following modules
$presentDir = Split-Path -parent $PSCommandPath
. ([System.IO.Path]::Combine($presentDir, "utils\write_messages.ps1"))
. ([System.IO.Path]::Combine($presentDir, "utils\create_session.ps1"))

forEach ($module in $modules) { . $module }

try {
    function Mount-File($guest_path, $hostpath ) {
        $hostpath = $hostpath.replace(":","")
        # If a folder exist remove it.
        if (Test-Path $guest_path) {
          try {
            # When it is a junction drive
            $junction = Get-Item $guest_path
            $junction.Delete()
          }
          # Catch any [IOException]
          catch  {
            # When it is a folder
            Remove-Item "$guest_path" -Force -Recurse
          }
        }

        # Check if the folder path exists
        $base_directory_for_mount = [System.IO.Path]::GetDirectoryName($guest_path)

        if (-not (Test-Path $base_directory_for_mount))
        {
          New-Item $base_directory_for_mount -Type Directory -Force | Out-Null
        }
        cmd /c  mklink /d $guest_path  "\\tsclient\$hostpath"
    }

    $response = Create-Remote-Session $guest_ip $username $password

    if (!$response["session"] -and $response["error"]) {
        $errortHash = @{
          type = "PowerShellError"
          message = $response["error"]
        }
        Write-Error-Message $errortHash
        return
    }

    try {
      Invoke-Command -Session $response["session"] -ScriptBlock ${function:Mount-File} -ArgumentList $guest_path, $hostpath  -ErrorAction "stop"
    } catch {
        $errortHash = @{
          type = "PowerShellError"
          message ="Failed to mount files VM  $_"
        }
        Write-Error-Message $errortHash
        return
    }
    Remove-PSSession -Id $response["session"].Id
    $resultHash = @{
      message = "OK"
    }
    Write-Output-Message $resultHash
}
catch {
    $errortHash = @{
      type = "PowerShellError"
      message ="Failed to mount files VM  $_"
    }
    Write-Error-Message $errortHash
    return
}
