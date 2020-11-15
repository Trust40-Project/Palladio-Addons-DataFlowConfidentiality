package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.impl.queries

import java.util.Stack
import org.palladiosimulator.pcm.allocation.Allocation
import org.palladiosimulator.pcm.core.composition.AssemblyContext

class AllocationLookup {

	val Allocation allocation

	new(Allocation allocation) {
		this.allocation = allocation
	}

	def findResourceContainer(Stack<AssemblyContext> context) {
		for (ac : context) {
			val result = allocation.allocationContexts_Allocation.findFirst[assemblyContext_AllocationContext === ac]
			if (result !== null) {
				return result.resourceContainer_AllocationContext
			}
		}
		return null
	}

}
