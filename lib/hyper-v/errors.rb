#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
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

      class SSHNotAvailable < VagrantHyperVError
        error_key(:ssh_not_available)
      end

      class RDPNotAvailable < VagrantHyperVError
        error_key(:rdp_not_available)
      end

      class IPTimeOut < VagrantHyperVError
        error_key(:ip_time_out)
      end

      class NoSwitches < VagrantHyperVError
        error_key(:no_switches)
      end

      class NetShareError < RuntimeError
        attr_reader :message
        def initialize(options)
          @message = options[:stderr]
        end
      end
    end
  end
end
