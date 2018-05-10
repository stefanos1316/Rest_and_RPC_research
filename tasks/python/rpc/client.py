import urllib2

for i in range(20000):
	content = urllib2.urlopen('http://195.251.251.27:8000/say_hello?name=World&times=1').read()
print content
