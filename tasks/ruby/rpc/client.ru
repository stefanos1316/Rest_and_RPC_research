require "xmlrpc/client"

server = XMLRPC::Client.new("195.251.251.27", "/RPC2", 8080)
begin
	(0..20000).each do |i|
      		param = server.call("michael.add", 4, 5)
  		#puts "4 + 5 = #{param}"
	end
rescue XMLRPC::FaultException => e
  puts "Error:"
  puts e.faultCode
  puts e.faultString
end
