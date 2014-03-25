#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module VagrantHyperV
    module Errors
      class VagrantHyperVError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_win_hyperv.errors")
      end

      class SSHNotAvailable < VagrantHyperVError
        error_key(:ssh_not_available)
      end

      class RDPNotAvailable < VagrantHyperVError
        error_key(:rdp_not_available)
      end

      class InvalidSMBCredentials < VagrantHyperVError
        error_key(:no_smb_credentials)
      end

      class WinRMNotReady < VagrantHyperVError
        error_key(:win_rm_not_ready)
      end

    end
  end
end
