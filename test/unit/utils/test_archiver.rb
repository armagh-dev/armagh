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
require_relative '../../helpers/coverage_helper'

require_relative '../../helpers/mock_logger'
require_relative '../../../lib/environment'
Armagh::Environment.init

require_relative '../../../lib/utils/archiver'

require 'test/unit'
require 'mocha/test_unit'
require 'fakefs/safe'

require 'fileutils'

class TestArchiver < Test::Unit::TestCase
  include ArmaghTest

  def setup
    @logger = mock_logger
    @archiver = Armagh::Utils::Archiver.new(@logger)
  end

  def teardown
    FakeFS::FileSystem.clear
  end

  def test_archive_file
    file = 'file.txt'
    metadata = {'meta' => true}
    source = Armagh::Documents::Source.new(mime_type: 'test_type')
    archive_data = {'metadata' => metadata, 'source' => source.to_hash}

    config = mock('config')
    sftp = mock('sftp)')
    Armagh::Support::SFTP.expects(:archive_config).returns(config)
    Armagh::Support::SFTP::Connection.expects(:open).with(config).yields(sftp)
    Time.stubs(:now).returns(Time.new(2010, 2, 15, 10))

    date_dir = '2010/02/15.0000'
    sftp.expects(:mkdir_p).with(date_dir)
    sftp.expects(:ls).with('2010/02').returns(['15.0000'])
    sftp.expects(:ls).with(date_dir).returns([])

    sftp.expects(:put_file).with("#{file}.meta", date_dir)
    sftp.expects(:put_file).with(file, date_dir)

    file_exists = nil
    meta_content = nil
    FakeFS do
      meta_filename = "#{file}.meta"
      FileUtils.touch(meta_filename)
      File.link(meta_filename, 'meta_reference') # Hardlink so we can access it after the automatic delete
      @archiver.within_archive_context do
        @archiver.archive_file(file, archive_data)
      end
      file_exists = File.exists? meta_filename

      meta_content = JSON.parse(File.read('meta_reference'))
    end

    assert_false file_exists
    assert_equal({'metadata' => metadata, 'source' => source.to_hash}, meta_content)
  end

  def test_archive_file_day_rollover
    file = 'file.txt'
    metadata = {'meta' => true}
    source = Armagh::Documents::Source.new(mime_type: 'test_type')
    archive_data = {'metadata' => metadata, 'source' => source.to_hash}

    config = mock('config')
    sftp = mock('sftp)')
    Armagh::Support::SFTP.expects(:archive_config).returns(config)
    Armagh::Support::SFTP::Connection.expects(:open).with(config).yields(sftp)
    Time.stubs(:now).returns(Time.new(2010, 2, 15, 10))

    date_dir = '2010/02/15.0000'
    sftp.expects(:mkdir_p).with(date_dir)
    sftp.expects(:ls).with('2010/02').returns(%w(15.0000 15.0001 15.0002))

    files = []
    Armagh::Utils::Archiver::MAX_ARCHIVES_PER_DIR.times{|i| files << "file_#{i}"}

    sftp.expects(:ls).with('2010/02/15.0002').returns(files)

    sftp.expects(:put_file).with("#{file}.meta", '2010/02/15.0003')
    sftp.expects(:put_file).with(file, '2010/02/15.0003')

    FakeFS do
      @archiver.within_archive_context do
        @archiver.archive_file(file, archive_data)
      end
    end
  end

  def test_archive_file_no_context
    error = Armagh::Utils::Archiver::ArchiveError.new('Unable to archive file when outside of an archive context.')
    assert_raise(error){@archiver.archive_file('path', {})}
  end
end