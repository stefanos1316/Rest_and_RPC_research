package tools.descartes.petsupplystore.webui.servlet;

import java.util.Arrays;
import java.util.List;

import javax.servlet.Servlet;
import org.junit.Assert;
import org.junit.Test;

import tools.descartes.petsupplystore.entities.message.SessionBlob;

public class CategoryTest extends AbstractUiTest {

	@Test
	public void testCategories() {

		List<Integer> categories = Arrays.asList(0, 3, 5, 1);
		for (int category : categories) {
			mockCategories(category);
			mockValidPostRestCall(new SessionBlob(),
					"/tools.descartes.petsupplystore.store/rest/useractions/isloggedin");
			String html = doGet();
			Assert.assertEquals("Test the number of shown categories", category, countString("Category ", html));

		}

	}

	@Override
	protected Servlet getServlet() {
		return new IndexServlet();
	}

}
