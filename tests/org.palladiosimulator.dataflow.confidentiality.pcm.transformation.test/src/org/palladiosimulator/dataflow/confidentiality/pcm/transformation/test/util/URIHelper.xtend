package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test.util

import org.eclipse.emf.common.util.URI

class URIHelper {
	
	static def getModelURI(String relativeModelPath) {
		getRelativePluginURI("models/" + relativeModelPath)
	}
	
	private static def getRelativePluginURI(String relativePath) {
		return URI.createPlatformPluginURI("/org.palladiosimulator.dataflow.confidentiality.pcm.transformation.test/" + relativePath, false);
	}

}
