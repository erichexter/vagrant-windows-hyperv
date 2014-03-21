#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module HyperV
    module Action
      class StartInstance
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info('Starting the Machine')
          response = env[:machine].provider.driver.start
          @app.call(env)
        end
      end
    end
  end
end
