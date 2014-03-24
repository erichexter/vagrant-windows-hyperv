#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "vagrant/util/subprocess"
require "tempfile"

module VagrantPlugins
  module VagrantHyperV
    module Action
      class SyncedFolders
        attr_reader :smb_shared_folders, :smb_credentials

        def initialize(app, env)
          @app = app
        end

        def call(env)
          @env = env
          fetch_smb_credentials
          fetch_smb_shared_folders
          if smb_shared_folders.length > 0
            if env[:machine].provider_config.guest == :windows
              env[:ui].info('Preparing SMB shared folders.')
              mount_shared_folders_to_windows
            elsif env[:machine].provider_config.guest == :linux
              env[:ui].info('Mounting shared folders with VM, This process may take few minutes.')
              mount_shared_folders_to_linux
            end
          end
          @app.call(env)
        end

        def fetch_smb_shared_folders
          @smb_shared_folders = {}
          @env[:machine].config.vm.synced_folders.each do |id, data|
            # Ignore disabled shared folders
            next if data[:disabled]

            # This to prevent overwriting the actual shared folders data
            @smb_shared_folders[id] = data.dup
            @smb_shared_folders[id][:smb_id] ||= @smb_shared_folders[id][:hostpath].gsub(/[\/\:\\]/,'_').sub(/^_/, '')
            @smb_shared_folders[id][:smb_username] ||= smb_credentials[:username]
            @smb_shared_folders[id][:smb_password] ||= smb_credentials[:password]
          end
        end

        def ssh_info
          @ssh_info || @env[:machine].ssh_info
        end

        def mount_shared_folders_to_windows
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})
          @host_ip = result["host_ip"]
          smb_shared_folders.each do |id, data|
            prepare_smb_share(data)
            hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
            @env[:ui].info "From #{hostpath}"
            guestpath = "\\\\#{@host_ip}\\#{data[:smb_id]}"
            @env[:ui].info("===>  #{guestpath} ...")
          end
          generate_vm_startup_scripts
        end

        def generate_vm_startup_scripts
          # Upload a startup script to VM,
          # This script will authenticate the Network share with the host, and
          # the guest can access the share path from a RDP session
          file = Tempfile.new(['vagrant-smb-auth', '.ps1'])
          begin
            smb_shared_folders.each do |id, data|
              smb_map_command = "New-SmbMapping"
              smb_map_command += " -RemotePath \\\\#{@host_ip}\\#{data[:smb_id]}"
              smb_map_command += " -UserName #{data[:smb_username]}"
              smb_map_command += " -Password #{data[:smb_password]}"
              file.puts(smb_map_command)
            end
            file.fsync
            file.close
          ensure
            file.close
          end
          @env[:machine].provider.driver.upload(file.path.to_s, "c:\\tmp\\vagrant-smb-auth.ps1")
          # Invoke Remote Schedule task command in VM
          command = 'schtasks /create /sc ONLOGON /tn vagrant-smb-auth /tr \"powershell c:\tmp\vagrant-smb-auth.ps1\"'
          @env[:machine].provider.driver.run_remote_ps(command)
        end

        def fetch_smb_credentials
          @smb_credentials = {}
          @env[:machine].ui.info (I18n.t("vagrant_sf_smb.warning_password") + "\n ")
          @smb_credentials[:username] = @env[:machine].ui.ask("Username: ")
          @smb_credentials[:password] = @env[:machine].ui.ask("Password (will be hidden): ", echo: false)
          @env[:machine].ui.info ("\n")
          if (@smb_credentials[:username].empty? ||
              @smb_credentials[:password].empty?)
            raise Errors::InvalidSMBCredentials
          end
          @smb_credentials
        end

        def prepare_smb_share(data)
          hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
          response = @env[:machine].provider.driver.share_folders(hostpath, data)
        end

        def mount_shared_folders_to_linux
          # Find Host Machine's credentials
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})
          smb_shared_folders.each do |id, data|
            begin
              prepare_smb_share(data)
              # Mount the Network drive to Guest VM
              @env[:ui].info "Linking to Guest at  ==> #{data[:guestpath]}"

              # Create a folder in guest against the guestpath
              @env[:machine].communicate.sudo("mkdir -p '#{data[:guestpath]}'")
              owner = data[:owner] || ssh_info[:username]
              group = data[:group] || ssh_info[:username]

              mount_options  = "-o rw,username=#{data[:smb_username]},"
              mount_options  += "pass=#{data[:smb_password]},"
              mount_options  += "sec=ntlm,file_mode=0777,dir_mode=0777,"
              mount_options  += "uid=`id -u #{owner}`,gid=`id -g #{group}` '#{data[:guestpath]}'"

              command = "mount -t cifs //#{result["host_ip"]}/#{data[:smb_id]} #{mount_options}"
              @env[:machine].communicate.sudo(command)
            rescue Errors::NetShareError => e
              @env[:ui].error e.message
            rescue RuntimeError => e
              @env[:ui].error("Failed to mount at #{data[:guestpath]}")
            end
          end
        end
      end
    end
  end
end
