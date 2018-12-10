require 'jsonrpc-client'

(0..20000).each do |i|
	client = JSONRPC::Client.new('http://195.251.251.27:8888')
	client.helloWorld('Stefanos' + i.to_s)
end
