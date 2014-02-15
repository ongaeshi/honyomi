# -*- coding: utf-8 -*-
require 'honyomi'
require 'grn_mini'

module Honyomi
  class Database
    attr_reader :books
    attr_reader :pages

    def initialize
      @books = GrnMini::Hash.new("Books")
      @pages = GrnMini::Hash.new("Pages")

      @books.setup_columns(title:    "",
                           author:   "",
                           page_num: 0,
                           )
      @pages.setup_columns(book:    @books,
                           text:    "",
                           page_no: 0,
                           )
    end

    def add_book_from_text(data)
      title      = data[:title]
      text_array = data[:text].split("\f")
      
      @books[title] = { title: title, page_num: text_array.size }
      
      text_array.each_with_index do |page, index|
        @pages["#{title}:#{index+1}"] = { book: title, text: page, page_no: index+1 }
      end
    end

    def search(query)
      @pages.select(query, default_column: "text")
    end
  end
end
