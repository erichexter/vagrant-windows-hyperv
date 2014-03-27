#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "pathname"
require "vagrant-hyperv/plugin"

module VagrantPlugins
  module VagrantHyperV
    lib_path = Pathname.new(File.expand_path("../vagrant-hyperv", __FILE__))
    autoload :Action, lib_path.join("action")
    autoload :Errors, lib_path.join("errors")
    autoload :Driver, lib_path.join("driver")

    # Load a communicator for Windows guest
    require lib_path.join("communication/powershell")

    # Include the provision scripts for Windows
    require lib_path.join("provisioner/shell")
    require lib_path.join("provisioner/puppet")
    require lib_path.join("provisioner/chef_solo")

    monkey_patch = Pathname.new(File.expand_path("../vagrant-hyperv/monkey_patch", __FILE__))
    # Monkey Patch the core Hyper-V vagrant with the following
    require monkey_patch.join("plugins/synced_folders/smb/synced_folders")
    require monkey_patch.join("action/provision")
    require monkey_patch.join("machine")

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end
