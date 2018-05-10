# Compiling and Executing code
## Pika 

For all the RPC pika examples remember to start the server using the following command:

		$ /sbin/service rabbitmq-server start

For java's pika, use the recompile.sh script to compile and execute both instances using the following commands:
		
		$ java -cp .:amqp-client-4.0.2.jar:slf4j-api-1.7.21.jar:slf4j-simple-1.7.22.jar server
		$ java -cp .:amqp-client-4.0.2.jar:slf4j-api-1.7.21.jar:slf4j-simple-1.7.22.jar client

## GRPC

For Go's examples make sure you have send the appropriate GOROOT path in your ~/.bash_rc, in that directory you have to install all the necessary package used by the provided examples.
For Java's exmaple you can use the Maven to build and run the example
	
		$ mvn verify
		$ # Run the server
		$ mvn exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldServer
		$ # In another terminal run the client
		$ mvn exec:java -Dexec.mainClass=io.grpc.examples.helloworld.HelloWorldClient


## RPC

For Java's Jax WS you may compile using javac pathToJavaFiles/*.java and run as follows:
	
		$ java -cp ./src com.thejavageek.HelloWorldServerPublisher
		$ java -cp ./src com.thejavageek.HelloWorldClient 


# License 

Code retrieve from this [link](https://github.com/grpc/grpc-java)
