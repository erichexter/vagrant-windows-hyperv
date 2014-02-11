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
    module HostShare
      class Config < Vagrant.plugin("2", :config)
        attr_accessor :username, :password

        def errors
          @errors
        end

        def validate
          @errors = []
          if username.nil?
            @errors << "Please configure a Windows user account to share folders"
          end
          if password.nil?
            @errors << "Please configure a Windows user account password to share folders"
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
