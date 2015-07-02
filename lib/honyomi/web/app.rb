# -*- coding: utf-8 -*-
require 'haml'
require 'honyomi/core'
require 'honyomi/database'
require 'honyomi/util'
require 'sinatra'
if ENV['SINATRA_RELOADER']
  require 'sinatra/reloader'
  also_reload '../../**/*.rb'
end

SEARCH_RPAGE = 20

BOOKMARK_RPAGE = 20
BOOKMARK_COMMENT_LENGTH = 255

include Honyomi

set :haml, :format => :html5

configure do
  $database = Database.new
end

get '/' do
  @database = $database

  if @params[:query] && !@params[:query].empty?
    search_home
  else
    home
  end
end

get '/add' do
  if !ENV['HONYOMI_DISABLE_WEB_ADD']
    haml :add
  else
    ""
  end
end

post '/upload' do
  return "" if ENV['HONYOMI_DISABLE_WEB_ADD']

  @database = $database

  if params[:files]
    save_dir = File.join(Util.home_dir, "book")
    FileUtils.mkdir_p(save_dir) unless File.exist?(save_dir)

    params[:files].each do |file|
      save_path = File.join(save_dir, file[:filename])

      File.open(save_path, 'wb') do |f|
        # p file[:tempfile]
        f.write file[:tempfile].read
      end

      @database.add_from_pdf(save_path)
    end

    @message = "Upload Success"
  else
    @message = "Upload Failed"
  end

  redirect "/"
end

get '/help' do
  haml :help
end

post '/search' do
  q = Query.new(params[:query])

  if params[:book_id] && !@params[:book_id].empty?
    if q.key['book'][0] || q.key['title'][0]
      redirect "/?query=#{escape(q.src)}"
    elsif q.jump_page_no
      redirect "/v/#{@params[:book_id]}?page=#{q.jump_page_no}&query=#{escape(q.src)}"
    else
      redirect "/v/#{@params[:book_id]}?query=#{escape(q.src)}"
    end
  else
    redirect "/?query=#{escape(q.src)}"
  end
end

get '/v/:id' do
  @database = $database

  book = @database.books[params[:id].to_i]

  if params[:pdf] == '1'
    send_file(book.path, :disposition => 'inline')
  elsif params[:dl] == '1'
    send_file(book.path, :disposition => 'download')
  elsif params[:image] == '1'
    page = @database.pages["#{params[:id].to_i}:#{params[:page].to_i}"]
    send_file(Util.image_path(page))
  else
    if params[:page]
      text_page(book, params[:page].to_i)
    else
      if @params[:query] && !@params[:query].empty?
        search_book_home(book)
      elsif @params[:b] == '1'
        book_bookmark(book)
      else
        book_home(book)
      end
    end
  end
end

post '/command' do
  @database = $database

  case params[:kind]
  when 'favorite'
    page = @database.pages["#{params[:id].to_i}:#{params[:page_no].to_i}"]

    if params[:favorited] == 'true'
      @database.add_bookmark(page)
    else
      @database.delete_bookmark(page)
    end
    ""

  when 'favorite-update'
    bm = @database.update_bookmark_comment(params[:id].to_i, params[:page_no].to_i, params[:comment])
    Util.render_bookmark_comment_to_html(bm)

  when 'title-form-save'
    @database.change_book(params[:id].to_i,
                          {
                            title: params[:title],
                            author: params[:author],
                            url: params[:url],
                          })
    ""
  end
end

helpers do

  def home
    if @params[:b] == '1'
      @header_info = %Q|<a href="/">#{@database.books.size}</a> books, <strong>#{@database.bookmarks.size}</strong> bookmarks.|
      render_bookmarks(@database.bookmarks, [{key: "timestamp", order: "descending"}])
    else
      @header_info = %Q|<strong>#{@database.books.size}</strong> books, <a href="/?b=1">#{@database.bookmarks.size}</a> bookmarks.|
      r = @database.books.map { |book|
        <<EOF
<li>#{book.id}: <a href="/v/#{book.id}">#{book.title}</a> (#{book.page_num}P)</li>
EOF
      }.reverse

      @content = <<EOF
<ul>
#{r.join("\n")}
</ul>
EOF
      haml :index
    end
  end

  def search_home
    search_common(@params[:query],
                  [["_score", :desc]],
                  true
                  )
  end

  def book_home(book)
    text_page(book, 1)
  end

  def search_book_home(book)
    @book_id = book.id
    @header_title = header_title_book(book, @params[:query])

    search_common(@params[:query] + " book:#{book.id}",
                  [["page_no", :asc]],
                  false
                  )
  end

  def text_all(book)
    @book_id = book.id
    @header_title = header_title_book(book, @params[:query])
    @header_info = header_info_book(book, @params[:query])

    pages = @database.book_pages(book.id)
    keywords = Util.extract_keywords(@params[:query])

    @content = pages.map { |page|
      render_page(page, keywords: keywords, with_number: true)
    }.join("\n")

    haml :index
  end

  PAGE_SIZE = 5

  def text_page(book, page_no)
    keywords = Util.extract_keywords(@params[:query])
    page = @database.pages["#{book.id}:#{page_no}"]

    @book_id = book.id
    @header_title = header_title_book(book, @params[:query])
    @header_info = header_info_book(book, @params[:query])
    @content = ""

    pages = @database.book_pages(@book_id)
    page_index = page_no - 1

    prev_link = ""
    if page_index > 0
      prev_link = <<EOF
<ul class="pager">
  <li><a href='#{url + "?page=#{[page_no - PAGE_SIZE, 1].max}"}' >Prev</a></li>
</ul>
EOF
    end

    main_contents = (pages.to_a[page_index, PAGE_SIZE] || []).map do |page|
      render_page(page, keywords: keywords, with_number: true)
    end

    pagination_str = ""
    if page_index + PAGE_SIZE < pages.count
      pagination_str = <<EOF
<ul class="pager">
  <li><a href='#{url + "?page=#{page_no + PAGE_SIZE}"}' rel='next'>Next</a></li>
</ul>
EOF
    end

    @content = <<EOF
#{prev_link}
<div class="autopagerize_page_element">
#{main_contents.join("\n")}
</div>
#{pagination_str}
EOF

    haml :index
  end

  def search_common(query, sort_keys, is_filter)
    results, snippet = @database.search(Query.new(query))

    rpage = @params[:rpage] ? @params[:rpage].to_i : 1
    rpage_entries = results.paginate(sort_keys, :page => rpage, :size => SEARCH_RPAGE)
    pagination_str = ""
    if (rpage - 1) * SEARCH_RPAGE + rpage_entries.count < results.count
      pagination_str = <<EOF
<ul class="pager">
  <li><a href='#{url + "?query=#{escape(@params[:query])}&rpage=#{rpage + 1}"}' rel='next'>Next</a></li>
</ul>
EOF
    end

    books = {}

    results.each do |page|
      books[page.book.path] = 1
    end

    if is_filter
      @header_info = %Q|#{books.size} books, #{results.size} pages|
    else
      @header_info = %Q|#{results.size} pages|
    end


    r = rpage_entries.map do |page|
      if is_filter
        query_plus  = escape "#{query} book:#{page.book.id}"
        query_minus = escape "#{query} -book:#{page.book.id}"
        filter_str = "<div class=\"col-xs-6\"><a href=\"/?query=#{query_plus}\">Filter+</a> <a href=\"/?query=#{query_minus}\">Filter-</a></div>"
      else
        filter_str = ""
      end

      bm = @database.bookmark_from_page(page)
      comment_hits = snippet.execute(bm ? (bm.comment || "") : "")
      text_hits = snippet.execute(page.text || "")

      main_contents =
        wrap_result_body_element(comment_hits) +
        wrap_result_body_element(text_hits)

      image_path = Util.image_path(page)

      if File.exist? image_path
        main_contents += %|<div><img src="/v/#{page.book.id}?image=1&page=#{page.page_no}" width="100%"/></div>|
      end

      <<EOF
  <div class="result">
    <div class="title">
      <div class="ss-box">#{favstar(page)}</div>
      <div><a href="/v/#{page.book.id}?query=#{escape(@params[:query])}&page=#{page.page_no}">#{page.book.title}</a> (P#{page.page_no})</div>
      <div class="ss-end"></div>
    </div>

    <div class="row info">
      #{filter_str}
    </div>

    <div class="main">
      #{main_contents}
    </div>

  </div>
EOF
    end

    @content = <<EOF
<div class="autopagerize_page_element">
#{r.join("\n")}
</div>
#{pagination_str}
EOF

    haml :index
  end

  def book_bookmark(book)
    @book_id = book.id
    @header_title = header_title_book(book, @params[:query])
    @header_info = header_info_book(book, @params[:query])
    render_bookmarks(@database.books_bookmark(book), [{key: "page.page_no", order: "ascending"}])
  end

  def render_bookmarks(bookmarks, sort_keys)
    rpage = @params[:rpage] ? @params[:rpage].to_i : 1
    sorted = bookmarks.sort(sort_keys, offset: (rpage - 1) * BOOKMARK_RPAGE, limit: BOOKMARK_RPAGE)

    r = sorted.map { |bookmark|
      page = bookmark.page
      book = page.book
      title = book.title

      image_path = Util.image_path(page)
      has_image = File.exist? image_path

      content = []
      content << bookmark.comment if bookmark.comment
      content << page.text if !has_image && page.text

      r = []
      rest = BOOKMARK_COMMENT_LENGTH
      content.each do |e|
        if e.length > rest
          r << e[0, rest]
          break
        else
          r << e
          rest -= e.length
        end
      end

      content = r.map { |e| "<p>#{escape_html(e)}</p>" }.join("\n")

      if has_image
        content += %|<p><img src="/v/#{page.book.id}?image=1&page=#{page.page_no}" width="100%"/></p>|
      end

      <<EOF
  <div class="result">
    <div class="title">
      <div class="ss-box">#{favstar(page)}</div>
      <div><a href="/v/#{book.id}?page=#{page.page_no}">#{book.title}</a> (P#{page.page_no})</div>
      <div class="ss-end"></div>
    </div>

    <div class="main">
      <div class="result-body-element">#{content}</div>
    </div>
  </div>
EOF
    }

    pagination_str = ""
    if rpage * BOOKMARK_RPAGE < bookmarks.count
      pagination_str = <<EOF
<ul class="pager">
  <li><a href='#{url + "?b=1&rpage=#{rpage + 1}"}' rel='next'>Next</a></li>
</ul>
EOF
    end
    

    @content = <<EOF
<div class="autopagerize_page_element">
#{r.join("\n")}
</div>
#{pagination_str}
EOF
    haml :index
  end

  def header_title_book(book, query)
    query = query ? "?query=#{query}" : ""

    <<EOF
<div class="title">
  <a href='/#{query}'>HOME</a> &gt; <a href='/v/#{book.id}#{query}' id="book-title" honyomi-book-id="#{book.id}">#{escape_html(book.title)}</a> <span class='edit-link'>- <a href="#">Edit</a></span>
</div>
<div class="etc">
  <span id="book-author">#{escape_html(book.author)}</span>
  <span><a id="book-url" href="#{book.url}">#{escape_html(book.url)}</a></span>
</div>
EOF
  end

  def header_info_book(book, query)
    query = query ? "&query=#{query}" : ""
    file_mb = File.stat(book.path).size / (1024 * 1024)

    pages = @params[:b] == '1' ? "<a href=\"/v/#{book.id}\">#{book.page_num}</a>" : "<strong>#{book.page_num}</strong>"

    bm = @database.books_bookmark(book)
    if @params[:b] == '1'
      bm_text = ", <strong><span class=\"boomark-number\">#{bm.count}</span></strong> bookmarks. "
    else
      bm_text = ", <a href=\"/v/#{book.id}?b=1\"><span class=\"boomark-number\">#{bm.count}</span></a> bookmarks. "
    end

    %Q|#{pages} pages#{bm_text}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?dl=1">Download</a> <span class="file-size">(#{file_mb}M)</span>|
  end

  def render_page(page, options = {})
    book = page.book

    # with_number
    with_number = ""
    if options[:with_number]
      with_number = <<EOF
<div class="no row">
  <div class="col-xs-8">
    <div class="ss-box">#{favstar(page)}</div>
    <a href="##{page.page_no}">P#{page.page_no}</a>
    &nbsp;&nbsp;&nbsp;<a href="javascript:" class="page-text-toggle">Text</a>
    &nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?pdf=1#page=#{page.page_no}">Pdf</a>
  </div>
</div>
EOF
    end

    # comment
    comment = ""

    bm = @database.bookmark_from_page(page)

    if  bm && bm.comment && !bm.comment.empty?
      comment = <<EOF
  <div class="comment">
#{Util.render_bookmark_comment_to_html(bm)}
  </div>
EOF
    end

<<EOF
<div class="page" id="#{page.page_no}">
  #{with_number}
  #{comment}
  #{render_page_main(page, options)}
</div>
EOF
  end

  def render_page_main(page, options)
    image_path = Util.image_path(page)

    text = Util.highlight_keywords(page.text, options[:keywords], 'highlight').gsub("\n\n", "<br/><br/>")

    if File.exist?(image_path)
      body = <<EOF
<div class="page-text hidden">#{text}</div>
<div><img src="/v/#{page.book.id}?image=1&page=#{page.page_no}" width="100%"/></div>
EOF
    else
      body = text
    end

    <<EOF
  <div class="main">
    #{body}
  </div>
EOF
  end

  def favstar(page)
    classes = @database.bookmark?(page) ? "star favorited" : "star"
    attr = []
    attr << %Q|honyomi-id="#{page.book.id}"|
    attr << %Q|honyomi-page-no="#{page.page_no}"|
    attr << %Q|honyomi-title="#{page.book.title}"|
    bm = @database.bookmark_from_page(page)
    attr << %Q|honyomi-comment="#{escape_html(bm.comment).gsub("\n", "&#13;")}"| if bm && bm.comment

    "<a href=\"javascript:\" id=\"star-#{page.book.id}-#{page.page_no}\" class=\"#{classes}\" #{attr.join(" ")}>Star</a>"
  end

  def wrap_result_body_element(hits)
    r = hits.map { |segment|
      "<div class=\"result-body-element\">" + segment.gsub("\n", "") + "</div>"
    }.join("\n")

    "<p>#{r}</p>"
  end
end
