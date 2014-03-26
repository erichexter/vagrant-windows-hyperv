#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "json"
require "#{Vagrant::source_root}/plugins/providers/hyperv/driver"
require "vagrant/util/powershell"

module VagrantPlugins
  module VagrantHyperV
    class Driver < VagrantPlugins::HyperV::Driver

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
        script_path = local_script_path('run_in_remote.ps1')
        # FIXME:  Vagrant's core driver method which executes PowerShell,
        # need to take an &block so that this piece of code can be avoided.
        ps_options = []
        options.each do |key, value|
          ps_options << "-#{key}"
          ps_options << "'#{value}'"
        end
        ps_options << "-ErrorAction" << "Stop"
        opts = { notify: [:stdout, :stderr, :stdin] }
        Vagrant::Util::PowerShell.execute(script_path, *ps_options, **opts, &block)
      end

      def export_vm_to(path)
        options = {
           vm_id: vm_id,
           path: windows_path(path)
         }
        script_path = local_script_path('export_vm.ps1')
        execute(script_path, options)
      end

      def upload(from, to)
        options = {
          vm_id: vm_id,
          host_path: windows_path(from),
          guest_path: windows_path(to)
        }.merge(remote_credentials)
        script_path = local_script_path('upload_file.ps1')
        execute(script_path, options)
      end

      def check_winrm
        script_path = local_script_path('check_winrm.ps1')
        execute(script_path, remote_credentials)
      end

      def get_host_ip
        script_path = local_script_path('host_info.ps1')
        execute(script_path, {})
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
