module VagrantPlugins
  module HyperV
    module Putty
      class Config < Vagrant.plugin("2", :config)
        attr_accessor :private_key_path

        def errors
          @errors
        end

        def validate
          @errors = []
          if private_key_path.nil?
            @errors << "Please configure a putty private key path"
          end
        end

        def valid_config?
          validate
          errors.empty?
        end

      end
    end
  end
end
