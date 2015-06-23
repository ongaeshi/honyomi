require 'honyomi'
require 'thor'

module Honyomi
  class CLI < Thor
    class_option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message'

    desc "init", "Create database in ENV['HONYOMI_DATABASE_DIR'] or '~/.honyomi'"
    def init
      begin
        core = Core.new
        core.init_database
        puts "Create database to \"#{core.db_path}\""
      rescue Groonga::FileExists
        puts "Database already exists in \"#{core.db_path}\""
      end
    end

    desc "add file1 [file2 ...]", "Add pdf files"
    option :title, :aliases => '-t', :type => :string,  :desc => 'Specify title'
    option :strip, :type => :boolean, :desc => 'Remove spaces'
    def add(*args)
      core = Core.new
      core.load_database

      if options[:title] && args.size > 1
        puts "Arguments is specified more than once, but there is --title option"
        return
      end

      args.each do |arg|
        begin
          book, status = core.add(arg, options)
        rescue Errno::ENOENT => e
          puts "Not found 'pdftotext' command (poppler, xpdf)"
          exit -1
        end

        unless book
          puts "Not exist: #{arg}"
          next
        end

        case status
        when :update
          puts "U #{book.id.to_s} #{book.title} (#{book.page_num} pages)"
        when :add
          puts "A #{book.id.to_s} #{book.title} (#{book.page_num} pages)"
        else
          raise
        end
      end
    end

    # desc "update [book_id1 book_id2 ...]", "Update pdf files"
    # option :all, :type => :boolean, :desc => 'Update all pdf'
    # def update(*args)
    #   core = Core.new
    #   core.load_database
    #   core.update(args[0], options)
    # end

    desc "edit book_id [options]", "Edit book info"
    option :title, :aliases => '-t', :type => :string,  :desc => 'Change title'
    option :author, :aliases => '-a', :type => :string,  :desc => 'Change author'
    option :url, :aliases => '-u', :type => :string,  :desc => 'Change url'
    option :path,  :type => :string,  :desc => 'Change file path'
    option :strip, :type => :boolean, :desc => 'Remove spaces'
    option :no_strip, :type => :boolean, :desc => 'Not remove spaces'
    option :timestamp, :type => :string, :desc => 'Change timestamp'
    def edit(*args)
      core = Core.new
      core.load_database

      begin 
        book_id = args[0].to_i
        core.edit(book_id, options)
        puts core.list([book_id])
      rescue HonyomiError => e
        puts e
        exit -1
      end
    end

    desc "remove book_id1 [book_id2 ...]", "Remove books"
    def remove(*args)
      core = Core.new
      core.load_database

      args.each do |id|
        puts core.list([id.to_i])
        core.remove(id.to_i)
      end
    end

    desc "search query", "Search pages"
    def search(*args)
      core = Core.new
      core.load_database

      results, snippet = core.search(args.join(" "))

      puts "#{results.size} matches"
      results.map do |page|
        puts "--- #{page.book.title} (#{page.page_no} page) ---"
        snippet.execute(page.text).each do |segment|
          puts segment.gsub("\n", "")
        end
      end
    end

    desc "list [book_id1 book_id2 ...]", "List books"
    option :path, :type => :boolean,  :desc => 'Display path'
    option :title, :aliases => '-t', :type => :string,  :desc => 'Filter title'
    def list(*args)
      core = Core.new
      core.load_database

      puts core.list(args.map{|v| v.to_i }, options)
    end

    desc "web", "Web search interface"
    option :no_browser, :type => :boolean, :default => false, :aliases => '-n', :desc => 'Do not launch browser.'
    option :host, :default => '127.0.0.1', :aliases => '-o', :desc => 'Listen on HOST.'
    option :port, :default => 9295, :aliases => '-p', :desc => 'Use PORT.'
    option :server, :default => 'thin', :aliases => '-s', :desc => 'Use SERVER.'
    def web
      core = Core.new
      core.load_database      
      core.web(options)
    end

    no_tasks do
      # Override method for support -h 
      # defined in /lib/thor/invocation.rb
      def invoke_command(task, *args)
        if task.name == "help" && args == [[]]
          print "honyomi #{Honyomi::VERSION}\n\n"
        end
        
        if options[:help]
          CLI.task_help(shell, task.name)
        else
          super
        end
      end
    end
  end
end
