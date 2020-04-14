package org.palladiosimulator.dataflow.confidentiality.pcm.queryutilsorg.palladiosimulator.dataflow.confidentiality.pcm.queryutils

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.palladiosimulator.pcm.core.composition.AssemblyContext
import org.palladiosimulator.pcm.seff.ResourceDemandingSEFF

@Data
class SeffWithContext {
	
	val ResourceDemandingSEFF seff;

	val List<AssemblyContext> context;

}
