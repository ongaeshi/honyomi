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
    def add(*args)
      puts "add #{args}"
    end

    desc "search query", "Search pages"
    def search(*args)
      puts "search #{args}"
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
