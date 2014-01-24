param (
    [string]$vm_id = $(throw "-vm_id is required.")
 )

$vm = Get-VM -Id $vm_id
# Shuts down virtual machine regardless of any unsaved application data
Stop-VM $vm -Force
