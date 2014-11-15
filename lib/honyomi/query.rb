# -*- coding: utf-8 -*-

module Honyomi
  class Query
    attr_reader :src
    attr_reader :page_query
    attr_reader :bookmark_query
    attr_reader :jump_page_no
    attr_reader :key
    
    OPTIONS = [
               ['book'  , 'b'],
               ['title' , 't'],
               ['page'  , 'p'],
              ]

    def initialize(src)
      @src = src
      init_hash
      parse
    end

    private

    def init_hash
      @key = {}

      OPTIONS.flatten.each do |key|
        @key[key] = []
      end
    end

    def parse
      kp = OPTIONS.flatten.join('|')
      parts = @src.scan(/(-)?(?:(#{kp}):)?(?:"(.+)"|(\S+))/)

      page_query = []
      bookmark_query = []

      parts.each do |minus, key, quoted_value, value|
        if quoted_value
          text = %Q|"#{quoted_value}"|
        else
          text = value
        end

        unless (key)
          begin
            @jump_page_no = Integer(text)
            page_query     << make_query(minus, text, "page_no")
            bookmark_query << make_query(minus, text, "page.page_no")
          rescue ArgumentError
            page_query     << make_query(minus, text)
            bookmark_query << make_query(minus, text)
          end
        else
          case key
          when 'book', 'b'
            @key['book']   << text
            page_query     << make_query(minus, text, "book")
            bookmark_query << make_query(minus, text, "page.book")
          when 'title', 't'
            @key['title']  << text
            page_query     << make_query(minus, text, "book.title:@")
            bookmark_query << make_query(minus, text, "page.book.title:@")
          when 'page', 'p'
            @key['page']   << text
            page_query     << make_query(minus, text, "page_no")
            bookmark_query << make_query(minus, text, "page.book.page_no")
          end
        end
      end

      @page_query = page_query.join(" ")
      @bookmark_query = bookmark_query.join(" ")
    end

    def make_query(minus, text, key = nil)
      m = minus ? "-" : ""

      if key
        if key[/@$/]
         "#{m}#{key}#{text}"
        else
         "#{m}#{key}:#{text}"
        end
      else
        "#{m}#{text}"
      end
    end
  end
end
