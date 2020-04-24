package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.datatypeusage.characteristicbased;

import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;
import org.prolog4j.manager.IProverManager;

public class Activator implements BundleActivator {

	private static Activator instance;
    private ServiceReference<IProverManager> proverManagerServiceReference;
    private IProverManager proverManager;

    public static Activator getInstance() {
        return instance;
    }
    
	public void start(BundleContext bundleContext) throws Exception {
	    setInstance(this);
		proverManagerServiceReference = bundleContext.getServiceReference(IProverManager.class);
		proverManager = bundleContext.getService(proverManagerServiceReference);
	}

	public void stop(BundleContext bundleContext) throws Exception {
		proverManager =  null;
		bundleContext.ungetService(proverManagerServiceReference);
		proverManagerServiceReference = null;
		setInstance(null);
	}
	
	public IProverManager getProverManager() {
	    return proverManager;
	}
	
	private static void setInstance(Activator instance) {
	    Activator.instance = instance;
	}

}
