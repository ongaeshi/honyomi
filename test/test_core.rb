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

    def test_add_strip
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test2.pdf"))
        assert_equal "aaa bbb ccc", core.database.pages["1:1"].text.sub(/\n+\Z/, "")
        assert_equal "dd ee", core.database.pages["1:2"].text.sub(/\n+\Z/, "")

        core.add(datafile("test2.pdf"), strip: true)
        assert_equal "aaabbbccc", core.database.pages["1:1"].text.sub(/\n+\Z/, "")
        assert_equal "ddee", core.database.pages["1:2"].text.sub(/\n+\Z/, "")
      end
    end

    def test_edit
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test2.pdf"))

        core.edit(1, title: "ttt")
        assert_equal "ttt", core.database.books[1].title 

        core.edit(1, strip: true)
        assert_equal "aaabbbccc", core.database.pages["1:1"].text.sub(/\n+\Z/, "")

        assert_equal datafile("test2.pdf"), core.database.books[1].path
        core.edit(1, path: datafile("test.pdf"))
        assert_equal datafile("test.pdf"), core.database.books[1].path
      end
    end

    def test_remove
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test.pdf"))
        core.add(datafile("test2.pdf"))
        assert_equal 2, core.database.books.size

        core.remove(1)
        assert_equal 1, core.database.books.size
        assert_equal 2, core.database.pages.size

        core.remove(2)
        assert_equal 0, core.database.books.size
        assert_equal 0, core.database.pages.size
      end
    end

    private

    def datafile(path)
      File.join(File.dirname(__FILE__), path)
    end

  end
end
