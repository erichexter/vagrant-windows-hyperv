#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

function Get-Remote-Session($guest_ip, $username, $password) {
    $secstr = convertto-securestring -AsPlainText -Force -String $password
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
    New-PSSession -ComputerName $guest_ip -Credential $cred -ErrorAction "stop"
}

function Create-Remote-Session($guest_ip, $username, $password) {
    $count = 0
    $session_error = ""
    $session = ""
    $max_attempts = 5
    do {
        $count++
        try {
            $session = Get-Remote-Session $guest_ip $username $password
            $session_error = ""
        }
        catch {
            $session_error = $_.Exception.message
            if ($_.FullyQualifiedErrorID -eq "AccessDenied,PSSessionOpenFailed") {
                $count = $max_attempts
            }
            elseif ($_FullyQualifiedErrorID -eq "CannotUseIPAddress,PSSessionOpenFailed") {
                $count = $max_attempts
            }
            elseif ( $_.FullyQualifiedErrorID -eq "WinRMOperationTimeout,PSSessionOpenFailed") {
                Start-Sleep -s 5
                $session = ""
            }
        }
    }
    while (!$session -and $count -lt $max_attempts)

    return  @{
        session = $session
        error = "$session_error"
    }
}
