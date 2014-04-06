require 'minitest_helper'
require 'honyomi/cli'

module Honyomi
  class TestCli < MiniTest::Test
    def setup
      @orig_stdout = $stdout
      $stdout = @stringio = StringIO.new
      ENV['HONYOMI_DATABASE_DIR'] = Dir.mktmpdir
    end

    def teardown
      $stdout = @orig_stdout
      FileUtils.rm_rf(ENV['HONYOMI_DATABASE_DIR'])
      ENV['HONYOMI_DATABASE_DIR'] = nil
    end

    def test_default
      assert_match /honyomi \d+/, command("")
    end

    def test_init
      assert_match /Create database to/, command("init")
      assert_match /Database already exists/, command("init")
    end
    private

    def command(arg)
      CLI.start(arg.split)
      $stdout.string
    end
  end
end
