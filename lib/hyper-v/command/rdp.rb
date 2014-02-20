#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "pathname"
require "vagrant/util/subprocess"
module VagrantPlugins
  module HyperV
    class Command  < Vagrant.plugin(2, :command)
      def execute
        if Pathname.new("machine.rdp").exist?
          command = ["mstsc", "machine.rdp"]
          Vagrant::Util::Subprocess.execute(*command)
          0
        else
          @env.ui.info "No rdp file found, please use vagrant up (or) vagrant reload to generate one"
        end
      end
    end
  end
end
