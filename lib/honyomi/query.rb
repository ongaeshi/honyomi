# -*- coding: utf-8 -*-

module Honyomi
  class Query
    attr_reader :src
    attr_reader :query
    attr_reader :jump_page_no
    
    OPTIONS = [
               ['book'  , 'b'],
               ['title' , 't'],
               ['page'  , 'p'],
              ]

    def initialize(src)
      @src = src
      @query = ""
      parse
    end

    private

    def parse
      kp = OPTIONS.flatten.join('|')
      parts = @src.scan(/(?:(#{kp}):)?(?:"(.+)"|(\S+))/)

      q = []

      parts.each do |key, quoted_value, value|
        if quoted_value
          text = %Q|"#{quoted_value}"|
        else
          text = value
        end
        
        unless (key)
          begin
            @jump_page_no = Integer(text)
          rescue ArgumentError
            q << text
          end
        else
          case key
          when 'book', 'b'
            q << "book:#{text}"
          when 'title', 't'
            q << "book.title:@#{text}"
          when 'page', 'p'
            q << "page_no:#{text}"
          end
        end

        @query = q.join(" ")
      end
    end
  end
end
