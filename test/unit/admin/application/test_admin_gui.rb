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

require 'test/unit'
require 'mocha/test_unit'

require_relative '../../../helpers/coverage_helper'
require_relative '../../../helpers/armagh_test'
require_relative '../../../../lib/armagh/admin/application/admin_gui'

require 'armagh/actions/workflow'

module Armagh
  module Admin
    module Application
      class TestAdminGUI < Test::Unit::TestCase

        def setup
          @admin_gui = AdminGUI.instance
          @user      = mock('user')
          @user.stubs(username: 'user', password: 'pass', show_retired: false)
        end

        def test_private_get_json
          response = mock('response')
          response.expects(:ok?).returns(true)
          response.expects(:body).returns({'message'=>'stuff'}.to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          result = @admin_gui.send(:get_json, @user, 'ok.url')
          assert_equal 'stuff', result
        end

        def test_private_get_json_error
          response = mock('response')
          response.expects(:ok?).returns(false)
          response.expects(:body).returns({'client_error_detail'=>{'message'=>'some error'}}.to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          e = assert_raise AdminGUIHTTPError do
            @admin_gui.send(:get_json, @user, 'error.url')
          end
          assert_equal 'some error', e.message
        end

        def test_private_get_json_http_404
          response = mock('response')
          response.expects(:ok?).returns(false)
          response.expects(:status).returns(404)
          response.expects(:reason).returns('not found')
          response.expects(:body).returns('whatever')
          HTTPClient.any_instance.expects(:get).returns(response)
          e = assert_raise AdminGUIHTTPError do
            @admin_gui.send(:get_json, @user, 'missing.url')
          end
          assert_equal 'API HTTP get request to http://127.0.0.1:4599/missing.url failed with status 404 not found', e.message
        end

        def test_private_get_json_with_status
          response = mock('response')
          response.expects(:ok?).returns(true)
          response.expects(:body).returns({'message'=>'stuff'}.to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          result = @admin_gui.send(:get_json_with_status, @user, 'ok.url')
          assert_equal [:success, 'stuff'], result
        end

        def test_private_post_json
          data = {'field'=>'value'}
          response = mock('response')
          response.expects(:ok?).returns(true)
          response.expects(:body).returns(data.to_json)
          HTTPClient.any_instance.expects(:post).returns(response)
          result = @admin_gui.send(:post_json, @user, 'ok.url')
          assert_equal [:success, 'value'], result
        end

        def test_private_post_json_error
          response = mock('response')
          response.expects(:ok?).returns(false)
          data = 'some error'
          response.expects(:body).returns({'client_error_detail'=>data}.to_json)
          HTTPClient.any_instance.expects(:post).returns(response)
          result = @admin_gui.send(:post_json, @user, 'error.url')
          assert_equal [:error, data], result
        end

        def test_private_post_json_http_404
          response = mock('response')
          response.expects(:ok?).returns(false)
          response.expects(:status).returns(404)
          response.expects(:reason).returns('not found')
          response.expects(:body).returns('body')
          HTTPClient.any_instance.expects(:post).returns(response)
          result = @admin_gui.send(:post_json, @user, 'missing.url')
          expected = 'API HTTP post request to http://127.0.0.1:4599/missing.url failed with status 404 not found'
          assert_equal [:error, expected], result
        end

        def test_private_put_json
          data = {'field'=>'value'}
          response = mock('response')
          response.expects(:ok?).returns(true)
          response.expects(:body).returns(data.to_json)
          HTTPClient.any_instance.expects(:put).returns(response)
          result = @admin_gui.send(:put_json, @user, 'ok.url')
          assert_equal [:success, 'value'], result
        end

        def test_private_put_json_error
          response = mock('response')
          response.expects(:ok?).returns(false)
          data = 'some error'
          response.expects(:body).returns({'client_error_detail'=>data}.to_json)
          HTTPClient.any_instance.expects(:put).returns(response)
          result = @admin_gui.send(:put_json, @user, 'error.url')
          assert_equal [:error, data], result
        end

        def test_private_put_json_http_404
          response = mock('response')
          response.expects(:ok?).returns(false)
          response.expects(:status).returns(404)
          response.expects(:reason).returns('not found')
          response.expects(:body).returns('body')
          HTTPClient.any_instance.expects(:put).returns(response)
          result = @admin_gui.send(:put_json, @user, 'missing.url')
          expected = 'API HTTP put request to http://127.0.0.1:4599/missing.url failed with status 404 not found'
          assert_equal [:error, expected], result
        end

        def test_private_patch_json
          data = {'field'=>'value'}
          response = mock('response')
          response.expects(:ok?).returns(true)
          response.expects(:body).returns(data.to_json)
          HTTPClient.any_instance.expects(:patch).returns(response)
          result = @admin_gui.send(:patch_json, @user, 'ok.url')
          assert_equal [:success, 'value'], result
        end

        def test_private_patch_json_error
          response = mock('response')
          response.expects(:ok?).returns(false)
          data = 'some error'
          response.expects(:body).returns({'client_error_detail'=>data}.to_json)
          HTTPClient.any_instance.expects(:patch).returns(response)
          result = @admin_gui.send(:patch_json, @user, 'error.url')
          assert_equal [:error, data], result
        end

        def test_private_patch_json_http_404
          response = mock('response')
          response.expects(:ok?).returns(false)
          response.expects(:status).returns(404)
          response.expects(:reason).returns('not found')
          response.expects(:body).returns('body')
          HTTPClient.any_instance.expects(:patch).returns(response)
          result = @admin_gui.send(:patch_json, @user, 'missing.url')
          expected = 'API HTTP patch request to http://127.0.0.1:4599/missing.url failed with status 404 not found'
          assert_equal [:error, expected], result
        end

        def test_private_delete_json
          response = mock('response')
          response.expects(:ok?).returns(true)
          response.expects(:body).returns({'message'=>'stuff'}.to_json)
          HTTPClient.any_instance.expects(:delete).returns(response)
          result = @admin_gui.send(:delete_json, @user, 'ok.url')
          assert_equal [:success, 'stuff'], result
        end

        def test_private_http_request_json_parse_error
          response = mock('response')
          response.expects(:ok?).returns(false)
          response.expects(:status).returns(400)
          response.expects(:reason).returns('bad')
          response.expects(:body).returns('this is not json')
          HTTPClient.any_instance.expects(:get).returns(response)
          e = assert_raise Armagh::Admin::Application::AdminGUIHTTPError do
            @admin_gui.send(:get_json, @user, 'fake.url')
          end
          assert_equal 'API HTTP get request to http://127.0.0.1:4599/fake.url failed with status 400 bad', e.message
        end

        def test_private_http_request_unrecognized_http_method
          e = assert_raise AdminGUIHTTPError do
            @admin_gui.send(:http_request, @user, 'fake.url', :unknown, {})
          end
          assert_equal 'Unrecognized HTTP method: unknown', e.message
        end

        def test_root_directory
          assert_match(/\/lib\/armagh\/admin\/application\/www_root$/, @admin_gui.root_directory)
        end

        def test_login
          username = 'hacker'
          password = 'secret'
          @admin_gui.expects(:authenticate).with(username, password).returns(:success)
          result = @admin_gui.login(username, password)
          assert_equal :success, result
        end

        def test_login_empty_fields
          username = ''
          password = ''
          result = @admin_gui.login(username, password)
          assert_equal [:error, 'Username and/or password cannot be blank.'], result
        end

        def test_login_failed_authentication
          username = 'hacker'
          password = 'secret'
          @admin_gui.expects(:authenticate).with(username, password).returns([:error, 'failed'])
          result = @admin_gui.login(username, password)
          assert_equal [:error, 'failed'], result
        end

        def test_change_password
          username = 'hacker'
          params = {'username'=>username, 'old'=>'secrey', 'new'=>'crypto', 'con'=>'crypto'}
          @admin_gui.expects(:authenticated?).with(username, params['old']).returns(true)
          user = Struct.new(:username, :password).new(username, params['old'])
          @admin_gui.expects(:post_json).returns([:success, user])
          result = @admin_gui.change_password(params)
          assert_equal [:success, user], result
        end

        def test_change_password_empty_fields
          params = {'username'=>'hacker', 'old'=>'', 'new'=>'', 'con'=>''}
          expected = [:error, 'One or more required fields are blank.']
          assert_equal expected, @admin_gui.change_password(params)
        end

        def test_change_password_mismatch
          params = {'username'=>'hacker', 'old'=>'secret', 'new'=>'abc', 'con'=>'xyz'}
          expected = [:error, 'New password does not match confirmation.']
          assert_equal expected, @admin_gui.change_password(params)
        end

        def test_change_password_failed_authentication
          params = {'username'=>'hacker', 'old'=>'fail', 'new'=>'jellybeans', 'con'=>'jellybeans'}
          expected = [:error, 'Incorrect current password provided.']
          @admin_gui.expects(:authenticated?).returns(false)
          assert_equal expected, @admin_gui.change_password(params)
        end

        def test_private_authenticate
          username = 'hacker'
          password = 'secret'
          expected = [:success, {'username'=>username, 'password'=>password}]
          @admin_gui.expects(:get_json_with_status).returns(expected)
          assert_equal expected, @admin_gui.send(:authenticate, username, password)
        end

        def test_private_authenticated?
          username = 'hacker'
          password = 'secret'
          @admin_gui.expects(:authenticate).with(username, password).returns([:success])
          assert_true @admin_gui.send(:authenticated?, username, password)
        end

        def test_set_session_flag
          @user.expects(:show_retired=).with(true)
          assert_true @admin_gui.set_session_flag(@user, 'show_retired'=>'true')
        end

        def test_set_session_flag_unkown
          e = assert_raise do
            @admin_gui.set_session_flag(@user, 'something'=>'true')
          end
          assert_equal 'Unknown session flag "something" with value "true"', e.message
        end

        def test_shutdown
          @user.expects(:roles).returns(%w(application_admin))
          @admin_gui.expects(:`).returns(:shutdown)
          assert_equal :shutdown, @admin_gui.shutdown(@user)
        end

        def test_shutdown_insufficient_permissions
          @user.expects(:roles).returns([])
          e = assert_raise do
            @admin_gui.shutdown(@user)
          end
          assert_equal 'Insufficient user permissions to perform this action.', e.message
        end

        def test_get_status
          response = mock('response')
          response.expects(:ok?).returns(true)
          expected = {'status'=>'ok'}
          response.expects(:body).returns(expected.to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          assert_equal 'ok', @admin_gui.get_status(@user)
        end

        def test_get_workflows
          response = mock('response')
          response.expects(:ok?).returns(true)
          response.expects(:body).returns([].to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          assert_equal(
            {workflows:[], show_retired: false},
            @admin_gui.get_workflows(@user)
          )
        end

        def test_create_workflow
          response = mock('response')
          response.expects(:ok?).returns(true)
          expected = {'workflow'=>{'run_mode'=>'stopped'}}
          response.expects(:body).returns(expected.to_json)
          HTTPClient.any_instance.expects(:post).returns(response)
          assert_equal [:success, {'run_mode'=>'stopped'}], @admin_gui.create_workflow(@user, 'workflow')
        end

        def test_get_workflow
          @admin_gui.expects(:get_workflow_actions).returns(['actions_go_here'])
          @admin_gui.expects(:get_workflow_status).returns({active: false, retired: false})
          expected = {
            :actions=>["actions_go_here"],
            :active=>false,
            :retired=>false,
            :show_retired=>false,
            :created=>nil,
            :updated=>true,
            :workflow=>"workflow"
          }
          assert_equal expected, @admin_gui.get_workflow(@user, 'workflow', nil, true)
        end

        def test_private_get_workflow_actions
          response = mock('response')
          response.expects(:ok?).returns(true)
          expected = {'actions'=>[]}
          response.expects(:body).returns(expected.to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          assert_equal [], @admin_gui.send(:get_workflow_actions, @user, 'workflow')
        end

        def test_private_workflow_status
          response = mock('response')
          response.expects(:ok?).returns(true)
          expected = {'workflow'=>{'run_mode'=>'running', 'retired'=>false}}
          response.expects(:body).returns(expected.to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          assert_equal Hash(:active=>true, :retired=>false), @admin_gui.send(:get_workflow_status, @user, 'workflow')
        end

        def test_private_get_defined_actions
          response = mock('response')
          response.expects(:ok?).returns(true)
          expected = {'defined_actions'=>[]}
          response.expects(:body).returns(expected.to_json)
          HTTPClient.any_instance.expects(:get).returns(response)
          assert_equal [], @admin_gui.send(:get_defined_actions, @user)
        end

        def test_run_stop_workflow
          response = {
            'run_mode' => 'running'
          }
          @admin_gui.expects(:patch_json).returns([:success, response])
          result = @admin_gui.run_stop_workflow(@user, 'dummy', 'run')
          assert_equal [:success, response], result
        end

        def test_run_stop_workflow_failure
          response = 'some error'
          @admin_gui.expects(:patch_json).returns([:error, response])
          result = @admin_gui.run_stop_workflow(@user, 'dummy', 'stop')
          expected = [:error, response]
          assert_equal expected, result
        end

        def test_private_get_defined_parameters
          data = {
            'parameters'=>[
              {'name'=>'name', 'description'=>'description', 'type'=>'type', 'required'=>true, 'prompt'=>'prompt', 'default'=>'default', 'group'=>'group'},
              {'error'=>'some error'},
              {'warning'=>'some warning'}
            ],
            'type'=>'Armagh::SomeType',
            'supertype'=>'Armagh::SomeSuperType'
          }
          @admin_gui.expects(:get_json).returns(data)
          result = @admin_gui.send(:get_defined_parameters, @user, 'workflow', 'type')
          expected = {:type=>"Armagh::SomeType",
                      :supertype=>"SomeSuperType",
                      "group"=>[{:default=>"default",
                                 :description=>"description",
                                 :error=>nil,
                                 :name=>"name",
                                 :options=>nil,
                                 :prompt=>"prompt",
                                 :required=>true,
                                 :type=>"type",
                                 :value=>nil,
                                 :warning=>nil}],
                      :errors=>["Validation error: some error"],
                      :warnings=>["Validation warning: some warning"]}
          assert_equal expected, result
        end

        def test_edit_workflow_action
          config = {
            'parameters' => ['config_params'],
            :type        => 'type',
            :supertype   => 'supertype',
          }
          @admin_gui.expects(:get_action_config).with(@user, 'workflow', 'action').returns(config)
          @admin_gui.expects(:get_workflow_status).returns({active: false, retired: false})
          @admin_gui.expects(:get_action_test_callbacks).with(@user, 'type').returns(['test_callbacks'])
          expected = {
            :action=>"action",
            :defined_parameters=>{"parameters"=>["config_params"]},
            :edit_action=>true,
            :active=>false,
            :retired=>false,
            :supertype=>"supertype",
            :test_callbacks=>["test_callbacks"],
            :type=>"type",
            :workflow=>"workflow"
          }
          assert_equal expected, @admin_gui.edit_workflow_action(@user, 'workflow', 'action')
        end

        def test_private_get_action_config
          data = {
            'parameters' => [{'name'=>'name', 'description'=>'description', 'type'=>'type', 'required'=>true, 'prompt'=>'prompt', 'default'=>'default', 'group'=>'group'}],
            'type' => 'Armagh::SomeType',
            'supertype' => 'Armagh::SomeSuperType'
          }
          @admin_gui.expects(:get_json).returns(data)
          result = @admin_gui.send(:get_action_config, @user, 'workflow', 'action')
          expected = {:type=>"Armagh::SomeType",
                      :supertype=>"SomeSuperType",
                      "group"=>[{:default=>"default",
                                 :description=>"description",
                                 :error=>nil,
                                 :name=>"name",
                                 :options=>nil,
                                 :prompt=>"prompt",
                                 :required=>true,
                                 :type=>"type",
                                 :value=>nil,
                                 :warning=>nil}]}
          assert_equal expected, result
        end

        def test_create_action_config
          parameters = {
            'action' => [{name: 'name', description: 'description', type: 'type', required: true, prompt: 'prompt', default: 'default'}],
            'input' => [{name: 'docspec', defined_states: ['collected']}],
            'output' => [{name: 'docspec', defined_states: ['ready', 'working']}],
            'html' => [{name: 'node', type: 'string'}],
            'rss' => [{name: 'url', type: 'string_array'}],
            'ssl' => [{name: 'keys', type: 'hash'}],
            type: 'Armagh::SomeType',
            supertype: 'SomeSuperType'
          }
          data = {
            'action' => 'action',
            'workflow' => 'workflow',
            'type' => 'Armagh::SomeType',
            'action-name' => 'action_name',
            'input-docspec_type' => 'type',
            'input-docspec_state' => 'state',
            'output-docspec_type' => 'type',
            'output-docspec_state' => 'state',
            'html-node' => '<div*.?<\div>',
            'rss-url' => "www.example.com\x19www.sample.com",
            'ssl-keys' => "cert\x11/var/armagh/cert\x19key\x11/var/armagh/key",
            'splat' => [],
            'captures' => []
          }
          response = [:success]
          @admin_gui.expects(:get_defined_parameters).returns(parameters)
          @admin_gui.expects(:post_json).returns(response)
          assert_equal :success, @admin_gui.create_action_config(@user, data)
        end

        def test_create_action_config_missing_expected_parameter
          parameters = {
            'action' => [{name: 'name', description: 'description', type: 'type', required: true, prompt: 'prompt', default: 'default'}],
            'input' => [{name: 'docspec'}],
            'output' => [{name: 'docspec'}],
            type: 'Armagh::SomeType',
            supertype: 'SomeSuperType'
          }
          data = {
            'action' => 'action',
            'workflow' => 'workflow',
            'type' => 'Armagh::SomeType',
            'splat' => [],
            'captures' => []
          }
          response = [:error, {'markup' => {}}]
          @admin_gui.expects(:get_defined_parameters).returns(parameters)
          @admin_gui.expects(:post_json).returns(response)
          @admin_gui.expects(:get_workflow_status).returns({active: false, retired: false})
          @admin_gui.expects(:get_action_test_callbacks)
          result = @admin_gui.create_action_config(@user, data)
          expected = [{:action=>"action",
            :defined_parameters=>
             {"action"=>
               [{:default=>"default",
                 :description=>"description",
                 :name=>"name",
                 :prompt=>"prompt",
                 :required=>true,
                 :type=>"type"}],
              "input"=>[{:name=>"docspec"}],
              "output"=>[{:name=>"docspec"}]},
            :edit_action=>false,
            :active=>false,
            :retired=>false,
            :pending_values=>{},
            :supertype=>"SomeSuperType",
            :test_callbacks=>nil,
            :type=>"Armagh::SomeType",
            :workflow=>"workflow"},
            ["Missing expected parameter \"name\" for group \"action\"", {"markup"=>{}}]]
          assert_equal expected, result
        end

        def test_create_action_config_drops_empty_strings_and_encoded_strings
          parameters = {
            'action' => [{name: 'name', description: 'description', type: 'string', required: true, prompt: 'prompt', default: 'default'}],
            'input' => [{name: 'docspec'}],
            'output' => [{name: 'docspec'}],
            'dropme' => [{name: 'plainstring', type: 'string'}, {name: 'encodedstring', type: 'encoded_string'}],
            'keepme' => [{name: 'plainstring', type: 'string'}, {name: 'encodedstring', type: 'encoded_string'}],
            type: 'Armagh::SomeType',
            supertype: 'SomeSuperType'
          }
          data = {
            'action' => 'action',
            'workflow' => 'workflow',
            'action-name' => 'action_name',
            'dropme-plainstring' => '',
            'dropme-encodedstring' => Configh::DataTypes::EncodedString.from_plain_text(''),
            'keepme-plainstring' => 'not_empty',
            'keepme-encodedstring' => Configh::DataTypes::EncodedString.from_plain_text('also_not_empty'),
            'type' => 'Armagh::SomeType',
            'splat' => [],
            'captures' => []
          }
          response = [:error, {'markup' => {}}]
          @admin_gui.expects(:get_defined_parameters).returns(parameters)
          @admin_gui.expects(:post_json).returns(response)
          @admin_gui.expects(:get_json).returns('also_not_empty')
          @admin_gui.expects(:get_workflow_status).returns({active: false, retired: false})
          @admin_gui.expects(:get_action_test_callbacks)
          result = @admin_gui.create_action_config(@user, data)
          expected = [{:action=>'action',
            :defined_parameters=>
             {'action'=>
               [{:default=>'default',
                 :description=>'description',
                 :name=>'name',
                 :prompt=>'prompt',
                 :required=>true,
                 :type=>'string',
                 :value=>'action_name'}],
              'dropme'=>
                [{:name=>'plainstring', :type=>'string'},
                 {:name=>'encodedstring', :type=>'encoded_string'}],
              'keepme'=>
                [{:name=>'plainstring', :type=>'string', :value=>'not_empty'},
                 {:name=>'encodedstring', :type=>'encoded_string', :value=>'also_not_empty'}],
              'input'=>[{:name=>'docspec'}],
              'output'=>[{:name=>'docspec'}]},
            :edit_action=>false,
            :active=>false,
            :retired=>false,
            :pending_values=>
              {'action-name'=>'action_name',
               'dropme-plainstring'=>'',
               'dropme-encodedstring'=>Configh::DataTypes::EncodedString.from_plain_text(''),
               'keepme-plainstring'=>'not_empty',
               'keepme-encodedstring'=>Configh::DataTypes::EncodedString.from_plain_text('also_not_empty')},
            :supertype=>'SomeSuperType',
            :test_callbacks=>nil,
            :type=>'Armagh::SomeType',
            :workflow=>'workflow'},
            [{'markup'=>{}}]]
          assert_equal expected, result
        end

        def test_update_action_config
          parameters = {
            'action' => [{name: 'name', description: 'description', type: 'type', required: true, prompt: 'prompt', default: 'default'}],
            type: 'Armagh::SomeType',
            supertype: 'SomeSuperType'
          }
          data = {
            'action' => 'action',
            'workflow' => 'workflow',
            'type' => 'Armagh::SomeType',
            'action-name' => 'action_name',
            'splat' => [],
            'captures' => []
          }
          response = [:success]
          @admin_gui.expects(:get_defined_parameters).returns(parameters)
          @admin_gui.expects(:post_json).returns(response)
          result = @admin_gui.create_action_config(@user, data)
          assert_equal :success, result
        end

        def test_update_action_config_missing_expected_parameter
          parameters = {
            'action' => [{name: 'name', description: 'description', type: 'type', required: true, prompt: 'prompt', default: 'default'}],
            type: 'Armagh::SomeType',
            supertype: 'SomeSuperType'
          }
          data = {
            'action' => 'action',
            'workflow' => 'workflow',
            'type' => 'Armagh::SomeType',
            'splat' => [],
            'captures' => []
          }
          response = [:error, {}]
          @admin_gui.expects(:get_defined_parameters).returns(parameters)
          @admin_gui.expects(:put_json).returns(response)
          @admin_gui.expects(:get_workflow_status).returns({active: false, retired: false})
          @admin_gui.expects(:get_action_test_callbacks)
          result = @admin_gui.update_action_config(@user, data)
          expected = [{:action=>"action",
                       :defined_parameters=>
                         {"action"=>
                           [{:default=>"default",
                             :description=>"description",
                             :name=>"name",
                             :prompt=>"prompt",
                             :required=>true,
                             :type=>"type"}]},
                       :edit_action=>true,
                       :active=>false,
                       :retired=>false,
                       :pending_values=>{},
                       :supertype=>"SomeSuperType",
                       :test_callbacks=>nil,
                       :type=>"Armagh::SomeType",
                       :workflow=>"workflow"},
                      ["Missing expected parameter \"name\" for group \"action\"", {}]]
          assert_equal expected, result
        end

        def test_import_workflow
          response = [:success, 'hi, i am json']
          @admin_gui.expects(:post_json).returns(response)
          config = {
            'type'=>'Armagh::SomeAction',
            'action'=>{
              'name'=>'name',
              'active'=>true
            }
          }
          tempfile = mock('tempfile')
          tempfile.expects(:read).returns(config.to_json)
          params = {
            'files'=>[
              {tempfile: tempfile, filename: 'filename'}
            ]
          }
          assert_equal(
            {'errors'=>[], 'imported'=>['hi, i am json']},
            JSON.parse(@admin_gui.import_workflow(@user, params))
          )
        end


        def test_import_workflow_missing_files
          e = assert_raise RuntimeError do
            @admin_gui.import_workflow(@user, {})
          end
          assert_equal 'No JSON file(s) found to import.', e.message
        end

        def test_import_workflow_bad_json
          tempfile = mock('tempfile')
          tempfile.expects(:read).raises('some error')
          params = {
            'files'=>[
              {tempfile: tempfile, filename: 'filename'}
            ]
          }
          assert_equal(
            {'errors'=>['Unable to parse workflow JSON file "filename": some error'], 'imported'=>[]},
            JSON.parse(@admin_gui.import_workflow(@user, params))
          )
        end

        def test_import_workflow_server_error
          tempfile = mock('tempfile')
          tempfile.expects(:read).returns('{"json":"data"}')
          params = {
            'files'=>[
              {tempfile: tempfile, filename: 'filename'}
            ]
          }
          @admin_gui.expects(:post_json).returns([:error, 'Unable to import workflow. some error'])
          assert_equal(
            {'errors'=>['Unable to import workflow file "filename". some error'], 'imported'=>[]},
            JSON.parse(@admin_gui.import_workflow(@user, params))
          )
        end

        def test_export_workflow
          @admin_gui.expects(:get_json).returns('json')
          assert_equal '"json"', @admin_gui.export_workflow(@user, 'workflow')
        end

        def test_new_workflow_action
          @admin_gui.expects(:get_defined_actions).returns(['defined_actions'])
          @admin_gui.expects(:get_workflow_status).returns({active: false, retired: false})
          expected = {
            :active=>false,
            :retired=>false,
            :defined_actions=>["defined_actions"],
            :filter=>"Some::Action::SuperType",
            :previous_action=>"previous_action",
            :workflow=>"workflow"
          }
          assert_equal expected, @admin_gui.new_workflow_action(@user, 'workflow', 'previous_action', 'Some::Action::SuperType')
        end

        def test_new_action_config
          params = {
            'parameters' => ['params_go_here'],
            :type        => 'type',
            :supertype   => 'supertype'
          }
          @admin_gui.expects(:get_defined_parameters).with(@user, 'workflow', 'action').returns(params)
          @admin_gui.expects(:get_action_test_callbacks).with(@user, 'type')
          expects = {
            :action=>"action",
            :defined_parameters=>{"parameters"=>["params_go_here"]},
            :supertype=>"supertype",
            :test_callbacks=>nil,
            :type=>"type",
            :workflow=>"workflow"
          }
          assert_equal expects, @admin_gui.new_action_config(@user, 'workflow', 'action')
        end

        def test_private_get_action_test_callbacks
          type = 'Armagh::Some::Type'
          callbacks = [{group: 'group', class: type, method: 'method'}]
          @admin_gui.expects(:get_json).returns(callbacks)
          result = @admin_gui.send(:get_action_test_callbacks, @user, type)
          assert_equal callbacks, result
        end

        def test_invoke_action_test_callback_success
          data = {
            'type'   => 'Armagh::Some::Type',
            'group'  => 'group',
            'method' => 'method'
          }
          response = nil
          @admin_gui.expects(:patch_json).returns([:success, response])
          result = @admin_gui.invoke_action_test_callback(@user, data)
          assert_equal ['success', response], JSON.parse(result)
        end

        def test_invoke_action_test_callback_failure
          data = {
            'type'   => 'Armagh::Some::Type',
            'group'  => 'group',
            'method' => 'method'
          }
          response = 'some callback error'
          @admin_gui.expects(:patch_json).returns([:success, response])
          result = @admin_gui.invoke_action_test_callback(@user, data)
          assert_equal ['error', response], JSON.parse(result)
        end

        private def mock_log_connection
          Date.stubs(:parse).returns(Date.new(2018, 01, 04))
          array = [{'_id'=>'id'}]
          Connection.stubs(
            log: stub(
              find: stub(
                sort: stub(
                  limit: stub(
                    return_key: array
                  )
                ),
                count: 10,
                projection: stub(
                  skip: stub(
                    limit: array
                  )
                )
              ),
              aggregate: array
            )
          )
        end

        def test_logs
          filter = "message\x11blah\x19_id\x11mongo_id\x19timestamp\x111982-01-04\x19pid\x119999\x19level\x11any"
          hide = "pid\x19hostname"
          mock_log_connection
          result = @admin_gui.get_logs(@user, page: 1, limit: 10, filter: filter, hide: hide, sample: 10)
          result[:filters].delete('timestamp')
          expected = {
            :count=>10,
            :errors=>[],
            :filter=>"message\u0011blah\u0019_id\u0011mongo_id\u0019timestamp\u00111982-01-04\u0019pid\u00119999\u0019level\u0011any",
            :filters=>
              {"action"=>["id"],
               "alert"=>["true", "false"],
               "component"=>["Agent", "id"],
               "hostname"=>["id"],
               "level"=>["id"],
               "action_supertype"=>["id"],
               "workflow"=>["id"]},
            :hide=>"pid\u0019hostname",
            :limit=>10,
            :logs=>[{"_id"=>"id"}],
            :page=>1,
            :pages=>1,
            :sample=>10,
            :skip=>0
          }
          assert_equal expected, result
        end

        def test_get_logs_empty_filter
          mock_log_connection
          result = @admin_gui.get_logs(@user, page: 1, limit: 10, filter: '', hide: '', sample: nil)
          result[:filters].delete('timestamp')
          expected = {
            :count=>10,
            :errors=>[],
            :filter=>"",
            :filters=>
              {"action"=>["id"],
               "alert"=>["true", "false"],
               "component"=>["Agent", "id"],
               "hostname"=>["id"],
               "level"=>["id"],
               "action_supertype"=>["id"],
               "workflow"=>["id"]},
            :hide=>"",
            :limit=>10,
            :logs=>[{"_id"=>"id"}],
            :page=>1,
            :pages=>1,
            :sample=>10000,
            :skip=>0
          }
          assert_equal expected, result
        end

        def test_get_logs_date_parse_error
          mock_log_connection
          Time.expects(:parse).raises(RuntimeError.new('parse error'))
          filter = "timestamp\x11fail_me"
          result = @admin_gui.get_logs(@user, page: 1, limit: 10, filter: filter, hide: nil, sample: 10)
          result[:filters].delete('timestamp')
          expected = {
            :count=>10,
            :errors=>["Unable to filter <strong>timestamp</strong>: parse error"],
            :filter=>"timestamp\u0011fail_me",
            :filters=>
              {"action"=>["id"],
               "alert"=>["true", "false"],
               "component"=>["Agent", "id"],
               "hostname"=>["id"],
               "level"=>["id"],
               "action_supertype"=>["id"],
               "workflow"=>["id"]},
            :hide=>nil,
            :limit=>10,
            :logs=>[{"_id"=>"id"}],
            :page=>1,
            :pages=>1,
            :sample=>10,
            :skip=>0
          }
          assert_equal expected, result
        end

        def test_get_logs_objectid_error
          mock_log_connection
          BSON.stubs(:ObjectId).raises(RuntimeError.new('objectid error'))
          filter = "document_internal_id\x11fail_me"
          result = @admin_gui.get_logs(@user, page: 1, limit: 10, filter: filter, hide: nil, sample: 10)
          result[:filters].delete('timestamp')
          expected = {
            :count=>10,
            :errors=>["Unable to filter <strong>document_internal_id</strong>: objectid error"],
            :filter=>"document_internal_id\u0011fail_me",
            :filters=>
              {"action"=>["id"],
               "alert"=>["true", "false"],
               "component"=>["Agent", "id"],
               "hostname"=>["id"],
               "level"=>["id"],
               "action_supertype"=>["id"],
               "workflow"=>["id"]},
            :hide=>nil,
            :limit=>10,
            :logs=>[{"_id"=>"id"}],
            :page=>1,
            :pages=>1,
            :sample=>10,
            :skip=>0
          }
          assert_equal expected, result
        end

        def test_get_doc_collections
          connection = mock('connection')
          connection.expects(:namespace).twice.returns('armagh.documents.collection')
          connection.expects(:count).twice.returns(16_500_000)
          Connection.expects(:failures).returns(connection)
          Connection.expects(:all_document_collections).returns([connection])
          result = @admin_gui.get_doc_collections(@user)
          expected = {"armagh.documents.collection"=>"Collection (16.5M)"}
          assert_equal expected, result
        end

        private def mock_doc_connection
          doc = mock('doc')
          doc.expects(:limit).returns([{'_id'=>'id'}])

          limit = mock('limit')
          limit.expects(:return_key).twice.returns([{'_id'=>'id'}])
          sort = mock('sort')
          sort.expects(:limit).twice.returns(limit)
          slice = mock('slice')
          slice.expects(:sort).twice.returns(sort)

          sample_sort = mock('sample_sort')
          sample_sort.expects(:limit).returns([{'_id'=>'id'}])
          sample = mock('sample')
          sample.expects(:sort).returns(sample_sort)

          collection = mock('collections')
          collection.expects(:find).times(4).returns(sample, slice, slice, doc)

          collections = mock('collections')
          collections.expects(:find).returns(collection)

          Connection.expects(:all_document_collections).returns(collections)
        end

        def test_get_doc
          params = {
            'collection' => 'collection',
            'page'       => 1,
            'from'       => '1982-01-04',
            'thru'       => '1982-12-27',
            'search'     => 'search',
            'sample'     => '100'
          }
          mock_doc_connection
          @user.expects(:doc_viewer=).with(
            collection: 'collection',
            page:       1,
            from:       '1982-01-04',
            thru:       '1982-12-27',
            search:     'search',
            sample:     100
          )
          result = @admin_gui.get_doc(@user, params)
          expected = {
            :count=>1,
            :doc=>{"_id"=>"id"},
            :expand=>false,
            :from=>"1982-01-04",
            :page=>0,
            :search=>"search",
            :thru=>"1982-12-27"
          }
          assert_equal expected, result
        end

        def test_get_doc_unexpected_collection
          params = {'collection' => 'collection'}
          @user.expects(:doc_viewer=)
          collections = mock('collection')
          collections.expects(:find)
          Connection.expects(:all_document_collections).returns(collections)
          e = assert_raise Armagh::Admin::Application::AdminGUIError do
            @admin_gui.get_doc(@user, params)
          end
          assert_equal 'Unexpected document collection "collection"', e.message
        end

        def test_get_doc_query_error
          params = {
            'collection' => 'collection',
            'page'       => 1,
            'from'       => '',
            'thru'       => '',
            'search'     => '',
            'sample'     => '100'
          }
          @user.expects(:doc_viewer=)
          collection = mock('collection')
          collection.expects(:find).raises(RuntimeError.new('some query error'))
          collections = mock('collection')
          collections.expects(:find).returns(collection)
          Connection.expects(:all_document_collections).returns(collections)
          e = assert_raise Armagh::Admin::Application::AdminGUIError do
            @admin_gui.get_doc(@user, params)
          end
          assert_equal 'Unable to process query: some query error', e.message
        end

      end
    end
  end
end
