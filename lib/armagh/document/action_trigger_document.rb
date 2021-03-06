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
require 'armagh/support/random'

require_relative 'document'

module Armagh
  class ActionTriggerDocument < Document

    def self.ensure_one_exists(state:, type:, pending_actions:, logger: nil)

      unless find_one_read_only( { 'type' => type, 'state' => state })
        values = {
            'document_id' => Armagh::Support::Random.random_id,
            'type' => type,
            'state' => state,
            'pending_actions' => pending_actions
        }
        create_one_unlocked( values, logger: logger )
        logger.debug "created one action trigger doc #{ values.inspect }" unless logger.nil?
      end
    end
  end
end
