package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF

@Data
class SeffWithContext {
	
	val ResourceDemandingSEFF seff;

	val List<AssemblyContext> context;

}