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

    def add_book_from_pages(filename, title, pages)
      path = File.expand_path(filename)
      results = @books.select("path:\"#{path}\"")
      book = results.first

      unless book
        # Add
        @books << { path: File.expand_path(filename), title: title, page_num: pages.size }
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

    def search(query)
      @pages.select(query, default_column: "text")
    end

    def book_pages(book_id)
      @pages.select("book._id:\"#{book_id}\"").sort(["page_no"])
    end
  end
end
