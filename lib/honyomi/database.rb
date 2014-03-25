require 'honyomi'
require 'grn_mini'

module Honyomi
  class Database
    attr_reader :books
    attr_reader :pages

    def initialize
      @books = GrnMini::Array.new("Books")
      @pages = GrnMini::Hash.new("Pages")

      @books.setup_columns(path:     "",
                           title:    "",
                           author:   "",
                           page_num: 0,
                           )
      @pages.setup_columns(book:    @books,
                           text:    "",
                           page_no: 0,
                           )
    end

    def add_book(path, title, pages)
      book = book_from_path(path)

      if book
        change_book(book.id, {title: title, pages: pages})
        return
      end

      @books << { path: path, title: title, page_num: pages.size }
      book = @books[@books.size]

      pages.each_with_index do |page, index|
        @pages["#{book.id}:#{index+1}"] = { book: book, text: page, page_no: index+1 }
      end
    end

    def change_book(book_id, options = {})
      book = @books[book_id]
      
      book.title = options[:title] if options[:title]
      book.path  = options[:path]  if options[:path]

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

    # @todo Remove
    def add_book_from_pages(filename, title, pages)
      path = File.expand_path(filename)
      results = @books.select("path:\"#{path}\"")
      book = results.first

      unless book
        # Add
        @books << { path: path, title: title, page_num: pages.size }
        book = @books[@books.size]
      else
        # Update
        book       = book.key         # Get the entity
        book.title = title
        page_num   = pages.size
      end

      pages.each_with_index do |page, index|
        @pages["#{book.id}:#{index+1}"] = { book: book, text: page, page_no: index+1 }
      end
    end

  end
end
