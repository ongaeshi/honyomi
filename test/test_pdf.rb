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

  def test_file_name_includes_special_characters
    Dir.mktmpdir do |dir|
      filename = File.join(dir, "test (1).pdf")

      FileUtils.cp test_pdf, filename
      pdf = Honyomi::Pdf.new(filename)

      assert_equal 3, pdf.pages.size
    end
  end
end
