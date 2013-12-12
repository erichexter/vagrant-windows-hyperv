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

require "win32ole"
require "pathname"
require "logger"
module VagrantPlugins
  module HyperV
  	module WMIProvider

  		wmi_root = Pathname.new(File.expand_path("../wmi-provider", __FILE__))
  		autoload :Machine, wmi_root.join('machine')
      autoload :Connection, wmi_root.join('connection')

      WMILogger = Logger.new(STDOUT)
      WMILogger.level = Logger::INFO
      WMILogger.formatter = proc do |severity, datetime, progname, msg|
        "WIN32 -- #{severity}: #{msg}\n"
      end
  	end
  end
end
