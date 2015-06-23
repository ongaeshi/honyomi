require 'honyomi'
require 'honyomi/query'
require 'grn_mini'

module Honyomi
  class HonyomiError < Exception ; end

  class Database
    attr_reader :books
    attr_reader :pages
    attr_reader :bookmarks

    def initialize
      @books = GrnMini::Array.new("Books")
      @pages = GrnMini::Hash.new("Pages")
      @bookmarks = GrnMini::Hash.new("Bookmarks")

      @books.setup_columns(path:     "",
                           title:    "",
                           author:   "",
                           url:      "",
                           page_num: 0,
                           timestamp: Time.new,
                           )
      @pages.setup_columns(book:    @books,
                           text:    "",
                           page_no: 0,
                           bookmark: @bookmarks,
                           )
      @bookmarks.setup_columns(page:    @pages,
                               comment: "",
                               timestamp: Time.new,
                               )
    end

    def add_from_pdf(filename, options = {})
      if File.exist?(filename)
        filename = File.expand_path(filename)
        options = options.dup
        pages = Pdf.new(filename).pages
        pages = pages.map { |page| Util.strip_page(page) } if options[:strip]
        options[:timestamp] = File.stat(filename).mtime
        add_book(filename, pages, options)
      else
        nil
      end
    end

    def add_book(path, pages, options = {})
      book = book_from_path(path)

      if book
        # Already exist
        opts = options.dup
        opts[:pages] = pages
        change_book(book.id, opts)
        return book, :update

      else
        # New book
        path = Util.filename_to_utf8(path)
        title = options[:title] || File.basename(path, File.extname(path))
        timestamp = options[:timestamp] || Time.now

        book = @books.add(path: path,
                          title: title,
                          author: "",
                          url:    "",
                          page_num: pages.size,
                          timestamp: timestamp,
                          )

        pages.each_with_index do |page, index|
          @pages["#{book.id}:#{index+1}"] = { book: book, text: page, page_no: index+1 }
        end

        return book, :add
      end
    end

    def change_book(book_id, options = {})
      book = @books[book_id]
      raise HonyomiError, "Invalid book id: #{book_id}" unless book.valid_id?
      
      book.title = options[:title] if options[:title]
      book.author = options[:author] if options[:author]
      book.url = options[:url] if options[:url]
      book.path  = options[:path]  if options[:path]
      book.timestamp = options[:timestamp] if options[:timestamp]

      if options[:pages]
        pages = options[:pages]
        book.page_num = pages.size

        @pages.delete do |page|
          page.book == book
        end
        
        pages.each_with_index do |page, index|
          @pages["#{book.id}:#{index+1}"] = { book: book, text: page, page_no: index+1 }
        end
      end
    end

    def delete_book(book_id)
      book = @books[book_id]
      
      @pages.delete do |page|
        page.book == book
      end

      book.delete
    end

    def search(query, options = {})
      match_pages = @pages.select(query.page_query, default_column: "text")

      if options[:cli]
        snippet = match_pages.expression.snippet([ ['<<',
                                                    '>>'] ],
                                                 {normalize: true})
      else
        snippet = match_pages.expression.snippet([["<span class=\"highlight\">", "</span>"]], {html_escape: true, normalize: true, max_results: 5})
      end

      match_bookmarks = @bookmarks.select do |record|
        record.match(query.bookmark_query) do |target|
          target.comment * 10
        end
      end

      group_by_page = match_bookmarks.group("page")

      return group_by_page.union!(match_pages), snippet
    end

    def book_pages(book_id)
      @pages.select("book._id:\"#{book_id}\"").sort(["page_no"])
    end

    def book_from_path(path)
      r = @books.select("path:\"#{path}\"").first

      if r
        r.key
      else
        nil
      end
    end

    def add_bookmark(page)
      @bookmarks["#{page.book.id}:#{page.page_no}"] = { page: page, timestamp: Time.now }
    end

    def delete_bookmark(page)
      @bookmarks.delete { |bookmark| bookmark.page == page }
    end

    def update_bookmark_comment(id, page_no, comment)
      bm = @bookmarks["#{id}:#{page_no}"]
      bm.comment = comment
      bm.timestamp = Time.now
      bm
    end

    def bookmark?(page)
      @bookmarks["#{page.book.id}:#{page.page_no}"]
    end

    def bookmark_from_page(page)
      @bookmarks["#{page.book.id}:#{page.page_no}"]
    end

    def books_bookmark(book)
      @bookmarks.select { |record| record.page.book == book }
    end
  end
end
