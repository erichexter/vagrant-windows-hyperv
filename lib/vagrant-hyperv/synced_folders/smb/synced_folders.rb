#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "#{Vagrant::source_root}/plugins/synced_folders/smb/synced_folder"

module VagrantPlugins
  module SyncedFolderSMB
    class SyncedFolder < Vagrant.plugin("2", :synced_folder)

      alias_method :original_enable, :enable

      def enable(machine, folders, nfsopts)
        response = machine.provider.driver.get_host_ip
        host_ip = response["host_ip"]
        if machine.config.vm.guest == :windows
          folders.each do |id, data|
            machine.ui.output "#{data[:hostpath]} ==>"
            machine.ui.output "\\\\#{host_ip}\\#{data[:smb_id]}"
          end
        guest_startup_script(machine, folders, host_ip)
        else
          original_enable(machine, folders, nfsopts)
        end
      end

      def guest_startup_script(machine, folders, host_ip)
        # Upload a startup script to VM,
        # This script will authenticate the Network share with the host, and
        # the guest can access the share path from a RDP session
        file = Tempfile.new(['vagrant-smb-auth', '.ps1'])
        begin
          folders.each do |id, data|
            smb_map_command = "New-SmbMapping"
            smb_map_command += " -RemotePath \\\\#{host_ip}\\#{data[:smb_id]}"
            smb_map_command += " -UserName #{data[:smb_username]}"
            smb_map_command += " -Password #{data[:smb_password]}"
            file.puts(smb_map_command)
          end
          file.fsync
          file.close
        ensure
          file.close
        end
        machine.provider.driver.upload(file.path.to_s, "c:\\tmp\\vagrant-smb-auth.ps1")
        # Invoke Remote Schedule task command in VM
        command = 'schtasks /create /sc ONLOGON /tn vagrant-smb-auth /tr \"powershell c:\tmp\vagrant-smb-auth.ps1\"'
        machine.provider.driver.run_remote_ps(command)
      end

    end
  end
end

