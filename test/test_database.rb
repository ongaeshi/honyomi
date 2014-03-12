require 'minitest_helper'

class TestDatabase < MiniTest::Test
  def test_open
    GrnMini::tmpdb do
      db = Honyomi::Database.new
    end
  end

  def test_add_book_from_text
    GrnMini::tmpdb do
      db = Honyomi::Database.new
      db.add_book_from_text(title: "Book1", text: "1aa\f")
      db.add_book_from_text(title: "Book2", text: "2aa\f2bb\f")
      db.add_book_from_text(title: "Book3", text: "3aa\f3bb\f3cc\f")

      assert_equal 3, db.books.size
      assert_equal 1, db.books[1].page_num
      assert_equal 2, db.books[2].page_num
      assert_equal 3, db.books[3].page_num

      assert_equal "Book1", db.pages["1:1"].book.title
      assert_equal       1, db.pages["1:1"].page_no
      assert_equal   "1aa", db.pages["1:1"].text

      assert_equal "Book2", db.pages["2:1"].book.title
      assert_equal       1, db.pages["2:1"].page_no
      assert_equal   "2aa", db.pages["2:1"].text
      assert_equal "Book2", db.pages["2:2"].book.title
      assert_equal       2, db.pages["2:2"].page_no
      assert_equal   "2bb", db.pages["2:2"].text

      assert_equal "Book3", db.pages["3:1"].book.title
      assert_equal       1, db.pages["3:1"].page_no
      assert_equal   "3aa", db.pages["3:1"].text
      assert_equal "Book3", db.pages["3:2"].book.title
      assert_equal       2, db.pages["3:2"].page_no
      assert_equal   "3bb", db.pages["3:2"].text
      assert_equal "Book3", db.pages["3:3"].book.title
      assert_equal       3, db.pages["3:3"].page_no
      assert_equal   "3cc", db.pages["3:3"].text
    end
  end

  def test_search
    GrnMini::tmpdb do
      db = Honyomi::Database.new
      db.add_book_from_text(title: "Book1", text: "1aa\f")
      db.add_book_from_text(title: "Book2", text: "2aa\f2bb\f")
      db.add_book_from_text(title: "Book3", text: "3aa\f3bb\f3cc\f")

      results = db.search("1aa")
      assert_equal 1, results.size

      results = db.search("aa")
      assert_equal 3, results.size

      results = db.search("bb OR cc")
      assert_equal 3, results.size
    end
  end

  def test_book_pages
    GrnMini::tmpdb do
      db = Honyomi::Database.new
      db.add_book_from_text(title: "Book1", text: "1aa\f")
      db.add_book_from_text(title: "Book2", text: "2aa\f2bb\f")
      db.add_book_from_text(title: "Book3", text: "3aa\f3bb\f3cc\f")

      assert_equal 1, db.book_pages(1).size
      assert_equal 2, db.book_pages(2).size
      assert_equal 3, db.book_pages(3).size
      assert_equal 0, db.book_pages(4).size # Not found
    end
  end
end
