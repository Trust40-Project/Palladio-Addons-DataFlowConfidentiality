package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.InformationFlowHierarchicalLatices_TestBase

class TravelPlanner_CallReturn_HL_Test extends InformationFlowHierarchicalLatices_TestBase {
	
	new() {
		super("TravelPlanner_CallReturn_HL")
	}
	
	@Test
	def testNoIssue() {
		runTest(0)
	}
	
	@Test
	def testIssue() {
		runTest(7, [um | 
			val elsc = um.usageScenario_UsageModel.map[scenarioBehaviour_UsageScenario].flatMap[actions_ScenarioBehaviour].filter(EntryLevelSystemCall).findFirst[entityName == "User.bookFlight.bookFlight"]
			val characterisations = elsc.inputParameterUsages_EntryLevelSystemCall.get(0).variableCharacterisation_VariableUsage
			characterisations.remove(2)
			characterisations.remove(1)
		])
	}
	
}