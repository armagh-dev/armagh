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

require_relative '../../test/helpers/mongo_support'

require 'test/unit/assertions'

Given(/^mongo is running$/) do
  MongoSupport.instance.start_mongo
  assert_true(MongoSupport.instance.running?, "Problem Connecting:\n  ####\n#{MongoSupport.instance.get_mongo_output}####\n")
end

Given(/^mongo is clean/) do
  MongoSupport.instance.clean_database
end

And(/^mongo isn't running$/) do
  if MongoSupport.instance.running?
    MongoSupport.instance.stop_mongo
  end
  assert_false MongoSupport.instance.running?
end