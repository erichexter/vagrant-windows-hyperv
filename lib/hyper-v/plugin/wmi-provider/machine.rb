#-------------------------------------------------------------------------
# Copyright 2013 Microsoft Open Technologies, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module HyperV
    module WMIProvider
      class Machine
        attr_reader :machine
        attr_reader :connection
        MachineState = {
          '0' => "unknown",
          '1' => "other",
          '2' => "enabled",
          '3' =>  "stopped",
          '4' => "shutting_down",
          '5' => "not_applicable",
          '6' => "enabled_but_offline",
          '7' => "in_test",
          '8' => "deferred",
          '9' => "quiesce",
          '10' => "starting"
        }

        def initialize(machine, connection)
          @machine = machine
          @connection = connection
        end

        def name
          machine.ElementName
        end

        def state
          MachineState[machine.EnabledState.to_s]
        end

        def id
          machine.Name
        end

        def path
          machine.Path_.Path
        end

        def start
          job = Object.new
          machine.RequestStateChange(2, job, nil)
        end

        def stop
          command = ["powershell", "Stop-VM", "-Name", machine.ElementName]
          r = Vagrant::Util::Subprocess.execute(*command)
        end

        def ip_address
          network_apaters = adapters = connection.ExecQuery("Select * from Msvm_GuestNetworkAdapterConfiguration")
          for adapter in network_apaters
            if adapter.InstanceID.split('\\').include?(self.id)
              return adapter.IPAddresses.first
            end
          end
        end

        def export(options)
          # Make a Query to get Export configurations
          query = "ASSOCIATORS OF {#{path}} WHERE resultClass = Msvm_VirtualSystemExportSettingData"
          config = Services.execute(query)
          config.each do |c|
            # TODO: Check for nil in each of the options and set the default value
            c.CopySnapshotConfiguration = options[:copy_snapshot]
            c.CopyVmStorage = options[:copy_vm_storgae]
            c.CopyVmRuntimeInformation = options[:copy_run_time_info]
            # TODO: Check if a valid directory exists
            c.CreateVmExportSubdirectory = options[:export_sub_dir]
          end
          # Build a XML data for this config Using (GetText_(1))
          export_settings = ''
          config.each do |c|
            export_settings = c.GetText_(1)
          end
          # Export this machine from virtual host
          exportJobRef = Object.new
          Services.virtual_host.ExportSystemDefinition(path, options[:path_to_export], export_settings, exportJobRef)
          get_job_status(WIN32OLE::ARGV[3])
        end

        def get_job_status(status)
          # This method is to tell the current job status when an export or import function is called.
          # ARGV[3] is the Fourth argument passed to ExportSystemDefinition
          sleep 1
          job = connection.Get(status)
          while (job && job.PercentComplete < 100 && job.ErrorCode == 0) do
            print " -- #{job.ErrorCode} -- Started #{job.Caption} --%02d%" % job.PercentComplete
            sleep 1
            print "\r"
            job = connection.Get(status)
          end
          puts "\n #{job.Caption} Complete"
        end

      end
    end
  end
end
