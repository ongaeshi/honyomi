require 'honyomi'
require 'grn_mini'

module Honyomi
  class Database
    attr_reader :books
    attr_reader :pages
    attr_reader :bookmarks

    def initialize
      @books = GrnMini::Array.new("Books")
      @pages = GrnMini::Hash.new("Pages")
      @bookmarks = GrnMini::Hash.new("Bookmarks")

      @books.setup_columns(path:     "",
                           title:    "",
                           author:   "",
                           page_num: 0,
                           timestamp: Time.new,
                           )
      @pages.setup_columns(book:    @books,
                           text:    "",
                           page_no: 0,
                           bookmark: @bookmarks,
                           )
      @bookmarks.setup_columns(page:    @pages,
                               comment: "",
                               timestamp: Time.new,
                               )
    end

    def add_book(path, pages, options = {})
      book = book_from_path(path)

      if book
        # Already exist
        opts = options.dup
        opts[:pages] = pages
        change_book(book.id, opts)
        return book, :update

      else
        # New book
        path = Util.filename_to_utf8(path)
        title = options[:title] || File.basename(path, File.extname(path))
        timestamp = options[:timestamp] || Time.now

        book = @books.add(path: path,
                          title: title,
                          page_num: pages.size,
                          timestamp: timestamp,
                          )

        pages.each_with_index do |page, index|
          @pages["#{book.id}:#{index+1}"] = { book: book, text: page, page_no: index+1 }
        end

        return book, :add
      end
    end

    def change_book(book_id, options = {})
      book = @books[book_id]
      
      book.title = options[:title] if options[:title]
      book.path  = options[:path]  if options[:path]
      book.timestamp = options[:timestamp] if options[:timestamp]

      if options[:pages]
        pages = options[:pages]
        book.page_num = pages.size

        @pages.delete do |page|
          page.book == book
        end
        
        pages.each_with_index do |page, index|
          @pages["#{book.id}:#{index+1}"] = { book: book, text: page, page_no: index+1 }
        end
      end
    end

    def delete_book(book_id)
      book = @books[book_id]
      
      @pages.delete do |page|
        page.book == book
      end

      book.delete
    end

    def search(query)
      @pages.select(query, default_column: "text")
    end

    def book_pages(book_id)
      @pages.select("book._id:\"#{book_id}\"").sort(["page_no"])
    end

    def book_from_path(path)
      r = @books.select("path:\"#{path}\"").first

      if r
        r.key
      else
        nil
      end
    end

    def add_bookmark(page)
      @bookmarks["#{page.book.id}:#{page.page_no}"] = { page: page, timestamp: Time.now }
    end

    def delete_bookmark(page)
      @bookmarks.delete { |bookmark| bookmark.page == page }
    end
  end
end
