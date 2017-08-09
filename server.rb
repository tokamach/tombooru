require 'sinatra'
require './booru.rb'

boo = Booru.new

get '/' do
  "hey"
end

get '/image/:md5' do
  erb :image, :locals => {:img => boo.request_md5(params['md5'])}
end
