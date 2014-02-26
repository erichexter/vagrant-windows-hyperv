#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
module VagrantPlugins
  module HyperV
    module Provisioner
      lib_path = Pathname.new(File.expand_path("../provisioner", __FILE__))
      autoload :Shell, lib_path.join("shell")
    end
  end
end
