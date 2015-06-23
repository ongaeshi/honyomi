require 'honyomi'
require 'tmpdir'

module Honyomi
  class Pdf
    def initialize(filename)
      @filename = filename

      Dir.mktmpdir do |dir|
        outfile = File.join(dir, "pdf.txt")
        system("pdftotext", filename, outfile) # Need pdftotext (poppler, xpdf)
        @text = File.read(outfile, encoding: Encoding::UTF_8)
      end
    end

    def pages
      @text.split("\f")
    end
  end
end

