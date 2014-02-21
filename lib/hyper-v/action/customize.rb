#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the MIT License.
#--------------------------------------------------------------------------
require "debugger"
require "log4r"
module VagrantPlugins
  module HyperV
    module Action
      class Customize
        def initialize(app, env, event)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::connection")
          @event = event
        end

        def call(env)
          customizations = []
          @env = env
          env[:machine].provider_config.customizations.each do |event, command|
            if event == @event
              customizations << command
            end
          end
          if !customizations.empty?
            env[:ui].info "Running customizations for the machine"
            customizations.each do |query|
              command = query[0]
              params = query[1]
              if self.respond_to?("custom_action_#{command}")
                self.send("custom_action_#{command}", params)
              end
            end
          end
          @app.call(env)
        end

        def custom_action_memory(memory)
          begin
            return if memory.nil? || memory.to_i == 0
            options = { vm_id: @env[:machine].id,
                        ram_memory: memory
                      }
            @env[:machine].provider.driver.execute('assign_memory.ps1', options)
          rescue Error::SubprocessError => e
            raise "Customize virtual_switch failed with options #{params}"
          end
        end

        def custom_action_virtual_switch(params)
          begin
            options = { vm_id: @env[:machine].id,
                        type: params[:type]  || "External",
                        name: params[:name]
                      }
            @env[:machine].provider.driver.execute('create_switch.ps1', options)
          rescue Error::SubprocessError => e
            raise "Customize virtual_switch failed with options #{params}"
          end
        end
      end
    end
  end
end
