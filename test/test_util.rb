require 'minitest_helper'

class TestUtil < MiniTest::Test
  include Honyomi
  
  def test_extract_keywords
    assert_equal [], Util::extract_keywords(nil)
    assert_equal %w(AA BB), Util::extract_keywords("AA BB")
    assert_equal %w(aa bb cc), Util::extract_keywords("aa AND (bb OR cc)")
    assert_equal %w(aa), Util::extract_keywords("aa -bb a:c")
  end

  def test_count_digit
    assert_equal 1, Util::count_digit(0)
    assert_equal 1, Util::count_digit(1)
    assert_equal 2, Util::count_digit(10)
    assert_equal 3, Util::count_digit(100)
    assert_equal 4, Util::count_digit(9999)
  end

  def test_exist_command?
    assert_equal true, Util::exist_command?('pdftotext')
    assert_equal false, Util::exist_command?('pdftotexts')
  end
end
