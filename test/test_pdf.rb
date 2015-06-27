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

  def test_generate_images
    Dir.mktmpdir do |dir|
      pdf = Honyomi::Pdf.new(test_pdf)
      pdf.generate_images(dir)

      Dir.chdir(dir) do
        assert_equal %w(book-1.jpg book-2.jpg book-3.jpg), Dir.glob("*")
      end
    end
  end
end
