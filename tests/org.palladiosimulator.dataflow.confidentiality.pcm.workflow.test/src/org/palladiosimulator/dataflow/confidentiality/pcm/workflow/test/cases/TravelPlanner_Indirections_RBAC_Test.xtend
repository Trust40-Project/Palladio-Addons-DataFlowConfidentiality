package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.RBAC_TestBase

class TravelPlanner_Indirections_RBAC_Test extends RBAC_TestBase {

	new() {
		super("TravelPlanner_Indirections_RBAC")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testIssueFound() {
		runTest(2, [ um |
			val elsc = um.usageScenario_UsageModel.get(1).scenarioBehaviour_UsageScenario.actions_ScenarioBehaviour.
				filter(EntryLevelSystemCall).findFirst[entityName.contains("getCCD")]
			val outputCharacterisations = elsc.outputParameterUsages_EntryLevelSystemCall.get(0).
				variableCharacterisation_VariableUsage
			outputCharacterisations.remove(1)
		])
	}

}
