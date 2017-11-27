require 'webrick'
require 'pry'

# runs on http://localhost:4000/. 
# sets value with http://localhost:4000/set?somekey=somevalue 
# gets value with http://localhost:4000/get?key=somekey

class Database
  attr_reader :data_hash
  
  def initialize
    @data_hash = {}
  end

  def get(key)
    if @data_hash.key? key
      {key => @data_hash[key]}
    else
      "key not found"
    end
  end

  def set(key_value_pair)
    @data_hash.merge! key_value_pair
    key_value_pair
  end
end

class DatabaseServer < WEBrick::HTTPServlet::AbstractServlet
  attr_accessor :database
  
  def initialize(server, database)
    super server
    @database = database
  end

  def do_GET (request, response)
    response.status = 200
    response.content_type = "text/plain"
    result = nil
    case request.path
    when "/get"
      result = @database.get(request.query['key'])
    when "/set"
      result = @database.set(request.query)
    when "/show"
      result = @database.data_hash
    else
      result = "No such method"
    end

    response.body = result.to_s + "\n"
  end
end

database = Database.new

server = WEBrick::HTTPServer.new(:Port => 4000)

server.mount "/", DatabaseServer, database

trap("INT") {
  server.shutdown
}

server.start