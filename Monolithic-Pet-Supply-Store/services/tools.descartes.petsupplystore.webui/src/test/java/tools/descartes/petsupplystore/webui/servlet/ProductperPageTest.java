package tools.descartes.petsupplystore.webui.servlet;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import javax.servlet.Servlet;
import javax.servlet.ServletException;

import org.junit.Assert;
import org.junit.Test;

import tools.descartes.petsupplystore.entities.Category;
import tools.descartes.petsupplystore.entities.Product;

public class ProductperPageTest extends AbstractUiTest {

	@Test
	public void testProductsperPage() throws IOException, ServletException, InterruptedException {
		mockCategories(1);
		mockValidPostRestCall(null, "/tools.descartes.petsupplystore.store/rest/useractions/isloggedin");
		mockValidGetRestCall(new Category(), "/tools.descartes.petsupplystore.store/rest/categories/0");
		mockValidGetRestCall(100, "/tools.descartes.petsupplystore.store/rest/products/category/0/totalNumber");
		mockValidPostRestCall(new HashMap<Long, String>(),
				"/tools.descartes.petsupplystore.image/rest/image/getProductImages");

		List<Product> products = new ArrayList<Product>();
		for (int i = 0; i < 100; i++) {
			Product p = new Product();
			p.setName("Name" + i);
			p.setId(i);

			products.add(p);
		}

		mockProducts(20, 1, products);

		String html = doGet();

		Assert.assertEquals("No category parameter should redirect to home", "Pet Supply Store Home",
				getWebSiteTitle(html));

		List<Integer> productsPerPage = Arrays.asList(5, 10, 20, 30, 50);

		for (int page : productsPerPage) {

			mockProducts(page, 1, products);

			html = doGet("?category=0&page=1", AbstractUIServlet.PRODUCTCOOKIE, page + "");

			Assert.assertEquals("There should be page products on page 1", page, countString("productid", html));

		}

		mockProducts(30, 1, products);
		html = doGet("?category=0&page=1", AbstractUIServlet.PRODUCTCOOKIE, 30 + "");
		String[] pagination = getPagination(html);

		Assert.assertArrayEquals("Test the paginationon page 1: 100 products and 30 per page",
				new String[] { "1", "2", "3", "4", "next" }, pagination);

		mockProducts(30, 4, products);

		html = doGet("?category=0&page=4", AbstractUIServlet.PRODUCTCOOKIE, 30 + "");
		Assert.assertEquals("There should be 10 products on page 4", 10, countString("productid", html));

	}

	private void mockProducts(int amount, int page, List<Product> productlist) {
		List<Product> products = new LinkedList<Product>();
		int max = Math.min(amount * page, productlist.size());
		for (int i = (page - 1) * amount; i < max; i++) {
			products.add(productlist.get(i));
		}

		mockValidGetRestCall(products, "/tools.descartes.petsupplystore.store/rest/products/category/0?page=" + page
				+ "&articlesPerPage=" + amount);
	}

	@Override
	protected Servlet getServlet() {
		return new CategoryServlet();
	}

}
