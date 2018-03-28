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
package tools.descartes.petsupplystore.image.setup;

import java.util.Arrays;

public enum CachingRule {

	ALL("All");
	
	public static final CachingRule STD_CACHING_RULE = ALL;
	
	private final String strRepresentation;
	
	private CachingRule(String strRepresentation) {
		this.strRepresentation = strRepresentation;
	}
	
	public String getStrRepresentation() {
		return new String(strRepresentation);
	}
	
	public static CachingRule getCachingRuleFromString(String strCachingRule) {
		return Arrays.asList(CachingRule.values()).stream()
				.filter(mode -> mode.strRepresentation.equals(strCachingRule))
				.findFirst()
				.orElse(STD_CACHING_RULE);
	}
}
