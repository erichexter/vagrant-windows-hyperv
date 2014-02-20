#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "vagrant/util/subprocess"
module VagrantPlugins
  module HyperV
    module Action
      class ShareFolders

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
          end

          if env[:machine].provider_config.guest == :windows
            mount_shared_folders_to_windows
            env[:ui].info "Generating a RDP file."
            generate_rdp_file
          elsif env[:machine].provider_config.guest == :linux
            prepare_smb_share
            mount_shared_folders_to_linux
          end
          @app.call(env)
        end

        def smb_shared_folders
          @smb_shared_folders = {}
          @env[:machine].config.vm.synced_folders.each do |id, data|
            # Ignore disabled shared folders
            next if data[:disabled]

            # Collect all SMB shares
            next unless data[:smb]
            # This to prevent overwriting the actual shared folders data
            @smb_shared_folders[id] = data.dup
            @smb_shared_folders[id][:share_name] = @smb_shared_folders[id][:share_name].gsub(" ","_")
          end
        end

        def prepare_smb_share
          @smb_shared_folders.each do |id, data|
            begin
              hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
              host_share_username = @env[:machine].provider_config.host_share.username
              options = {:path => hostpath,
                         :share_name => data[:share_name],
                         :host_share_username => host_share_username}
              response = @env[:machine].provider.driver.execute('set_smb_share.ps1', options)
              if response["message"] == "OK"
                @env[:ui].info "Successfully created SMB share for #{hostpath} with name #{data[:share_name]}"
              end
            rescue Error::SubprocessError => e
              @env[:ui].info e.message
            end
          end
        end

        def ssh_info
          @ssh_info || @env[:machine].ssh_info
        end

        def mount_shared_folders_to_windows
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})
          @smb_shared_folders.each do |id, data|
            hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
            begin
              options = { :guest_path => data[:guestpath].gsub("/", "\\"),
                          :hostpath => hostpath.gsub("/", "\\"),
                          :guest_ip => ssh_info[:host],
                          :username => ssh_info[:username],
                          :host_ip => result["host_ip"],
                          :password => "vagrant"}
              @env[:ui].info("Linking #{data[:share_name]} to Guest at #{data[:guestpath]} ...")
              @env[:machine].provider.driver.execute('mount_share.ps1', options)
            rescue Error::SubprocessError => e
              @env[:ui].info "Failed to link #{data[:share_name]} to Guest"
              @env[:ui].info e.message
            end
          end
        end

        def generate_rdp_file
            rdp_options = {
              "drivestoredirect:s" => "*",
              "username:s" => ssh_info[:username],
              "prompt for credentials:i" => "1",
              "full address:s" => ssh_info[:host]
            }
            file = File.open("machine.rdp", "w")
              rdp_options.each do |key, value|
                file.puts "#{key}:#{value}"
            end
            file.close
        end

        def mount_shared_folders_to_linux
          # Find Host Machine's credentials
          result = @env[:machine].provider.driver.execute('host_info.ps1', {})
          host_share_username = @env[:machine].provider_config.host_share.username
          host_share_password = @env[:machine].provider_config.host_share.password
          @smb_shared_folders.each do |id, data|
            begin
              # Mount the Network drive to Guest VM
              @env[:ui].info("Linking #{data[:share_name]} to Guest at #{data[:guestpath]} ...")

              # Create a location in guest to guestpath
              @env[:machine].communicate.sudo("mkdir -p '#{data[:guestpath]}'")
              owner = data[:owner] || ssh_info[:username]
              group = data[:group] || ssh_info[:username]

              mount_options  = "-o rw,username=#{host_share_username},pass=#{host_share_password},"
              mount_options  += "sec=ntlm,file_mode=0777,dir_mode=0777,"
              mount_options  += "uid=`id -u #{owner}`,gid=`id -g #{group}` '#{data[:guestpath]}'"

              command = "mount -t cifs //#{result["host_ip"]}/#{data[:share_name]} #{mount_options}"
              @env[:machine].communicate.sudo(command)

            rescue RuntimeError => e
              @env[:ui].error("Failed to mount at #{data[:guestpath]}")
            end
          end

        end
      end
    end
  end
end
