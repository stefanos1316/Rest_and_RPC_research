package com.javatpoint;
import javax.xml.ws.Endpoint;
//Endpoint publisher
public class HelloWorldPublisher{
 
	public static void main(String[] args) {
	   Endpoint.publish("http://195.251.251.27:8080/ws/hello", new HelloWorldImpl());
    }
}