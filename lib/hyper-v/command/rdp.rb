#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "vagrant/util/subprocess"
module VagrantPlugins
  module HyperV
    class Command  < Vagrant.plugin(2, :command)
      def execute
        command = ["mstsc", "machine.rdp"]
        Vagrant::Util::Subprocess.execute(*command)
        0
      end
    end
  end
end
