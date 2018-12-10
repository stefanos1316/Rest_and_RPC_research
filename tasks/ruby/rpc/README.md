# Jimson

### JSON-RPC 2.0 Client and Server for Ruby
[![Build Status](https://travis-ci.org/speedyrails/sr-jimson.png?branch=staging)](https://travis-ci.org/speedyrails/sr-jimson)

## Why the fork

This is a customized version of the `jimson` gem by Speedyrails, super awesome
rails managed hosting solution.

Among the modifications done or planed are:

* Remove blankslate warning in ruby 1.9.3+. DONE.
* Don't automtically require files, but load only what is needed. DONE.
* Change HTTP library to faraday to allow middlewares. PLANED.
* Allow block configuration (log, middlewares, etc). PLANED.

## Client: Quick Start
    require 'sr/jimson'
    client = Sr::Jimson::Client.new("http://www.example.com:8999") # the URL for the JSON-RPC 2.0 server to connect to
    result = client.sum(1,2) # call the 'sum' method on the RPC server and save the result '3'

## Server: Quick Start
    require 'sr/jimson'

    class MyHandler
      extend Sr::Jimson::Handler

      def sum(a,b)
        a + b
      end
    end

    server = Sr::Jimson::Server.new(MyHandler.new)
    server.start # serve with webrick on http://0.0.0.0:8999/

## JSON Engine
Jimson uses multi\_json, so you can load the JSON library of your choice in your application and Jimson will use it automatically.

For example, require the 'json' gem in your application:
    require 'json'

