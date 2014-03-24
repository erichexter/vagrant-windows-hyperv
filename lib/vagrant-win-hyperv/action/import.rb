#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "log4r"

module VagrantPlugins
  module VagrantHyperV
    module Action
      class Import
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::connection")
        end

        def call(env)
          @env = env
          box_directory = env[:machine].box.directory.to_s
          path = Pathname.new(box_directory.to_s + '/Virtual Machines')
          config_path = ""
          path.each_child do |f|
            config_path = f.to_s if f.extname.downcase == ".xml"
          end

          path = Pathname.new(box_directory.to_s + '/Virtual Hard Disks')
          vhdx_path = ""
          path.each_child do |f|
            vhdx_path = f.to_s if f.extname.downcase == ".vhdx"
          end

          switches = env[:machine].provider.driver.execute("get_switches.ps1", {})
          raise Errors::NoSwitches if switches.empty?

          selected_switch = display_switch_list(switches)

          options = {
            vm_xml_config:  config_path.gsub("/", "\\"),
            vhdx_path: vhdx_path.gsub("/", "\\"),
            switchname: selected_switch
          }

          env[:ui].info "Importing a Hyper-V instance"
          server = env[:machine].provider.driver.execute('import_vm.ps1', options)
          env[:ui].info "Successfully imported a VM with name   #{server['name']}"
          env[:machine].id = server["id"]
          @app.call(env)
        end

        def display_switch_list(switches)
          switch = switches[0]["Name"]
          if switches.length > 1
            @env[:ui].info(I18n.t("vagrant_hyperv.choose_switch") + "\n ")
            switches.each_index do |i|
              switch = switches[i]
              @env[:ui].info("#{i+1}) #{switch["Name"]}")
            end
            @env[:ui].info(" ")

            switch = nil
            while !switch
              switch = @env[:ui].ask("What switch would you like to use? ")
              next if !switch
              switch = switch.to_i - 1
              switch = nil if switch < 0 || switch >= switches.length
            end
            switches[switch]["Name"]
          end
        end

      end
    end
  end
end
