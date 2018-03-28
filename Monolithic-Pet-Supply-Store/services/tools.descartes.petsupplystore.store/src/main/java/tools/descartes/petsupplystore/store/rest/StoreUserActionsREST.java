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

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Response;

import org.mindrot.jbcrypt.BCrypt;

import tools.descartes.petsupplystore.entities.Order;
import tools.descartes.petsupplystore.entities.OrderItem;
import tools.descartes.petsupplystore.entities.User;
import tools.descartes.petsupplystore.entities.message.SessionBlob;
import tools.descartes.petsupplystore.registryclient.Service;
import tools.descartes.petsupplystore.registryclient.rest.LoadBalancedCRUDOperations;
import tools.descartes.petsupplystore.rest.NotFoundException;
import tools.descartes.petsupplystore.rest.TimeoutException;
import tools.descartes.petsupplystore.store.security.SHASecurityProvider;
import tools.descartes.petsupplystore.store.security.RandomSessionIdGenerator;

/**
 * Rest endpoint for the store user actions.
 * 
 * @author Simon
 */
@Path("useractions")
@Produces({ "application/json" })
@Consumes({ "application/json" })
public class StoreUserActionsREST {

	/**
	 * 
	 * Persists order in database.
	 * 
	 * @param blob
	 *            SessionBlob
	 * @param totalPriceInCents
	 *            totalPrice
	 * @param addressName
	 *            address
	 * @param address1
	 *            address
	 * @param address2
	 *            address
	 * @param creditCardCompany
	 *            creditcard
	 * @param creditCardNumber
	 *            creditcard
	 * @param creditCardExpiryDate
	 *            creditcard
	 * @return Response containing SessionBlob
	 */
	@POST
	@Path("placeorder")
	public Response placeOrder(SessionBlob blob, @QueryParam("totalPriceInCents") long totalPriceInCents,
			@QueryParam("addressName") String addressName, @QueryParam("address1") String address1,
			@QueryParam("address2") String address2, @QueryParam("creditCardCompany") String creditCardCompany,
			@QueryParam("creditCardNumber") String creditCardNumber,
			@QueryParam("creditCardExpiryDate") String creditCardExpiryDate) {
		if (new SHASecurityProvider().validate(blob) == null || blob.getOrderItems().isEmpty()) {
			return Response.status(Response.Status.NOT_FOUND).build();
		}

		blob.getOrder().setUserId(blob.getUID());
		blob.getOrder().setTotalPriceInCents(totalPriceInCents);
		blob.getOrder().setAddressName(addressName);
		blob.getOrder().setAddress1(address1);
		blob.getOrder().setAddress2(address2);
		blob.getOrder().setCreditCardCompany(creditCardCompany);
		blob.getOrder().setCreditCardExpiryDate(creditCardExpiryDate);
		blob.getOrder().setCreditCardNumber(creditCardNumber);
		blob.getOrder().setTime(LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));

		long orderId;
		try {
			orderId = LoadBalancedCRUDOperations.sendEntityForCreation(Service.PERSISTENCE, "orders", Order.class,
					blob.getOrder());
		} catch (TimeoutException e) {
			return Response.status(408).build();
		} catch (NotFoundException e) {
			return Response.status(404).build();
		}
		for (OrderItem item : blob.getOrderItems()) {
			try {
				item.setOrderId(orderId);
				LoadBalancedCRUDOperations.sendEntityForCreation(Service.PERSISTENCE, "orderitems", OrderItem.class,
						item);
			} catch (TimeoutException e) {
				return Response.status(408).build();
			} catch (NotFoundException e) {
				return Response.status(404).build();
			}
		}
		blob.setOrder(new Order());
		blob.getOrderItems().clear();
		blob = new SHASecurityProvider().secure(blob);
		return Response.status(Response.Status.OK).entity(blob).build();
	}

	/**
	 * User login.
	 * 
	 * @param blob
	 *            SessionBlob
	 * @param name
	 *            Username
	 * @param password
	 *            password
	 * @return Response with SessionBlob containing login information.
	 */
	@POST
	@Path("login")
	public Response login(SessionBlob blob, @QueryParam("name") String name, @QueryParam("password") String password) {
		User user;
		try {
			user = LoadBalancedCRUDOperations.getEntityWithProperties(Service.PERSISTENCE, "users", User.class, "name",
					name);
		} catch (TimeoutException e) {
			return Response.status(408).build();
		} catch (NotFoundException e) {
			return Response.status(Response.Status.OK).entity(blob).build();
		}
		if (user != null && BCrypt.checkpw(password, user.getPassword())) {
			blob.setUID(user.getId());
			blob.setSID(new RandomSessionIdGenerator().getSessionID());
			blob = new SHASecurityProvider().secure(blob);
			return Response.status(Response.Status.OK).entity(blob).build();
		}
		return Response.status(Response.Status.OK).entity(blob).build();
	}

	/**
	 * User logout.
	 * 
	 * @param blob
	 *            SessionBlob
	 * @return Response with SessionBlob
	 */
	@POST
	@Path("logout")
	public Response logout(SessionBlob blob) {
		blob.setUID(null);
		blob.setSID(null);
		blob.setOrder(new Order());
		blob.getOrderItems().clear();
		return Response.status(Response.Status.OK).entity(blob).build();
	}

	/**
	 * Checks if user is logged in.
	 * 
	 * @param blob
	 *            Sessionblob
	 * @return Response with true if logged in
	 */
	@POST
	@Path("isloggedin")
	public Response isLoggedIn(SessionBlob blob) {
		return Response.status(Response.Status.OK).entity(new SHASecurityProvider().validate(blob)).build();
	}

}
