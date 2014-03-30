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
        core.add(arg, options)
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
    option :title, :type => :string,  :desc => 'Change title'
    option :path,  :type => :string,  :desc => 'Change file path'
    option :strip, :type => :boolean, :desc => 'Remove spaces'
    def edit(*args)
      core = Core.new
      core.load_database

      book_id = args[0].to_i
      core.edit(book_id, options)
      puts core.list([book_id])
    end

    desc "remove book_id1 [book_id2 ...]", "Remove books"
    def remove(*args)
      core = Core.new
      core.load_database

      args.each do |id|
        core.remove(id.to_i)
      end
    end

    desc "search query", "Search pages"
    def search(*args)
      core = Core.new
      core.load_database

      results = core.search(args.join(" "))
      snippet = GrnMini::Util.text_snippet_from_selection_results(results)

      puts "#{results.size} matches"
      results.map do |page|
        puts "--- #{page.book.title} (#{page.page_no} page) ---"
        snippet.execute(page.text).each do |segment|
          puts segment.gsub("\n", "")
        end
      end
    end

    desc "list [book_id1 book_id2 ...]", "List books"
    def list(*args)
      core = Core.new
      core.load_database

      puts core.list(args.map{|v| v.to_i })
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
