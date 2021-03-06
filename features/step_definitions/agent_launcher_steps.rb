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

require_relative '../support/launcher_support'
require_relative '../../test/helpers/mongo_support'

require 'test/unit/assertions'
require 'time'

Given(/^armagh isn't already running$/) do
  LauncherSupport.kill_launcher_processes
  assert_empty LauncherSupport.get_launcher_processes, 'Armagh is already running'
end

When(/^armagh doesn't have a "([^"]*)" config$/) do |config_type|
  MongoSupport.instance.delete_config(config_type)
end

When(/^I run armagh$/) do
  @spawn_pid = LauncherSupport.launch_launcher
end

Then(/^armagh should have exited$/) do
  assert_false LauncherSupport.running?(@spawn_pid)
end

Then(/^armagh should be running$/) do
  assert_true LauncherSupport.running?(@spawn_pid)
end

Then(/^the number of running agents equals (\d+)$/) do |num_agents|
  assert_equal(num_agents.to_i, LauncherSupport.get_agent_processes.size)
end

When(/^an agent is killed/) do
  @original_agents = LauncherSupport.get_agent_processes
  @agent_to_kill = @original_agents.last.pid
  Process.kill(:SIGKILL, @agent_to_kill)
end

Then(/^a new agent shall launch to take its place$/) do
  agents = LauncherSupport.get_agent_processes
  assert_equal(@original_agents.size, agents.size)
  assert_false agents.include?(@agent_to_kill)
end

When(/^I run armagh as a daemon$/) do
  LauncherSupport.start_launcher_daemon
  sleep 2
end

When(/^I restart the armagh daemon$/) do
  LauncherSupport.restart_launcher_daemon
  sleep 2
end

Then(/^armagh should run in the background$/) do
  status = LauncherSupport.get_daemon_status
  assert_match(/armagh-agentsd is running as PID \d+/, status, 'Armagh was not running')
  @spawn_pid = status[/\d+/].to_i
  sleep 2
end

Then(/^armagh was restarted$/) do
  old_pid = @spawn_pid
  step 'armagh should run in the background'
  assert_not_equal(old_pid, @spawn_pid, 'Armagh is running with a previously used PID.')
end

Then(/^the armagh daemon can be stopped$/) do
  LauncherSupport.stop_launcher_daemon
  assert_true LauncherSupport.get_launcher_processes.empty?
end

When(/^the armagh daemon is killed$/) do
  status = LauncherSupport.get_daemon_status
  assert_match(/running \[pid \d+\]/, status)
  @old_pid = status[/\d+/].to_i

  Process.kill(:SIGTERM, @old_pid)
end

