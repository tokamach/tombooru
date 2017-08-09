#!/usr/bin/env ruby
require 'find'
require 'sqlite3'
require 'digest/md5'

class Image
  def initialize(md5, path, tags)
    @md5 = md5
    @path = path
    @tags = tags
  end

  attr_reader :path
  attr_reader :md5
  attr_reader :tags
end

class Booru
  def initialize(**opts)
    if(opts[:root])
      @FOLDER_ROOT = opts[:root]
    else
      @FOLDER_ROOT = "/Users/tom/Pictures/animu"
    end

    if(opts[:db_name])
      @db = SQLite3::Database.new(opts[:db_name])
    else
      @db = SQLite3::Database.new("db.db")
    end

    #check if Images table exists
    if(@db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = 'Images'")[0][0] == 0)
      puts "LOG::populating DB"
      populate_db @FOLDER_ROOT
    else
      puts "LOG::DB populated already"
      @populated = true
    end
  end

  def request_md5(md5)
    res = @db.execute("select MD5, PATH, TAGS from Images where MD5 = \"#{md5}\" ;")
    if res == []
      abort("ERROR::Database cannot find image for md5 \"#{md5}\"")
    else if res.length > 1
      abort("ERROR::Database returned multiple results for MD5 \"#{md5}\"")
    else
      res = res[0]
      md5 = res[0]
      path = res[1]
      tags = res[2]
      return Image.new(md5, path, tags)
    end
  end

  def request_path(path)
    res = @db.execute("select MD5, PATH, TAGS from Images where PATH = \"#{path}\" ;")
    if res == []
      abort("ERROR::Database cannot find image for PATH \"#{path}\"")
    else if res.length > 1
      #TODO: correctly handle duplicates
      abort("ERROR::Database returned multiple results for PATH \"#{path}\"")
    else
      res = res[0]
      md5 = res[0]
      path = res[1]
      tags = res[2]
      return Image.new(md5, path, tags)
    end
  end

  def add(md5, path, tags)
    @db.execute("insert into Images (MD5, PATH, TAGS) VALUES ( \"#{md5}\", \"#{path}\", \"#{tags}\" );")
  end

  #populate an image database by recursively iterating through folders
  def populate_db(folder_path)
    unless @populated
      @db.execute("create table Images (MD5 text, PATH text, TAGS text);")
      Find.find(folder_path) do |f|
        if(f =~ /.*\.(png|jpg|gif|jpeg)/)
          md5 = Digest::MD5.file(f).hexdigest
#         puts "adding path: #{f} \nmd5: #{md5}\n\n"
          add(md5, f, "image")
        end
      end
    end
  end
end

# check if being run as a commandline program
if $0 == __FILE__
  # examples
  # booru.rb get_md5 $MD5
  # booru.rb get_path $PATH
  # booru.rb -db "other.db" get_md5 $MD5
  # booru.rb repopulate
  # booru.rb sql $SQL_EXPR
  puts "hey there user"
end
