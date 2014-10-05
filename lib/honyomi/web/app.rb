require 'haml'
require 'honyomi/database'
require 'sinatra'
require 'sinatra/reloader' if ENV['SINATRA_RELOADER']

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

  if params[:raw] == '1'
    raw_all(book)
  elsif params[:pdf] == '1'
    send_file(book.path, :disposition => 'inline')
  elsif params[:dl] == '1'
    send_file(book.path, :disposition => 'download')
  else
    if params[:page]
      raw_page(book, params[:page].to_i)
    else
      if @params[:query] && !@params[:query].empty?
        search_book_home(book)
      else
        book_home(book)
      end
    end
  end
end

helpers do

  def home
    @header_info = %Q|#{@database.books.size} books, #{@database.pages.size} pages.|

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

  def search_home
    search_common(@params[:query],
                  [["_score", :desc]],
                  true
                  )
  end

  def book_home(book)
    @book_id = book.id
    @header_title = header_title_book(book)
    @header_info = header_info_book(book)
    @content = ""
    haml :index
  end

  def search_book_home(book)
    @book_id = book.id
    @header_title = header_title_book(book)

    search_common(@params[:query] + " book: #{book.id}",
                  [["page_no", :asc]],
                  false
                  )
  end

  def raw_all(book)
    @book_id = book.id
    @header_title = header_title_book(book)
    @header_info = header_info_book(book)

    pages = @database.book_pages(book.id)

    @content = pages.map { |page|
      render_page(page, with_number: true)
    }.join("\n")

    haml :index
  end

  def raw_page(book, page_no)
    page = @database.book_pages(book.id)[page_no]

    @book_id = book.id
    @header_title = header_title_book(book)
    @header_info = header_info_book(book, page)

    @content = render_page(page)

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

    snippet = results.expression.snippet([["<strong>", "</strong>"]], {html_escape: true, normalize: true, max_results: 10})

    books = {}

    results.each do |page|
      books[page.book.path] = 1
    end

    @header_info = %Q|#{books.size} books, #{results.size} pages|

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
    <div class="title"><a href="/v/#{page.book.id}?page=#{page.page_no}">#{page.book.title}</a> (P#{page.page_no})</div>
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

  def header_title_book(book)
    "<a href='/v/#{book.id}'>#{book.title}</a>"
  end

  def header_info_book(book, page = nil)
    file_mb = File.stat(book.path).size / (1024 * 1024)

    if page.nil?
      %Q|#{book.page_num} pages. <a href="/v/#{book.id}?dl=1">Download</a> <span class="file-size">(#{file_mb}M)</span>&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?pdf=1">Pdf</a>&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?raw=1">Raw</a>|
    else
      %Q|<i class="fa fa-file-text-o"></i> P#{page.page_no} &nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?dl=1">Download</a> <span class="file-size">(#{file_mb}M)</span>&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?pdf=1#page=#{page.page_no}">Pdf</a>&nbsp;&nbsp;&nbsp;<a href="/v/#{book.id}?raw=1##{page.page_no}">Raw</a>|
    end
  end

  def render_page(page, options = {})
    with_number = options[:with_number] ? %Q|<div class="no"><i class="fa fa-file-text-o"></i> <a href="##{page.page_no}">P#{page.page_no}</a></div>| : ""

<<EOF
<div class="page" id="#{page.page_no}">
  #{with_number}
  <div class="main">
    #{escape_html(page.text).gsub("\n\n", "<br/><br/>")}
  </div>
</div>
EOF
  end
end
