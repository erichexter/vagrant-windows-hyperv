#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------

require "log4r"
require "timeout"

module VagrantPlugins
  module HyperV
    module Action
      # This action checks if the Virtual Machine's boot sequence is complete
      # and the machine returns back its IP Address.
      class WaitForBootReady
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::connection")
        end

        def call(env)
          env[:ui].info "Waiting for the VM to Boot... [default timeout 120 sec]"
          ssh_info = nil
          ssh_info = env[:machine].ssh_info
          raise Errors::IPTimeOut if ssh_info.nil? || ssh_info[:host].nil?
          env[:ui].info "Virtual Machine's IP is #{ssh_info[:host]}"
          @app.call(env)
        end
      end
    end
  end
end
