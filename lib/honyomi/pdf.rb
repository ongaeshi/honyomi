# coding: utf-8
require 'honyomi'
require 'tmpdir'
require 'fileutils'
require "open3"
require "shellwords"

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

          o, e, s = Open3.capture3("pdftotext -f #{page_no} -l #{page_no} #{Shellwords.escape(@filename)} #{Shellwords.escape(outfile)}") # Need pdftotext (poppler, xpdf)
          break if s.exitstatus != 0
          
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

