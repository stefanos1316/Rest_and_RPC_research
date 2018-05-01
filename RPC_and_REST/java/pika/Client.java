import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;

public class Client {

  private final static String QUEUE_NAME = "hello";

  public static void main(String[] argv) throws Exception {
    ConnectionFactory factory = new ConnectionFactory();
    factory.setHost("localhost");
    Connection connection = factory.newConnection();
    Channel channel = connection.createChannel();

    channel.queueDeclare(QUEUE_NAME, false, false, false, null);
    String message = "Hello World!";
for (int i = 0; i < 4500; ++i) {
    message = message + i;
    channel.basicPublish("", QUEUE_NAME, null, message.getBytes("UTF-8"));
    message = "Hello World " + i;
    System.out.println(" [x] Sent '" + message + "'");
}
    channel.close();
    connection.close();
  }
}
