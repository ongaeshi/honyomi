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

    def test_add_by_relative_path
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        absolute_path = File.expand_path(datafile("test.pdf"))
        relative_path = Pathname.new(datafile("test.pdf")).relative_path_from(Pathname.new(Dir.getwd)).to_s
        assert absolute_path != relative_path

        core.add(relative_path)

        assert_equal absolute_path, core.database.books[1].path
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
        assert_equal "aaa bbb ccc", core.database.pages["1:1"].text.sub(/\n*\f*\Z/, "")
        assert_equal "dd ee", core.database.pages["1:2"].text.sub(/\n*\f*\Z/, "")

        core.add(datafile("test2.pdf"), strip: true)
        assert_equal "aaabbbccc", core.database.pages["1:1"].text.sub(/\n*\f*\Z/, "")
        assert_equal "ddee", core.database.pages["1:2"].text.sub(/\n*\f*\Z/, "")
      end
    end

    def test_add_with_status
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        book, status = core.add(datafile("test2.pdf"))
        assert_equal :add, status

        book, status = core.add(datafile("test2.pdf"), strip: true)
        assert_equal :update, status
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
        assert_equal "aaabbbccc", core.database.pages["1:1"].text.sub(/\n*\f*\Z/, "")

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

    def test_list_empty
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database
        assert_equal [], core.list
      end
    end    

    def test_list_title
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test.pdf"))
        core.add(datafile("test2.pdf"))

        assert_equal ["2 test2 (2 pages)"], core.list([], {title: "2"})
        assert_equal ["1 test (3 pages)", "2 test2 (2 pages)"], core.list([], {title: "test"})
      end
    end

    def test_list_id_with_titile
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        core.add(datafile("test.pdf"))
        core.add(datafile("test2.pdf"))

        assert_equal 1, core.list([1], {title: "test"}).size
      end
    end

    def test_image
      Dir.mktmpdir do |dir|
        core = Core.new({home_dir: dir})
        core.init_database

        book, _ = core.add(datafile("test.pdf"), title: "TEST PDF")
        
        image_dir = File.join(dir, "image", book.id.to_s)
        assert File.exist?(File.join(image_dir, "book-1.jpg"))
        assert File.exist?(File.join(image_dir, "book-2.jpg"))
        assert File.exist?(File.join(image_dir, "book-3.jpg"))

        core.image(book.id, {delete: true})
        assert !File.exist?(File.join(image_dir, "book-1.jpg"))
        assert !File.exist?(File.join(image_dir, "book-2.jpg"))
        assert !File.exist?(File.join(image_dir, "book-3.jpg"))

        core.image(book.id)
        assert File.exist?(File.join(image_dir, "book-1.jpg"))
        assert File.exist?(File.join(image_dir, "book-2.jpg"))
        assert File.exist?(File.join(image_dir, "book-3.jpg"))
      end
    end

    private

    def datafile(path)
      File.expand_path(File.join(File.dirname(__FILE__), path))
    end

  end
end
