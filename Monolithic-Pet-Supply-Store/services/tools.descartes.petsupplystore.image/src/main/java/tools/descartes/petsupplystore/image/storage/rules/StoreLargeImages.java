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
package tools.descartes.petsupplystore.image.storage.rules;

import java.util.function.Predicate;

import tools.descartes.petsupplystore.entities.ImageSizePreset;
import tools.descartes.petsupplystore.image.StoreImage;

public class StoreLargeImages implements Predicate<StoreImage> {

	@Override
	public boolean test(StoreImage t) {
		return t == null ? false : t.getSize().equals(ImageSizePreset.FULL.getSize());
	}

}
