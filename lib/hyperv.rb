#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "pathname"
require "hyper-v/plugin"

module VagrantPlugins
  module HyperV
    lib_path = Pathname.new(File.expand_path("../hyper-v", __FILE__))
    autoload :Action, lib_path.join("action")
    autoload :Driver, lib_path.join("driver")
    autoload :Provisioner, lib_path.join("provisioner")

    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path("../../", __FILE__))
    end
  end
end
