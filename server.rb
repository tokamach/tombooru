require 'sinatra'
require './booru.rb'

boo = Booru.new

get '/' do
  "hey"
end

get '/image/:md5' do
  boo.request_md5(params['md5']).path
end
