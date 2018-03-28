/**
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package tools.descartes.petsupplystore.webui.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import tools.descartes.petsupplystore.entities.ImageSizePreset;
import tools.descartes.petsupplystore.registryclient.loadbalancers.LoadBalancerTimeoutException;
import tools.descartes.petsupplystore.registryclient.rest.LoadBalancedImageOperations;
import tools.descartes.petsupplystore.registryclient.rest.LoadBalancedStoreOperations;

/**
 * Servlet implementation for the web view of "Error page"
 * 
 * @author Andre Bauer
 */
@WebServlet("/error")
public class ErrorServlet extends AbstractUIServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ErrorServlet() {
		super();
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	protected void doGetInternal(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException, LoadBalancerTimeoutException {

		Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");

		if (statusCode == null) {
			redirect("/", response);
		} else {
			request.setAttribute("CategoryList", LoadBalancedStoreOperations.getCategories());
			request.setAttribute("storeIcon", 
					LoadBalancedImageOperations.getWebImage("icon", ImageSizePreset.ICON.getSize()));
			request.setAttribute("errorImage", 
					LoadBalancedImageOperations.getWebImage("error", ImageSizePreset.ERROR.getSize()));
			request.setAttribute("title", "Pet Supply Store Error ");
			request.setAttribute("login", LoadBalancedStoreOperations.isLoggedIn(getSessionBlob(request)));
			request.getRequestDispatcher("WEB-INF/pages/error.jsp").forward(request, response);

		}
	}

}
