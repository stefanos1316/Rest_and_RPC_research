import requests
url = 'http://195.251.251.27:5000/'

for i in range(20000):
	response = requests.get(url)
print response.content
