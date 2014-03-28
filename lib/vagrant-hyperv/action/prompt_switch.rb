# Check if there are any customization for Virtual Switches
          customization = nil
          env[:machine].provider_config.customizations.each do |event, command|
            if event == "pre-boot"
              next if command[0] != "virtual_switch"
              customization = command
            end
          end
          if customization

            switches = env[:machine].provider.driver.execute("get_switches.ps1", {})
            raise Errors::NoSwitches if switches.empty?

            switch = switches[0]["Name"]
            if switches.length > 1
              env[:ui].detail(I18n.t("vagrant_hyperv.choose_switch") + "\n ")
              switches.each_index do |i|
                switch = switches[i]
                env[:ui].detail("#{i+1}) #{switch["Name"]}")
              end
              env[:ui].detail(" ")

              switch = nil
              while !switch
                switch = env[:ui].ask("What switch would you like to use? ")
                next if !switch
                switch = switch.to_i - 1
                switch = nil if switch < 0 || switch >= switches.length
              end
              switch = switches[switch]["Name"]
            end
          end
