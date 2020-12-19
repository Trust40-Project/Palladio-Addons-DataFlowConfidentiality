package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.jupiter.api.Test
import org.palladiosimulator.indirections.composition.AssemblyDataConnector
import org.palladiosimulator.indirections.composition.DataSourceDelegationConnector
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.pcm.repository.OperationProvidedRole
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.TMAC_TestBase

class TravelPlanner_Indirections_TMAC_Test extends TMAC_TestBase {
	
	new() {
		super("TravelPlanner_Indirections_TMAC")
	}
	
	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testValidationMissing() {
		runTest(2, [um |
			val repository = um.eAllContents.filter(EntryLevelSystemCall).map[providedRole_EntryLevelSystemCall].filter(OperationProvidedRole).map[providedInterface__OperationProvidedRole.repository__Interface].findFirst[true]
			val travelPlannerComposite = repository.components__Repository.filter(CompositeComponent).findFirst[entityName == "TravelPlanner"]
			val validateCriteriaAc = travelPlannerComposite.assemblyContexts__ComposedStructure.findFirst[entityName == "Assembly_ValidateCriteria"]
			val facade2ValidateConnector = travelPlannerComposite.connectors__ComposedStructure.filter(AssemblyDataConnector).findFirst[sinkAssemblyContext === validateCriteriaAc]
			val validate2OutsideConnector = travelPlannerComposite.connectors__ComposedStructure.filter(DataSourceDelegationConnector).findFirst[assemblyContext === validateCriteriaAc]
			validate2OutsideConnector.innerDataSourceRole = facade2ValidateConnector.dataSourceRole
			validate2OutsideConnector.assemblyContext = facade2ValidateConnector.sourceAssemblyContext
			EcoreUtil.remove(facade2ValidateConnector)
			EcoreUtil.remove(validateCriteriaAc)
		])
	}
}