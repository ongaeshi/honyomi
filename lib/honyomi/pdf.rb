# coding: utf-8
require 'honyomi'
require 'tmpdir'
require 'fileutils'

module Honyomi
  class Pdf
    def initialize(filename)
      @filename = filename
    end

    def pages
      result = []
      
      Dir.mktmpdir do |dir|
        outfile = File.join(dir, "pdf.txt")

        loop do
          page_no = (result.count + 1).to_s

          is_success = system("pdftotext", "-f", page_no, "-l", page_no, @filename, outfile) # Need pdftotext (poppler, xpdf)
          break unless is_success
          
          text = File.read(outfile, encoding: Encoding::UTF_8)

          if String.method_defined? :scrub
            text = text.scrub('?')
          end

          result << text
        end
      end

      result
    end

    def generate_images(output_dir)
      FileUtils.mkdir_p output_dir
      system("pdftoppm", "-jpeg", @filename, File.join(output_dir, "book"))
    end
  end
end

