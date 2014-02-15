require 'minitest_helper'

class TestHonyomi < MiniTest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Honyomi::VERSION
  end
end
