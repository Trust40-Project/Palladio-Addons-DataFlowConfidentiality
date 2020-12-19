package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.indirections.composition.DataSourceDelegationConnector
import org.palladiosimulator.indirections.repository.DataSourceRole
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.pcm.repository.Repository
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.PrivateTaxi_LG_TestBase

class PrivateTaxi_Indirections_LG_Test extends PrivateTaxi_LG_TestBase {
	
	new() {
		super("PrivateTaxi_Indirections_LG")
	}

	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testIssue() {
		runTest(2, [um |
			val repository = um.eResource.resourceSet.resources.findFirst[r|r.URI.lastSegment == "newRepository.repository"].contents.get(0) as Repository
			val privateDriverComposite = repository.components__Repository.filter(CompositeComponent).findFirst[entityName == "PrivateDriver"]
			val taxiServiceRole = privateDriverComposite.requiredRoles_InterfaceRequiringEntity.filter(DataSourceRole).findFirst[entityName == "PrivateDriver.Route.source.toTaxi"]
			val taxiServiceConnector = privateDriverComposite.connectors__ComposedStructure.filter(DataSourceDelegationConnector).findFirst[outerDataSourceRole === taxiServiceRole]
			val facadeAc = privateDriverComposite.assemblyContexts__ComposedStructure.findFirst[entityName == "Assembly_PrivateDriverFacade"]
			val facadeRole = facadeAc.encapsulatedComponent__AssemblyContext.requiredRoles_InterfaceRequiringEntity.filter(DataSourceRole).findFirst[entityName == "PrivateTaxiLogic.Route.sourceToTaxi"]
			taxiServiceConnector.assemblyContext = facadeAc
			taxiServiceConnector.innerDataSourceRole = facadeRole
		])
	}

}