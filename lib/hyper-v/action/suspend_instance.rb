#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "log4r"
module VagrantPlugins
  module HyperV
    module Action
      class SuspendInstance
        def initialize(app, env)
          @app    = app
        end

        def call(env)
          env[:ui].info('Suspending the Machine')
          begin
            response = env[:machine].provider.driver.suspend
            env[:ui].info "Machine #{response["name"]} suspended"
          rescue Error::SubprocessError => e
            env[:ui].info e.message
            return
          end
          @app.call(env)
        end
      end
    end
  end
end
