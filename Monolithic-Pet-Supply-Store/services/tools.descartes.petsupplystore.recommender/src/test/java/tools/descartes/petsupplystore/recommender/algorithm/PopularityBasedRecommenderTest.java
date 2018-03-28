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

import java.util.List;

import org.junit.Assert;
import tools.descartes.petsupplystore.recommender.algorithm.impl.pop.PopularityBasedRecommender;

/**
 * Test for the Dummy Recommender.
 * 
 * @author Johannes Grohmann
 *
 */
public class PopularityBasedRecommenderTest extends AbstractRecommenderTest {

	/*
	 * (non-Javadoc)
	 * 
	 * @see tools.descartes.petsupplystore.recommender.algorithm.AbstractRecommenderTest#
	 * setupAlgo()
	 */
	@Override
	protected void setupAlgo() {
		setAlgo(new PopularityBasedRecommender());
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see tools.descartes.petsupplystore.recommender.algorithm.AbstractRecommenderTest#
	 * testResults()
	 */
	@Override
	public void testResults() {
		// test single
		List<Long> result = getAlgo().recommendProducts(getRecommendSingle());
		Assert.assertEquals(3L, result.get(0).longValue());
		Assert.assertEquals(4L, result.get(1).longValue());
		Assert.assertEquals(1L, result.get(2).longValue());
		Assert.assertEquals(5L, result.get(3).longValue());
		Assert.assertEquals(4, result.size());

		// test multi
		result = getAlgo().recommendProducts(getRecommendMulti());
		Assert.assertEquals(2L, result.get(0).longValue());
		Assert.assertEquals(4L, result.get(1).longValue());
		Assert.assertEquals(1L, result.get(2).longValue());
		Assert.assertEquals(3, result.size());

	}

}
