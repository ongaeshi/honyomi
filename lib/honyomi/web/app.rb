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
    results = @database.search(@params[:query])

    page_entries = results.paginate([["_score", :desc]], :page => 1, :size => 20)
    snippet = results.expression.snippet([["<strong>", "</strong>"]], {html_escape: true, normalize: true, max_results: 10})

    books = {}

    r = page_entries.map do |page|
      books[page.book.path] = 1
      
      file_mb = File.stat(page.book.path).size / (1024 * 1024)

      query_plus  = escape "#{@params[:query]} book.title:@\"#{page.book.title}\""
      query_minus = escape "#{@params[:query]} -book.title:@\"#{page.book.title}\""

      <<EOF
  <div class="result">
    <div class="result-header"><a href="/v/#{page.book.key}#page=#{page.page_no}">#{page.book.title}</a> (P#{page.page_no})</div>
    <div class="row result-sub-header">
      <div class="col-xs-6"><a href="/v/#{page.book.key}?dl=1">Download</a> <span class="result-file-size">(#{file_mb}M)</span>&nbsp;&nbsp;&nbsp;<a href="/v/#{page.book.key}?raw=1##{page.page_no}">Raw</a>&nbsp;&nbsp;&nbsp;</div>
      <div class="col-xs-6"><a href="/?query=#{query_plus}">Filter+</a> <a href="/?query=#{query_minus}">Filter-</a></div>
    </div>
    <div class="result-body">
      #{snippet.execute(page.text).map {|segment| "<div class=\"result-body-element\">" + segment.gsub("\n", "") + "</div>"}.join("\n") }
    </div>
  </div>
EOF
    end

    @content = <<EOF
<div class="matches">#{books.size} books, #{results.size} pages</div>
#{r.join("\n")}
EOF
  else
    @content = <<EOF
<div class="result">#{@database.books.size} books, #{@database.pages.size} pages.</div>
EOF
  end

  haml :index
end

post '/search' do
  redirect "/?query=#{escape(params[:query])}"
end

get '/v/:id' do
  @database = $database

  book = @database.books[params[:id]]

  if params[:raw] == '1'
    pages = @database.book_pages(book.key)

    @navbar_href = "#1"
    @navbar_title = book.title

    @content = pages.map { |page|
      <<EOF
<div class="raw-page" id="#{page.page_no}">
  <div class="raw-page-no"><i class="fa fa-file-text-o"></i> <a href="##{page.page_no}">P#{page.page_no}</a></div>
  <pre>#{escape_html page.text}</pre>
</div>
EOF
    }.join("\n")

    haml :raw
  else
    send_file(book.path, :disposition => params[:dl] == '1' ? 'download' : 'inline')
  end
end

