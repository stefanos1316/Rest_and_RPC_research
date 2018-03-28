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
package tools.descartes.petsupplystore.recommender.algorithm;

import java.util.HashSet;
import java.util.Set;

import tools.descartes.petsupplystore.entities.Order;
import tools.descartes.petsupplystore.entities.OrderItem;

/**
 * Objects of this class hold sets of {@link OrderItem}s that were bought in the
 * same {@link Order}.
 * 
 * @author Johannes Grohmann
 *
 */
public class OrderItemSet {

	/**
	 * Standard constructor.
	 */
	public OrderItemSet() {
		orderset = new HashSet<>();
	}

	/**
	 * The orderId that the Items were bought in.
	 */
	private long orderId;

	/**
	 * The productIds that were bought together.
	 */
	private Set<Long> orderset;

	/**
	 * @return the orderset
	 */
	public Set<Long> getOrderset() {
		return orderset;
	}

	/**
	 * @param orderset
	 *            the orderset to set
	 */
	public void setOrderset(Set<Long> orderset) {
		this.orderset = orderset;
	}

	/**
	 * @return the orderId
	 */
	public long getOrderId() {
		return orderId;
	}

	/**
	 * @param orderId
	 *            the orderId to set
	 */
	public void setOrderId(long orderId) {
		this.orderId = orderId;
	}
}
