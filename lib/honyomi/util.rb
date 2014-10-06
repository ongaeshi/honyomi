require 'kconv'

module Honyomi
  module Util
    module_function

    def ruby20?
      RUBY_VERSION >= '2.0.0'
    end

    def ruby19?
      RUBY_VERSION >= '1.9.0'
    end

    def platform_win?
      RUBY_PLATFORM =~ /mswin(?!ce)|mingw|cygwin|bccwin/
    end

    def platform_osx?
      RUBY_PLATFORM =~ /darwin/
    end

    def filename_to_utf8(src)
      if platform_osx?
        if ruby19?
          src.encode('UTF-8', 'UTF8-MAC')
        else
          src
        end
      elsif platform_win?
        Kconv.kconv(src, Kconv::UTF8)        
      else
        src
      end
    end

    def strip_page(page)
      page.gsub(/[ \t]/, "")
    end

    def highlight_keywords(src, keywords, css_class)
      # Init highlight_map
      hightlight_map = Array.new(src.length, nil)

      keywords.each do |keyword|
        pos = 0

        loop do
          r = src.match(/#{Regexp.escape(keyword)}/i, pos) do |m|
            s = m.begin(0)
            l = keyword.length
            e = s+l
            (s...e).each {|i| hightlight_map[i] = 1 }
            pos = e
          end

          break if r.nil?
        end
      end

      # Delete html tag
      index = 0
      in_tag = false
      src.each_char do |char|
        in_tag = true               if char == '<'
        hightlight_map[index] = nil if in_tag
        in_tag = false              if char == '>'
        index += 1
      end

      # Output
      result = ""

      index = 0
      prev = nil
      src.each_char do |char|
        current = hightlight_map[index]

        if prev.nil? && current
          result += "<span class='#{css_class}'>"
        elsif prev && current.nil?
          result += "</span>"
        end

        result += char

        index += 1
        prev = current
      end
      result += "</span>" if prev

      result
    end

    def extract_keywords(query)
      query.split.reduce([]) do |a, e|
        e = e.gsub(/^\(|\)|AND|OR$/, "")

        if e =~ /^"(.+)"$/
          a  + [$1]
        elsif e =~ /^-/
          a
        elsif e =~ /:/
          a
        else
          a + [e]
        end
      end
    end
  end
end
