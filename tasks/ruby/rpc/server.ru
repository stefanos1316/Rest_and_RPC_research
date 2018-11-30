require "xmlrpc/server"

s = XMLRPC::Server.new(9090, "195.251.251.27")

s.add_handler("michael.add") do |a,b|
	a + b
end

s.add_handler("michael.div") do |a, b|
  if b == 0
    raise XMLRPC::FaultException.new(1, "division by zero")
  else
    a / b
  end
end

s.set_default_handler do |name, *args|
  raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
                                   " or wrong number of parameters!")
end

s.serve
