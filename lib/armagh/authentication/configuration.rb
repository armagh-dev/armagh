# Copyright 2018 Noragh Analytics, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'configh'

module Armagh
  module Authentication
    class Configuration
      CONFIG_NAME = 'default'

      include Configh::Configurable

      define_parameter name: 'max_login_attempts', type: 'positive_integer', description: 'Maximum number of allowed failed login attempts before locking account.', required: true, default: 3, group: 'authentication'
      define_parameter name: 'min_password_length', type: 'positive_integer', description: 'Minimum length of a password.', required: true, default: 8, group: 'authentication'
    end
  end
end
