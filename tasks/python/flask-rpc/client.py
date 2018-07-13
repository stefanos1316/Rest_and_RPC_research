import jsonrpcclient

for i in range(20000):
    jsonrpcclient.request('http://195.251.251.27:8000/', 'say_hello')
