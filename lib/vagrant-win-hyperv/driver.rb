#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "json"
require "#{Vagrant::source_root}/plugins/providers/hyperv/driver"
require "vagrant/util/powershell"

module VagrantPlugins
  module HyperV
    class Driver

      def initialize(machine)
        @vm_id = machine.id
        @machine = machine
      end

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
        path = local_script_path('run_in_remote.ps1')
        execute(path, options, &block)
      end

      def export_vm_to(path)
        options = {
           vm_id: vm_id,
           path: windows_path(path)
         }
        path = local_script_path('export_vm.ps1')
        execute(path, options)
      end

      def upload(from, to)
        options = {
          vm_id: vm_id,
          host_path: windows_path(from),
          guest_path: windows_path(to)
        }.merge(remote_credentials)
        path = local_script_path('upload_file.ps1')
        execute(path,options)
      end

      protected

      def local_script_path(path)
        lib_path = Pathname.new(File.expand_path("../scripts", __FILE__))
        lib_path.join(path).to_s
      end

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
