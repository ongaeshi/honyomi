require 'minitest_helper'
require 'honyomi/cli'

module Honyomi
  class TestCli < MiniTest::Test
    def setup
      @orig_stdout = $stdout
      $stdout = @stringio = StringIO.new
    end

    def teardown
      $stdout = @orig_stdout
    end

    def test_default
      assert_match /honyomi \d+/, command("")
    end

    private

    def command(arg)
      CLI.start(arg.split)
      $stdout.string
    end
  end
end
