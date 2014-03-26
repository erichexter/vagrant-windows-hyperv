#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

require "fileutils"

module VagrantPlugins
  module VagrantHyperV
    module Action
      class Export
         attr_reader :temp_dir
         def initialize(app, env)
           @app = app
         end

         def call(env)
           @env = env

           raise "Please off the machine before package" if \
             @env[:machine].provider.state.id != :off

           @temp_dir = env[:tmp_path].join(Time.now.to_i.to_s)
           export
           add_metadata_json

           @app.call(env)

           recover(env) # called to cleanup temp directory
         end

         def recover(env)
           if temp_dir && File.exist?(temp_dir)
             FileUtils.rm_rf(temp_dir)
           end
         end

         def export
           @env[:ui].info('Exporting the VM, this process may take a while.')
           result = @env[:machine].provider.driver.export_vm_to(temp_dir.to_s)
           # Hyper-V Exports the VM under the VM's name in to the temp directory.
           # Set the package directory to this folder, all files should go into this folder
           @env["package.directory"] = temp_dir.join(result["name"])
         end

         def add_metadata_json
           File.open(File.join(@env["package.directory"], "metadata.json"), "w") do |f|
             f.write(' { "provider" : "hyperv" }')
           end
         end
      end
    end
  end
end
