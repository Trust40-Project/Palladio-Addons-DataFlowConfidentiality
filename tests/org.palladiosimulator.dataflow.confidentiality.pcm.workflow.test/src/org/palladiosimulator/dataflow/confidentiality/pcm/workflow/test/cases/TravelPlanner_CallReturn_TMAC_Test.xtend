package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.jupiter.api.Test
import org.palladiosimulator.pcm.core.composition.AssemblyConnector
import org.palladiosimulator.pcm.core.composition.ProvidedDelegationConnector
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.pcm.repository.OperationProvidedRole
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.TMAC_TestBase

class TravelPlanner_CallReturn_TMAC_Test extends TMAC_TestBase {
	
	new() {
		super("TravelPlanner_CallReturn_TMAC")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testValidationMissing() {
		runTest(5, [um |
			val repository = um.eAllContents.filter(EntryLevelSystemCall).map[providedRole_EntryLevelSystemCall].filter(OperationProvidedRole).map[providedInterface__OperationProvidedRole.repository__Interface].findFirst[true]
			val travelPlannerComposite = repository.components__Repository.filter(CompositeComponent).findFirst[entityName == "TravelPlanner"]
			val validateCriteriaAc = travelPlannerComposite.assemblyContexts__ComposedStructure.findFirst[entityName == "Assembly_FindFlightsValidator"]
			val validator2LogicConnector = travelPlannerComposite.connectors__ComposedStructure.filter(AssemblyConnector).findFirst[requiringAssemblyContext_AssemblyConnector === validateCriteriaAc]
			val validate2OutsideConnector = travelPlannerComposite.connectors__ComposedStructure.filter(ProvidedDelegationConnector).findFirst[assemblyContext_ProvidedDelegationConnector === validateCriteriaAc]
			validate2OutsideConnector.innerProvidedRole_ProvidedDelegationConnector = validator2LogicConnector.providedRole_AssemblyConnector
			validate2OutsideConnector.assemblyContext_ProvidedDelegationConnector = validator2LogicConnector.providingAssemblyContext_AssemblyConnector
			EcoreUtil.remove(validator2LogicConnector)
			EcoreUtil.remove(validateCriteriaAc)
		])
	}
}