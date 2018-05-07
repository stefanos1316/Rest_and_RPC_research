package com.thejavageek;

import javax.xml.ws.Endpoint;

public class HelloWorldServerPublisher {

	public static void main(String[] args) {

		System.out.println("Beginning to publish HelloWorldService now");
		Endpoint.publish("http://localhost:9876/jax_ws_rpc", new HelloWorldServerImpl());
		System.out.println("Done publishing");
	}

}