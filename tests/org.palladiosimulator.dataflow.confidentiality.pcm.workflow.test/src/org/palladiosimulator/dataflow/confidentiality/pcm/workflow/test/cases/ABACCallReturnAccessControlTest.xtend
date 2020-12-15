package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.ABACTwoBranchesTestBase
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.pcm.repository.OperationProvidedRole

class ABACCallReturnAccessControlTest extends ABACTwoBranchesTestBase {
	
	new() {
		super("ABAC-CallReturn-AC")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testIssue() {
		runTest(4, [um |
			val elsc = um.usageScenario_UsageModel.findFirst[entityName == "ClerkUSA"].eAllContents.filter(EntryLevelSystemCall).findFirst[entityName == "ClerkUSA.findCustomer.RegularUSA"]
			val system = elsc.providedRole_EntryLevelSystemCall.providingEntity_ProvidedRole as org.palladiosimulator.pcm.system.System
			val newRole = system.providedRoles_InterfaceProvidingEntity.filter(OperationProvidedRole).findFirst[entityName == "CustomerHandlingProvidedRole_Asia_Regular"]
			elsc.providedRole_EntryLevelSystemCall = newRole
		])
	}
	
}