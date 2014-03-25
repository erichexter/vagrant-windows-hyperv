#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module Vagrant
  class Machine

    alias_method :original_communicate, :communicate

    def communicate
      unless @communicator
        if @config.guest.type == :windows
          @communicator = VagrantPlugins::VagrantHyperV::Communicator::PowerShell.new(self)
        else
         @communicator = original_communicate
        end
      end
      @communicator
    end
  end
end
