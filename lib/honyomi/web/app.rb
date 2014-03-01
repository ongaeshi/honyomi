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

  results = @database.search("css text")
  results.sort([["_score", :desc]])
  snippet = GrnMini::Util::html_snippet_from_selection_results(results)

  r = results.map do |page|
    text = "--- #{page.book.title} (#{page.page_no} page) ---\n"
    snippet.execute(page.text).each do |segment|
      text += segment.gsub("\n", "") + "\n"
    end
    text
  end

  @content = <<EOF
<pre>
#{results.size} matches
#{r.join("\n\n")}
</pre>
EOF

  haml :index
end

post '/search' do
  redirect "/?query=#{escape(params[:query])}"
end
