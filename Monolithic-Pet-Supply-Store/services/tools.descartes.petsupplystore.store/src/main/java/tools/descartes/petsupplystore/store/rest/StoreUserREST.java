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
package tools.descartes.petsupplystore.store.rest;

import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;

import tools.descartes.petsupplystore.entities.Order;
import tools.descartes.petsupplystore.entities.User;
import tools.descartes.petsupplystore.registryclient.Service;
import tools.descartes.petsupplystore.registryclient.rest.LoadBalancedCRUDOperations;
import tools.descartes.petsupplystore.rest.NotFoundException;
import tools.descartes.petsupplystore.rest.TimeoutException;

/**
 * Rest endpoint for the store user.
 * 
 * @author Simon
 */
@Path("users")
@Produces({ "application/json" })
@Consumes({ "application/json" })
public class StoreUserREST {

	/**
	 * Gets user by user id.
	 * 
	 * @param uid
	 *            user id
	 * @return Response containing user
	 */
	@GET
	@Path("{uid}")
	public Response getUser(@PathParam("uid") final Long uid) {
		User user;
		try {
			user = LoadBalancedCRUDOperations.getEntity(Service.PERSISTENCE, "users", User.class, uid);
		} catch (TimeoutException e) {
			return Response.status(408).build();
		} catch (NotFoundException e) {
			return Response.status(404).build();
		}
		return Response.status(Response.Status.OK).entity(user).build();
	}

	/**
	 * Gets all orders from a user.
	 * 
	 * @param uid
	 *            user id
	 * @return Response containing List of products
	 */
	@GET
	@Path("{uid}/orders/")
	public Response getOrdersForUser(@PathParam("uid") final Long uid) {
		List<Order> orders;
		try {
			orders = LoadBalancedCRUDOperations.getEntities(Service.PERSISTENCE, "orders", Order.class, "user", uid, -1,
					-1);
		} catch (TimeoutException e) {
			return Response.status(408).build();
		} catch (NotFoundException e) {
			return Response.status(404).build();
		}
		return Response.status(Response.Status.OK).entity(orders).build();
	}
}
