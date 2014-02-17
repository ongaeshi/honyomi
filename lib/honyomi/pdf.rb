require 'honyomi'
require 'tmpdir'

module Honyomi
  class Pdf
    def initialize(filename)
      @filename = filename

      Dir.mktmpdir do |dir|
        outfile = File.join(dir, "pdf.txt")
        system("pdftotext #{filename.gsub(' ', '\ ')} #{outfile}") # Need pdftotext (poppler, xpdf)
        @text = File.read(outfile)
      end
    end

    def pages
      @text.split("\f")
    end

    def strip_pages
      @text.split("\f").map { |page| page.gsub(/[\n\s]/, "") }
    end
  end
end
