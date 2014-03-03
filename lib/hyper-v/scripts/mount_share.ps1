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
$modules = @()
$modules += $presentDir + "\utils\create_session.ps1"
$modules += $presentDir + "\utils\write_messages.ps1"

forEach ($module in $modules) { . $module }

try {
    function Mount-File($guest_path, $hostpath ) {
        $hostpath = $hostpath.replace(":","")
        # If a folder exist remove it.
        if (Test-Path $guest_path) {
          $junction = Get-Item $guest_path
          $junction.Delete()
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
        Write-Error-Message $response["error"]
        return
    }

    try {
      Invoke-Command -Session $response["session"] -ScriptBlock ${function:Mount-File} -ArgumentList $guest_path, $hostpath  -ErrorAction "stop"
    } catch {
        Write-Error-Message "Failed to mount files VM  $_"
        return
    }
    Remove-PSSession -Id $response["session"].Id
    $resultHash = @{
      message = "OK"
    }
    $result = ConvertTo-Json $resultHash
    Write-Output-Message $result
}
catch {
    Write-Error-Message "Failed to mount files VM  $_"
    return
}
