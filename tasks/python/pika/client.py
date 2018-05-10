#!/usr/bin/env python
import pika

connection = pika.BlockingConnection(pika.ConnectionParameters(host='195.251.251.27'))
channel = connection.channel()

for i in range(20000):
	channel.queue_declare(queue='hello')
	channel.basic_publish(exchange='',
                      routing_key='hello',
                      body='Hello World!')
	print(" [x] Sent 'Hello World '")
connection.close()
