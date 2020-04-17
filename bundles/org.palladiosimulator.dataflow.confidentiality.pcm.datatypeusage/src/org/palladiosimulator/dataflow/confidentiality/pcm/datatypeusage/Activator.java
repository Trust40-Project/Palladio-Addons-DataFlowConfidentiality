package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.BundleContext;
import org.osgi.framework.ServiceReference;

public class Activator extends Plugin {

    private static Activator instance;
    private DataTypeUsageAnalysisFactory factory;
    private ServiceReference<DataTypeUsageAnalysisFactory> factoryServiceReference;

    public static Activator getInstance() {
        return instance;
    }

    private static void setInstance(Activator instance) {
        Activator.instance = instance;
    }

    @Override
    public void start(BundleContext context) throws Exception {
        super.start(context);
        setInstance(this);

        factoryServiceReference = context.getServiceReference(DataTypeUsageAnalysisFactory.class);
        factory = context.getService(factoryServiceReference);
    }

    @Override
    public void stop(BundleContext context) throws Exception {
        factory = null;
        context.ungetService(factoryServiceReference);
        factoryServiceReference = null;
        setInstance(null);
        super.stop(context);
    }

    public DataTypeUsageAnalysisFactory getDataTypeUsageAnalysisFactory() {
        return factory;
    }

}
