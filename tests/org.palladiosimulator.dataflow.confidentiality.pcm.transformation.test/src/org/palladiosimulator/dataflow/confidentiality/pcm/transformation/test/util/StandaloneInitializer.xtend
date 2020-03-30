package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util

import java.io.File
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.plugin.EcorePlugin
import org.eclipse.emf.ecore.resource.impl.URIMappingRegistryImpl
import org.eclipse.ocl.ecore.OCL
import org.eclipse.ocl.ecore.delegate.OCLDelegateDomain
import org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.TransformationTest

class StandaloneInitializer {

	static def void init() {
		if (!Platform.isRunning()) {
			// OCL initialization
			OCL.initialize(null);
			OCLDelegateDomain.initialize(null);

			// Detection of Meta Models and URIs by classpath magic
			// https://wiki.eclipse.org/EMF/FAQ#How_do_I_make_my_EMF_standalone_application_Eclipse-aware.3F
			EcorePlugin.ExtensionProcessor.process(null);

			// standalone language initializations
			registerProjectURI(TransformationTest, "org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test",
				"org.palladiosimulator.dataflow.confidentiality.pcm.transformation");
		}
	}

	/**
	 * Registers the project path derived from a class of this project under the
	 * given project name.
	 * 
	 * As a result, the platform:/resource/ URI belonging to the project is
	 * registered. In addition, a URI mapping from the corresponding plugin URI to
	 * the resource URI is registered.
	 * 
	 * @param clz         The class to derive the project path from.
	 * @param projectName The project name to register the path to.
	 */
	private static def void registerProjectURI(Class<?> clz, String projectName, String hostProjectName) {
		val location = getProjectLocation(clz, projectName, hostProjectName);
		val projectURI = URI.createFileURI(location.getAbsolutePath()).appendSegment("");
		EcorePlugin.getPlatformResourceMap().put(projectName, projectURI);
		val pluginURI = URI.createPlatformPluginURI("/" + projectName + "/", false);
		val platformURI = URI.createPlatformResourceURI("/" + projectName + "/", false);
		URIMappingRegistryImpl.INSTANCE.put(pluginURI, platformURI);
	}

	/**
	 * Determine the location of a project from a given class.
	 * 
	 * This method assumes that the project name is part of the path. If this is not
	 * the case, the method will fail.
	 * 
	 * @param clz         The class to derive the project path from.
	 * @param projectName The name of the project to be found.
	 * @return Location of the project root.
	 */
	private static def File getProjectLocation(Class<?> clz, String projectName, String hostProjectName) {
		val classLocation = clz.getProtectionDomain().getCodeSource().getLocation().getPath();
		var projectNameIndex = classLocation.indexOf(projectName);
		var projectNameLength = projectName.length()
		if (projectNameIndex < 0) {
			projectNameIndex = classLocation.indexOf(hostProjectName);
			projectNameLength = hostProjectName.length()
		}
		val projectLocation = classLocation.substring(0, projectNameIndex + projectNameLength);
		return new File(projectLocation);
	}

}
