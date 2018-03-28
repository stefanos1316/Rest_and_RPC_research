package tools.descartes.petsupplystore.webui.servlet;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.Servlet;
import javax.servlet.ServletException;

import org.junit.Assert;
import org.junit.Test;

import com.fasterxml.jackson.databind.ObjectMapper;

import tools.descartes.petsupplystore.entities.OrderItem;
import tools.descartes.petsupplystore.entities.message.SessionBlob;

public class CartActionTest extends AbstractUiTest {

	@Test
	public void testCartAction() throws IOException, ServletException, InterruptedException {
		mockCategories(1);
		mockValidPostRestCall(null,  "/tools.descartes.petsupplystore.store/rest/useractions/isloggedin");
		
		String html = doPost("proceedtoCheckout=");
		Assert.assertEquals("User is not logged in, thus redirect to login", "Pet Supply Store Login", getWebSiteTitle(html));
		
		SessionBlob blob = new SessionBlob();
		blob.setSID("1");
		List<OrderItem> orderItems = new ArrayList<OrderItem>();
		orderItems.add(new OrderItem());
		blob.setOrderItems(orderItems);
		mockValidPostRestCall(blob,  "/tools.descartes.petsupplystore.store/rest/useractions/isloggedin");
		ObjectMapper o = new ObjectMapper();
		String value = URLEncoder.encode(o.writeValueAsString(blob), "UTF-8");
		
		
		html = doPost("proceedtoCheckout=", "sessionBlob", value);
		Assert.assertEquals("User should be redirect to order", "Pet Supply Store Order", getWebSiteTitle(html));


	}

	@Override
	protected Servlet getServlet() {
		return new CartActionServlet();
	}

	

}
