$hostname =  $(whoami)
$ip = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]
Write-Host "===Begin-Output==="
Write-Host "{
  \'host_name\' : \'$username\',
  \'host_ip\' : \'$ip\'
}"
Write-Host "===End-Output==="
