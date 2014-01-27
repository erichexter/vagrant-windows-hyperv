param (
    [string]$path = $(throw "-path is required."),
    [string]$name = $(throw "-name is required.")
 )
$result = Get-SMBShare | Where-Object {$_.path -eq $path -and $_.name -eq $name }
if (!$result) {
  New-SmbShare -Name $name -Path $path
}
