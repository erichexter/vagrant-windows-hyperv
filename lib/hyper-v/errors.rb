#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module HyperV
    module Errors
      class VagrantHyperVError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_hyperv.errors")
      end
      class AdminRequired < VagrantHyperVError
        error_key(:admin_required)
      end

      class PowerShellRequired < VagrantHyperVError
        error_key(:powershell_required)
      end

      class PowerShellError < VagrantHyperVError
        error_key(:powershell_error)
      end
    end
  end
end
