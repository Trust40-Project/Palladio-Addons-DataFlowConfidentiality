package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import java.util.List
import org.palladiosimulator.dataflow.confidentiality.pcm.model.characterizedActions.CharacterizedResourceDemandingSEFF
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF

class CharacterizedSeffWithContext extends SeffWithContext {
	
	new(ResourceDemandingSEFF seff, List<AssemblyContext> context) {
		super(seff, context)
	}
	
	def getCharacterizedSeff() {
		seff as CharacterizedResourceDemandingSEFF
	}
	
}
