#--------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require 'log4r'

# Barebones basic implemenation. This a work in progress in very early stages
module VagrantPlugins
  module WinAzure
    module Action
      class StopInstance
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::stop_instance')
        end

        def call(env)
          env[:machine].id = "#{env[:machine].provider_config.vm_name}@#{env[:machine].provider_config.cloud_service_name}" unless env[:machine].id
          env[:machine].id =~ /@/

          env[:ui].info "Attempting to stop '#{$`}' in '#{$'}'"

          env[:azure_vm_service].shutdown_virtual_machine(
            $`, $'
          )

          @app.call(env)
        end
      end
    end
  end
end
