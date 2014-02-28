#---------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require 'azure'
require 'log4r'

module VagrantPlugins
  module WinAzure
    module Action
      class ConnectAzure
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::connect_aws')
        end

        def call (env)
          config = env[:machine].provider_config

          Azure.configure do |c|
            c.storage_account_name                  = config.storage_acct_name
            c.storage_access_key                    = config.storage_access_key

            c.sb_namespace                          = config.sb_namespace
            c.sb_access_key                         = config.sb_access_key
            c.sb_issuer                             = config.sb_issuer

            c.management_certificate                = config.mgmt_certificate
            c.subscription_id                       = config.subscription_id
            c.management_endpoint                   = config.mgmt_endpoint
          end

          env[:azure_vm_service] = Azure::VirtualMachineManagementService.new

          @app.call(env)
        end
      end
    end
  end
end
