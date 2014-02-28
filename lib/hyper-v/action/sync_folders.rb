#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "log4r"
require "vagrant/util/subprocess"
require "vagrant/util/which"
module VagrantPlugins
  module HyperV
    module Action
      class SyncFolders

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_hyperv::action::sync_folders")
        end

        def call(env)
          @env = env
          @app.call(env)
          synced_folders

          if @synced_folders.length > 0
            env[:ui].info "Syncing folders from Host to Guest"
          end
          if env[:machine].provider_config.guest == :windows
            sync_folders_to_windows
          elsif env[:machine].provider_config.guest == :linux
            sync_folders_to_linux
          end
        end

        def ssh_info
          @ssh_info ||= @env[:machine].ssh_info
        end

        def synced_folders
          @synced_folders = {}
          @env[:machine].config.vm.synced_folders.each do |id, data|
            # Ignore disabled shared folders
            next if data[:disabled]

            # Collect all SMB shares
            next if data[:smb]
            # This to prevent overwriting the actual shared folders data
            @synced_folders[id] = data.dup
          end
        end

        def sync_folders_to_windows
          @synced_folders.each do |id, data|
            from = File.expand_path(data[:hostpath], @env[:root_path])
            to = data[:guestpath]
            response = @env[:machine].provider.driver.upload(from, to)
            # TODO
            # There is a script file_sync which does the delta copy. Just to keep
            # the upload function clean using upload function
            # response = @env[:machine].provider.driver.execute('file_sync.ps1', options)
            end
        end

        def sync_folders_to_linux
          if ssh_info.nil?
            @env[:ui].info('SSH Info not available, Aborting Sync folder')
            return
          end
          @synced_folders.each do |id, data|
            hostpath  = File.expand_path(data[:hostpath], @env[:root_path])
            guestpath = data[:guestpath]
            begin
              # Make sure the guest's parent directory exists
              pa = Pathname.new(guestpath)
              @env[:machine].communicate.tap do |comm|
                comm.sudo("mkdir -p #{pa.parent.to_s}")
                comm.sudo("chmod 0777 #{pa.parent.to_s}")
              end
              @env[:machine].communicate.upload(hostpath, guestpath)
            rescue RuntimeError => e
              @env[:ui].error(e.message)
            end

          end
        end

      end
    end
  end
end
