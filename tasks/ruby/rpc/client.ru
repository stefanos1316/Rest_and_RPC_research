require 'jsonrpc-client'

(0..5000).each do |i|
	client = JSONRPC::Client.new('http://192.168.1.13:8888')
	client.helloWorld('Stefanos' + i.to_s)
end
