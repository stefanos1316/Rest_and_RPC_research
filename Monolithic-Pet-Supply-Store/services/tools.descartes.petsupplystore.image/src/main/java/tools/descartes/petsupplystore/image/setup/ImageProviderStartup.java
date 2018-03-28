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

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import tools.descartes.petsupplystore.registryclient.RegistryClient;
import tools.descartes.petsupplystore.registryclient.Service;
import tools.descartes.petsupplystore.registryclient.StartupCallback;
import tools.descartes.petsupplystore.registryclient.loadbalancers.ServiceLoadBalancer;

/**
 * Application Lifecycle Listener implementation class Registry Client Startup.
 * @author Simon Eismann
 *
 */
@WebListener
public class ImageProviderStartup implements ServletContextListener {
	
	/**
	 * Empty constructor.
	 */
    public ImageProviderStartup() {
    	
    }
    
	/**
     * @see ServletContextListener#contextDestroyed(ServletContextEvent)
     * @param event The servlet context event at destruction.
     */
    public void contextDestroyed(ServletContextEvent event)  { 
		RegistryClient.getClient().unregister(event.getServletContext().getContextPath());
		SetupController.SETUP.teardown();
    }

	/**
     * @see ServletContextListener#contextInitialized(ServletContextEvent)
     * @param event The servlet context event at initialization.
     */
    public void contextInitialized(ServletContextEvent event)  {
    	ServiceLoadBalancer.preInitializeServiceLoadBalancers(Service.PERSISTENCE);
    	RegistryClient.getClient().runAfterServiceIsAvailable(Service.PERSISTENCE, new StartupCallback() {
			
			@Override
			public void callback() {
				SetupController.SETUP.startup();
				RegistryClient.getClient().register(event.getServletContext().getContextPath());
			}
		}, Service.IMAGE);
    }
    
}
