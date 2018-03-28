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
package tools.descartes.petsupplystore.store.startup;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import tools.descartes.petsupplystore.registryclient.RegistryClient;
import tools.descartes.petsupplystore.registryclient.Service;
import tools.descartes.petsupplystore.registryclient.loadbalancers.ServiceLoadBalancer;
import tools.descartes.petsupplystore.rest.RESTClient;

/**
 * Application Lifecycle Listener implementation class Registry Client Startup.
 * @author Simon Eismann
 *
 */
@WebListener
public class StoreStartup implements ServletContextListener {
	
	private static final int REST_READ_TIMOUT = 1750;
	
	/**
	 * Also set this accordingly in RegistryClientStartup.
	 */
	
	/**
	 * Empty constructor.
	 */
    public StoreStartup() {
    	
    }

	/**
     * @see ServletContextListener#contextDestroyed(ServletContextEvent)
     * @param arg0 The servlet context event at destruction.
     */
    public void contextDestroyed(ServletContextEvent event)  { 
    	RegistryClient.getClient().unregister(event.getServletContext().getContextPath());
    }

	/**
     * @see ServletContextListener#contextInitialized(ServletContextEvent)
     * @param arg0 The servlet context event at initialization.
     */
    public void contextInitialized(ServletContextEvent event)  {
    	RESTClient.setGlobalReadTimeout(REST_READ_TIMOUT);
    	ServiceLoadBalancer.preInitializeServiceLoadBalancers(Service.PERSISTENCE, Service.RECOMMENDER);
    	RegistryClient.getClient().register(event.getServletContext().getContextPath());
    }
    
}
