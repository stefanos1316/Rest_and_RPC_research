require 'net/http'

(0..20000).each do |i|
		url = URI.parse('http://195.251.251.27:8080/')
			req = Net::HTTP::Get.new(url.to_s)
				res = Net::HTTP.start(url.host, url.port) {|http|
							  http.request(req)
							  	}
end

