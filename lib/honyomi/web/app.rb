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
  haml :index
end

post '/search' do
  redirect "/?query=#{escape(params[:query])}"
end
