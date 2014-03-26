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
  end
end
