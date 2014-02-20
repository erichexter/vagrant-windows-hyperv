#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module HyperV
    module Action
      class ResumeInstance
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info('Resuming the Machine')
          options = { vm_id: env[:machine].id }
          begin
            response = env[:machine].provider.driver.execute('resume_vm.ps1', options)
            env[:ui].info "Machine #{response["name"]} resumed"
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
