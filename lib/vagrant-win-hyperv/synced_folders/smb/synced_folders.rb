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
        if machine.config.vm.guest == :windows
          machine.ui.output("My code. Thanks GOD")
        else
          original_enable
        end
      end

    end
  end
end

