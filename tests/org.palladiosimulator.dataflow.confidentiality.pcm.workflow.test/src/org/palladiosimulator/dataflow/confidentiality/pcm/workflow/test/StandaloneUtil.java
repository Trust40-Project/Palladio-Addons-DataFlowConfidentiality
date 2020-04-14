package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test;

import org.eclipse.emf.common.util.URI;
import org.palladiosimulator.dataflow.confidentiality.pcm.testmodels.Activator;
import org.palladiosimulator.supporting.prolog.PrologStandaloneSetup;

import tools.mdsd.library.standalone.initialization.StandaloneInitializationException;
import tools.mdsd.library.standalone.initialization.StandaloneInitializer;
import tools.mdsd.library.standalone.initialization.StandaloneInitializerBuilder;
import tools.mdsd.library.standalone.initialization.log4j.Log4jInitilizationTask;

public class StandaloneUtil {

    private StandaloneUtil() {
        // intentionally left blank
    }

    public static void init() throws StandaloneInitializationException {
        StandaloneInitializer initializer = StandaloneInitializerBuilder.builder()
            .registerProjectURI(Activator.class,
                    "org.palladiosimulator.dataflow.confidentiality.pcm.testmodels")
            .addCustomTask(new Log4jInitilizationTask())
            .addCustomTask(PrologStandaloneSetup::doSetup)
            .build();
        initializer.init();
    }

    public static URI getModelURI(String relativeModelPath) {
        return getRelativePluginURI("models/" + relativeModelPath);
    }
    
    private static URI getRelativePluginURI(String relativePath) {
        return URI.createPlatformPluginURI("/org.palladiosimulator.dataflow.confidentiality.pcm.testmodels/" + relativePath, false);
    }
    
}
