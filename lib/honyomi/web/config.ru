require './app'

map (ENV['HONYOMI_RELATIVE_URL'] || '/') do
  run Sinatra::Application
end

