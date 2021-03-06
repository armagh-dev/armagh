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

class User
  attr_reader :id, :username, :name, :roles, :groups, :auth_failures, :directory, :password_timestamp, :permanent, :updated_timestamp, :created_timestamp, :last_login, :email, :disabled, :locked
  attr_accessor :required_password_reset, :password, :show_retired, :expand_all, :doc_viewer

  def initialize(fields)
    fields[:show_retired] = false
    fields[:expand_all]   = true
    fields[:doc_viewer]   = {}
    fields.each { |field, value| self.instance_variable_set "@#{field}", value }
  end

end
