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
      class Connection
        attr_reader :connection
        def initialize(path)
          @connection = WIN32OLE.connect(path)
        end

    		def virtual_host
    	    @host ||= find_virtual_host
    	  end

    	  def find_virtual_host
    	    execute('Select * from Msvm_VirtualSystemManagementService').each do |host|
    	      return host
    	    end
    	  end

    	  def find_vm_by_id(machine_id)
    	    machine = nil
          #FIXME:sanitize string to avoid SQL injection
          # If this is required in more than one place. find a better place to make it generic.
          machine_id = machine_id.to_s.gsub(/\\/, '\&\&').gsub(/'/, "''")
    	    execute("Select * from Msvm_ComputerSystem where Caption = 'Virtual Machine' AND Name = '#{machine_id}'").each do |m|
    	      machine = WMIProvider::Machine.new(m, connection)
    	    end
    	    machine
    	  end

        def find_vm_by_name(name)
          machine = nil
          #FIXME:sanitize string to avoid SQL injection
          # If this is required in more than one place. find a better place to make it generic.
          name = name.to_s.gsub(/\\/, '\&\&').gsub(/'/, "''")
          execute("Select * from Msvm_ComputerSystem where Caption = 'Virtual Machine' AND ElementName = '#{name}'").each do |m|
            machine = WMIProvider::Machine.new(m, connection)
          end
          machine
        end

        def import(options)
          # Define a Virtual Machine.
          virtual_host.ImportSystemDefinition(options[:xml_path], options[:root_folder], options[:need_unique_id], nil, nil)
          planned_vm = WIN32OLE::ARGV[3]
          machine = connection.Get(planned_vm)

          # Get a setting object for the machine
          settings = nil
          connection.ExecQuery("Select * from Msvm_VirtualSystemSettingData where ElementName = '#{machine.ElementName}'").each do |host|
            next if !host.InstanceID.include?(machine.Name)
            settings = host
          end

          # Set a Unique Name for this VM
          begin
            machine_exist = find_vm_by_name(settings.ElementName)
            settings.ElementName = settings.ElementName + "_1" if machine_exist
          end until machine_exist.nil?
          settings.NetworkBootPreferredProtocol = nil
          # Modify the system
          s_result = virtual_host.ModifySystemSettings(settings.GetText_(1))

          # Define a System
          job = Object.new
          comp = Object.new
          a = virtual_host.DefineSystem(settings.GetText_(1), [], nil, comp, job)
          comp = WIN32OLE::ARGV[3]
          machine = connection.Get(comp)
          # Attach a VHD To Virtual Machine, Using powershell.
          command = [
            "powershell", "Add-VMHardDiskDrive", "-VMName", "'#{machine.ElementName}'",
            "-Path", "'#{options[:vhdx_path]}'"
          ]
          Vagrant::Util::Subprocess.execute(*command)

          # Add a Network Switch
          # TODO: Read the exact switch name from config
          switch_name = "External Switch"
          command = [
            "powershell", "Add-VMNetworkAdapter", "-VMName", machine.ElementName,
            "-SwitchName", "'#{switch_name}'"
          ]
          Vagrant::Util::Subprocess.execute(*command)
          return WMIProvider::Machine.new(machine, connection)
        end

        def get_job_status(status)
          #FIXME: Find a nice logging way
          sleep 1
          job = connection.Get(status)
          job_type = job.Caption
          WMILogger.info "Started #{job_type}"
          error = false
          while ((job && job.PercentComplete < 100) && !error ) do
            WMILogger.info "Started #{job_type} --%03d%" % job.PercentComplete
            sleep 1
            job = connection.Get(status)
            error = job.GetError > 0
          end
          WMILogger.info(error ? "Some error #{job.GetError}" :  "#{job_type} Complete")
        end

        private
        def execute(query)
          connection.ExecQuery(query)
        end
    	end
    end
  end
end

