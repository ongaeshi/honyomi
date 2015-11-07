require 'minitest_helper'

class TestDatabase < MiniTest::Test
  def test_open
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)
    end
  end

  def test_add_book
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)

      db.add_book("/path/to/book1.pdf", ["1aa"], title: "Book1")
      db.add_book("/path/to/book2.pdf", ["2aa", "2bb"], title: "Book2")
      db.add_book("/path/to/book3.pdf", ["3aa", "3bb", "3cc"], title: "Book3")

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

  def test_add_book_title_default
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)

      db.add_book("/path/to/book1.pdf", ["1aa"])
      assert_equal "book1", db.books[1].title
    end
  end

  def test_add_book_same_path
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)

      db.add_book("/path/to/book1.pdf", ["1aa"], title: "Book1")
      db.add_book("/path/to/book2.pdf", ["2aa", "2bb"], title: "Book2")
      db.add_book("/path/to/book3.pdf", ["3aa", "3bb", "3cc"], title: "Book3")

      db.add_book("/path/to/book2.pdf", ["4aa"])

      assert_equal 3, db.books.size
      assert_equal 1, db.books[2].page_num
      assert_equal "Book2", db.books[2].title
    end
  end

  def test_change_book
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)

      db.add_book("/path/to/book1.pdf", ["1aa"], title: "Book1")
      db.add_book("/path/to/book2.pdf", ["2aa", "2bb"], title: "Book2")

      # title
      db.change_book(1, title: "BOOK1")
      assert_equal "BOOK1", db.books[1].title
      
      # path
      db.change_book(2, path: "/PATH/TO/BOOK2.pdf")
      assert_equal "/PATH/TO/BOOK2.pdf", db.books[2].path

      # pages
      db.change_book(2, pages: ["AA"])
      assert_equal 1, db.books[2].page_num
      assert_equal "AA", db.pages["2:1"].text
      assert_equal nil, db.pages["2:2"]
    end
  end

  def test_delete_book
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)

      db.add_book("/path/to/book1.pdf", ["1aa"], title: "Book1")
      db.add_book("/path/to/book2.pdf", ["2aa", "2bb"], title: "Book2")
      db.add_book("/path/to/book3.pdf", ["3aa", "3bb", "3cc"], title: "Book3")

      db.delete_book(2)

      assert_equal 2, db.books.size
      assert_equal 4, db.pages.size
    end
  end

  def test_search
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)
      db.add_book("/path/to/book1.pdf", ["1aa"])
      db.add_book("/path/to/book2.pdf", ["2aa", "2bb"])
      db.add_book("/path/to/book3.pdf", ["3aa", "3bb", "3cc"])

      results, _ = db.search(Honyomi::Query.new("1aa"))
      assert_equal 1, results.size

      results, _ = db.search(Honyomi::Query.new("aa"))
      assert_equal 3, results.size

      results, _ = db.search(Honyomi::Query.new("bb OR cc"))
      assert_equal 3, results.size
    end
  end

  def test_book_pages
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)
      db.add_book("/path/to/book1.pdf", ["1aa"])
      db.add_book("/path/to/book2.pdf", ["2aa", "2bb"])
      db.add_book("/path/to/book3.pdf", ["3aa", "3bb", "3cc"])

      assert_equal 1, db.book_pages(1).size
      assert_equal 2, db.book_pages(2).size
      assert_equal 3, db.book_pages(3).size
      assert_equal 0, db.book_pages(4).size # Not found
    end
  end


  def test_book_page
    GrnMini::tmpdb do
      db = Honyomi::Database.new(nil)
      db.add_book("/path/to/book1.pdf", ["1aa"])
      db.add_book("/path/to/book2.pdf", ["2aa", "2bb"])
      db.add_book("/path/to/book3.pdf", ["3aa", "3bb", "3cc"])

      book = db.books[2]
      assert_equal 1, db.book_page(book, 1).page_no
      assert_equal "2aa", db.book_page(book, 1).text
      assert_equal 2, db.book_page(book, 2).page_no
      assert_equal nil, db.book_page(book, 3)
    end
  end
end
