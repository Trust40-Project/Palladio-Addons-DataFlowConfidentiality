package org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases

import org.junit.jupiter.api.Test
import org.palladiosimulator.dataflow.confidentiality.pcm.workflow.test.cases.impl.InformationFlowHierarchicalLaticesTestBase
import org.palladiosimulator.indirections.composition.AssemblyDataConnector
import org.palladiosimulator.indirections.repository.DataSourceRole
import org.palladiosimulator.pcm.repository.OperationProvidedRole
import org.palladiosimulator.pcm.system.System
import org.palladiosimulator.pcm.usagemodel.EntryLevelSystemCall

class MACDataChannelsAccessControlTest extends InformationFlowHierarchicalLaticesTestBase {
	
	new() {
		super("MAC-DC-AC")
	}

	@Test
	def void testNoIssueFound() {
		runTest(0)
	}
	
	@Test
	def void testWrongDBAccess() {
		runTest(11, [um |
			val system = um.eAllContents.filter(EntryLevelSystemCall).map[providedRole_EntryLevelSystemCall].filter(OperationProvidedRole).map[providingEntity_ProvidedRole].filter(System).findFirst[true]
			val connectorToChange = system.connectors__ComposedStructure.filter(AssemblyDataConnector).findFirst[connector | connector.dataSourceRole.entityName == "FlightDB.Plane.civil.source"]
			val flightDBAC = system.assemblyContexts__ComposedStructure.findFirst[encapsulatedComponent__AssemblyContext.entityName == "FlightDB"]
			val newRole = flightDBAC.encapsulatedComponent__AssemblyContext.requiredRoles_InterfaceRequiringEntity.filter(DataSourceRole).findFirst[entityName == "FlightDB.Plane.military.source"]
			connectorToChange.dataSourceRole = newRole
		])
	}
}
