# Copyright 2017 Noragh Analytics, Inc.
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

require_relative '../helpers/coverage_helper'
require_relative '../helpers/integration_helper'

require_relative '../../lib/environment'
Armagh::Environment.init

require_relative '../helpers/mongo_support'

require_relative '../../lib/authentication'

require 'test/unit'

class TestAuthentication < Test::Unit::TestCase

  def setup
    MongoSupport.instance.clean_database

    Armagh::Authentication::User.setup_default_users
    Armagh::Authentication::Group.setup_default_groups
  end

  def test_user_group_membership
    user1 = Armagh::Authentication::User.create(username: 'user1', password: 'testpassword')
    user2 = Armagh::Authentication::User.create(username: 'user2', password: 'testpassword')

    group1 = Armagh::Authentication::Group.create(name: 'group 1', description: 'test group')
    group2 = Armagh::Authentication::Group.create(name: 'group 2', description: 'test group')

    user1.join_group group1
    group1.add_user user2

    group1.save
    group2.save

    assert_true group1.has_user? user1
    assert_true group1.has_user? user2
    assert_false group2.has_user? user1
    assert_false group2.has_user? user2

    assert_true user1.member_of? group1
    assert_true user2.member_of? group1

    assert_false user1.member_of? group2
    assert_false user2.member_of? group2



    user1.delete
    group1.refresh
    assert_false group1.has_user? user1

    assert_true user2.member_of? group1
    group1.delete
    user2.refresh
    assert_false user2.member_of? group1
  end

  def test_permissions
    user1 = Armagh::Authentication::User.create(username: 'user1', password: 'testpassword')
    user2 = Armagh::Authentication::User.create(username: 'user2', password: 'testpassword')

    group1 = Armagh::Authentication::Group.create(name: 'group 1', description: 'test group')
    group2 = Armagh::Authentication::Group.create(name: 'group 2', description: 'test group')

    pub_collection = MongoSupport.instance.create_collection('documents.PubType')
    doctype_role = Armagh::Authentication::Role.published_collection_role(pub_collection)

    user1.join_group group1
    user1.join_group group2
    user2.join_group group2

    user1.add_role Armagh::Authentication::Role::RESOURCE_ADMIN
    user1.add_role Armagh::Authentication::Role::USER

    user2.add_role Armagh::Authentication::Role::APPLICATION_ADMIN
    user2.add_role doctype_role

    group1.add_role Armagh::Authentication::Role::USER_ADMIN
    group2.add_role Armagh::Authentication::Role::USER_MANAGER

    user1.save
    user2.save
    group1.save
    group2.save

    # User 1 direct
    assert_true user1.has_role? Armagh::Authentication::Role::RESOURCE_ADMIN
    assert_true user1.has_role? Armagh::Authentication::Role::USER

    # User1 indirect
    assert_true user1.has_role? doctype_role

    # User1 through Groups
    assert_true user1.has_role? Armagh::Authentication::Role::USER_ADMIN
    assert_true user1.has_role? Armagh::Authentication::Role::USER_MANAGER

    # User1 no
    assert_false user1.has_role? Armagh::Authentication::Role::APPLICATION_ADMIN

    # User2 direct
    assert_true user2.has_role? Armagh::Authentication::Role::APPLICATION_ADMIN
    assert_true user2.has_role? doctype_role

    # User2 indirect
    assert_false user2.has_role? Armagh::Authentication::Role::USER

    # User2 through groups
    assert_true user2.has_role? Armagh::Authentication::Role::USER_MANAGER

    # User2 no
    assert_false user2.has_role? Armagh::Authentication::Role::RESOURCE_ADMIN
  end
end