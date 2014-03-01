require 'honyomi'
require 'fileutils'
require 'rack'

module Honyomi
  class Core
    def initialize(opts = {})
      @opts = opts
    end

    def init_database
      FileUtils.mkdir_p(db_dir)
      Groonga::Database.create(path: db_path)
    end

    def load_database
      Groonga::Database.open(db_path)
      @database = Database.new
    end

    def add(filename, title, options)
      pages = options[:strip] ? Pdf.new(filename).strip_pages : Pdf.new(filename).pages
      @database.add_book_from_pages(title, pages)
    end

    def search(query)
      @database.search(query)
    end

    def list
      @database.books.map do |book|
        "#{book.title} (#{book.page_num} pages)"
      end
    end

    def web
      options = {
        :environment => ENV['RACK_ENV'] || "development",
        :pid         => nil,
        :Port        => 9295,
        :Host        => "0.0.0.0",
        :AccessLog   => [],
        :config      => "config.ru",
        # ----------------------------
        :server      => "thin",
      }

      # Move to the location of the server script
      FileUtils.cd(File.join(File.dirname(__FILE__), 'web'))

      # Create Rack Server
      rack_server = Rack::Server.new(options)

      # Start Rack
      rack_server.start do
        # Launchy.open(launch_url) if launch_url
      end
    end

    private

    def home_dir
      unless @home_dir
        @home_dir = @opts[:home_dir] || File.join(default_home, '.honyomi')
        FileUtils.mkdir_p(@home_dir) unless File.exist?(@home_dir)
      end
      
      @home_dir
    end

    def db_dir
      File.join(home_dir, 'db')
    end

    def db_path
      File.join(db_dir, 'honyomi.db')
    end

    def default_home
      File.expand_path '~'
    end
  end
end
