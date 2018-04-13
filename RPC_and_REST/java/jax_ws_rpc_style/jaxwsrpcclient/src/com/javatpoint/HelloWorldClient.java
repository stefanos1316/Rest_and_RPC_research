package com.javatpoint;
import java.net.URL;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
 
public class HelloWorldClient{
 	public static void main(String[] args) throws Exception {
 	URL url = new URL("http://195.251.251.27:8080/ws/hello?wsdl");
 
        //1st argument service URI, refer to wsdl document above
	    //2nd argument is service name, refer to wsdl document above
        QName qname = new QName("http://javatpoint.com/", "HelloWorldImplService");
 
        Service service = Service.create(url, qname);
        HelloWorld hello = service.getPort(HelloWorld.class);
 
        System.out.println(hello.getHelloWorldAsString("javatpoint rpc"));
 
    }
 
}