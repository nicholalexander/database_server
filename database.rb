require 'webrick'
require 'yaml'

# runs on http://localhost:4000/.
# sets value with http://localhost:4000/set?somekey=somevalue
# gets value with http://localhost:4000/get?key=somekey

# handle missing data.yaml
# multiple key/value pairs and more error handling on inputs
# yaml store or pstore under multiple clients

class DatabasePersistence
end

class Database
  attr_reader :data_hash

  def initialize
    @data_hash = Hash.new(nil)
    @file_name = './data.yaml'
    read_from_disk
  end

  def get(key)
    { key => @data_hash[key] }
  end

  def set(key_value_pair)
    @data_hash.merge! key_value_pair
    write_to_disk
    return key_value_pair
  end

  private

  def write_to_disk
    File.open("#{@file_name}", 'w') {|f| f.write @data_hash.to_yaml } #Store
  end

  def read_from_disk
    @data_hash = YAML::load_file("#{@file_name}")
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