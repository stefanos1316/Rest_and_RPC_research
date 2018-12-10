require 'jimson'
require '~/.gem/ruby/gems/rest-client-1.8.0/lib/rest_client'

class MyHandler
  extend Jimson::Handler

  def helloWorld(a)
    a + a
  end
end

server = Jimson::Server.new(MyHandler.new,
			    :host =>  '195.251.251.27',
     			    :port =>  8888)
server.start # serve with webrick on http://0.0.0.0:8999/
#

#server = Jimson::Server.new("195.251.251.27:9090")
#server.start
