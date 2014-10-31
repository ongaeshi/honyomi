# -*- coding: utf-8 -*-

module Honyomi
  class Query
    attr_reader :src
    attr_reader :query
    attr_reader :jump_page_no
    attr_reader :key
    
    OPTIONS = [
               ['book'  , 'b'],
               ['title' , 't'],
               ['page'  , 'p'],
              ]

    def initialize(src)
      @src = src
      @query = ""
      init_hash
      parse
    end

    def add_p_to_number
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
            q << "p:#{Integer(text)}"
          rescue ArgumentError
            q << text
          end
        else
          q << "#{key}:#{text}"
        end
      end

      q.join(" ")
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
            @key['book'] << text
            q << "book:#{text}"
          when 'title', 't'
            @key['title'] << text
            q << "book.title:@#{text}"
          when 'page', 'p'
            @key['page'] << text
            q << "page_no:#{text}"
          end
        end
      end

      @query = q.join(" ")
    end
  end
end
