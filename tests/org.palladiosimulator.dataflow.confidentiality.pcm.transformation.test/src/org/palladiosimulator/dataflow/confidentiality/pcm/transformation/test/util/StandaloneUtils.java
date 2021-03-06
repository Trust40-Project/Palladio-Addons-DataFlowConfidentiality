package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util;

import org.eclipse.emf.common.util.URI;
import org.modelversioning.emfprofile.registry.IProfileRegistry;
import org.palladiosimulator.dataflow.confidentiality.pcm.model.profile.ProfileConstants;
import org.palladiosimulator.dataflow.confidentiality.pcm.testmodels.Activator;

import tools.mdsd.library.standalone.initialization.InitializationTask;
import tools.mdsd.library.standalone.initialization.StandaloneInitializationException;
import tools.mdsd.library.standalone.initialization.StandaloneInitializerBuilder;
import tools.mdsd.library.standalone.initialization.log4j.Log4jInitilizationTask;

public class StandaloneUtils {

    public static void init() throws StandaloneInitializationException {
        StandaloneInitializerBuilder.builder()
            .registerProjectURI(Activator.class, "org.palladiosimulator.dataflow.confidentiality.pcm.testmodels")
            .registerProjectURI(ProfileConstants.class,
                    "org.palladiosimulator.dataflow.confidentiality.pcm.model.profile")
            .registerMetaModel("org.palladiosimulator.dataflow.confidentiality.pcm.model.profile", "profile.emfprofile_diagram")
            .addCustomTask(new Log4jInitilizationTask())
            .addCustomTask(new InitializationTask() {
                @Override
                public void initilizationWithoutPlatform() throws StandaloneInitializationException {
                }
                @Override
                public void initializationWithPlatform() throws StandaloneInitializationException {
                    IProfileRegistry.eINSTANCE.getClass();
                }
            })
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
