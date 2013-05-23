$LOAD_PATH << File.expand_path('../lib',__FILE__)

require 'rubygems'
require 'bundler'

require 'sinatra/base'
require "sinatra/config_file"

require 'mongo'
require 'json'
require 'awesome_print'

require 'greeby'

DB = Mongo::Connection.new.db("greenmongo", pool_size: 5, timeout: 5)

Encoding.default_external = 'utf-8' if defined?(::Encoding)

class App < Sinatra::Base

  include Greeby::Mongo
  include Greeby::Tools

  register Sinatra::ConfigFile
  config_file 'config.yml'

  set :root, File.dirname(__FILE__)
  set :static, true
  set :public_folder, ->{ File.join(root, "static") }
  set :views, ->{ File.join(root, "views") }
  set :environments, %w{development test production}
  set :environment, :development
  set :sessions, true
  set :stats, { server: '', id: 0 }
  set :haml, :format => :html5

  get '/' do
    @title = 'wip (dev)'
    @stats = settings.stats
    haml :dev
  end

  get '/v1/:thing' do
    DB.collection(params[:thing]).find.toa.map{ |t| frombsonid(t) }.to_json
  end

  get '/api/:thing/:id' do
    frombsonid(DB.collection(params[:thing]).findone(tobsonid(params[:id]))).to_json
  end

  post '/api/:thing' do
    oid = DB.collection(params[:thing]).insert(JSON.parse(request.body.read.tos))
    "{\"id\": \"#{oid.to_s}\"}"
  end

  delete '/api/:thing/:id' do
    DB.collection(params[:thing]).remove('id' => tobson_id(params[:id]))
  end

  put '/api/:thing/:id' do
    DB.collection(params[:thing]).update({
      'id' => tobsonid(params[:id])},
      {'$set' => JSON.parse(request.body.read.tos).reject{|k,v| k == 'id'}
    })
  end

  get '/pages/:page' do
    page = clean(params[:page])
    if File.exist? "app/pages/#{page}.md"
      markdown File.read("app/pages/#{page}.md")
    end
  end

  run! if app_file == $0
end
