#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "vagrant/util/subprocess"

module VagrantPlugins
  module HyperV
    module Action
      class SyncedFolders

        def initialize(app, env)
          @app = app
        end

        def call(env)
          @env = env
          smb_shared_folders
          # A BIG Clean UP
          # There should be a communicator class which branches between windows
          # and Linux
          if @smb_shared_folders.length > 0
            env[:ui].info('Mounting shared folders with VM, This process may take few minutes.')
            if env[:machine].provider_config.guest == :windows
              mount_shared_folders_to_windows
            elsif env[:machine].provider_config.guest == :linux
              mount_shared_folders_to_linux
            end
          end
          @app.call(env)
        end

        def smb_shared_folders
          @smb_shared_folders = {}
          @env[:machine].config.vm.synced_folders.each do |id, data|
            # Ignore disabled shared folders
            next if data[:disabled]

            # This to prevent overwriting the actual shared folders data
            @smb_shared_folders[id] = data.dup
            @smb_shared_folders[id][:share_name] ||= @smb_shared_folders[id][:hostpath].gsub(/[\/\:\\]/,'_').sub(/^_/, '')
          end
        end

        def ssh_info
          @ssh_info || @env[:machine].ssh_info
        end

        def mount_shared_folders_to_windows
          @env[:ui].info "Creating SMB drive mount"
          @smb_shared_folders.each do |id, data|
            hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
            @env[:ui].info "From #{hostpath}"
            @env[:ui].info("===>  #{data[:guestpath]} ...")
            @env[:machine].provider.driver.mount_to_windows(hostpath, data[:guestpath])
          end
        end

        def prepare_smb_share(data)
          hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
          response = @env[:machine].provider.driver.share_folders(hostpath, data[:share_name])
          if response["message"] == "OK"
            @env[:ui].info "Successfully created SMB share for #{hostpath}}"
          end
        end

        def mount_shared_folders_to_linux
          # Find Host Machine's credentials
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})
          host_share_username = @env[:machine].provider_config.host_share.username
          host_share_password = @env[:machine].provider_config.host_share.password
          @smb_shared_folders.each do |id, data|
            begin
              prepare_smb_share(data)
              # Mount the Network drive to Guest VM
              @env[:ui].info "Linking to Guest at  ==> #{data[:guestpath]}"

              # Create a folder in guest against the guestpath
              @env[:machine].communicate.sudo("mkdir -p '#{data[:guestpath]}'")
              owner = data[:owner] || ssh_info[:username]
              group = data[:group] || ssh_info[:username]

              mount_options  = "-o rw,username=#{host_share_username},pass=#{host_share_password},"
              mount_options  += "sec=ntlm,file_mode=0777,dir_mode=0777,"
              mount_options  += "uid=`id -u #{owner}`,gid=`id -g #{group}` '#{data[:guestpath]}'"

              command = "mount -t cifs //#{result["host_ip"]}/#{data[:share_name]} #{mount_options}"
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
