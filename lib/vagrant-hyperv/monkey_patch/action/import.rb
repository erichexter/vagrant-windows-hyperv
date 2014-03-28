#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "fileutils"

require "log4r"

module VagrantPlugins
  module HyperV
    module Action
      class Import
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant::hyperv::import")
        end

        def call(env)
          vm_dir = env[:machine].box.directory.join("Virtual Machines")
          hd_dir = env[:machine].box.directory.join("Virtual Hard Disks")

          if !vm_dir.directory? || !hd_dir.directory?
            raise Errors::BoxInvalid
          end

          config_path = nil
          vm_dir.each_child do |f|
            if f.extname.downcase == ".xml"
              config_path = f
              break
            end
          end

          vhdx_path = nil
          hd_dir.each_child do |f|
            if f.extname.downcase == ".vhdx"
              vhdx_path = f
              break
            end
          end

          if !config_path || !vhdx_path
            raise Errors::BoxInvalid
          end

          env[:ui].output("Importing a Hyper-V instance")

          # Check if there are any customization for Virtual Switches
          customization = nil
          env[:machine].provider_config.customizations.each do |event, command|
            if event == "pre-boot"
              next if command[0] != "virtual_switch"
              customization = command
            end
          end

          if customization
            begin
              options = { vm_id: @env[:machine].id,
                          type: params[:type].downcase  || "external",
                          name: params[:name],
                          adapter: params[:bridge] || ""
                        }
              if options[:type] == "external" && options[:adapter].empty?
                adapters = env[:machine].provider.driver.execute("get_adapters.ps1", {})
                options[:adapter] = choose_option_from(adapters, "adapter")
              end
              @env[:machine].provider.driver.list_net_adapters
              switch = params[:name]
            rescue #Error::SubprocessError => e
              raise "Customize virtual_switch failed with options #{params}"
            end
          else
            switches = env[:machine].provider.driver.execute("get_switches.ps1", {})
            raise Errors::NoSwitches if switches.empty?
            switch = choose_option_from(adapters, "adapter")
          end


          env[:ui].detail("Cloning virtual hard drive...")
          source_path = vhdx_path.to_s
          dest_path   = env[:machine].data_dir.join("disk.vhdx").to_s
          FileUtils.cp(source_path, dest_path)
          vhdx_path = dest_path

          # We have to normalize the paths to be Windows paths since
          # we're executing PowerShell.
          options = {
            vm_xml_config:  config_path.to_s.gsub("/", "\\"),
            vhdx_path:      vhdx_path.to_s.gsub("/", "\\")
          }
          options[:switchname] = switch if switch

          env[:ui].detail("Creating and registering the VM...")
          server = env[:machine].provider.driver.import(options)
          env[:ui].detail("Successfully imported a VM with name: #{server['name']}")
          env[:machine].id = server["id"]
          @app.call(env)
        end

        def choose_option_from(options, key)
          if options.length > 1
            env[:ui].detail(I18n.t("vagrant_hyperv.choose_#{key}") + "\n ")
            options.each_index do |i|
              selected = options[i]
              env[:ui].detail("#{i+1}) #{options["Name"]}")
            end
            env[:ui].detail(" ")

            selected = nil
            while !selected
              selected = env[:ui].ask("What #{key} would you like to use? ")
              next if !selected
              selected = selected.to_i - 1
              selected = nil if selected < 0 || selected >= options.length
            end
            options[selected]["Name"]
          end
        end
      end
    end
  end
end
