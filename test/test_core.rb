require 'minitest_helper'
require 'tmpdir'

module Honyomi
  class TestCore < MiniTest::Test
    def test_init
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database
      end
    end

    def test_add
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test.pdf"), title: "TEST PDF")

        assert_equal 1, core.database.books.size
      end
    end

    def test_add_same_name
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test.pdf"), title: "TEST1")
        assert_equal "TEST1", core.database.books[1].title 
        
        core.add(datafile("test.pdf"), title: "TEST2")
        assert_equal "TEST2", core.database.books[1].title 

        assert_equal 1, core.database.books.size
      end
    end

    def test_add_by_specifying_only_filename
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test.pdf"))
        assert_equal "test", core.database.books[1].title 
      end
    end

    def test_add_with_title
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test.pdf"), {title: "ttt"})
        assert_equal "ttt", core.database.books[1].title 
      end
    end

    private

    def datafile(path)
      File.join(File.dirname(__FILE__), path)
    end

  end
end
