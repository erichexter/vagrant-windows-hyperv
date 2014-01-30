$hostname =  $(whoami)
$username = $hostname.split('\')[1] + "@" + $hostname.split('\')[0]
$ip = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]
Write-Host "===Begin-Output==="
Write-Host "{
  \'host_name\' : \'$username\',
  \'host_ip\' : \'$ip\'
}"
Write-Host "===End-Output==="
