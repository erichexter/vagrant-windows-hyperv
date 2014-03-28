#-------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved. Licensed under the Apache 2.0 License.
#--------------------------------------------------------------------------

module VagrantPlugins
  module HyperV
    module Action

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use Call, IsState, :not_created do |env1, b1|
            if env1[:result]
              b1.use Import
            end
            b1.use Customize, "pre-boot"
            b1.use action_start
          end
        end
      end

    end
  end
end
