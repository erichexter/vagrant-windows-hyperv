#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module VagrantHyperV
    module Guest
      module Cap
        class Halt
          def self.halt(machine)
            machine.provider.driver.run_remote_ps("shutdown -a")
            machine.provider.driver.run_remote_ps("shutdown /s /t 1")
          end
        end
      end
    end
  end
end
