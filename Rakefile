# Copyright 2016 Noragh Analytics, Inc.
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

require 'cucumber/rake/task'
require 'noragh/gem/tasks'
require 'rake/testtask'
require 'yard'
require 'fileutils'

desc 'Run tests'

task :ci => [:clean, :yard, :test]
task :nightly => [:ci, :cucumber]
task :default => [:nightly]

Rake::TestTask.new do |t|
  log_dir = '/var/log/armagh'
  FileUtils.mkdir_p log_dir
  raise "Invalid permissions on #{log_dir}" unless File.readable?(log_dir) && File.writable?(log_dir)

  t.libs << 'test'
  t.pattern = 'test/**/test_*.rb'
end

task :clean do
  rm_rf %w(doc coverage .yardoc)
end

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = '-e "test-client_actions"'
end

YARD::Rake::YardocTask.new