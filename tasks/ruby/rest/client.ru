require 'net/http'

(0..5000).each do |i|
	url = URI.parse('http://192.168.1.13:8080/')
			req = Net::HTTP::Get.new(url.to_s)
				res = Net::HTTP.start(url.host, url.port) {|http|
							  http.request(req)
							  	}
end

