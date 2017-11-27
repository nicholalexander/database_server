require 'webrick'
require 'pry'

# runs on http://localhost:4000/. 
# sets value with http://localhost:4000/set?somekey=somevalue 
# gets value with http://localhost:4000/get?key=somekey

@@data = {}

class DatabaseServer < WEBrick::HTTPServlet::AbstractServlet
  def do_GET (request, response)

    response.status = 200
    response.content_type = "text/plain"
    result = nil

    case request.path
    when "/get"
      result = @@data[request.query['key']]
    when "/set"
      @@data.merge! request.query
      result = @@data
    else
      result = "No such method"
    end

    response.body = result.to_s + "\n"
  
  end
end

server = WEBrick::HTTPServer.new(:Port => 4000)

server.mount "/", DatabaseServer

trap("INT") {
  server.shutdown
}

server.start