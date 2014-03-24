#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "log4r"

module VagrantPlugins
  module VagrantHyperV
    module Action
      class SuspendInstance
        def initialize(app, env)
          @app    = app
        end

        def call(env)
          env[:ui].info('Suspending the Machine')
          response = env[:machine].provider.driver.suspend
          env[:ui].info "Machine #{response["name"]} suspended"
          @app.call(env)
        end
      end
    end
  end
end
