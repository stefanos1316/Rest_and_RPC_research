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
package tools.descartes.petsupplystore.recommender.algorithm.impl;

import java.util.ArrayList;
import java.util.List;

import tools.descartes.petsupplystore.recommender.algorithm.AbstractRecommender;

/**
 * Temporary class to be replaced by something actually useful.
 * 
 * @author Johannes Grohmann
 *
 */
public class DummyRecommender extends AbstractRecommender {
	
	/* (non-Javadoc)
	 * @see tools.descartes.petsupplystore.recommender.algorithm.AbstractRecommender#execute(java.util.List)
	 */
	@Override
	protected List<Long> execute(List<Long> currentItems) {
		List<Long> recommended = new ArrayList<Long>();
		recommended.add(new Long(-1));
		return recommended;
	}

}
