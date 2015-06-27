require 'honyomi'
require 'tmpdir'

module Honyomi
  class Pdf
    def initialize(filename)
      @filename = filename
    end

    def pages
      Dir.mktmpdir do |dir|
        outfile = File.join(dir, "pdf.txt")
        system("pdftotext", @filename, outfile) # Need pdftotext (poppler, xpdf)
        @text = File.read(outfile, encoding: Encoding::UTF_8)
        if String.method_defined? :scrub
          @text = @text.scrub('?')
        end
      end

      @text.split("\f")
    end
  end
end

