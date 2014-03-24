#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "log4r"

module VagrantPlugins
  module VagrantHyperV
    module Action
      class ReadState
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::connection")
        end

        def call(env)
          if env[:machine].id
              response = env[:machine].provider.driver.get_current_state
              env[:machine_state_id] = response["state"].downcase.to_sym
            if env[:machine_state_id] == :not_created
              env[:machine].id = nil
              env[:ui].info "Could not find a machine, assuming it to be deleted or terminated."
            end
          else
            env[:machine_state_id] = :not_created
          end
          @app.call(env)
        end

      end
    end
  end
end
