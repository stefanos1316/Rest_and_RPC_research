import requests
url = 'http://127.0.0.1:5000/'

for i in range(4500):
	response = requests.get(url)
print response.content
