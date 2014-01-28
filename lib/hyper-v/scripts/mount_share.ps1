param (
    [string]$share_name = $(throw "-share_name is required."),
    [string]$guest_path = $(throw "-guest_path is required."),
    [string]$guest_ip = $(throw "-guest_ip is required."),
    [string]$username = $(throw "-username is required."),
    [string]$password = $(throw "-password is required.")
 )

function Get-Remote-Session($guest_ip, $username, $password) {
    $secstr = convertto-securestring -AsPlainText -Force -String $password
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
    New-PSSession -ComputerName $guest_ip -Credential $cred
}

function Mount-File($share_name, $guest_path, $host_path) {
  $guest_path = $guest_path.replace("/", "\")
  cmd /c  mklink /d $guest_path  $host_path
}

$session = ""
$count = 0
do {
    $count++
    try {
        $session = Get-Remote-Session $guest_ip $username $password
    }
    catch {
        Start-Sleep -s 10
        $session = ""
    }
}
while (!$session -and $count -lt 20)

Set-Item wsman:\localhost\client\trustedhosts *
$host_ip = '10.18.20.77'
$host_path = "\\$host_ip\$share_name"
Invoke-Command -Session $session -ScriptBlock ${function:Mount-File} -ArgumentList $share_name, $guest_path, $host_path
Remove-PSSession -Id $session.Id
