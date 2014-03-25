# Vagrant Hyper-V Provider

Hyper-V provider is available by default starting in Vagrant starting from version 1.5 onwards. This plugin is created to provide windows guest features for Hyper-V.


## Installation
Install Vagrant 1.5

vagrant plugin install vagrant-hyperv

## Configuration


### VagrntFile needs the following changes.

- Sync Folder configuration

With Vagrant 1.5 SMB share is available by default and vagrant picks the most suitable
implementation for the providers.

You can even specify the following options

 :type
 
 :smb_id

For more information please visit the Vagrant Documentation.

```ruby
   # Mounts the host/path to guest/path and will have realtime sync
   config.vm.synced_folder 'host/path', "guest/path"
```
- Mention the type of VM Guest

```ruby
config.vm.guest = :windows
config.vm.provider "hyperv" do |hv, override|
  override.ssh.username = "vagrant"
end
```
### New RDP Command
* A new command vagrant rdp is introduced to connect to the Windows VM
` vagrant rdp `

## Troubleshooting

### Remote PowerShell
Vagrant-HyperV uses remote PowerShell to communicate with the guest VMs, the guest VMs should have WinRM service running and remote PowerShell running.

To Enable remote PowerShell in the guest.
Go to the guest VM, open a cmd terminal and type the following command
```
powershell Enable-PSRemoting –force
```
### Trustedhosts
With PowerShell being enabled in the remote VM, the host has to trust this guest for further communication to happen.
One can add the guest IP under trustedhost. Here "*" can be used as a wildcard to trust all hosts, or replace the * with the IP address of the guest..

Type this command from a cmd Administrator terminal

`
powershell set-item wsman:\localhost\client\trustedhosts *
`
