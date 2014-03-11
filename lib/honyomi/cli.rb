require 'honyomi'
require 'thor'

module Honyomi
  class CLI < Thor
    class_option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message'

    desc "init", "Init database"
    def init
      core = Core.new
      core.init_database
    end

    desc "add file1 [file2 ...]", "Add pdf files"
    option :strip, :type => :boolean, :desc => 'Remove spaces and line breaks'
    def add(*args)
      core = Core.new
      core.load_database

      args.each do |arg|
        title = File.basename(Util::filename_to_utf8(arg), ".pdf")
        core.add(arg, title, options)
      end
    end

    desc "search query", "Search pages"
    def search(*args)
      core = Core.new
      core.load_database

      results = core.search(args.join(" "))
      snippet = GrnMini::Util::text_snippet_from_selection_results(results)

      puts "#{results.size} matches"
      results.map do |page|
        puts "--- #{page.book.title} (#{page.page_no} page) ---"
        snippet.execute(page.text).each do |segment|
          puts segment.gsub("\n", "")
        end
      end
    end

    desc "list", "List books"
    def list
      core = Core.new
      core.load_database

      puts core.list
    end

    desc "web", "Web search interface"
    def web
      core = Core.new
      core.load_database      
      core.web
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
