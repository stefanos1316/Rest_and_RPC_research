package com.thejavageek;

import java.net.URL;

import javax.xml.namespace.QName;
import javax.xml.ws.Service;

public class HelloWorldClient {

	public static void main(String[] args) {

		try {

			URL url = new URL("http://195.251.251.25:9876/jax_ws_rpc?wsdl");
			QName qname = new QName("http://thejavageek.com/",
					"HelloWorldServerImplService");

			Service service = Service.create(url, qname);
			
			HelloWorldServer server = service.getPort(HelloWorldServer.class);
			
			for (int i = 0; i < 1000; ++i) {
				String name = "World " + i;
				//System.out.println(server.sayHello(name));
				server.sayHello(name);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

}
