package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.ConfidentialityVariableCharacterisation
import org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.expression.LhsEnumCharacteristicReference
import org.palladiosimulator.pcm.seff.ExternalCallAction
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.InformationFlowHierarchicalLaticesTestBase

class DistanceTrackerCallReturnInformationFlowTest extends InformationFlowHierarchicalLaticesTestBase {
	
	new() {
		super("DistanceTracker-CallReturn-IF")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testIssueFound() {
		runTest(7, [ um |
			val repository = um.usageScenario_UsageModel.map[scenarioBehaviour_UsageScenario].flatMap[actions_ScenarioBehaviour].filter(EntryLevelSystemCall).findFirst[true].operationSignature__EntryLevelSystemCall.interface__OperationSignature.repository__Interface
			val eca = repository.eAllContents.filter(ExternalCallAction).findFirst[entityName == "DistanceTrackerLogic.uploadDistance.callTrackingService"]
			val declassCharacterization = eca.inputVariableUsages__CallAction.get(0).variableCharacterisation_VariableUsage.get(2) as ConfidentialityVariableCharacterisation
			val lhs = declassCharacterization.lhs as LhsEnumCharacteristicReference
			lhs.literal = lhs.literal.enum.literals.findFirst[name == "Distance"]
		])
	}
	
}