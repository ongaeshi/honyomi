require 'sinatra'
require 'sinatra/reloader' if ENV['SINATRA_RELOADER']
require 'honyomi/database'

include Honyomi

configure do
  $database = Database.new
end

get '/' do
  @database = $database

  <<EOF
<pre>
Hello Honyomi!
#{@database.books.size} Books, #{@database.pages.size} Pages.
</pre>
EOF
end
