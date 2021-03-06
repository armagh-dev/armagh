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

require_relative '../../helpers/coverage_helper'
require_relative '../../helpers/armagh_test'
require 'test/unit'
require 'mocha/test_unit'

require_relative '../../helpers/workflow_generator_helper'
require_relative '../../../lib/armagh/actions/workflow'
require_relative '../../../lib/armagh/actions/workflow_set'
require_relative '../../../lib/armagh/logging/alert'
require_relative '../../../lib/armagh/connection'
require_relative '../../../lib/armagh/document/document'

require 'armagh/actions'

class TestWorkflow < Test::Unit::TestCase
  include ArmaghTest

  def setup
    @config_store = []
    @logger = mock
    @logger.stubs(:fullname).returns('fred')
    @logger.expects(:debug).at_least(0)
    @logger.expects(:any).at_least(0)
    @caller = mock

    @alice_workflow_config_values = {'workflow'=>{'name'=>'alice'}}
    @alice_workflow_actions_config_values = WorkflowGeneratorHelper.workflow_actions_config_values_with_divide( 'alice' )
    @fred_workflow_config_values = {'workflow'=>{'name' => 'fred'}}
    @fred_workflow_actions_config_values  = WorkflowGeneratorHelper.workflow_actions_config_values_no_divide('fred')
    @state_coll = mock
    Armagh::Connection.stubs(:config).returns(@config_store)

    Armagh::Document.clear_document_counts
  end

  def good_alice_in_db(check_unused_output = false)
    @wf_set ||= Armagh::Actions::WorkflowSet.for_admin( Armagh::Connection.config, logger: @logger )
    @alice = @wf_set.create_workflow( { 'workflow' => { 'name' => 'alice' }} )
    @alice.unused_output_docspec_check = check_unused_output
    @alice_workflow_actions_config_values.each do |type,action_config_values|
      @alice.create_action_config(type, action_config_values)
    end
    @alice
  end

  def good_fred_in_db(check_unused_output = false)
    @wf_set ||= Armagh::Actions::WorkflowSet.for_admin( Armagh::Connection.config, logger: @logger )
    @fred = @wf_set.create_workflow( { 'workflow' => { 'name' => 'fred' }} )
    @fred.unused_output_docspec_check = check_unused_output
    @fred_workflow_actions_config_values.each do |type,action_config_values|
      @fred.create_action_config(type, action_config_values)
    end
    @fred
  end

  def bad_alice_in_db
    good_alice_in_db
    WorkflowGeneratorHelper.break_array_config_store( @config_store, 'alice' )
  end

  def stored_alice(retired = false)
    wf_set = Armagh::Actions::WorkflowSet.for_admin( Armagh::Connection.config, logger: @logger )
    wf_set.refresh( include_retired: true ) if retired
    wf_set.get_workflow('alice')
  end

  def expect_alice_docs_in_db
    expect_document_counts([
        { 'category' => 'in process', 'docspec_string' => 'a_alicedoc:ready',       'count' =>9},
        { 'category' => 'in process', 'docspec_string' => 'b_alicedocs_aggr:ready', 'count' =>20},
        { 'category' => 'failed',     'docspec_string' => 'a_alicedoc:ready',       'count'=>3 }
    ])
    Armagh::Logging::Alert.stubs( get_counts: { 'warn' => 0, 'error' => 0, 'fatal' => 0})
  end

  def expect_no_alice_docs_in_db
    expect_document_counts([])
    Armagh::Logging::Alert.stubs( get_counts: { 'warn' => 0, 'error' => 0, 'fatal' => 0})
  end

  def teardown
  end

  def test_check_run_mode
    modes = [ Armagh::Status::RUNNING,
              Armagh::Status::STOPPING,
              Armagh::Status::STOPPED ]
    modes.each do |mode|
      cc = mock('candidate_config')
      wf = mock('workflow')
      wf.expects(:run_mode).once.returns(mode)
      cc.expects(:workflow).once.returns(wf)
      assert_nothing_raised do
        Armagh::Actions::Workflow.check_run_mode(cc)
      end
    end
  end

  def test_check_run_mode_error
    cc = mock('candidate_config')
    wf = mock('workflow')
    wf.expects(:run_mode).once.returns('unknown')
    cc.expects(:workflow).once.returns(wf)
    result = Armagh::Actions::Workflow.check_run_mode(cc)
    assert_equal 'run_mode must be one of: running, stopping, stopped', result
  end

  def test_workflow_create
    good_alice_in_db
    assert_equal 'alice',@alice.name
    assert_equal 'stopped',@alice.run_mode
    assert_equal false,@alice.retired
    assert_equal false,@alice.unused_output_docspec_check
    assert_equal 8, @alice.valid_action_configs.length
    assert_true @alice.has_no_cycles
  end

  def test_workflow_create_dup_name
    good_alice_in_db
    e = assert_raises( Armagh::Actions::WorkflowConfigError ) do
      @wf_set.create_workflow( { 'workflow' => { 'name' => 'alice'}})
    end
    assert_equal 'Name already in use', e.message
  end

  def test_edit_configuration
    result = Armagh::Actions::Workflow.edit_configuration({}, creating_in: @workflow_set)
    expected = {"parameters" =>
                    [{"default" => "stopped",
                      "description" => "running, stopping, stopped",
                      "error" => nil,
                      "group" => "workflow",
                      "name" => "run_mode",
                      "prompt" => nil,
                      "required" => true,
                      "type" => "string",
                      "value" => "stopped",
                      "warning" => nil,
                      "options" => nil},
                     {"default" => false,
                      "description" => "not normally displayed",
                      "error" => nil,
                      "group" => "workflow",
                      "name" => "retired",
                      "prompt" => nil,
                      "required" => true,
                      "type" => "boolean",
                      "value" => false,
                      "warning" => nil,
                      "options" => nil},
                     {"default" => true,
                      "description" => "verify that there are no unused output docspecs",
                      "error" => nil,
                      "group" => "workflow",
                      "name" => "unused_output_docspec_check",
                      "prompt" => nil,
                      "required" => true,
                      "type" => "boolean",
                      "value" => true,
                      "warning" => nil,
                      "options" => nil},
                     {"error" => nil, "group" => "workflow"}],
                "type" => Armagh::Actions::Workflow}
    assert_equal expected, result
  end

  def test_edit_configuration_error
    good_alice_in_db
    config = {'workflow'=>{'name'=>'alice'}}
    Armagh::Actions::Workflow
      .expects(:exists?)
      .returns(true)
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      Armagh::Actions::Workflow.edit_configuration(config, creating_in: @config_store)
    end
    assert_equal 'Workflow name already in use', e.message
  end

  def test_workflow_find
    good_alice_in_db

    assert_equal 'alice',stored_alice.name
    assert_equal 'stopped',stored_alice.run_mode
    assert_equal false,stored_alice.retired
    assert_equal false,stored_alice.unused_output_docspec_check
    assert_equal 8, stored_alice.valid_action_configs.length
    assert_true stored_alice.has_no_cycles
  end

  def test_workflow_find_not_found
    not_stored = Armagh::Actions::Workflow.exists?( @config_store, 'bilbo')
    assert_false not_stored
  end

  def test_workflow_find_error
    Armagh::Actions::Workflow
      .expects(:find_configuration)
      .once
      .raises(Configh::ConfigInitError, 'some error')
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      Armagh::Actions::Workflow.exists?(@config_store, 'error')
    end
    assert_equal 'some error', e.message
  end

  def test_find_all
    good_alice_in_db
    result = Armagh::Actions::Workflow.find_all(@config_store, logger: @logger)
    assert_equal Array, result.class
    assert_equal 1, result.size
  end

  def test_find_all_error
    Armagh::Actions::Workflow
      .expects(:find_all_configurations)
      .once
      .raises(Configh::ConfigInitError, 'some error')
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      Armagh::Actions::Workflow.find_all(@config_store, logger: @logger)
    end
    assert_equal 'some error', e.message
  end

  def test_workflow_new_private
    assert_raises NoMethodError do
      Armagh::Actions::Workflow.new( @config_store, 'bilbo', Object.new )
    end
  end

  def test_retired
    good_alice_in_db
    @alice.retired=true

    assert_true stored_alice(true).retired
  end

  def test_maintain_history
    good_alice_in_db
    @alice.retired=true

    assert_true stored_alice(true).retired
    assert_equal 3, stored_alice(true).instance_variable_get(:@config).history.length
  end

  def test_update_action_config_action_find_error
    good_alice_in_db
    e = assert_raise Armagh::Actions::ActionFindError do
      @alice.update_action_config('error', 'cand_config_values')
    end
    assert_equal 'Action class name error not valid', e.message
  end

  def test_update_action_config_validation_error
    good_alice_in_db
    config = @alice_workflow_actions_config_values.first.last
    type = 'Armagh::StandardActions::TWTestCollect'
    @alice.expects(:load_action_configs)
      .once
      .raises(Configh::ConfigValidationError, 'validation error')
    e = assert_raise Armagh::Actions::ActionConfigError do
      @alice.update_action_config(type, config)
    end
    assert_equal 'Configuration has errors: validation error', e.message
  end

  def test_workflow_create_actions_load_actions

    good_alice_in_db
    assert_true @alice.actions_valid?
    assert_true @alice.valid?

    assert_equal @alice_workflow_actions_config_values.length, stored_alice.valid_action_configs.length
  end

  def test_workflow_create_actions_load_actions_update_action

    good_alice_in_db
    assert_true @alice.actions_valid?
    assert_true @alice.valid?

    assert_equal @alice_workflow_actions_config_values.length, stored_alice.valid_action_configs.length

    action_class_to_change, action_to_change = @alice_workflow_actions_config_values.find{ |_k,c|
      c['action']['name'] == 'collect_alicedocs_from_source'
    }
    action_to_change[ 'collect' ][ 'schedule' ] = '5 * * * *'
    sleep 1
    stored_alice.update_action_config( action_class_to_change, action_to_change )

    assert_equal @alice_workflow_actions_config_values.length, stored_alice.valid_action_configs.length
    assert_true stored_alice.actions_valid?
    assert_true stored_alice.valid?
    config = stored_alice.valid_action_configs.find{ |ac| ac.action.name == 'collect_alicedocs_from_source' }
    assert_equal '5 * * * *', config.collect.schedule
  end

  def test_workflow_create_invalid_action
    WorkflowGeneratorHelper.break_workflow_actions_config( @alice_workflow_actions_config_values, 'alice' )
    alice = Armagh::Actions::Workflow.create(@config_store, 'alice', logger: @logger )
    bad_action_config = @alice_workflow_actions_config_values.find{ |_k,c| c['action']['name'] == 'collect_alicedocs_from_source'}
    e = assert_raises( Armagh::Actions::ActionConfigError ) do
      alice.create_action_config(*bad_action_config)
    end
    assert_true alice.actions_valid?, "bad action loaded on create; shouldn't happen"
    assert_true alice.valid?
    assert_equal "Configuration has errors: Unable to create configuration for 'Armagh::StandardActions::TWTestCollect' named 'collect_alicedocs_from_source' because: \n    Group 'output' Parameter 'docspec': type validation failed: value cannot be nil", e.message
  end

  def test_workflow_create_invalid_action_dup_name
    WorkflowGeneratorHelper.force_duplicate_action_name( @alice_workflow_actions_config_values, 'alice')
    e = assert_raises( Armagh::Actions::ActionConfigError ) do
      good_alice_in_db # not really
    end
    assert_equal 'Configuration has errors: Name already in use', e.message
  end

  def test_workflow_load_some_invalid_actions
    bad_alice_in_db

    alice = Armagh::Actions::Workflow.find(@config_store, 'alice', logger: @logger )
    assert_false alice.actions_valid?
    assert_false alice.valid?
    assert_equal 2, alice.invalid_action_configs.length
  end

  def test_workflow_actions_with_cycles
    WorkflowGeneratorHelper.force_cycle( @alice_workflow_actions_config_values, 'alice' )
    good_alice_in_db #not really!
    assert_false @alice.valid?
  end

  def test_running_false
    good_alice_in_db
    assert_false @alice.running?
  end

  def test_running_true
    good_alice_in_db
    expect_no_alice_docs_in_db
    @alice.run
    assert_true @alice.running?
  end

  def test_run
    good_alice_in_db
    expect_no_alice_docs_in_db
    @alice.run

    assert @alice.running?
    assert_equal [true], @alice.valid_action_configs.collect{ |ac| ac.action.active }.uniq
    assert @alice.running?
    assert stored_alice.running?
  end

  def test_run_while_stopping
    good_alice_in_db
    expect_no_alice_docs_in_db
    @alice.run

    Armagh::Document.clear_document_counts
    expect_alice_docs_in_db
    e = assert_raises( Armagh::Actions::WorkflowDocumentsInProcessError ) do
      @alice.stop
    end

    e = assert_raises( Armagh::Actions::WorkflowActivationError ) do
      @alice.run
    end
    assert_equal 'Wait for workflow to stop before restarting', e.message
  end

  def test_run_with_callback_errors
    good_alice_in_db
    @alice.instance_variable_get(:@valid_action_configs).each_with_index do |action_config, index|
      action_config.expects(:test_and_return_errors).returns('test_connection'=>"Some error #{index + 1}")
    end
    e = assert_raises Armagh::Actions::WorkflowActivationError do
      @alice.run
    end
    expected = "Action \"collect_alicedocs_from_source\" failed test_connection: Some error 1\n" +
      "Action \"consume_a_alicedoc_1\" failed test_connection: Some error 2\n" +
      "Action \"consume_a_alicedoc_2\" failed test_connection: Some error 3\n" +
      "Action \"consume_b_alicedoc_1\" failed test_connection: Some error 4\n" +
      "Action \"divide_b_alicedocs\" failed test_connection: Some error 5\n" +
      "Action \"publish_a_alicedocs\" failed test_connection: Some error 6\n" +
      "Action \"publish_b_alicedocs\" failed test_connection: Some error 7\n" +
      "Action \"split_b_alicedocs\" failed test_connection: Some error 8"
    assert_equal expected, e.message
  end

  def test_stop
    good_alice_in_db

    expect_no_alice_docs_in_db
    @alice.run

    @alice.stop

    assert stored_alice.stopped?

    @alice.run

    assert_nothing_raised do
      @alice.stop
    end

    assert stored_alice.stopped?
    assert_equal [false], stored_alice.valid_action_configs.collect{ |ac| ac.action.active }.uniq

  end

  def test_stop_docs_processing
    good_alice_in_db

    expect_no_alice_docs_in_db
    @alice.run

    Armagh::Document.clear_document_counts
    e = assert_raises( Armagh::Actions::WorkflowDocumentsInProcessError) do
      expect_alice_docs_in_db
      @alice.stop
    end
    assert_equal 'Cannot stop - 29 documents still processing', e.message
    assert @alice.stopping?
  end

  def test_stop_running_invalid
    good_alice_in_db
    expect_no_alice_docs_in_db
    @alice.run

    @alice.stubs( count_of_documents_in_process: 2 )

    assert_raises( Armagh::Actions::WorkflowDocumentsInProcessError.new( 'Cannot stop - 2 documents still processing' )) do
      @alice.stop
    end
    assert_false @alice.stopped?

    @alice.stubs( valid?: false )
    assert_nothing_raised do
      @alice.stop
    end
    assert_true @alice.stopped?
  end

  def test_valid_action_config_status
    good_alice_in_db
    action_config = stored_alice.valid_action_configs.first
    result = @alice.valid_action_config_status(action_config)
    result.delete('last_updated')
    expected = {"active"=>false,
      "input_docspec"=>"__COLLECT__collect_alicedocs_from_source:ready",
      "name"=>"collect_alicedocs_from_source",
      "output_docspecs"=>["a_alicedoc:ready", "b_alicedocs_aggr_big:ready"],
      "retired"=>false,
      "supertype"=>"Armagh::Actions::Collect",
      "type"=>"Armagh::StandardActions::TWTestCollect",
      "valid"=>true}
    assert_equal expected, result
  end

  def test_invalid_action_config_status
    bad_alice_in_db
    stored_alice = Armagh::Actions::Workflow.find(@config_store, 'alice', @workflow_set, logger: @logger)
    action_config = stored_alice.invalid_action_configs.first
    result = @alice.invalid_action_config_status(action_config)
    expected = {"active"=>false,
      "input_docspec"=>"__COLLECT__collect_alicedocs_from_source:ready",
      "last_updated"=>"",
      "name"=>"collect_alicedocs_from_source",
      "output_docspecs"=>["b_alicedocs_aggr_big:ready"],
      "retired"=>false,
      "supertype"=>"Armagh::Actions::Collect",
      "type"=>"Armagh::StandardActions::TWTestCollect",
      "valid"=>false}
    assert_equal expected, result
  end

  def test_action_statuses
    good_alice_in_db
    result = @alice.action_statuses
    assert_equal Array, result.class
    assert_equal 8, result.size
    result.first.delete('last_updated')
    expected = {"active"=>false,
      "input_docspec"=>"__COLLECT__collect_alicedocs_from_source:ready",
      "name"=>"collect_alicedocs_from_source",
      "output_docspecs"=>["a_alicedoc:ready", "b_alicedocs_aggr_big:ready"],
      "retired"=>false,
      "supertype"=>"Armagh::Actions::Collect",
      "type"=>"Armagh::StandardActions::TWTestCollect",
      "valid"=>true}
    assert_equal expected, result.first
  end

  def test_action_status_valid
    good_alice_in_db
    result = @alice.action_status('collect_alicedocs_from_source')
    result.delete('last_updated')
    expected = {"active"=>false,
      "input_docspec"=>"__COLLECT__collect_alicedocs_from_source:ready",
      "name"=>"collect_alicedocs_from_source",
      "output_docspecs"=>["a_alicedoc:ready", "b_alicedocs_aggr_big:ready"],
      "retired"=>false,
      "supertype"=>"Armagh::Actions::Collect",
      "type"=>"Armagh::StandardActions::TWTestCollect",
      "valid"=>true}
    assert_equal expected, result
  end

  def test_action_status_invalid
    bad_alice_in_db
    @alice.instance_variable_set(:@valid_action_configs, [])
    invalid_configs = [{'parameters'=>[{
      'name'=>'name',
      'group'=>'action',
      'value'=>'some_action'
    }]}]
    @alice.instance_variable_set(:@invalid_action_configs, invalid_configs)
    @alice.expects(:invalid_action_config_status)
      .once
      .returns(true)
    result = @alice.action_status('some_action')
    assert_true result
  end

  def test_action_status_invalid_action_find_error
    bad_alice_in_db
    @alice.instance_variable_set(:@valid_action_configs, [])
    @alice.instance_variable_set(:@invalid_action_configs, [])
    e = assert_raise Armagh::Actions::ActionFindError do
      @alice.action_status('some_action')
    end
    assert_equal 'Workflow alice has no some_action action', e.message
  end

  def test_type_valid
    good_alice_in_db
    result = @alice.type('collect_alicedocs_from_source')
    assert_equal 'Armagh::StandardActions::TWTestCollect', result
  end

  def test_type_invalid
    bad_alice_in_db
    @alice.instance_variable_set(:@valid_action_configs, [])
    invalid_configs = [{'parameters'=>[{
      'name'=>'name',
      'group'=>'action',
      'value'=>'some_action'
    }], 'type'=>'some_type'}]
    @alice.instance_variable_set(:@invalid_action_configs, invalid_configs)
    result = @alice.type('some_action')
    assert_equal 'some_type', result
  end

  def test_type_invalid_action_find_error
    bad_alice_in_db
    e = assert_raise Armagh::Actions::ActionFindError do
      @alice.type('some_action')
    end
    assert_equal 'Workflow alice has no some_action action', e.message
  end

  def test_new_action_config
    good_alice_in_db
    type = 'Armagh::StandardActions::TWTestCollect'
    result = @alice.new_action_config(type)
    assert_equal Hash, result.class
    assert_true result.has_key?('parameters')
    assert_equal Array, result['parameters'].class
    assert_equal 14, result['parameters'].size
    expected = {"default" => nil,
                "description" => "Name of this action configuration",
                "error" => nil,
                "group" => "action",
                "name" => "name",
                "prompt" => "example-collect (Warning: Cannot be changed once set)",
                "required" => true,
                "type" => "string",
                "value" => nil,
                "warning" => nil,
                "options" => nil}
    assert_equal expected, result.dig('parameters', 0)
  end

  def test_new_action_config_action_find_error
    good_alice_in_db
    type = 'some_action'
    e = assert_raise Armagh::Actions::ActionFindError do
      @alice.new_action_config(type)
    end
    assert_equal 'Action class name some_action not valid', e.message
  end

  def test_edit_action_config_valid
    good_alice_in_db
    result = @alice.edit_action_config('collect_alicedocs_from_source')
    assert_equal Hash, result.class
    assert_true result.has_key?('parameters')
    assert_equal Array, result['parameters'].class
    assert_equal 16, result['parameters'].size
    expected = {"default" => nil,
                "description" => "Name of this action configuration",
                "error" => nil,
                "group" => "action",
                "name" => "name",
                "prompt" => "example-collect (Warning: Cannot be changed once set)",
                "required" => true,
                "type" => "string",
                "value" => "collect_alicedocs_from_source",
                "warning" => nil,
                "options" => nil}
    assert_equal expected, result.dig('parameters', 0)
  end

  def test_edit_action_config_invalid
    bad_alice_in_db
    @alice.instance_variable_set(:@valid_action_configs, [])
    invalid_configs = [{'parameters'=>[{
      'name'=>'name',
      'group'=>'action',
      'value'=>'some_action'
    }], 'type'=>'some_type', 'markup'=>'some_markup'}]
    @alice.instance_variable_set(:@invalid_action_configs, invalid_configs)
    @alice.expects(:append_valid_docstates_to_config).once.returns(true)
    result = @alice.edit_action_config('some_action')
    expected = {"markup"=>"some_markup",
      "parameters"=>[{"group"=>"action", "name"=>"name", "value"=>"some_action"}],
      "type"=>"some_type"}
    assert_equal expected, result
  end

  def test_edit_action_config_action_find_error
    good_alice_in_db
    @alice.instance_variable_set(:@valid_action_configs, [])
    @alice.instance_variable_set(:@invalid_action_configs, [])
    e = assert_raise Armagh::Actions::ActionFindError do
      @alice.edit_action_config('some_action')
    end
    assert_equal 'Workflow alice has no some_action action', e.message
  end

  def test_setting_output_check_to_non_boolean_fails
    good_alice_in_db
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      @alice.unused_output_docspec_check = 'boo'
    end
    assert_equal 'Must specify boolean value for unused_output_docspec_check', e.message
  end

  def test_setting_output_check_while_running_fails
    good_alice_in_db
    expect_no_alice_docs_in_db
    assert_false @alice.unused_output_docspec_check
    @alice.run
    assert_true @alice.running?
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      @alice.unused_output_docspec_check = true
    end
    assert_equal 'Stop workflow before changing unused_output_docspec_check', e.message
  end

  def test_workflow_that_has_no_unused_outputs
    @fred_workflow_actions_config_values = WorkflowGeneratorHelper.workflow_actions_config_values_with_no_unused_output('fred')
    good_fred_in_db
    assert_false @fred.unused_output_docspec_check
    assert_nothing_raised do
      @fred.unused_output_docspec_check = true
    end
    assert_true @fred.unused_output_docspec_check
  end

  def test_workflow_that_has_unused_outputs
    good_alice_in_db
    assert_false @alice.unused_output_docspec_check
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      @alice.unused_output_docspec_check = true
    end
    assert_equal 'Workflow has unused outputs: a_alicedoc_out:ready from consume_a_alicedoc_2, b_aliceconsume_out_doc:ready from consume_b_alicedoc_1, b_alicedocs_aggr:ready from divide_b_alicedocs', e.message
    assert_false @alice.unused_output_docspec_check
  end

  def test_workflow_run_checks_unused_outputs
    good_alice_in_db(true)
    assert_true @alice.unused_output_docspec_check
    e = assert_raise Armagh::Actions::WorkflowActivationError do
      @alice.run
    end
    assert_equal 'Workflow has unused outputs: a_alicedoc_out:ready from consume_a_alicedoc_2, b_aliceconsume_out_doc:ready from consume_b_alicedoc_1, b_alicedocs_aggr:ready from divide_b_alicedocs', e.message
  end

  def test_retire_and_unretire_action
    good_alice_in_db
    action_name = 'collect_alicedocs_from_source'
    @alice.retire_action(action_name)
    config = @alice.retired_action_configs.find { |ac| ac.action.name == action_name }
    assert_not_nil config
    assert_true config.action.retired
    @alice.unretire_action(action_name)
    config = @alice.valid_action_configs.find { |ac| ac.action.name == action_name }
    assert_not_nil config
    assert_false config.action.retired
  end

  def test_retire_and_unretire_invalid_action
    bad_alice_in_db
    @alice.load_action_configs
    action_name = 'collect_alicedocs_from_source'
    @alice.retire_action(action_name)
    config = @alice.retired_action_configs.find { |ac| ac.action.name == action_name }
    assert_not_nil config
    assert_true config.action.retired
    @alice.unretire_action(action_name)
    config = @alice.invalid_bypassed_configs.find { |ac| ac.action.name == action_name }
    assert_not_nil config
    assert_false config.action.retired
  end

  def test_retire_action_while_workflow_running
    good_alice_in_db
    @alice.expects(:stopped?).returns(false)
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      @alice.retire_action('collect_alicedocs_from_source')
    end
    assert_equal 'Stop workflow before retiring action "collect_alicedocs_from_source".', e.message
  end

  def test_retire_action_does_not_exist
    good_alice_in_db
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      @alice.retire_action('i do not exist')
    end
    assert_equal 'Action "i do not exist" does not exist for this workflow.', e.message
  end

  def test_retire_action_already_retired
    good_alice_in_db
    action_name = 'collect_alicedocs_from_source'
    @alice.retire_action(action_name)
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      @alice.retire_action(action_name)
    end
    assert_equal 'Action "collect_alicedocs_from_source" is already retired.', e.message
  end

  def test_unretire_action_not_retired
    good_alice_in_db
    e = assert_raise Armagh::Actions::WorkflowConfigError do
      @alice.unretire_action('collect_alicedocs_from_source')
    end
    assert_equal 'Action "collect_alicedocs_from_source" is not retired.', e.message
  end

end
