package com.mkyong.client;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;

public class JerseyClientGet {

	public static void main(String[] args) {
		try {

			Client client = Client.create();

			for (int i = 0; i < 20000; ++i) {
				WebResource webResource = client.resource("http://195.251.251.27:8080/RESTfulServer/rest/hello/mkyong");
				ClientResponse response = webResource.accept("application/json").get(ClientResponse.class);

			if (response.getStatus() != 200) {
				throw new RuntimeException("Failed : HTTP error code : "
						+ response.getStatus());
			}

			String output = response.getEntity(String.class);
			}
			System.out.println("Done .... \n");

		} catch (Exception e) {

			e.printStackTrace();

		}

	}

}
