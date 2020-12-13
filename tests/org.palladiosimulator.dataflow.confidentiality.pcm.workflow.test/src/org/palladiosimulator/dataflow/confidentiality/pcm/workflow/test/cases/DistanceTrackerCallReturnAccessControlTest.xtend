package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.RBACTestBase
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

class DistanceTrackerCallReturnAccessControlTest extends RBACTestBase {

	new() {
		super("DistanceTracker-CallReturn-AC")
	}

	@Test
	def void testNoIssueFound() {
		runTest(0)
	}

	@Test
	def void testIssueFound() {
		runTest(5, [ um |
			val repository = um.usageScenario_UsageModel.map[scenarioBehaviour_UsageScenario].flatMap[actions_ScenarioBehaviour].filter(EntryLevelSystemCall).findFirst[true].operationSignature__EntryLevelSystemCall.interface__OperationSignature.repository__Interface
			val eca = repository.eAllContents.filter(ExternalCallAction).findFirst[entityName == "DistanceTrackerLogic.uploadDistance.callTrackingService"]
			eca.inputVariableUsages__CallAction.get(0).variableCharacterisation_VariableUsage.remove(1)
		])
	}

}
