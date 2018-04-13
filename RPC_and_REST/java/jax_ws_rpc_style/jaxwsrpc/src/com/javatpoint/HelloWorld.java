package com.javatpoint;
import javax.jws.WebMethod;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.jws.soap.SOAPBinding.Style;
 
//Service Endpoint Interface
@WebService
@SOAPBinding(style = Style.RPC)
//@SOAPBinding(style = Style.DOCUMENT)
public interface HelloWorld{
 
	@WebMethod String getHelloWorldAsString(String name);
 
}