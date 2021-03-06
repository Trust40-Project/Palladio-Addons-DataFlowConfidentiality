package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.RBAC_TestBase

class TravelPlanner_CallReturn_RBAC_Test extends RBAC_TestBase {

	new() {
		super("TravelPlanner_CallReturn_RBAC")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testIssueFound() {
		runTest(5, [ um |
			val elsc = um.usageScenario_UsageModel.get(1).scenarioBehaviour_UsageScenario.actions_ScenarioBehaviour.
				filter(EntryLevelSystemCall).findFirst[entityName.contains("User.bookFlight.bookFlight")]
			val outputCharacterisations = elsc.inputParameterUsages_EntryLevelSystemCall.get(0).
				variableCharacterisation_VariableUsage
			outputCharacterisations.remove(1)
		])
	}

}
