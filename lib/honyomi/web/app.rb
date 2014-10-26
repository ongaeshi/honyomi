require 'haml'
require 'honyomi/database'
require 'honyomi/util'
require 'sinatra'
if ENV['SINATRA_RELOADER']
  require 'sinatra/reloader'
  also_reload '../../**/*.rb'
end

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

post '/search' do
  if params[:book_id] && !@params[:book_id].empty?
    redirect "/v/#{@params[:book_id]}?query=#{escape(params[:query])}"
  else
    redirect "/?query=#{escape(params[:query])}"
  end
end

get '/v/:id' do
  @database = $database

  book = @database.books[params[:id].to_i]

  if params[:text] == '1'
    text_all(book)
  elsif params[:pdf] == '1'
    send_file(book.path, :disposition => 'inline')
  elsif params[:dl] == '1'
    send_file(book.path, :disposition => 'download')
  else
    if params[:page]
      text_page(book, params[:page].to_i)
    else
      if @params[:query] && !@params[:query].empty?
        search_book_home(book)
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
  end
end

helpers do

  def home
    if @params[:b] == '1'
      @header_info = %Q|<a href="/">#{@database.books.size}</a> books, <strong>#{@database.bookmarks.size}</strong> bookmarks.|
      sorted = @database.bookmarks.sort([{:key => "timestamp", :order => "ascending"}])

      r = sorted.map { |bookmark|
        page = bookmark.page
        book = page.book
        title = book.title
        content = bookmark.comment || page.text
        content = content[0, 255]

        <<EOF
  <div class="result">
    <div class="title">
      <div><a href="/v/#{book.id}?page=#{page.page_no}">#{book.title}</a> (P#{page.page_no})</div>
    </div>

    <div class="main">
      <div class="result-body-element">#{content}</div>
    </div>
  </div>
EOF
      }.reverse

      @content = <<EOF
<div class="autopagerize_page_element">
#{r.join("\n")}
</div>
EOF
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
    end

    haml :index
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

    search_common(@params[:query] + " book: #{book.id}",
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

    main_contents = pages.to_a[page_index, PAGE_SIZE].map { |page|
      render_page(page, keywords: keywords, with_number: true)
    }

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

  RPAGE_SIZE = 20

  def search_common(query, sort_keys, is_filter)
    results = @database.search(query)

    rpage = @params[:rpage] ? @params[:rpage].to_i : 1
    rpage_entries = results.paginate(sort_keys, :page => rpage, :size => RPAGE_SIZE)
    pagination_str = ""
    if (rpage - 1) * RPAGE_SIZE + rpage_entries.count < results.count
      pagination_str = <<EOF
<ul class="pager">
  <li><a href='#{url + "?query=#{escape(@params[:query])}&rpage=#{rpage + 1}"}' rel='next'>Next</a></li>
</ul>
EOF
    end

    snippet = results.expression.snippet([["<span class=\"highlight\">", "</span>"]], {html_escape: true, normalize: true, max_results: 5})

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
      #{snippet.execute(page.text).map {|segment| "<div class=\"result-body-element\">" + segment.gsub("\n", "") + "</div>"}.join("\n") }
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

  def header_title_book(book, query)
    query = query ? "?query=#{query}" : ""
    "<a href='/#{query}'>HOME</a> &gt; <a href='/v/#{book.id}#{query}'>#{book.title}</a>"
  end

  def header_info_book(book, query)
    query = query ? "&query=#{query}" : ""
    file_mb = File.stat(book.path).size / (1024 * 1024)

    pages = @params[:b] == '1' ? "<a href=\"/v/#{book.id}\">#{book.page_num}</a>" : "<strong>#{book.page_num}</strong>"

    bm = @database.books_bookmark(book)
    bm_text = ". "
    if bm.count > 0
      if @params[:b] == '1'
        bm_text = ", <strong>#{bm.count}</strong> bookmarks. "
      else
        bm_text = ", <a href=\"/v/#{book.id}?b=1\">#{bm.count}</a> bookmarks. "
      end
    end

    %Q|#{pages} pages#{bm_text}&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?dl=1">Download</a> <span class="file-size">(#{file_mb}M)</span>&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?pdf=1">Pdf</a>&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?text=1#{query}">Text</a>|
  end

  def render_page(page, options = {})
    book = page.book
    with_number = options[:with_number] ? %Q|<div class="no"><div class="ss-box">#{favstar(page)}</div> <a href="##{page.page_no}">P#{page.page_no}</a> &nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?pdf=1#page=#{page.page_no}"><i class="fa fa-file-text-o"></i></a></div>| : ""

    text = Util.highlight_keywords(page.text, options[:keywords], 'highlight')
    text = text.gsub("\n\n", "<br/><br/>")

<<EOF
<div class="page" id="#{page.page_no}">
  #{with_number}
  <div class="main">
    #{text}
  </div>
</div>
EOF
  end

  def favstar(page)
    classes = @database.bookmark?(page) ? "star favorited" : "star"
    "<a href=\"javascript:\" class=\"#{classes}\" honyomi-id=\"#{page.book.id}\" honyomi-page-no=\"#{page.page_no}\">Favorite Me</a>"
  end
end
