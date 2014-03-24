#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "pathname"
require "vagrant-win-hyperv/plugin"
require "debugger"

module VagrantPlugins
  module VagrantHyperV
    lib_path = Pathname.new(File.expand_path("../vagrant-win-hyperv", __FILE__))
    autoload :Action, lib_path.join("action")

    autoload :Provisioner, lib_path.join("provisioner")
    autoload :Errors, File.expand_path("../errors", __FILE__)

    # Monkey Patch the synced folders for SMB share for Windows guest
    require lib_path.join("synced_folders/smb/synced_folders")
    require lib_path.join("driver")

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end
