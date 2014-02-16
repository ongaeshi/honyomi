require 'minitest_helper'

class TestPdf < MiniTest::Test
  def test_basic
    text = Honyomi::Pdf.new("~/tmp/matz.pdf")
    p text.pages.map { |page| page[0..10] }
  end
end
