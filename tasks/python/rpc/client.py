import urllib2

for i in range(4500):
	content = urllib2.urlopen('http://localhost:8000/say_hello?name=World&times=1').read()
	print content
