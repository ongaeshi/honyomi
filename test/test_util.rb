require 'minitest_helper'

class TestUtil < MiniTest::Test
  include Honyomi
  
  def test_extract_keywords
    assert_equal [], Util::extract_keywords(nil)
    assert_equal %w(AA BB), Util::extract_keywords("AA BB")
    assert_equal %w(aa bb cc), Util::extract_keywords("aa AND (bb OR cc)")
    assert_equal %w(aa), Util::extract_keywords("aa -bb a:c")
  end

end
