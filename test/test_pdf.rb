require 'minitest_helper'

class TestPdf < MiniTest::Test
  def test_pdf
    File.join(File.dirname(__FILE__), "test.pdf")
  end
  
  def test_pages
    pdf = Honyomi::Pdf.new(test_pdf)

    assert_equal         3, pdf.pages.size
    assert_equal "aaa\n\n", pdf.pages[0]
    assert_equal "bbb\n\n", pdf.pages[1]
    assert_equal "ccc\n\n", pdf.pages[2]
  end
end
