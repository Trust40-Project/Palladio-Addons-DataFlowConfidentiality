package org.palladiosimulator.dataflow.confidentiality.pcm.datatypeusage.test;

import org.eclipse.emf.common.util.URI;
import org.palladiosimulator.dataflow.confidentiality.pcm.testmodels.Activator;

import tools.mdsd.library.standalone.initialization.StandaloneInitializationException;
import tools.mdsd.library.standalone.initialization.StandaloneInitializerBuilder;

public final class StandaloneUtils {

    public static void init() throws StandaloneInitializationException {
        StandaloneInitializerBuilder.builder()
            .registerProjectURI(Activator.class, "org.palladiosimulator.dataflow.confidentiality.pcm.testmodels")
            .build()
            .init();
    }

    public static URI getModelURI(String relativeModelPath) {
        return getRelativePluginURI("models/" + relativeModelPath);
    }

    private static URI getRelativePluginURI(String relativePath) {
        return URI.createPlatformPluginURI(
                "/org.palladiosimulator.dataflow.confidentiality.pcm.testmodels/" + relativePath, false);
    }
}
