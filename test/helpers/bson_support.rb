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

require 'bson'

module BSONSupport
  def self.random_object_id
    BSON::ObjectId.from_data(Random.new.bytes(12))
  end

  def self.random_object_ids(count)
    ids = []
    count.times {ids << random_object_id}
    ids
  end
end
