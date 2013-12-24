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

        def import(options)
          virtual_host.ImportSystemDefinition(options[:xml_path], options[:root_folder], options[:need_unique_id], nil, nil)
          planned_vm = WIN32OLE::ARGV[3]
          vm = connection.Get(planned_vm)
          job = Object.new
          virtual_host.RealizePlannedSystem(planned_vm,nil, job)
          get_job_status(WIN32OLE::ARGV[2])
          return WMIProvider::Machine.new(vm, connection)
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

