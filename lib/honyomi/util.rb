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
      return "" if src.nil?

      words = Groonga::PatriciaTrie.create(:key_type => "ShortText", :key_normalize => true)
      keywords.each { |keword| words.add(keword) }

      other_text_handler = Proc.new { |string| ERB::Util.h(string) }
      options = { other_text_handler: other_text_handler }

      words.tag_keys(src, options) do |record, word|
        "<span class='#{css_class}'>#{ERB::Util.h(word)}</span>"
      end
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
