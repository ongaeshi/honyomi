require 'minitest_helper'

class TestPdf < MiniTest::Test
  def test_pages
    pages = Honyomi::Pdf.new("~/tmp/matz.pdf")
    p pages.pages.map { |page| page[0..10] }
  end

  def test_strip_pages
    pages = Honyomi::Pdf.new("~/tmp/matz.pdf")
    p pages.strip_pages.map { |page| page[0..10] }
  end
end
