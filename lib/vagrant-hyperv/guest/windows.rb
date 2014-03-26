#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------
require "vagrant"

module VagrantPlugins
  module VagrantHyperV
    module Guest
      class Windows < Vagrant.plugin("2", :guest)
        attr_reader :machin

        def initialize(machine = nil)
          super(machine) unless machine == nil
          @machine = machine
        end

        def halt
          VagrantHyperV::VagrantPlugins::Guest::Cap::Halt.halt(@machine)
        end

      end
    end
  end
end
