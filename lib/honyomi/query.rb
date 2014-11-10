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
      parts = @src.scan(/(?:(#{kp}):)?(?:"(.+)"|(\S+))/)

      page_query = []
      bookmark_query = []

      parts.each do |key, quoted_value, value|
        if quoted_value
          text = %Q|"#{quoted_value}"|
        else
          text = value
        end
        
        unless (key)
          begin
            @jump_page_no = Integer(text)
            page_query << "page_no:#{text}"
            bookmark_query << "page_no:#{text}"
          rescue ArgumentError
            page_query << text
            bookmark_query << text
          end
        else
          case key
          when 'book', 'b'
            @key['book'] << text
            page_query << "book:#{text}"
            bookmark_query << "page.book:#{text}"
          when 'title', 't'
            @key['title'] << text
            page_query << "book.title:@#{text}"
            bookmark_query << "page.book.title:@#{text}"
          when 'page', 'p'
            @key['page'] << text
            page_query << "page_no:#{text}"
            bookmark_query << "page.book.page_no:#{text}"
          end
        end
      end

      @page_query = page_query.join(" ")
      @bookmark_query = bookmark_query.join(" ")
    end
  end
end
