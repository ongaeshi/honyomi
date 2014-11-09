require 'honyomi'
require 'fileutils'
require 'launchy'
require 'rack'

module Honyomi
  class Core
    attr_reader :database

    def initialize(opts = {})
      @opts = opts
    end

    def init_database
      FileUtils.mkdir_p(db_dir)
      Groonga::Database.create(path: db_path)
      @database = Database.new
    end

    def load_database
      Groonga::Database.open(db_path)
      @database = Database.new
    end

    def add(filename, options = {})
      if File.exist?(filename)
        filename = File.expand_path(filename)
        options = options.dup
        pages = Pdf.new(filename).pages
        pages = pages.map { |page| Util.strip_page(page) } if options[:strip]
        options[:timestamp] = File.stat(filename).mtime
        @database.add_book(filename, pages, options)
      else
        nil
      end
    end

    def update(book_id, options)
    end

    def edit(book_id, options)
      opts = {}
      opts[:title]     = options[:title]                 if options[:title]
      opts[:author]    = options[:author]                if options[:author]
      opts[:url]       = options[:url]                   if options[:url]
      opts[:path]      = options[:path]                  if options[:path]
      opts[:timestamp] = Time.parse(options[:timestamp]) if options[:timestamp]

      if options[:strip] || options[:no_strip]
        filename = @database.books[book_id].path
        opts[:pages] = Pdf.new(filename).pages
        opts[:pages] = opts[:pages].map { |page| Util.strip_page(page) } if options[:strip]
      end

      @database.change_book(book_id, opts)
    end
    
    def remove(book_id)
      @database.delete_book(book_id)
    end

    def search(query)
      @database.search(query)
    end

    def list(args = [], options = {})
      books = @database.books
      books = books.select("title:@#{options[:title]}").map {|record| record.key} if options[:title]
      
      if args.empty?
        id_length = books.max { |book| book.id.to_s.length }
        id_length = id_length ? id_length.id.to_s.length : 0

        books.map do |book|
          # "#{book.id} #{book.title} (#{book.page_num} pages) #{book.path}"
          "#{book.id.to_s.rjust(id_length)} #{book.title} (#{book.page_num} pages)"
        end
      else
        results = []
        
        books.each do |book|
          if args.include?(book.id)
            results << <<EOF
id:        #{book.id.to_s}
title:     #{book.title}
author:    #{book.author}
url:       #{book.url}
path:      #{book.path}
pages:     #{book.page_num}
timestamp: #{book.timestamp}

EOF
          end
        end

        results
      end
    end

    def web(options)
      rack_options = {
        :environment => ENV['RACK_ENV'] || "development",
        :pid         => nil,
        :Port        => options[:port],
        :Host        => options[:host],
        :AccessLog   => [],
        :config      => "config.ru",
        # ----------------------------
        :server      => options[:server],
      }

      # Move to the location of the server script
      FileUtils.cd(File.join(File.dirname(__FILE__), 'web'))

      # Create Rack Server
      rack_server = Rack::Server.new(rack_options)

      # Start Rack
      rack_server.start do
        unless options[:no_browser]
          Launchy.open("http://#{options[:host]}:#{options[:port]}")
        end
      end
    end

    def db_dir
      File.join(home_dir, 'db')
    end

    def db_path
      File.join(db_dir, 'honyomi.db')
    end

    private

    def home_dir
      unless @home_dir
        @home_dir = @opts[:home_dir] || ENV['HONYOMI_DATABASE_DIR'] || File.join(default_home, '.honyomi')
        FileUtils.mkdir_p(@home_dir) unless File.exist?(@home_dir)
      end
      
      @home_dir
    end

    def default_home
      File.expand_path '~'
    end
  end
end
