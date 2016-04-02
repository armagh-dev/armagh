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

@agent @launcher
Feature: Agent Launcher
  Instead of launching agents manually
  I want armagh to launch them for me

  Scenario: Run as a daemon
    Given armagh isn't already running
    And mongo is running
    And mongo is clean
    And I run armagh as a daemon
    Then armagh should run in the background
    And the number of running agents equals 1
    And the armagh daemon can be stopped

  Scenario: Handle daemon that dies
    Given armagh isn't already running
    And mongo is running
    And mongo is clean
    When I run armagh as a daemon
    And the armagh daemon is killed
    And I wait 60 seconds
    Then a new daemon shall take its place

  Scenario: Unable to connect to database
    Given armagh isn't already running
    And mongo isn't running
    When I run armagh
    Then armagh should have exited
    And stderr should contain "Unable to establish connection to the MongoConnection database configured in '/.+'.  Ensure the database is running."
