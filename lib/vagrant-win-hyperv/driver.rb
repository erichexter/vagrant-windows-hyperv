#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "vagrant/util/subprocess"

require "#{Vagrant::source_root}/plugins/providers/hyperv/driver"

module VagrantPlugins
  module VagrantHyperV
    class Driver < VagrantPlugins::HyperV::Driver

      def ssh_info
        @ssh_info ||= @machine.ssh_info
      end

      def remote_credentials
        @remote_credentials ||= {  guest_ip: ssh_info[:host],
           username:  ssh_info[:username],
           password: "vagrant" }
      end

      def run_remote_ps(command, &block)
        options = remote_credentials.merge(command: command)
        execute('run_in_remote.ps1', options, &block)
      end

      def export_vm_to(path)
        options = {
           vm_id: vm_id,
           path: windows_path(path)
         }
        execute("export_vm.ps1", options)
      end

      def upload(from, to)
        options = {
          vm_id: vm_id,
          host_path: windows_path(from),
          guest_path: windows_path(to)
        }.merge(remote_credentials)
        execute('upload_file.ps1',options)
      end

      protected

      def windows_path(path)
        if path
          path = path.gsub("/","\\")
          path = "c:#{path}" if path =~ /^\\/
        end
        path
      end

    end
  end
end
