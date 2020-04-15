package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.ui;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.BundleContext;

public class Activator extends Plugin {

	private static Activator instance;
	
	public static Activator getContext() {
		return instance;
	}

	public void start(BundleContext context) throws Exception {
	    super.start(context);
		Activator.instance = this;
	}

	public void stop(BundleContext context) throws Exception {
	    super.stop(context);
		Activator.instance = null;
	}
	
	public String getBundleId() {
	    return getBundle().getSymbolicName();
	}

}
