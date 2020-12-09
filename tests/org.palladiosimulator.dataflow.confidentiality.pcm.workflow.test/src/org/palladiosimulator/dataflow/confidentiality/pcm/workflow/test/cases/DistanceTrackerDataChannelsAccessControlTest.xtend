package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.RBACTestBase
import org.palladiosimulator.indirections.composition.CompositionFactory
import org.palladiosimulator.indirections.composition.DataSourceDelegationConnector
import org.palladiosimulator.indirections.repository.DataSourceRole
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

class DistanceTrackerDataChannelsAccessControlTest extends RBACTestBase {

	new() {
		super("DistanceTracker-DC-AC")
	}

	@Test
	def void testNoIssueFound() {
		runTest(0)
	}

	@Test
	def void testIssueFound() {
		runTest(2, [ um |
			val repository = um.usageScenario_UsageModel.map[scenarioBehaviour_UsageScenario].flatMap [
				actions_ScenarioBehaviour
			].filter(EntryLevelSystemCall).map[operationSignature__EntryLevelSystemCall].findFirst[true].
				interface__OperationSignature.repository__Interface
			val distanceServiceComposite = repository.components__Repository.filter(CompositeComponent).filter[entityName == "DistanceTracker"].findFirst[true]
			val facadeAc = distanceServiceComposite.assemblyContexts__ComposedStructure.findFirst[entityName.contains("Assembly_DistanceTrackerFacade")]
			val outerSourceRole = distanceServiceComposite.requiredRoles_InterfaceRequiringEntity.filter(DataSourceRole).findFirst[entityName == "DistanceTracker.source.Distance"]
			val oldConnector = distanceServiceComposite.connectors__ComposedStructure.filter(DataSourceDelegationConnector).findFirst[c| c.outerDataSourceRole == outerSourceRole]
			distanceServiceComposite.connectors__ComposedStructure.remove(oldConnector)
			val newConnector = CompositionFactory.eINSTANCE.createDataSourceDelegationConnector
			newConnector.assemblyContext = facadeAc
			newConnector.outerDataSourceRole = outerSourceRole
			newConnector.innerDataSourceRole = facadeAc.encapsulatedComponent__AssemblyContext.requiredRoles_InterfaceRequiringEntity.filter(DataSourceRole).findFirst[entityName == "DistanceTrackerFacade.source.Distance"]
			distanceServiceComposite.connectors__ComposedStructure += newConnector
		])
	}
}
