require 'sinatra'
require "sinatra/reloader" if ENV['SINATRA_RELOADER']

configure do
end

get '/' do
  'Hello Honyomi!'
end
