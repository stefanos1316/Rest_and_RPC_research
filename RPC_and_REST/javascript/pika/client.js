#!/usr/bin/env node

var amqp = require('amqplib/callback_api');

amqp.connect('amqp://localhost', function(err, conn) {

for (var i = 0 ;  i < 4500; ++i) {
  conn.createChannel(function(err, ch) {
    var q = 'hello';
    var msg = 'Hello World!';

    ch.assertQueue(q, {durable: false});
    ch.sendToQueue(q, new Buffer(msg));
    console.log(" [x] Sent %s" + i, msg);
  });
}
  setTimeout(function() { conn.close(); process.exit(0) }, 500);
});


