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
package tools.descartes.petsupplystore.image.rest;

import java.util.HashMap;
import java.util.stream.Collectors;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;

import tools.descartes.petsupplystore.entities.ImageSize;
import tools.descartes.petsupplystore.image.ImageProvider;
import tools.descartes.petsupplystore.image.setup.SetupController;

@Path("image")
@Produces({ "application/json" })
@Consumes({ "application/json" })
public class ImageProviderEndpoint {

	@POST
	@Path("getProductImages")
	public Response getProductImages(HashMap<Long, String> images) {
		return Response.ok().entity(ImageProvider.IP.getProductImages(images.entrySet().parallelStream()
				.collect(Collectors.toMap(e -> e.getKey(), e -> ImageSize.parseImageSize(e.getValue()))))).build();
	}
	
	@POST
	@Path("getWebImages")
	public Response getWebUIImages(HashMap<String, String> images) {
		return Response.ok().entity(ImageProvider.IP.getWebUIImages(images.entrySet().parallelStream()
				.collect(Collectors.toMap(e -> e.getKey(), e -> ImageSize.parseImageSize(e.getValue()))))).build();
	}
	
	@GET
	@Path("regenerateImages")
	public Response regenerateImages() {
		SetupController.SETUP.reconfiguration();
		return Response.ok().build();
	}
	
	@GET
	@Path("finished")
	public Response isFinished() {
		return Response.ok().entity(SetupController.SETUP.isFinished()).build();
	}
	
	@GET
	@Path("state")
	@Produces({ "text/plain" })
	public Response getState() {
		return Response.ok().entity(SetupController.SETUP.getState()).build();
	}
	
	@POST
	@Path("setCacheSize")
	public Response setCacheSize(long cacheSize) {
		return Response.ok().entity(SetupController.SETUP.setCacheSize(cacheSize)).build();
	}
	
}
