package org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils

import java.util.Stack
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF

@Data
class SeffWithContext {
	
	val ResourceDemandingSEFF seff;

	val Stack<AssemblyContext> context;

}
