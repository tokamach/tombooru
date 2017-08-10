require 'sinatra'
require 'sinatra/reloader' if development?
require './booru.rb'

boo = Booru.new

get '/' do
  "hey"
end

get '/image/:md5' do
  image = boo.request_md5(params['md5'])
  erb :image, :locals => {:img => image}
end

get '/search/:tag' do
  image = boo.request_tag(params['tag'])
  if(image.class == Array)
    erb :search, :locals => {:images => image,
                             :tags => params['tag']}
  elsif (image.class == Image)
    erb :image, :locals => {:img => image}
  end
end

get '/image/raw/:md5' do
  send_file boo.request_md5(params['md5']).path
end
                                                             
